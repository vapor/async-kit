import NIO

extension EventLoopGroup {
    /// Creates a new, succeeded `EventLoopFuture` from the worker's event loop with a `Void` value.
    ///
    ///    let a: EventLoopFuture<Void> = req.future()
    ///
    /// - Returns: The succeeded future.
    public func future() -> EventLoopFuture<Void> {
        return self.next().makeSucceededFuture(())
    }
    
    /// Creates a new, succeeded `EventLoopFuture` from the worker's event loop.
    ///
    ///    let a: EventLoopFuture<String> = req.future("hello")
    ///
    /// - Parameter value: The value that the future will wrap.
    /// - Returns: The succeeded future.
    public func future<T>(_ value: T) -> EventLoopFuture<T> {
        return self.next().makeSucceededFuture(value)
    }
    
    /// Creates a new, failed `EventLoopFuture` from the worker's event loop.
    ///
    ///    let b: EvenLoopFuture<String> = req.future(error: Abort(...))
    ///
    /// - Parameter error: The error that the future will wrap.
    /// - Returns: The failed future.
    public func future<T>(error: Error) -> EventLoopFuture<T> {
        return self.next().makeFailedFuture(error)
    }
}
