/// Errors thrown by ``EventLoopGroupConnectionPool`` and ``EventLoopConnectionPool`` regarding state.
public enum ConnectionPoolError: Error {
    /// The connection pool has shutdown.
    case shutdown
}

/// Errors thrown by ``EventLoopGroupConnectionPool`` and ``EventLoopConnectionPool`` regarding timeouts.
public enum ConnectionPoolTimeoutError: Error {
    /// The connection request timed out.
    case connectionRequestTimeout
}
