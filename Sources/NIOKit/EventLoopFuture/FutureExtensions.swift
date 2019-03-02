public extension EventLoopFuture {
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
    func `guard`(_ callback: @escaping ((Value) -> Bool), else error: @escaping @autoclosure () -> Error) -> EventLoopFuture<Value> {
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
}
