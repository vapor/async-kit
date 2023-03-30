import NIO

extension EventLoopGroup {
    /// Creates a new, succeeded `EventLoopFuture` from the worker's event loop with a `Void` value.
    ///
    ///    let a: EventLoopFuture<Void> = req.future()
    ///
    /// - Returns: The succeeded future.
    public func future() -> EventLoopFuture<Void> {
        return self.any().makeSucceededFuture(())
    }
    
    /// Creates a new, succeeded `EventLoopFuture` from the worker's event loop.
    ///
    ///    let a: EventLoopFuture<String> = req.future("hello")
    ///
    /// - Parameter value: The value that the future will wrap.
    /// - Returns: The succeeded future.
    public func future<T>(_ value: T) -> EventLoopFuture<T> {
        return self.any().makeSucceededFuture(value)
    }
    
    /// Creates a new, failed `EventLoopFuture` from the worker's event loop.
    ///
    ///    let b: EvenLoopFuture<String> = req.future(error: Abort(...))
    ///
    /// - Parameter error: The error that the future will wrap.
    /// - Returns: The failed future.
    public func future<T>(error: Error) -> EventLoopFuture<T> {
        return self.any().makeFailedFuture(error)
    }
    
    /// Creates a new `Future` from the worker's event loop, succeeded or failed based on the input `Result`.
    ///
    ///     let a: EventLoopFuture<String> = req.future(.success("hello"))
    ///     let b: EventLoopFuture<String> = req.future(.failed(Abort(.imATeapot))
    ///
    /// - Parameter result: The result that the future will wrap.
    /// - Returns: The succeeded or failed future.
    public func future<T>(result: Result<T, Error>) -> EventLoopFuture<T> {
        let promise: EventLoopPromise<T> = self.any().makePromise()
        promise.completeWith(result)
        return promise.futureResult
    }
}
