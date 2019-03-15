import NIO

extension EventLoopFuture where Value: Sequence {
    
    /// Calls a closure on each element in the sequence that is wrapped by an `EventLoopFuture`.
    ///
    ///     let collection = eventLoop.future([1, 2, 3, 4, 5, 6, 7, 8, 9])
    ///     let times2 = collection.mapEach { int in
    ///         return int * 2
    ///     }
    ///     // times2: EventLoopFuture([2, 4, 6, 8, 10, 12, 14, 16, 18])
    ///
    /// - parameters:
    ///   - transform: The closure that each element in the sequence is passed into.
    ///   - element: The element from the sequence that you can operate on.
    /// - returns: A new `EventLoopFuture` that wraps that sequence of transformed elements.
    public func mapEach<Result>(_ transform: @escaping (_ element: Value.Element) -> Result) -> EventLoopFuture<[Result]> {
        return self.map { sequence -> [Result] in
            return sequence.map(transform)
        }
    }
    
    /// Calls a closure which returns an `EventLoopFuture` on each element
    /// in a sequence that is wrapped by an `EventLoopFuture`.
    ///
    ///     let users = [User(name: "Tanner", ...), ...]
    ///     let saved = users.flatMapEach(on: eventLoop) { $0.save(on: database) }
    ///
    /// - parameters:
    ///   - eventLoop: The `EventLoop` to flatten the resulting array of futures on.
    ///   - transform: The closure that each element in the sequence is passed into.
    ///   - element: The element from the sequence that you can operate on.
    /// - returns: A new `EventLoopFuture` that wrapps the results
    ///   of all the `EventLoopFuture`s returned from the closure.
    public func flatMapEach<Result>(
        on eventLoop: EventLoop,
        _ transform: @escaping (_ element: Value.Element) -> EventLoopFuture<Result>
    ) -> EventLoopFuture<[Result]> {
        return self.flatMap { sequence -> EventLoopFuture<[Result]> in
            return sequence.map(transform).flatten(on: eventLoop)
        }
    }
}
