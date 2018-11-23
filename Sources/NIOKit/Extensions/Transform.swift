import NIO

extension EventLoopFuture {
    /// Maps the current future to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
    ///
    ///     user.save(on: req).transform(to: HTTPStatus.created)
    ///
    public func transform<T>(to instance: T) -> EventLoopFuture<T> {
        return self.map { _ in
            instance
        }
    }
    
    /// Maps the current future to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
    ///
    ///     let user = User.find(id, on: request)
    ///     posts.save(on: request).transform(to: user)
    ///
    public func transform<T>(to future: EventLoopFuture<T>) -> EventLoopFuture<T> {
        return self.then { _ in
            future
        }
    }
}

/// Maps the current futures to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
///
///     transform(futureA, futureB, to: HTTPStatus.created)
///
public func transform<A, B, Result>(
    _ futureA: EventLoopFuture<A>,
    _ futureB: EventLoopFuture<B>,
    to instance: Result) -> EventLoopFuture<Result>
{
    return futureA.and(futureB).map { _  in
        instance
    }
}

/// Maps the futures to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
///
///     let user = User.find(id, on: request)
///     transform(futureA, futureB, to: user)
///
public func transform<A, B, Result>(
    _ futureA: EventLoopFuture<A>,
    _ futureB: EventLoopFuture<B>,
    to future: EventLoopFuture<Result>) -> EventLoopFuture<Result>
{
    return futureA.and(futureB).then { _ in
        future
    }
}

/// Maps the current futures to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
///
///     transform(futureA, futureB, futureC, to: HTTPStatus.created)
///
public func transform<A, B, C, Result>(
    _ futureA: EventLoopFuture<A>,
    _ futureB: EventLoopFuture<B>,
    _ futureC: EventLoopFuture<C>,
    to instance: Result) -> EventLoopFuture<Result>
{
    return futureA.and(futureB).and(futureC).map { _  in
        instance
    }
}

/// Maps the futures to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
///
///     let user = User.find(id, on: request)
///     transform(futureA, futureB, futureC, to: user)
///
public func transform<A, B, C, Result>(
    _ futureA: EventLoopFuture<A>,
    _ futureB: EventLoopFuture<B>,
    _ futureC: EventLoopFuture<C>,
    to future: EventLoopFuture<Result>) -> EventLoopFuture<Result>
{
    return futureA.and(futureB).and(futureC).then { _  in
        future
    }
}

/// Maps the current futures to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
///
///     transform(futureA, futureB, futureC, futureD, to: HTTPStatus.created)
///
public func transform<A, B, C, D, Result>(
    _ futureA: EventLoopFuture<A>,
    _ futureB: EventLoopFuture<B>,
    _ futureC: EventLoopFuture<C>,
    _ futureD: EventLoopFuture<D>,
    to instance: Result) -> EventLoopFuture<Result>
{
    return futureA.and(futureB).and(futureC).and(futureD).map { _  in
        instance
    }
}

/// Maps the futures to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
///
///     let user = User.find(id, on: request)
///     transform(futureA, futureB, futureC, futureD, to: user)
///
public func transform<A, B, C, D, Result>(
    _ futureA: EventLoopFuture<A>,
    _ futureB: EventLoopFuture<B>,
    _ futureC: EventLoopFuture<C>,
    _ futureD: EventLoopFuture<D>,
    to future: EventLoopFuture<Result>) -> EventLoopFuture<Result>
{
    return futureA.and(futureB).and(futureC).and(futureD).then { _  in
        future
    }
}

/// Maps the current futures to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
///
///     transform(futureA, futureB, futureC, futureD, futureE, to: HTTPStatus.created)
///
public func transform<A, B, C, D, E, Result>(
    _ futureA: EventLoopFuture<A>,
    _ futureB: EventLoopFuture<B>,
    _ futureC: EventLoopFuture<C>,
    _ futureD: EventLoopFuture<D>,
    _ futureE: EventLoopFuture<E>,
    to instance: Result) -> EventLoopFuture<Result>
{
    return futureA.and(futureB).and(futureC).and(futureD).and(futureE).map { _  in
        instance
    }
}

/// Maps the futures to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
///
///     let user = User.find(id, on: request)
///     transform(futureA, futureB, futureC, futureD, futureE, to: user)
///
public func transform<A, B, C, D, E, Result>(
    _ futureA: EventLoopFuture<A>,
    _ futureB: EventLoopFuture<B>,
    _ futureC: EventLoopFuture<C>,
    _ futureD: EventLoopFuture<D>,
    _ futureE: EventLoopFuture<E>,
    to future: EventLoopFuture<Result>) -> EventLoopFuture<Result>
{
    return futureA.and(futureB).and(futureC).and(futureD).and(futureE).then { _  in
        future
    }
}
