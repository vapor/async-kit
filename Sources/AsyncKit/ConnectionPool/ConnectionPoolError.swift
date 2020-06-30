/// Errors thrown by `ConnectionPool`.
public enum ConnectionPoolError: Error {
    /// The connection pool has shutdown.
    case shutdown
}

public enum ConnectionPoolTimeoutError: Error {
    /// The connection request timed out.
    case connectionRequestTimeout
}
