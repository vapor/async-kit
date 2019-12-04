import struct Logging.Logger

/// Source of new connections for `ConnectionPool`.
public protocol ConnectionPoolSource {
    /// Associated `ConnectionPoolItem` that will be returned by `makeConnection()`.
    associatedtype Connection: ConnectionPoolItem
    
    /// Creates a new connection.
    func makeConnection(logger: Logger, on eventLoop: EventLoop) -> EventLoopFuture<Connection>
}

/// A wrapper around the `Source` instance for an `EventLoopConnectionPool` that allows the client to access public properties from the `Source` instance.
///
///     connectionPool.sourceInfo.someProperty
@dynamicMemberLookup
public struct SourceInformation<Source> {
    private let source: Source

    /// Creates a new instance of `SourceInformation` that wraps a given `Source` instance.
    ///
    /// - Parameter source: The `Source` instance that can be accessed.
    public init(source: Source) {
        self.source = source
    }

    /// Required by `@dynamicMemberLookup`.
    ///
    /// Allows you to use dot syntax to get public `Source` properties from the `SourceInformation` instance.
    ///
    /// - Parameter keyPath: The `KeyPath` to the `Source` property you want to access.
    ///
    /// - Returns: The value of the property referanced by the `KeyPath` passed in.
    public subscript <Property>(dynamicMember keyPath: KeyPath<Source, Property>) -> Property {
        return self.source[keyPath: keyPath]
    }
}
