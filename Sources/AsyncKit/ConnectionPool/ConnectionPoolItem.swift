import NIOCore

/// Item managed by a connection pool.
public protocol ConnectionPoolItem: AnyObject {
    /// EventLoop this connection belongs to.
    var eventLoop: EventLoop { get }
    
    /// If `true`, this connection has closed.
    var isClosed: Bool { get }
    
    /// Closes this connection.
    func close() -> EventLoopFuture<Void>
}
