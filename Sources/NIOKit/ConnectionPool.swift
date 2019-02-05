/// Source of new connections for `ConnectionPool`.
public protocol ConnectionPoolSource {
    /// Associated `ConnectionPoolItem` that will be returned by `makeConnection()`.
    associatedtype Connection: ConnectionPoolItem
    
    /// This source's event loop.
    var eventLoop: EventLoop { get }
    
    /// Creates a new connection.
    func makeConnection() -> EventLoopFuture<Connection>
}

/// Item managed by a connection pool.
public protocol ConnectionPoolItem: class {
    /// If `true`, this connection has closed.
    var isClosed: Bool { get }
}

/// Configuration options for `ConnectionPool`.
public struct ConnectionPoolConfig {
    /// Limits the maximum number of connections that can be open at a given time
    /// for a single connection pool.
    var maxConnections: Int
    
    /// Creates a new `ConnectionPoolConfig`.
    ///
    /// - parameters:
    ///     - maxConnections: Limits the maximum number of connections that can be open at a given time
    ///                       for a single connection pool.
    ///                       Defaults to 12.
    public init(maxConnections: Int = 12) {
        self.maxConnections = maxConnections
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
    public let config: ConnectionPoolConfig
    
    /// Creates new connections when needed. See `ConnectionPoolSource`.
    public let source: Source
    
    // MARK: Private

    /// All currently available connections.
    /// - note: These connections may have closed since last use.
    private var available: [Source.Connection]
    
    /// Current active connection count.
    private var activeConnections: Int
    
    /// All requests for a connection that were unable to be fulfilled
    /// to to max connection limit having been reached.
    private var waiters: [EventLoopPromise<Source.Connection>]
    
    /// Creates a new `ConnectionPool`.
    ///
    ///     let pool = ConnectionPool(config: ..., source: ...)
    ///     pool.withConnection { conn in
    ///         // use conn
    ///     }
    ///
    /// - parameters:
    ///     - config: Config options for this pool.
    ///     - source: Creates new connections when needed.
    public init(config: ConnectionPoolConfig = .init(), source: Source) {
        self.config = config
        self.source = source
        self.available = []
        self.activeConnections = 0
        self.waiters = []
    }
    
    /// Fetches a pooled connection for the lifetime of the closure.
    ///
    /// The connection is provided to the supplied callback and will be automatically released when the
    /// future returned by the callback is completed.
    ///
    ///     pool.withPooledConnection { conn in
    ///         // use the connection
    ///     }
    ///
    /// See `requestConnection()` to request a pooled connection without using a callback.
    ///
    /// - parameters:
    ///     - closure: Callback that accepts the pooled connection.
    /// - returns: A future containing the result of the closure.
    public func withConnection<Result>(_ closure: @escaping (Source.Connection) -> EventLoopFuture<Result>) -> EventLoopFuture<Result> {
        return requestConnection().flatMap { conn in
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
    ///     let conn = try pool.requestConnection().wait()
    ///     defer { pool.releaseConnection(conn) }
    ///     // use the connection
    ///
    /// See `withConnection(_:)` for a callback-based method that automatically releases the connection.
    ///
    /// - returns: A future containing the requested connection.
    public func requestConnection() -> EventLoopFuture<Source.Connection> {
        if let conn = self.available.popLast() {
            // check if it is still open
            if !conn.isClosed {
                // connection is still open, we can return it directly
                return self.source.eventLoop.makeSucceededFuture(conn)
            } else {
                // connection is closed, we need to replace it
                return self.source.makeConnection()
            }
        } else if self.activeConnections < config.maxConnections  {
            // all connections are busy, but we have room to open a new connection!
            self.activeConnections += 1
            
            // make the new connection
            return self.source.makeConnection()
        } else {
            // connections are exhausted, we must wait for one to be returned
            let promise = self.source.eventLoop.makePromise(of: Source.Connection.self)
            self.waiters.append(promise)
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
        // get the active connection for this connection
        self.available.append(conn)
        
        // now that we know a new connection is available, we should
        // take this chance to fulfill one of the waiters
        if let waiter = self.waiters.popLast() {
            self.requestConnection().cascade(to: waiter)
        }
    }
}
