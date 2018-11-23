import NIO

extension EventLoopFuture {
    /// Maps the current future to contain the new type. Errors are carried over, successful (expected) results are transformed into the given instance.
    ///
    ///     user.save(on: req).transform(to: HTTPStatus.created)
    ///
    public func transform<T>(to instance: T) -> EventLoopFuture<T> {
        return self.map { _ -> T in
            instance
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
    return futureA.and(futureB).map { _ -> Result in
        instance
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
    return futureA.and(futureB).and(futureC).map { _ -> Result in
        instance
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
    return futureA.and(futureB).and(futureC).and(futureD).map { _ -> Result in
        instance
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
    return futureA.and(futureB).and(futureC).and(futureD).and(futureE).map { _ -> Result in
        instance
    }
}
