#if compiler(>=5.5) && canImport(_Concurrency)
import NIOCore

extension EventLoopGroup {
    /// Run the `async` function `body` on an event loop in this group and return its
    /// result as an `EventLoopFuture`.
    ///
    /// This function can be used to bridge the `async` world into an `EventLoopGroup`.
    ///
    /// See also ``EventLoop.performWithTask(_:)``, ``EventLoopPromise.completeWithTask(_:)``
    ///
    /// - parameters:
    ///   - body: The `async` function to run.
    /// - returns: An `EventLoopFuture` which is completed when `body` finishes. On
    ///   success the future has the result returned by `body`; if `body` throws an
    ///   error, the future is failed with that error.
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    @inlinable
    public func performWithTask<Value>(
        _ body: @escaping @Sendable () async throws -> Value
    ) -> EventLoopFuture<Value> {
        return self.next().performWithTask(body)
    }
}
#endif
