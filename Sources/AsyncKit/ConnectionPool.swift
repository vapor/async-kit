import struct NIO.CircularBuffer
import class NIOConcurrencyHelpers.Lock
import struct Logging.Logger

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

public enum ConnectionPoolEventLoop {
    case any
    case prefer(EventLoop)

    func on(_ eventLoopGroup: EventLoopGroup) -> EventLoop {
        switch self {
        case .any:
            return eventLoopGroup.next()
        case .prefer(let eventLoop):
            return eventLoop
        }
    }
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

    /// Event loop source when not specified.
    public let eventLoopGroup: EventLoopGroup
    
    // MARK: Private

    /// All currently available connections.
    /// - note: These connections may have closed since last use.
    private var available: CircularBuffer<Source.Connection>
    
    /// Current active connection count.
    private var activeConnections: Int
    
    /// All requests for a connection that were unable to be fulfilled
    /// due to max connection limit having been reached.
    private var waiters: CircularBuffer<EventLoopPromise<Source.Connection>>

    /// Synchronizes access to the pool's shared connections.
    private let lock: Lock

    /// If `true`, this connection pool has been closed.
    private var didShutdown: Bool
    
    /// Used for trace and debug logs.
    private let logger: Logger
    
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
    ///     - logger: For trace and debug logs.
    ///     - on: Event loop source when not specified
    public init(
        configuration: ConnectionPoolConfiguration = .init(),
        source: Source,
        logger: Logger = .init(label: "codes.vapor.pool"),
        on eventLoopGroup: EventLoopGroup
    ) {
        self.configuration = configuration
        self.source = source
        self.logger = logger
        self.eventLoopGroup = eventLoopGroup
        self.available = .init(initialCapacity: configuration.maxConnections)
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
        on eventLoop: ConnectionPoolEventLoop = .any,
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
    public func requestConnection(
        on eventLoop: ConnectionPoolEventLoop = .any
    ) -> EventLoopFuture<Source.Connection> {
        // synchronize access to available / active connection checks
        self.lock.lock()
        defer { self.lock.unlock() }

        let eventLoop = eventLoop.on(self.eventLoopGroup)
        guard !self.didShutdown else {
            return eventLoop.makeFailedFuture(ConnectionPoolError.shutdown)
        }
        
        // creates a new connection assuming `activeConnections`
        // has already been incremented
        func makeActiveConnection() -> EventLoopFuture<Source.Connection> {
            return self.source.makeConnection(on: eventLoop).flatMapErrorThrowing { error in
                self.lock.lock()
                defer { self.lock.unlock() }
                self.activeConnections -= 1
                throw error
            }
        }

        if let conn = self.available.popFirst() {
            // check if it is still open
            if !conn.isClosed {
                // connection is still open, we can return it directly
                self.logger.trace("Re-using available connection")
                return eventLoop.makeSucceededFuture(conn)
            } else {
                // connection is closed, we need to replace it
                self.logger.debug("Replacing an active connection that has closed")
                return makeActiveConnection()
            }
        } else if self.activeConnections < self.configuration.maxConnections {
            // all connections are busy, but we have room to open a new connection!
            self.logger.debug("All connections are busy, creating a new one")
            self.activeConnections += 1
            return makeActiveConnection()
        } else {
            // connections are exhausted, we must wait for one to be returned
            self.logger.debug("Connection pool exhausted, adding request to waitlist")
            let promise = eventLoop.makePromise(of: Source.Connection.self)
            self.waiters.append(promise)
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
        // synchronize access to available / active connection checks
        self.lock.lock()

        guard !self.didShutdown else {
            // nothing happening, we can unlock
            self.lock.unlock()

            // this pool is closed and we are responsible for closing all
            // of our connections
            _ = conn.close()
            return
        }

        // add this connection back to the list of available
        self.logger.trace("Releasing connection")
        self.available.append(conn)

        // now that we know a new connection is available, we should
        // take this chance to fulfill one of the waiters
        let waiter: EventLoopPromise<Source.Connection>?
        if !self.waiters.isEmpty {
            waiter = self.waiters.removeFirst()
        } else {
            waiter = nil
        }

        // must unlock before calling requestConnection which locks
        self.lock.unlock()

        // if there is a waiter, request a connection for it
        if let waiter = waiter {
            self.logger.debug("Fulfilling connection waitlist request")
            self.requestConnection(
                on: .prefer(waiter.futureResult.eventLoop)
            ).cascade(to: waiter)
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
        defer { self.lock.unlock() }

        // check to make sure we aren't double closing
        guard !self.didShutdown else {
            return
        }
        self.didShutdown = true
        self.logger.debug("Connection pool shutting down, closing all available connections")

        // no locks needed as this can only happen once
        for available in self.available {
            do {
                try available.close().wait()
                self.activeConnections -= 1
            } catch {
                self.logger.error("Could not close connection: \(error)")
            }
        }

        // inform any waiters that they will never be receiving a connection
        while let waiter = self.waiters.popFirst() {
            waiter.fail(ConnectionPoolError.shutdown)
        }
            
        // reset any variables to free up memory
        self.available = .init()
    }
    
    deinit {
        if !self.didShutdown {
            assertionFailure("ConnectionPool.shutdown() was not called before deinit.")
        }
    }
}
