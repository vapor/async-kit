#if compiler(>=5.5) && canImport(_Concurrency)
import NIOCore

extension EventLoop {
    /// Run the `async` function `body` on this event loop and return its result as
    /// an `EventLoopFuture`.
    ///
    /// This function can be used to bridge the `async` world into an `EventLoop`.
    ///
    /// See also ``EventLoopPromise.completeWithTask(_:)``
    ///
    /// - parameters:
    ///   - body: The `async` function to run.
    /// - returns: An `EventLoopFuture` which is completed when `body` finishes. On
    ///   success the future has the result returned by `body`; if `body` throws an
    ///   error, the future is failed with that error.
    @available(macOS 10.15, iOS 15, watchOS 8, tvOS 15, *)
    @inlinable
    public func performWithTask<Value>(
        _ body: @escaping @Sendable () async throws -> Value
    ) -> EventLoopFuture<Value> {
        let promise = self.makePromise(of: Value.self)
        
        promise.completeWithTask(body)
        return promise.futureResult
    }
}
#endif
