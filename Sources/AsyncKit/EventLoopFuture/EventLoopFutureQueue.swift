import NIO

public final class EventLoopFutureQueue {
    public enum Continue {
        case success
        case failure
        case complete
    }

    public enum ContinueError: Error {
        case previousError(Error)
        case previousSuccess
    }

    public let eventLoop: EventLoop
    public var future: EventLoopFuture<Void> { self.current }

    private var current: EventLoopFuture<Void>

    public init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.current = eventLoop.makeSucceededFuture(())
    }

    public func append<Value>(generator: @escaping () -> EventLoopFuture<Value>, runningOn next: Continue = .complete) -> EventLoopFuture<Value> {
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
