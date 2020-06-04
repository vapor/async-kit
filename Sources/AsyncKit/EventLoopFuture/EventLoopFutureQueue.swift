import NIO

/// Allows you to queue closures that produce an `EventLoopFuture`, so each future only gets run if the previous ones complete, succeed, or fail.
public final class EventLoopFutureQueue {

    /// Under what conditions an appended closure should be run.
    public enum ContinueCondition {

        /// Run closure on the previous future's success.
        case success

        /// Run closure on the previous future's failure.
        case failure

        /// Run closure on the previous future's completion.
        case complete
    }

    /// Errors that get propogated based on a future's completion status and the next appended closure's continuation condition.
    public enum ContinueError: Error, CustomStringConvertible {

        /// A previous future failed with an error, which we don't desire.
        case previousError(Error)

        /// A previous future succeeded, which we don't desire.
        case previousSuccess

        /// A textual representation of the error.
        ///
        /// In the case of a `.previousError` case, the result will be flattened to a single `.previousError(error)`,
        /// instead of being nested _n_ cases deep `.previousError(.previousError(.previousError(error)))`.
        public var description: String {
            switch self {
            case .previousSuccess: return "previousSuccess"
            case let .previousError(error):
                if let sub = error as? ContinueError {
                    return sub.description
                } else {
                    return "previousError(\(error))"
                }
            }
        }
    }

    /// The event loop that all the futures's completions are handled on.
    public let eventLoop: EventLoop
    
    /// The current waiter future.
    private var current: EventLoopFuture<Void>

    /// Create a new `EventLoopFutureQueue` on a given event loop.
    ///
    /// - Parameter eventLoop: The event loop that all the futures's completions are handled on.
    public init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.current = eventLoop.makeSucceededFuture(())
    }

    /// Adds another `EventLoopFuture` producing closure to be run as soon as all previously queued future have completed, succeeded, or failed.
    ///
    ///     let model: EventLoopFuture<Model> = queue.append(generator: { Model.query(on: database).first() })
    ///
    /// - Parameters:
    ///   - next: The condition that the previous future(s) must meet on thier completion for the appended future to be run.
    ///     The default value is `.complete`.
    ///   - generator: The closure that produces the `EventLoopFuture`. We need a closure because otherwise the
    ///     future starts running right away and the queuing doesn't do you any good.
    ///
    /// - Returns: The resulting future from the `generator` closure passed in.
    public func append<Value>(
        onPrevious next: ContinueCondition = .complete,
        generator: @escaping () -> EventLoopFuture<Value>
    ) -> EventLoopFuture<Value> {
        return self.eventLoop.flatSubmit {
            let promise = self.eventLoop.makePromise(of: Void.self)

            switch next {
            case .success:
                self.current.whenComplete { result in
                    switch result {
                    case .success: promise.succeed(())
                    case let .failure(error): promise.fail(ContinueError.previousError(error))
                    }
                }
            case .failure:
                self.current.whenComplete { result in
                    switch result {
                    case .success: promise.fail(ContinueError.previousSuccess)
                    case .failure: promise.succeed(())
                    }
                }
            case .complete:
                self.current.whenComplete { _ in promise.succeed(()) }
            }

            let next = promise.futureResult.flatMap { generator() }
            self.current = next.map { _ in () }
            return next
        }
    }

    /// An overload for `append(generator:runningOn:)` that takes in an `EventLoopFuture` as an auto closure to provide a better 1-liner API.
    ///
    ///     let model: EventLoopFuture<Model> = queue.append(Model.query(on: database).first())
    ///
    /// - Parameters:
    ///   - generator: The statement that will produce an `EventLoopFuture`.
    ///     This will automatically get wrapped in a closure.
    ///   - next: The condition that the previous future(s) must meet on their completion for the appended future to be run.
    ///     The default value is `.complete`.
    ///
    /// - Returns: The future passed into the `generator` parameter.
    public func append<Value>(
        _ generator: @autoclosure @escaping () -> EventLoopFuture<Value>,
        runningOn next: ContinueCondition = .complete
    ) -> EventLoopFuture<Value> {
        self.append(onPrevious: next, generator: generator)
    }
}
