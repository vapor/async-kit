import NIO

extension EventLoopFuture {
    func addAwaitier(callback: @escaping (Result<T, Error>) -> ()) {
        self.whenSuccess { callback(.success($0)) }
        self.whenFailure { callback(.failure($0)) }
    }
}
