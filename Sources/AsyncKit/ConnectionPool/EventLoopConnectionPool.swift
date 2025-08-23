import Atomics
import Collections
import NIOCore
import struct Foundation.UUID
import struct Logging.Logger

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
/// ```swift
/// let pool = EventLoopConnectionPool(...)
/// pool.withConnection(...) { conn in
///     // use conn
/// }
/// ```
public final class EventLoopConnectionPool<Source> where Source: ConnectionPoolSource {
    private typealias WaitlistItem = (logger: Logger, promise: EventLoopPromise<Source.Connection>, timeoutTask: Scheduled<Void>)

    /// Connection source.
    public let source: Source

    /// Max connections for this pool.
    private let maxConnections: Int

    /// Timeout for requesting a new connection.
    private let requestTimeout: TimeAmount

    /// This pool's event loop.
    public let eventLoop: any EventLoop

    /// ID generator
    private let idGenerator = ManagedAtomic(0)

    /// All currently available connections, paired with their last usage times.
    ///
    /// > Note: Any connection in this list may have become invalid since its last use.
    private var available: Deque<(connection: Source.Connection, lastUse: NIODeadline)>

    /// Current active connection count.
    private var activeConnections: Int

    /// Connection requests waiting to be fulfilled due to pool exhaustion.
    private var waiters: OrderedDictionary<Int, WaitlistItem>

    /// If `true`, this storage has been shutdown.
    private var didShutdown: Bool

    /// For lifecycle logs.
    public let logger: Logger

    /// Pruning interval, if enabled.
    private let pruningInterval: TimeAmount?

    /// Max connection idle time before pruning, if enabled.
    private let maxIdleTimeBeforePruning: TimeAmount

    /// Connection pruning timer, if pruning is enabled.
    private var pruningTask: RepeatedTask?

    /// Creates a new ``EventLoopConnectionPool``.
    ///
    /// ```swift
    /// let pool = EventLoopConnectionPool(...)
    /// pool.withConnection(...) { conn in
    ///     // use conn
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - source: Creates new connections when needed.
    ///   - maxConnections: Limits the number of connections that can be open. Defaults to 1.
    ///   - requestTimeout: Timeout for requesting a new connection. Defaults to 10 seconds.
    ///   - logger: For lifecycle logs.
    ///   - on: Event loop.
    public convenience init(
        source: Source,
        maxConnections: Int,
        requestTimeout: TimeAmount = .seconds(10),
        logger: Logger = .init(label: "codes.vapor.pool"),
        on eventLoop: any EventLoop
    ) {
        self.init(
            source: source,
            maxConnections: maxConnections,
            requestTimeout: requestTimeout,
            pruneInterval: nil,
            logger: logger,
            on: eventLoop
        )
    }

    /// Creates a new ``EventLoopConnectionPool``.
    ///
    /// ```swift
    /// let pool = EventLoopConnectionPool(...)
    /// pool.withConnection(...) { conn in
    ///     // use conn
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - source: Creates new connections when needed.
    ///   - maxConnections: Limits the number of connections that can be open. Defaults to 1.
    ///   - requestTimeout: Timeout for requesting a new connection. Defaults to 10 seconds.
    ///   - pruneInterval: How often to check for and prune idle database connections. If `nil` (the default),
    ///     no pruning is performed.
    ///   - maxIdleTimeBeforePruning: How long a connection may remain idle before being pruned, if pruning is enabled.
    ///     Defaults to 2 minutes. Ignored if `pruneInterval` is `nil`.
    ///   - logger: For lifecycle logs.
    ///   - on: Event loop.
    public init(
        source: Source,
        maxConnections: Int,
        requestTimeout: TimeAmount = .seconds(10),
        pruneInterval: TimeAmount?,
        maxIdleTimeBeforePruning: TimeAmount = .seconds(120),
        logger: Logger = .init(label: "codes.vapor.pool"),
        on eventLoop: any EventLoop
    ) {
        self.source = source
        self.maxConnections = maxConnections
        self.requestTimeout = requestTimeout
        self.pruningInterval = pruneInterval
        self.maxIdleTimeBeforePruning = maxIdleTimeBeforePruning
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
    /// ```swift
    /// pool.withConnection { conn in
    ///     // use the connection
    /// }
    /// ```
    ///
    /// See ``EventLoopConnectionPool/requestConnection()`` to request a pooled connection without using a callback.
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
    /// ```swift
    /// pool.withConnection(...) { conn in
    ///     // use the connection
    /// }
    /// ```
    ///
    /// See ``EventLoopConnectionPool/requestConnection(logger:)`` to request a pooled connection without using a callback.
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
    /// ```swift
    /// let conn = try pool.requestConnection(...).wait()
    /// defer { pool.releaseConnection(conn) }
    /// // use the connection
    /// ```
    ///
    /// See ``EventLoopConnectionPool/withConnection(_:)`` for a callback-based method that automatically releases the connection.
    ///
    /// - Returns: A future containing the requested connection.
    public func requestConnection() -> EventLoopFuture<Source.Connection> {
        self.requestConnection(logger: self.logger)
    }

    /// Requests a pooled connection.
    ///
    /// The connection returned by this method MUST be released when you are finished using it.
    ///
    /// ```swift
    /// let conn = try pool.requestConnection(...).wait()
    /// defer { pool.releaseConnection(conn) }
    /// // use the connection
    /// ```
    ///
    /// See ``EventLoopConnectionPool/withConnection(logger:_:)`` for a callback-based method that automatically releases the connection.
    ///
    /// - Parameters:
    ///   - logger: For trace and debug logs.
    ///   - eventLoop: Preferred event loop for the new connection.
    /// - Returns: A future containing the requested connection.
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

    /// Actual implementation of ``EventLoopConnectionPool/requestConnection(logger:)``.
    private func _requestConnection0(logger: Logger) -> EventLoopFuture<Source.Connection> {
        self.eventLoop.assertInEventLoop()

        guard !self.didShutdown else {
            return self.eventLoop.makeFailedFuture(ConnectionPoolError.shutdown)
        }

        // Find an available connection that isn't closed
        while let conn = self.available.popLast() {
            if !conn.connection.isClosed {
                logger.trace("Using available connection")
                return self.eventLoop.makeSucceededFuture(conn.connection)
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
                logger.trace("Waiter already removed when timeout task fired", metadata: ["waiter": .stringConvertible(waiterId)])
                return
            }
            logger.error("""
                Connection request timed out. This might indicate a connection deadlock in \
                your application. If you have long-running requests, consider increasing your connection timeout.
                """,
                metadata: ["waiter": .stringConvertible(waiterId)]
            )
            promise.fail(ConnectionPoolTimeoutError.connectionRequestTimeout)
        }
        logger.trace("Adding connection request to waitlist", metadata: ["waiter": .stringConvertible(waiterId)])
        self.waiters[waiterId] = (logger: logger, promise: promise, timeoutTask: timeoutTask)

        promise.futureResult.whenComplete { [weak self] _ in
            logger.trace("Connection request completed", metadata: ["waiter": .stringConvertible(waiterId)])
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
                logger.error("Opening new connection for pool failed", metadata: ["error": .string(String(reflecting: error))])
                return eventLoop.makeFailedFuture(error)
            }.cascadeFailure(to: promise)
        }

        return promise.futureResult
    }

    /// Releases a connection back to the pool. Use with ``EventLoopConnectionPool/requestConnection()``.
    ///
    /// ```swift
    /// let conn = try pool.requestConnection().wait()
    /// defer { pool.releaseConnection(conn) }
    /// // use the connection
    /// ```
    ///
    /// - Parameters:
    ///   - connection: Connection to release back to the pool.
    public func releaseConnection(_ connection: Source.Connection) {
        self.releaseConnection(connection, logger: self.logger)
    }

    /// Releases a connection back to the pool. Use with ``EventLoopConnectionPool/requestConnection(logger:)``.
    ///
    /// ```swift
    /// let conn = try pool.requestConnection().wait()
    /// defer { pool.releaseConnection(conn) }
    /// // use the connection
    /// ```
    ///
    /// - Parameters:
    ///   - connection: Connection to release back to the pool.
    ///   - logger: For trace and debug logs.
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

        logger.trace("Releasing pool connection.", metadata: [
            "eventloop": .string(self.eventLoop.description
                .components(separatedBy: "thread = NIOThread(name = ").dropFirst().first?
                .components(separatedBy: ")").first ?? "<unknown>"
            ),
            "available": .stringConvertible(self.available.count + (connection.isClosed ? 0 : 1))
        ])

        // Push the connection onto the end of the available list so it's the first one to get used
        // on the next request. Do this even if the connection is closed in order to ensure we service
        // the waitlist and start a new connection if needed.
        self.available.append((connection: connection, lastUse: .now()))

        if self.available.count == 1, let pruningInterval = self.pruningInterval, self.pruningTask == nil { // just added our very first connection
            self.pruningTask = self.eventLoop.scheduleRepeatedTask(
                initialDelay: pruningInterval,
                delay: pruningInterval
            ) { [unowned self] _ in
                var prunedConnections: Set<ObjectIdentifier> = []

                for conninfo in self.available where !conninfo.connection.isClosed {
                    if conninfo.lastUse + self.maxIdleTimeBeforePruning < .now() {
                        self.logger.debug("Pruning idle connection.")
                        _ = conninfo.connection.close()
                        prunedConnections.insert(.init(conninfo.connection))
                    }
                }
                if !prunedConnections.isEmpty {
                    self.available.removeAll(where: { prunedConnections.contains(ObjectIdentifier($0.connection)) })
                    self.activeConnections -= prunedConnections.count
                }
            }
        }

        // For as long as there are connections available, try to dequeue waiters. Even if the available
        // connection(s) are closed, the request logic will try to open new ones.
        while !self.available.isEmpty, !self.waiters.isEmpty {
            let waiter = self.waiters.removeFirst()

            logger.debug("Servicing connection waitlist item", metadata: ["waiter": .stringConvertible(waiter.key)])
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

        let pruningCancellationPromise = self.eventLoop.makePromise(of: Void.self)
        if let pruningTask = self.pruningTask {
            pruningTask.cancel(promise: pruningCancellationPromise)
        } else {
            pruningCancellationPromise.succeed()
        }

        for (_, waiter) in self.waiters {
            waiter.timeoutTask.cancel()
            waiter.promise.fail(ConnectionPoolError.shutdown)
        }
        self.waiters.removeAll()

        return pruningCancellationPromise.futureResult.flatMap {
            self.available.map {
                $0.connection.close()
            }.flatten(on: self.eventLoop)
        }.map {
            self.activeConnections = 0
            self.available.removeAll()
        }
    }

    internal/*testable*/ func poolState() -> EventLoopFuture<(known: Int, active: Int, open: Int)> {
        if self.eventLoop.inEventLoop {
            self.eventLoop.makeSucceededFuture((self.available.count, self.activeConnections, self.available.filter { !$0.connection.isClosed }.count))
        } else {
            self.eventLoop.submit { (self.available.count, self.activeConnections, self.available.filter { !$0.connection.isClosed }.count) }
        }
    }

    deinit {
        if !self.didShutdown {
            assertionFailure("ConnectionPoolStorage.shutdown() was not called before deinit.")
        }
    }
}
