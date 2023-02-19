import struct Logging.Logger
import NIOConcurrencyHelpers
import NIOCore
import Dispatch

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
    private let lock: NIOLock

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
    ///     - requestTimeout: Timeout for requesting a new connection.
    ///                       Defaults to 10 seconds.
    ///     - logger: For lifecycle logs.
    ///     - on: Event loop group.
    public init(
        source: Source,
        maxConnectionsPerEventLoop: Int = 1,
        requestTimeout: TimeAmount = .seconds(10),
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
            requestTimeout: requestTimeout,
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
        return self.pool(for: eventLoop ?? self.eventLoopGroup.any())
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
        return self.pool(for: eventLoop ?? self.eventLoopGroup.any())
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
    ///
    /// - Warning: This method is soft-deprecated. Use `syncShutdownGracefully()` or
    ///   `shutdownGracefully()` instead.
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
    
    /// Closes the connection pool.
    ///
    /// All available connections will be closed immediately. Any connections still in use will be
    /// closed as soon as they are returned to the pool. Once closed, the pool can not be used to
    /// create new connections.
    ///
    /// Connection pools must be closed before they deinitialize.
    ///
    /// This method shuts down synchronously, waiting for all connection closures to complete before
    /// returning.
    ///
    /// - Warning: The pool is always fully shut down once this method returns, even if an error is
    ///   thrown. All errors are purely advisory.
    public func syncShutdownGracefully() throws {
        // - TODO: Does this need to assert "not on any EventLoop", as `EventLoopGroup.syncShutdownGracefully()` does?
        var possibleError: Error? = nil
        let waiter = DispatchWorkItem {}
        let errorLock = NIOLock()
        
        self.shutdownGracefully {
            if let error = $0 {
                errorLock.withLock { possibleError = error }
            }
            waiter.perform()
        }
        waiter.wait()
        try errorLock.withLock {
            if let error = possibleError {
                throw error
            }
        }
    }
    
    /// Closes the connection pool.
    ///
    /// All available connections will be closed immediately. Any connections still in use will be
    /// closed as soon as they are returned to the pool. Once closed, the pool can not be used to
    /// create new connections.
    ///
    /// Connection pools must be closed before they deinitialize.
    ///
    /// This method shuts the pool down asynchronously. It may be invoked on any event loop. The
    /// provided callback will be notified when shutdown is complete. It is invalid to allow a pool
    /// to deinitialize before it has fully shut down.
    ///
    /// This method promises explicitly as API contract not to invoke the callback before returning
    /// to its caller. It further promises the callback will not be invoked on any event loop
    /// belonging to the pool.
    ///
    /// - Warning: Any invocation of the callback represents a signal that the pool has fully shut
    ///   down. This is true even if the error parameter is non-`nil`; errors are purely advisory.
    public func shutdownGracefully(_ callback: @escaping (Error?) -> Void) {
        // Protect access to shared state.
        guard self.lock.withLock({
            // Do not initiate shutdown multiple times.
            guard !self.didShutdown else {
                DispatchQueue.global().async {
                    self.logger.warning("Connection pool can not be shut down more than once.")
                    callback(ConnectionPoolError.shutdown)
                }
                return false
            }
            
            // Set the flag as soon as we know a shutdown is needed.
            self.didShutdown = true
            self.logger.trace("Connection group pool shutdown start - telling the loop pools what's up.")
            // Don't need to hold the lock anymore; the shutdown can proceed without blocking anything else, though
            // it's also true there's nothing else to block that we care about after shutdown begin.
            return true
        }) else { return }
        
        // Tell each pool to shut down and take note of any errors if they show up. Use the dispatch
        // queue to manage synchronization to avoid being trapped on any of our own event loops. When
        // all pools are closed, invoke the callback and provide it the first encountered error, if
        // any. By design, this loosely matches the general flow used by `MultiThreadedEventLoopGroup`'s
        // `shutdownGracefully(queue:_:)` implementation.
        let shutdownQueue = DispatchQueue(label: "codes.vapor.async-kit.poolShutdownGracefullyQueue")
        let shutdownGroup = DispatchGroup()
        var outcome: Result<Void, Error> = .success(())
        
        for pool in self.storage.values {
            shutdownGroup.enter()
            pool.close().whenComplete { result in
                shutdownQueue.async() {
                    outcome = outcome.flatMap { result }
                    shutdownGroup.leave()
                }
            }
        }
        
        shutdownGroup.notify(queue: shutdownQueue) {
            switch outcome {
            case .success:
                self.logger.debug("Connection group pool finished shutdown.")
                callback(nil)
            case .failure(let error):
                self.logger.error("Connection group pool got shutdown error (and then shut down anyway): \(error)")
                callback(error)
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
