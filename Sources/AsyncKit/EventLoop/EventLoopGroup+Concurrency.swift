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
    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    @available(*, deprecated, renamed: "makeFutureWithTask(_:)")
    @inlinable
    public func performWithTask<Value>(
        _ body: @escaping @Sendable () async throws -> Value
    ) -> EventLoopFuture<Value> {
        return self.makeFutureWithTask(body)
    }
    
    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    @inlinable
    public func makeFutureWithTask<Value>(
        _ body: @escaping @Sendable () async throws -> Value
    ) -> EventLoopFuture<Value> {
        return self.any().makeFutureWithTask(body)
    }
}
