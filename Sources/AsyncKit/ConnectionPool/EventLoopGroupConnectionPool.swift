import struct Logging.Logger
import class NIOConcurrencyHelpers.Lock

/// Holds a collection of connection pools for each `EventLoop` on an `EventLoopGroup`.
///
/// Connection pools are used to offset the overhead of creating new connections. Newly
/// opened connections are returned back to the pool and can be re-used until they
/// close.
///
/// New connections are created as needed until the maximum configured connection limit
/// is reached. After the maximum is reached, no new connections will be created unless
/// existing connections are closed.
///
///     let pool = EventLoopGroupConnectionPool(...)
///     pool.withConnection { conn in
///         // use conn
///     }
///
public final class EventLoopGroupConnectionPool<Source> where Source: ConnectionPoolSource  {
    /// Creates new connections when needed. See `ConnectionPoolSource`.
    public let source: Source
    
    /// Limits the maximum number of connections that can be open at a given time
    /// for a single connection pool.
    public let maxConnectionsPerEventLoop: Int

    /// Event loop source when not specified.
    public let eventLoopGroup: EventLoopGroup
    
    // MARK: Private
    
    /// For lifecycle logs.
    private let logger: Logger
    
    /// Synchronize access.
    private let lock: Lock

    /// If `true`, this connection pool has been closed.
    private var didShutdown: Bool
    
    /// Actual connection pool storage.
    private let storage: [EventLoop.Key: EventLoopConnectionPool<Source>]

    /// Creates a new `EventLoopGroupConnectionPool`.
    ///
    ///     let pool = EventLoopGroupConnectionPool(...)
    ///     pool.withConnection(...) { conn in
    ///         // use conn
    ///     }
    ///
    /// - parameters:
    ///     - source: Creates new connections when needed.
    ///     - maxConnectionsPerEventLoop: Limits the number of connections that can be open per event loop.
    ///                                   Defaults to 1.
    ///     - logger: For lifecycle logs.
    ///     - on: Event loop group.
    public init(
        source: Source,
        maxConnectionsPerEventLoop: Int = 1,
        logger: Logger = .init(label: "codes.vapor.pool"),
        on eventLoopGroup: EventLoopGroup
    ) {
        self.source = source
        self.maxConnectionsPerEventLoop = maxConnectionsPerEventLoop
        self.logger = logger
        self.lock = .init()
        self.eventLoopGroup = eventLoopGroup
        self.didShutdown = false
        self.storage = .init(uniqueKeysWithValues: eventLoopGroup.makeIterator().map { ($0.key, .init(
            source: source,
            maxConnections: maxConnectionsPerEventLoop,
            logger: logger,
            on: $0
        )) })
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
    ///     - eventLoop: Preferred event loop for the new connection.
    ///     - closure: Callback that accepts the pooled connection.
    /// - returns: A future containing the result of the closure.
    public func withConnection<Result>(
        logger: Logger? = nil,
        on eventLoop: EventLoop? = nil,
        _ closure: @escaping (Source.Connection) -> EventLoopFuture<Result>
    ) -> EventLoopFuture<Result> {
        guard !self.lock.withLock({ self.didShutdown }) else {
            return (eventLoop ?? self.eventLoopGroup).future(error: ConnectionPoolError.shutdown)
        }
        return self.pool(for: eventLoop ?? self.eventLoopGroup.next())
                   .withConnection(logger: logger ?? self.logger, closure)
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
    public func requestConnection(
        logger: Logger? = nil,
        on eventLoop: EventLoop? = nil
    ) -> EventLoopFuture<Source.Connection> {
        guard !self.lock.withLock({ self.didShutdown }) else {
            return (eventLoop ?? self.eventLoopGroup).future(error: ConnectionPoolError.shutdown)
        }
        return self.pool(for: eventLoop ?? self.eventLoopGroup.next())
                   .requestConnection(logger: logger ?? self.logger)
    }
    
    /// Releases a connection back to the pool. Use with `requestConnection()`.
    ///
    ///     let conn = try pool.requestConnection(...).wait()
    ///     defer { pool.releaseConnection(conn) }
    ///     // use the connection
    ///
    /// - parameters:
    ///     - connection: Connection to release back to the pool.
    ///     - logger: For trace and debug logs.
    public func releaseConnection(
        _ connection: Source.Connection,
        logger: Logger? = nil
    ) {
        self.pool(for: connection.eventLoop)
            .releaseConnection(connection, logger: logger ?? self.logger)
    }
    
    /// Returns the `EventLoopConnectionPool` for a specific event loop.
    public func pool(for eventLoop: EventLoop) -> EventLoopConnectionPool<Source> {
        self.storage[eventLoop.key]!
    }
    
    /// Closes the connection pool.
    ///
    /// All available connections will be closed immediately.
    /// Any connections currently in use will be closed when they are returned to the pool.
    ///
    /// Once closed, the connection pool cannot be used to create new connections.
    ///
    /// Connection pools must be closed before they deinitialize.
    public func shutdown() {
        // synchronize access to closing
        guard self.lock.withLock({
            // check to make sure we aren't double closing
            guard !self.didShutdown else {
                return false
            }
            self.didShutdown = true
            self.logger.debug("Connection pool shutting down, closing each event loop's storage")
            return true
        }) else {
            return
        }

        // shutdown all pools
        for pool in self.storage.values {
            do {
                try pool.close().wait()
            } catch {
                self.logger.error("Failed shutting down event loop pool: \(error)")
            }
        }
    }
    
    deinit {
        assert(self.lock.withLock { self.didShutdown }, "ConnectionPool.shutdown() was not called before deinit.")
    }
}

private extension EventLoop {
    typealias Key = ObjectIdentifier
    var key: Key {
        ObjectIdentifier(self)
    }
}
