import struct NIO.CircularBuffer
import class NIOConcurrencyHelpers.Lock

/// Source of new connections for `ConnectionPool`.
public protocol ConnectionPoolSource {
    /// Associated `ConnectionPoolItem` that will be returned by `makeConnection()`.
    associatedtype Connection: ConnectionPoolItem
    
    /// Creates a new connection.
    func makeConnection(on eventLoop: EventLoop) -> EventLoopFuture<Connection>
}

/// Item managed by a connection pool.
public protocol ConnectionPoolItem: class {
    /// If `true`, this connection has closed.
    var isClosed: Bool { get }
    
    /// Closes this connection.
    func close() -> EventLoopFuture<Void>
}

/// Configuration options for `ConnectionPool`.
public struct ConnectionPoolConfiguration {
    /// Limits the maximum number of connections that can be open at a given time
    /// for a single connection pool.
    var maxConnections: Int
    
    /// Creates a new `ConnectionPoolConfiguration`.
    ///
    /// - parameters:
    ///     - maxConnections: Limits the maximum number of connections that can be open at a given time
    ///                       for a single connection pool.
    ///                       Defaults to 12.
    public init(maxConnections: Int = 12) {
        self.maxConnections = maxConnections
    }
}

/// Errors thrown by `ConnectionPool`.
public enum ConnectionPoolError: Error {
    /// The connection pool has shutdown.
    case shutdown
}

/// Holds a collection of active connections that can be requested and later released
/// back into the pool.
///
/// Connection pools are used to offset the overhead of creating new connections. Newly
/// opened connections are returned back to the pool and can be re-used until they
/// close.
///
/// New connections are created as needed until the maximum configured connection limit
/// is reached. After the maximum is reached, no new connections will be created unless
/// existing connections are closed.
///
///     let pool = ConnectionPool(config: ..., source: ...)
///     pool.withConnection { conn in
///         // use conn
///     }
///
public final class ConnectionPool<Source> where Source: ConnectionPoolSource  {
    /// Config options for this pool.
    public let configuration: ConnectionPoolConfiguration
    
    /// Creates new connections when needed. See `ConnectionPoolSource`.
    public let source: Source
    
    // MARK: Private

    /// All currently available connections.
    /// - note: These connections may have closed since last use.
    private var available: [Source.Connection]
    
    /// Current active connection count.
    private var activeConnections: Int
    
    /// All requests for a connection that were unable to be fulfilled
    /// due to max connection limit having been reached.
    private var waiters: CircularBuffer<EventLoopPromise<Source.Connection>>

    /// Synchronizes access to the pool's shared connections.
    private let lock: Lock

    /// If `true`, this connection pool has been closed.
    private var didShutdown: Bool
    
    /// Creates a new `ConnectionPool`.
    ///
    ///     let pool = ConnectionPool(config: ..., source: ...)
    ///     pool.withConnection { conn in
    ///         // use conn
    ///     }
    ///
    /// - parameters:
    ///     - configuration: Config options for this pool.
    ///     - source: Creates new connections when needed.
    public init(configuration: ConnectionPoolConfiguration = .init(), source: Source) {
        self.configuration = configuration
        self.source = source
        self.available = []
        self.available.reserveCapacity(configuration.maxConnections)
        self.activeConnections = 0
        self.waiters = .init(initialCapacity: 0)
        self.lock = .init()
        self.didShutdown = false
    }
    
    /// Fetches a pooled connection for the lifetime of the closure.
    ///
    /// The connection is provided to the supplied callback and will be automatically released when the
    /// future returned by the callback is completed.
    ///
    ///     pool.withConnection(on: ...) { conn in
    ///         // use the connection
    ///     }
    ///
    /// See `requestConnection(on:)` to request a pooled connection without using a callback.
    ///
    /// - parameters:
    ///     - on: Preferred event loop for the new connection.
    ///     - closure: Callback that accepts the pooled connection.
    /// - returns: A future containing the result of the closure.
    public func withConnection<Result>(
        on eventLoop: EventLoop,
        _ closure: @escaping (Source.Connection) -> EventLoopFuture<Result>
    ) -> EventLoopFuture<Result> {
        return self.requestConnection(on: eventLoop).flatMap { conn in
            return closure(conn).map { res in
                self.releaseConnection(conn)
                return res
            }.flatMapErrorThrowing { error in
                self.releaseConnection(conn)
                throw error
            }
        }
    }
    
    /// Requests a pooled connection.
    ///
    /// The connection returned by this method should be released when you are finished using it.
    ///
    ///     let conn = try pool.requestConnection(on: ...).wait()
    ///     defer { pool.releaseConnection(conn) }
    ///     // use the connection
    ///
    /// See `withConnection(_:)` for a callback-based method that automatically releases the connection.
    ///
    /// - parameters:
    ///     - on: Preferred event loop for the new connection.
    /// - returns: A future containing the requested connection.
    public func requestConnection(on eventLoop: EventLoop) -> EventLoopFuture<Source.Connection> {
        guard !self.didShutdown else {
            return eventLoop.makeFailedFuture(ConnectionPoolError.shutdown)
        }

        // synchronize access to available / active connection checks
        self.lock.lock()

        if let conn = self.available.popLast() {
            // available list mutated
            self.lock.unlock()

            // check if it is still open
            if !conn.isClosed {
                // connection is still open, we can return it directly
                return eventLoop.makeSucceededFuture(conn)
            } else {
                // connection is closed, we need to replace it
                return self.source.makeConnection(on: eventLoop).flatMapErrorThrowing { error in
                    // mutating active conn count must be sync
                    self.lock.withLockVoid {
                        // there is one less active conn open
                        self.activeConnections -= 1
                    }
                    throw error
                }
            }
        } else if self.activeConnections < self.configuration.maxConnections  {
            // all connections are busy, but we have room to open a new connection!
            self.activeConnections += 1

            // active connections count mutated
            self.lock.unlock()
            
            // make the new connection
            return self.source.makeConnection(on: eventLoop).flatMapErrorThrowing { error in
                // mutating active conn count must be sync
                self.lock.withLockVoid {
                    // there is one less active conn open
                    self.activeConnections -= 1
                }
                throw error
            }
        } else {
            // connections are exhausted, we must wait for one to be returned
            let promise = eventLoop.makePromise(of: Source.Connection.self)
            self.waiters.append(promise)

            // waiters list mutated
            self.lock.unlock()

            // return waiter
            return promise.futureResult
        }
    }
    
    /// Releases a connection back to the pool. Use with `requestConnection()`.
    ///
    ///     let conn = try pool.requestConnection().wait()
    ///     defer { pool.releaseConnection(conn) }
    ///     // use the connection
    ///
    /// - parameters:
    ///     - conn: Connection to release back to the pool.
    public func releaseConnection(_ conn: Source.Connection) {
        guard !self.didShutdown else {
            // this pool is closed and we are responsible for closing all
            // of our connections
            _ = conn.close()
            return
        }

        // synchronize access to available / active connection checks
        self.lock.lock()

        // add this connection back to the list of available
        self.available.append(conn)

        // now that we know a new connection is available, we should
        // take this chance to fulfill one of the waiters
        if !self.waiters.isEmpty {
            let waiter = self.waiters.removeFirst()
            self.lock.unlock()
            self.requestConnection(
                on: waiter.futureResult.eventLoop
            ).cascade(to: waiter)
        } else {
            self.lock.unlock()
        }
    }
    
    /// Closes the connection pool.
    ///
    /// All available connections will be closed immediately.
    /// Any connections currently in use will be closed when they are returned to the pool.
    ///
    /// Once closed, the connection pool cannot be used to create new connections.
    ///
    /// Connection pools must be closed before they deinitialize.
    ///
    /// - returns: A future indicating close completion.
    public func shutdown() {
        // synchronize access to closing
        self.lock.lock()

        // check to make sure we aren't double closing
        guard !self.didShutdown else {
            return
        }
        self.didShutdown = true

        // is closed variable mutated
        self.lock.unlock()

        // no locks needed as this can only happen once
        for available in self.available {
            do {
                try available.close().wait()
            } catch {
                #warning("TODO: use logger")
                print("Could not close connection: \(error)")
            }
        }
        // inform any waiters that they will never be receiving a connection
        while let waiter = self.waiters.popFirst() {
            waiter.fail(ConnectionPoolError.shutdown)
        }
            
        // reset any variables to free up memory
        self.available = []
        self.activeConnections = 0
    }
    
    deinit {
        if !self.didShutdown {
            assertionFailure("ConnectionPool.shutdown() was not called before deinit.")
        }
    }
}
