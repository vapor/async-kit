import NIOCore

extension EventLoopFuture {
    // MARK: - Guard
    
    /// Guards that the future's value satisfies the callback's condition or
    /// fails with the given error.
    ///
    ///
    /// Example usage:
    ///
    ///     future.guard({ $0.userID == user.id }, else: AccessError.unauthorized)
    ///
    /// - parameters:
    ///   - callback: Callback that asynchronously executes a condition.
    ///   - error: The error to fail with if condition isn't met.
    /// - returns: A future containing the original future's result.
    public func `guard`(_ callback: @escaping ((Value) -> Bool), else error: @escaping @autoclosure () -> Error) -> EventLoopFuture<Value> {
        let promise = self.eventLoop.makePromise(of: Value.self)
        self.whenComplete { result in
            switch result {
            case .success(let value):
                if callback(value) {
                    promise.succeed(value)
                } else {
                    promise.fail(error())
                }
            case .failure(let error): promise.fail(error)
            }
        }
        return promise.futureResult
    }

    // MARK: - flatMapAlways
    
    /// When the current `EventLoopFuture` receives any result, run the provided callback, which will provide a new
    /// `EventLoopFuture`. Essentially combines the behaviors of `.always(_:)` and `.flatMap(file:line:_:)`.
    ///
    /// This is useful when some work must be done for both success and failure states, especially work that requires
    /// temporarily extending the lifetime of one or more objects.
    public func flatMapAlways<NewValue>(
        file: StaticString = #file, line: UInt = #line,
        _ callback: @escaping (Result<Value, Error>) -> EventLoopFuture<NewValue>
    ) -> EventLoopFuture<NewValue> {
        let promise = self.eventLoop.makePromise(of: NewValue.self, file: file, line: line)
        self.whenComplete { result in callback(result).cascade(to: promise) }
        return promise.futureResult
    }
}
