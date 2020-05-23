/// Errors thrown by `ConnectionPool`.
public enum ConnectionPoolError: Error {
    /// The connection pool has shutdown.
    case shutdown
    /// The connection creationg timed out.
    case connectionCreateTimeout
}
