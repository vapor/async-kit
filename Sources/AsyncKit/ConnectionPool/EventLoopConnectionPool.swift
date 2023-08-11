import Atomics
import struct Logging.Logger
import struct Foundation.UUID
import NIOCore
import Collections

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
public final class EventLoopConnectionPool<Source> where Source: ConnectionPoolSource {
    private typealias WaitlistItem = (logger: Logger, promise: EventLoopPromise<Source.Connection>, timeoutTask: Scheduled<Void>)
    
    /// Connection source.
    public let source: Source
    
    /// Max connections for this pool.
    private let maxConnections: Int
    
    /// Timeout for requesting a new connection.
    private let requestTimeout: TimeAmount
    
    /// This pool's event loop.
    public let eventLoop: EventLoop
    
    /// ID generator
    private var idGenerator = ManagedAtomic(0)
    
    /// All currently available connections.
    ///
    /// > Note: Any connection in this list may have become invalid since its last use.
    private var available: Deque<Source.Connection>
    
    /// Current active connection count.
    private var activeConnections: Int
    
    /// Connection requests waiting to be fulfilled due to pool exhaustion.
    private var waiters: OrderedDictionary<Int, WaitlistItem>
    
    /// If `true`, this storage has been shutdown.
    private var didShutdown: Bool
    
    /// For lifecycle logs.
    public let logger: Logger

    /// Creates a new ``EventLoopConnectionPool``.
    ///
    ///     let pool = EventLoopConnectionPool(...)
    ///     pool.withConnection(...) { conn in
    ///         // use conn
    ///     }
    ///
    /// - Parameters:
    ///   - source: Creates new connections when needed.
    ///   - maxConnections: Limits the number of connections that can be open. Defaults to 1.
    ///   - requestTimeout: Timeout for requesting a new connection. Defaults to 10 seconds.
    ///   - logger: For lifecycle logs.
    ///   - on: Event loop.
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
        self.available = .init(minimumCapacity: maxConnections)
        self.activeConnections = 0
        self.waiters = .init(minimumCapacity: maxConnections << 2)
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
    /// See ``requestConnection()`` to request a pooled connection without using a callback.
    ///
    /// - Parameters:
    ///   - closure: Callback that accepts the pooled connection.
    /// - Returns: A future containing the result of the closure.
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
    /// See ``requestConnection(logger:)`` to request a pooled connection without using a callback.
    ///
    /// - Parameters:
    ///   - logger: For trace and debug logs.
    ///   - closure: Callback that accepts the pooled connection.
    /// - Returns: A future containing the result of the closure.
    public func withConnection<Result>(
        logger: Logger,
        _ closure: @escaping (Source.Connection) -> EventLoopFuture<Result>
    ) -> EventLoopFuture<Result> {
        self.requestConnection(logger: logger).flatMap { conn in
            closure(conn).always { _ in
                self.releaseConnection(conn, logger: logger)
            }
        }
    }
    
    /// Requests a pooled connection.
    ///
    /// The connection returned by this method MUST be released when you are finished using it.
    ///
    ///     let conn = try pool.requestConnection(...).wait()
    ///     defer { pool.releaseConnection(conn) }
    ///     // use the connection
    ///
    /// See ``withConnection(_:)`` for a callback-based method that automatically releases the connection.
    ///
    /// - Returns: A future containing the requested connection.
    public func requestConnection() -> EventLoopFuture<Source.Connection> {
        self.requestConnection(logger: self.logger)
    }
    
    /// Requests a pooled connection.
    ///
    /// The connection returned by this method MUST be released when you are finished using it.
    ///
    ///     let conn = try pool.requestConnection(...).wait()
    ///     defer { pool.releaseConnection(conn) }
    ///     // use the connection
    ///
    /// See ``withConnection(logger:_:)`` for a callback-based method that automatically releases the connection.
    ///
    /// - parameters:
    ///     - logger: For trace and debug logs.
    ///     - eventLoop: Preferred event loop for the new connection.
    /// - returns: A future containing the requested connection.
    public func requestConnection(logger: Logger) -> EventLoopFuture<Source.Connection> {
        /// N.B.: This particular pattern (the use of a promise to forward the result when off the event loop)
        /// is straight out of NIO's `EventLoopFuture.fold()` implementation.
        if self.eventLoop.inEventLoop {
            return self._requestConnection0(logger: logger)
        } else {
            let promise = self.eventLoop.makePromise(of: Source.Connection.self)
            self.eventLoop.execute { self._requestConnection0(logger: logger).cascade(to: promise) }
            return promise.futureResult
        }
    }
    
    /// Actual implementation of ``requestConnection(logger:)``.
    private func _requestConnection0(logger: Logger) -> EventLoopFuture<Source.Connection> {
        self.eventLoop.assertInEventLoop()
        
        guard !self.didShutdown else {
            return self.eventLoop.makeFailedFuture(ConnectionPoolError.shutdown)
        }
        
        // Find an available connection that isn't closed
        while let conn = self.available.popLast() {
            if !conn.isClosed {
                logger.trace("Using available connection")
                return self.eventLoop.makeSucceededFuture(conn)
            } else {
                logger.debug("Pruning defunct connection")
                self.activeConnections -= 1
            }
        }
        
        // Put the current request on the waiter list in case opening a new connection is slow
        let waiterId = self.idGenerator.wrappingIncrementThenLoad(ordering: .relaxed)
        let promise = self.eventLoop.makePromise(of: Source.Connection.self)
        let timeoutTask = self.eventLoop.scheduleTask(in: self.requestTimeout) { [weak self] in
            // Try to avoid a spurious log message and failure if the waiter has already been removed from the list.
            guard self?.waiters.removeValue(forKey: waiterId) != nil else {
                logger.trace("Waiter \(waiterId) already removed when timeout task fired")
                return
            }
            logger.error("""
                Connection request (ID \(waiterId) timed out. This might indicate a connection deadlock in \
                your application. If you have long-running requests, consider increasing your connection timeout.
                """)
            promise.fail(ConnectionPoolTimeoutError.connectionRequestTimeout)
        }
        logger.trace("Adding connection request to waitlist with ID \(waiterId)")
        self.waiters[waiterId] = (logger: logger, promise: promise, timeoutTask: timeoutTask)
        
        promise.futureResult.whenComplete { [weak self] _ in
            logger.trace("Connection request with ID \(waiterId) completed")
            timeoutTask.cancel()
            self?.waiters.removeValue(forKey: waiterId)
        }

        // If the pool isn't full, attempt to open a new connection
        if self.activeConnections < self.maxConnections {
            logger.trace("Attemping new connection for pool")
            self.activeConnections += 1
            self.source.makeConnection(logger: logger, on: self.eventLoop).map {
                // On success, "release" the new connection to the pool and let the waitlist logic take over
                logger.trace("New connection successful, servicing waitlist")
                self._releaseConnection0($0, logger: logger)
            }.flatMapErrorWithEventLoop { [weak self] error, eventLoop in
                self?.activeConnections -= 1
                logger.error("Opening new connection for pool failed: \(String(reflecting: error))")
                return eventLoop.makeFailedFuture(error)
            }.cascadeFailure(to: promise)
        }
        
        return promise.futureResult
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
        if self.eventLoop.inEventLoop {
            self._releaseConnection0(connection, logger: logger)
        } else {
            self.eventLoop.execute { self._releaseConnection0(connection, logger: logger) }
        }
    }
    
    private func _releaseConnection0(_ connection: Source.Connection, logger: Logger) {
        self.eventLoop.assertInEventLoop()
        
        // If the pool has shut down, just close the connection and return
        guard !self.didShutdown else {
            if !connection.isClosed {
                _ = connection.close()
            }
            return
        }
        
        // Push the connection onto the end of the available list so it's the first one to get used
        // on the next request.
        logger.trace("Releasing pool connection on \(self.eventLoop.description), \(self.available.count + (connection.isClosed ? 0 : 1)) connnections available.")
        self.available.append(connection)
        
        // For as long as there are connections available, try to dequeue waiters. Even if the available
        // connection(s) are closed, the request logic will try to open new ones.
        while !self.available.isEmpty, !self.waiters.isEmpty {
            let waiter = self.waiters.removeFirst()
            
            logger.debug("Servicing connection waitlist item with id \(waiter.key)")
            waiter.value.timeoutTask.cancel()
            self._requestConnection0(logger: waiter.value.logger).cascade(to: waiter.value.promise)
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
        if self.eventLoop.inEventLoop {
            return self._close0()
        } else {
            let promise = self.eventLoop.makePromise(of: Void.self)
            self.eventLoop.execute { self._close0().cascade(to: promise) }
            return promise.futureResult
        }
    }
    
    private func _close0() -> EventLoopFuture<Void> {
        self.eventLoop.assertInEventLoop()
        
        guard !self.didShutdown else {
            return self.eventLoop.makeSucceededVoidFuture()
        }
        self.didShutdown = true
        self.logger.trace("Connection pool shutting down - closing all available connections on this event loop")
        
        for (_, waiter) in self.waiters {
            waiter.timeoutTask.cancel()
            waiter.promise.fail(ConnectionPoolError.shutdown)
        }
        self.waiters.removeAll()
        
        return self.available.map {
            $0.close()
        }.flatten(on: self.eventLoop).map {
            self.activeConnections = 0
            self.available.removeAll()
        }
    }
    
    deinit {
        if !self.didShutdown {
            assertionFailure("ConnectionPoolStorage.shutdown() was not called before deinit.")
        }
    }
}
