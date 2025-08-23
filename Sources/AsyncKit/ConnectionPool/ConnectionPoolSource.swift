import NIOCore
import struct Logging.Logger

/// Source of new connections for ``EventLoopGroupConnectionPool``.
public protocol ConnectionPoolSource {
    /// Associated ``ConnectionPoolItem`` that will be returned by ``ConnectionPoolSource/makeConnection(logger:on:)``.
    associatedtype Connection: ConnectionPoolItem

    /// Creates a new connection.
    func makeConnection(logger: Logger, on eventLoop: any EventLoop) -> EventLoopFuture<Connection>
}
