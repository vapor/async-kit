import NIOCore
import struct Logging.Logger

/// Source of new connections for `ConnectionPool`.
public protocol ConnectionPoolSource {
    /// Associated `ConnectionPoolItem` that will be returned by `makeConnection()`.
    associatedtype Connection: ConnectionPoolItem
    
    /// Creates a new connection.
    func makeConnection(logger: Logger, on eventLoop: EventLoop) -> EventLoopFuture<Connection>
}
