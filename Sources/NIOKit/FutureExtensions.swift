// MARK: - Guard

public extension EventLoopFuture {
	/// Guards that the future's value satisfies the callback's condition or fails with the given error.
	func `guard`(_ callback: @escaping ((Value) -> Bool), else error: Error) -> EventLoopFuture<Value> {
		let promise = eventLoop.makePromise(of: Value.self)
		whenSuccess {
			if callback($0) { promise.succeed($0) } else { promise.fail(error) }
		}
		whenFailure { promise.fail($0) }
		return promise.futureResult
	}
}
