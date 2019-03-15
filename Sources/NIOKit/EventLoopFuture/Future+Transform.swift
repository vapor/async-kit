import NIO

extension EventLoopFuture {
    /// Maps the current future to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
    ///
    ///     user.save(on: req).transform(to: HTTPStatus.created)
    ///
    public func transform<T>(to instance: @escaping @autoclosure () -> T) -> EventLoopFuture<T> {
        return self.map { _ in
            instance()
        }
    }
    
    /// Maps the current future to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
    ///
    ///     let user = User.find(id, on: request)
    ///     posts.save(on: request).transform(to: user)
    ///
    public func transform<T>(to future: EventLoopFuture<T>) -> EventLoopFuture<T> {
        return self.flatMap { _ in
            future
        }
    }
}
