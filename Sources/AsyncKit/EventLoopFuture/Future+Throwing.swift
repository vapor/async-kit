import NIO

extension EventLoopGroup {
    /// An alternate name for this would be `future(catching:)`, but with that
    /// name, trailing closure syntax just looks like `el.future { ... }`, which
    /// does not indicate to readers of the code that it is the error-capturing
    /// version. Since such an indication is highly desirable, a slightly less
    /// idiomatic name is used instead.
    ///
    /// This method replaces this code:
    ///
    /// ```swift
    /// return something.eventLoop.future().flatMapThrowing {
    /// ```
    ///
    /// With this code:
    ///
    /// ```swift
    /// return something.eventLoop.tryFuture {
    /// ```
    ///
    /// That's pretty much it. It's sugar.
    ///
    /// - Parameter work: The potentially throwing closure to execute as a
    ///   future. If the closure throws, a failed future is returned.
    public func tryFuture<T>(_ work: @escaping () throws -> T) -> EventLoopFuture<T> {
        return self.next().submit(work)
    }
    
#if compiler(>=5.5) && canImport(_Concurrency)
    /// Performs an async work and returns the result in form of an `EventLoopFuture`.
    ///
    /// - Parameter work: The async, potentially throwing closure to execute as a
    ///   future. If the closure throws, a failed future is returned.
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    public func performWithTask<T>(
        _ work: @escaping @Sendable () async throws -> T
    ) -> EventLoopFuture<T> {
        let promise = self.next().makePromise(of: T.self)
        promise.completeWithTask(work)
        return promise.futureResult
    }
#endif
}

