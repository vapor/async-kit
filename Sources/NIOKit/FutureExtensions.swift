// MARK: - Guard

public extension EventLoopFuture {
    /// Guards that the future's value satisfies the callback's condition or fails with the given error.
    func `guard`(_ callback: @escaping ((Value) -> Bool), else error: @escaping @autoclosure () -> Error) -> EventLoopFuture<Value> {
        let promise = eventLoop.makePromise(of: Value.self)
        whenComplete { result in
            switch result {
            case .success(let value):
                if callback(value) { promise.succeed(value) }
                else { promise.fail(error()) }
            case .failure(let error): promise.fail(error)
            }
        }
        return promise.futureResult
    }
}
