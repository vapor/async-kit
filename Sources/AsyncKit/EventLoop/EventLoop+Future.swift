import NIO

extension EventLoopGroup {
    
    /// Creates a new, succeeded `Future` from the worker's event loop with a `Void` value.
    ///
    ///    let a: Future<Void> = req.future()
    ///
    /// - Returns: The succeeded future.
    public func future() -> EventLoopFuture<Void> {
        return self.next().makeSucceededFuture(())
    }
    
    /// Creates a new, succeeded `Future` from the worker's event loop.
    ///
    ///    let a: Future<String> = req.future("hello")
    ///
    /// - Parameter value: The value that the future will wrap.
    /// - Returns: The succeeded future.
    public func future<T>(_ value: T) -> EventLoopFuture<T> {
        return self.next().makeSucceededFuture(value)
    }
    
    /// Creates a new, failed `Future` from the worker's event loop.
    ///
    ///    let b: Future<String> = req.future(error: Abort(...))
    ///
    /// - Parameter error: The error that the future will wrap.
    /// - Returns: The failed future.
    public func future<T>(error: Error) -> EventLoopFuture<T> {
        return self.next().makeFailedFuture(error)
    }
}
