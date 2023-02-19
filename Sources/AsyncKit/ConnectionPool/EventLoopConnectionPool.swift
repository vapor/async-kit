import struct Logging.Logger
import struct Foundation.UUID
import NIOCore

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
///     let pool = EventLoopConnectionPool(...)
///     pool.withConnection(...) { conn in
///         // use conn
///     }
///
public final class EventLoopConnectionPool<Source> where Source: ConnectionPoolSource {
    /// Connection source.
    public let source: Source
    
    /// Max connections for this storage.
    private let maxConnections: Int
    
    /// Timeout for requesting a new connection.
    private let requestTimeout: TimeAmount
    
    /// This pool's event loop.
    public let eventLoop: EventLoop
    
    /// All currently available connections.
    /// - note: These connections may have closed since last use.
    private var available: CircularBuffer<Source.Connection>
    
    /// Current active connection count.
    private var activeConnections: Int
    
    /// All requests for a connection that were unable to be fulfilled
    /// due to max connection limit having been reached.
    private var waiters: CircularBuffer<(Logger, EventLoopPromise<Source.Connection>)>
    
    /// If `true`, this storage has been shutdown.
    private var didShutdown: Bool
    
    /// For lifecycle logs.
    public let logger: Logger

    /// Creates a new `EventLoopConnectionPool`.
    ///
    ///     let pool = EventLoopConnectionPool(...)
    ///     pool.withConnection(...) { conn in
    ///         // use conn
    ///     }
    ///
    /// - parameters:
    ///     - source: Creates new connections when needed.
    ///     - maxConnections: Limits the number of connections that can be open.
    ///                       Defaults to 1.
    ///     - requestTimeout: Timeout for requesting a new connection.
    ///                       Defaults to 10 seconds.
    ///     - logger: For lifecycle logs.
    ///     - on: Event loop.
    public init(
        source: Source,
        maxConnections: Int,
        requestTimeout: TimeAmount = .seconds(10),
        logger: Logger = .init(label: "codes.vapor.pool"),
        on eventLoop: EventLoop
    ) {
        self.source = source
        self.maxConnections = maxConnections
        self.requestTimeout = requestTimeout
        self.logger = logger
        self.eventLoop = eventLoop
        self.available = .init(initialCapacity: maxConnections)
        self.activeConnections = 0
        self.waiters = .init()
        self.didShutdown = false
    }
    
    /// Fetches a pooled connection for the lifetime of the closure.
    ///
    /// The connection is provided to the supplied callback and will be automatically released when the
    /// future returned by the callback is completed.
    ///
    ///     pool.withConnection { conn in
    ///         // use the connection
    ///     }
    ///
    /// See `requestConnection(on:)` to request a pooled connection without using a callback.
    ///
    /// - parameters:
    ///     - closure: Callback that accepts the pooled connection.
    /// - returns: A future containing the result of the closure.
    public func withConnection<Result>(
        _ closure: @escaping (Source.Connection) -> EventLoopFuture<Result>
    ) -> EventLoopFuture<Result> {
        self.withConnection(logger: self.logger, closure)
    }
    
    /// Fetches a pooled connection for the lifetime of the closure.
    ///
    /// The connection is provided to the supplied callback and will be automatically released when the
    /// future returned by the callback is completed.
    ///
    ///     pool.withConnection(...) { conn in
    ///         // use the connection
    ///     }
    ///
    /// See `requestConnection(on:)` to request a pooled connection without using a callback.
    ///
    /// - parameters:
    ///     - logger: For trace and debug logs.
    ///     - closure: Callback that accepts the pooled connection.
    /// - returns: A future containing the result of the closure.
    public func withConnection<Result>(
        logger: Logger,
        _ closure: @escaping (Source.Connection) -> EventLoopFuture<Result>
    ) -> EventLoopFuture<Result> {
        return self.requestConnection(logger: logger).flatMap { conn in
            return closure(conn).map { res in
                self.releaseConnection(conn, logger: logger)
                return res
            }.flatMapErrorThrowing { error in
                self.releaseConnection(conn, logger: logger)
                throw error
            }
        }
    }
    
    /// Requests a pooled connection.
    ///
    /// The connection returned by this method should be released when you are finished using it.
    ///
    ///     let conn = try pool.requestConnection(...).wait()
    ///     defer { pool.releaseConnection(conn) }
    ///     // use the connection
    ///
    /// See `withConnection(_:)` for a callback-based method that automatically releases the connection.
    ///
    /// - returns: A future containing the requested connection.
    public func requestConnection() -> EventLoopFuture<Source.Connection> {
        self.requestConnection(logger: self.logger)
    }
    
    /// Requests a pooled connection.
    ///
    /// The connection returned by this method should be released when you are finished using it.
    ///
    ///     let conn = try pool.requestConnection(...).wait()
    ///     defer { pool.releaseConnection(conn) }
    ///     // use the connection
    ///
    /// See `withConnection(_:)` for a callback-based method that automatically releases the connection.
    ///
    /// - parameters:
    ///     - logger: For trace and debug logs.
    ///     - eventLoop: Preferred event loop for the new connection.
    /// - returns: A future containing the requested connection.
    public func requestConnection(logger: Logger) -> EventLoopFuture<Source.Connection> {
        // dispatch to event loop thread if necessary
        guard self.eventLoop.inEventLoop else {
            return self.eventLoop.flatSubmit {
                self.requestConnection(logger: logger)
            }
        }
        
        // synchronize access to available / active connection checks
        guard !self.didShutdown else {
            return self.eventLoop.makeFailedFuture(ConnectionPoolError.shutdown)
        }
        
        // creates a new connection assuming `activeConnections`
        // has already been incremented
        func makeActiveConnection() -> EventLoopFuture<Source.Connection> {
            return self.source.makeConnection(logger: logger, on: eventLoop).flatMapErrorThrowing { error in
                self.activeConnections -= 1
                throw error
            }
        }

        // iterate over available connections
        while let conn = self.available.popFirst() {
            // check if it is still open
            if !conn.isClosed {
                // connection is still open, we can return it directly
                logger.trace("Re-using available connection")
                return eventLoop.makeSucceededFuture(conn)
            } else {
                // connection is closed
                logger.debug("Pruning available connection that has closed")
                self.activeConnections -= 1
            }
        }
        
        // all connections are busy, check if we have room for more
        if self.activeConnections < self.maxConnections {
            logger.debug("No available connections on this event loop, creating a new one")
            self.activeConnections += 1
            return makeActiveConnection()
        } else {
            // connections are exhausted, we must wait for one to be returned
            logger.debug("Connection pool exhausted on this event loop, adding request to waitlist")
            let promise = eventLoop.makePromise(of: Source.Connection.self)
            self.waiters.append((logger, promise))
            
            let task = eventLoop.scheduleTask(in: self.requestTimeout) { [weak self] in
                guard let self = self else { return }
                logger.error("Connection request timed out. This might indicate a connection deadlock in your application. If you're running long running requests, consider increasing your connection timeout.")
                if let idx = self.waiters.firstIndex(where: { _, p in return p.futureResult === promise.futureResult }) {
                    self.waiters.remove(at: idx)
                }
                promise.fail(ConnectionPoolTimeoutError.connectionRequestTimeout)
            }
            
            return promise.futureResult.always { _ in task.cancel() }
        }
    }
    
    /// Releases a connection back to the pool. Use with `requestConnection()`.
    ///
    ///     let conn = try pool.requestConnection().wait()
    ///     defer { pool.releaseConnection(conn) }
    ///     // use the connection
    ///
    /// - parameters:
    ///     - connection: Connection to release back to the pool.
    public func releaseConnection(_ connection: Source.Connection) {
        self.releaseConnection(connection, logger: self.logger)
    }
    
    /// Releases a connection back to the pool. Use with `requestConnection()`.
    ///
    ///     let conn = try pool.requestConnection().wait()
    ///     defer { pool.releaseConnection(conn) }
    ///     // use the connection
    ///
    /// - parameters:
    ///     - connection: Connection to release back to the pool.
    ///     - logger: For trace and debug logs.
    public func releaseConnection(_ connection: Source.Connection, logger: Logger) {
        // dispatch to event loop thread if necessary
        guard self.eventLoop.inEventLoop else {
            return self.eventLoop.execute {
                self.releaseConnection(connection, logger: logger)
            }
        }
        
        // synchronize access to available / active connection checks
        guard !self.didShutdown else {
            // this pool is closed and we are responsible for closing all
            // of our connections
            _ = connection.close()
            return
        }

        // add this connection back to the list of available
        logger.trace("Releasing connection")
        self.available.append(connection)

        // now that we know a new connection is available, we should
        // take this chance to fulfill one of the waiters
        let waiter: (Logger, EventLoopPromise<Source.Connection>)?
        if !self.waiters.isEmpty {
            waiter = self.waiters.removeFirst()
        } else {
            waiter = nil
        }

        // if there is a waiter, request a connection for it
        if let (logger, promise) = waiter {
            logger.debug("Fulfilling connection waitlist request")
            self.requestConnection(
                logger: logger
            ).cascade(to: promise)
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
    public func close() -> EventLoopFuture<Void> {
        // dispatch to event loop thread if necessary
        guard self.eventLoop.inEventLoop else {
            return self.eventLoop.flatSubmit {
                return self.close()
            }
        }
        
        // check to make sure we aren't double closing
        guard !self.didShutdown else {
            return self.eventLoop.makeSucceededFuture(())
        }
        self.didShutdown = true
        self.logger.trace("Connection pool storage shutting down, closing all available connections on this event loop")

        // no locks needed as this can only happen once
        return self.available.map {
            $0.close().map {
                self.activeConnections -= 1
            }
        }.flatten(on: self.eventLoop).map {
            // inform any waiters that they will never be receiving a connection
            while let (_, promise) = self.waiters.popFirst() {
                promise.fail(ConnectionPoolError.shutdown)
            }
            // reset any variables to free up memory
            self.available = .init()
        }
    }
    
    deinit {
        if !self.didShutdown {
            assertionFailure("ConnectionPoolStorage.shutdown() was not called before deinit.")
        }
    }
}
