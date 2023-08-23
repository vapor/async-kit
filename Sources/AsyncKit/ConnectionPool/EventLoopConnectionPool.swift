import Atomics
import struct Logging.Logger
import struct Foundation.UUID
import struct Foundation.TimeInterval
import struct Foundation.Date
import struct NIOConcurrencyHelpers.NIOLock
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
    private let idGenerator = ManagedAtomic(0)

    // How often to check for stale connections
    public let pruneInterval: TimeInterval
    
    // The max time a connection can remain unused
    public let maxIdleTimeBeforePrunning: TimeInterval
    
    /// All currently available connections.
    /// - note: These connections may have closed since last use.
    private var available: Deque<PrunableConnection>
    
    /// Current active connection count.
    public private(set) var activeConnections: Int
    
    /// Connection requests waiting to be fulfilled due to pool exhaustion.
    private var waiters: OrderedDictionary<Int, WaitlistItem>
    
    /// If `true`, this storage has been shutdown.
    private var didShutdown: Bool
    
    /// For lifecycle logs.
    public let logger: Logger
    
    private let lock: NIOLock
    
    /// Creates a new `EventLoopConnectionPool`.
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
        on eventLoop: EventLoop,
        pruneInterval: TimeInterval = 60,
        maxIdleTimeBeforePrunning: TimeInterval = 120
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
        self.pruneInterval = pruneInterval
        self.maxIdleTimeBeforePrunning = maxIdleTimeBeforePrunning
        self.lock = .init()
        
        self.pruneConnections()
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

        // creates a new connection assuming `activeConnections`
        // has already been incremented
        func makeActiveConnection() -> EventLoopFuture<Source.Connection> {
            return self.source.makeConnection(logger: logger, on: eventLoop).flatMapErrorThrowing { error in
                self.activeConnections -= 1
                throw error
            }
        }

        // iterate over available connections
        while let conn = self.lock.withLock({ self.available.popFirst() }) {
            // check if it is still open
            if !conn.originalConnection.isClosed {
                // connection is still open, we can return it directly
                logger.trace("Re-using available connection")
                return eventLoop.makeSucceededFuture(conn.originalConnection as! Source.Connection)
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

        // add this connection back to the list of available
        logger.trace("Releasing connection")

        let knownConnection = lock.withLock { available.first { $0.originalConnection === connection } }
        if let knownConnection = knownConnection {
            knownConnection.lastUsed = Date()
            self.available.append(knownConnection)
        } else {
            //this is connection that we don't know yet, it was returned by a future and the client just wants to release it.
            let newConnection = PrunableConnection(connection: connection, lastUsed: Date())
            self.available.append(newConnection)
        }

        // now that we know a new connection is available, we should
        // take this chance to fulfill one of the waiters
        let waiter: WaitlistItem?
        if !self.waiters.isEmpty {
            waiter = self.waiters.removeFirst().value
        } else {
            waiter = nil
        }

        // if there is a waiter, request a connection for it
        if let (logger, promise, _) = waiter {
            logger.debug("Fulfilling connection waitlist request")
            self.requestConnection(
                logger: logger
            ).cascade(to: promise)
        }
    }
    
    
    private func pruneConnections() {
        // dispatch to event loop thread if necessary
        guard self.eventLoop.inEventLoop else {
            return self.eventLoop.execute {
                self.pruneConnections()
            }
        }

        self.lock.withLockVoid {
            self.available.filter{!$0.originalConnection.isClosed}.forEach { conn in
                if Date().timeIntervalSince(conn.lastUsed) >= self.maxIdleTimeBeforePrunning {
                    // the connection is too old, just releasing it
                    logger.debug("Connection is too old, closing it")
                    _ = conn.originalConnection.close()
                }
            }
        }

        _ = self.eventLoop.scheduleTask(in: .milliseconds(Int64(1000 * self.pruneInterval))) { [weak self] in
            self?.pruneConnections()
        }
    }
    
    public var openedConnections: Int {
        return self.available.filter{!$0.isClosed}.count
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
            $0.originalConnection.close().map {
                self.activeConnections -= 1
            }
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

public final class PrunableConnection {
    var originalConnection: ConnectionPoolItem
    var lastUsed: Date
    
    init(connection: ConnectionPoolItem, lastUsed: Date) {
        self.originalConnection = connection
        self.lastUsed = lastUsed
    }
    
    public var isClosed: Bool {
        return self.originalConnection.isClosed
    }
}
