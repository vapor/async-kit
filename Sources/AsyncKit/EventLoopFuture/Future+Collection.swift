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
    
    /// Calls a closure, which returns an `Optional`, on each element in the sequence that is wrapped by an `EventLoopFuture`.
    ///
    ///     let collection = eventLoop.future(["one", "2", "3", "4", "five", "^", "7"])
    ///     let times2 = collection.mapEachCompact { int in
    ///         return Int(int)
    ///     }
    ///     // times2: EventLoopFuture([2, 3, 4, 7])
    ///
    /// - parameters:
    ///   - transform: The closure that each element in the sequence is passed into.
    ///   - element: The element from the sequence that you can operate on.
    /// - returns: A new `EventLoopFuture` that wraps that sequence of transformed elements.
    public func mapEachCompact<Result>(
        _ transform: @escaping (_ element: Value.Element) -> Result?
    ) -> EventLoopFuture<[Result]> {
        return self.map { sequence -> [Result] in
            return sequence.compactMap(transform)
        }
    }
    
    /// Calls a closure, which returns an `EventLoopFuture`, on each element
    /// in a sequence that is wrapped by an `EventLoopFuture`.
    ///
    ///     let users = eventLoop.future([User(name: "Tanner", ...), ...])
    ///     let saved = users.flatMapEach(on: eventLoop) { $0.save(on: database) }
    ///
    /// - parameters:
    ///   - eventLoop: The `EventLoop` to flatten the resulting array of futures on.
    ///   - transform: The closure that each element in the sequence is passed into.
    ///   - element: The element from the sequence that you can operate on.
    /// - returns: A new `EventLoopFuture` that wraps the results
    ///   of all the `EventLoopFuture`s returned from the closure.
    public func flatMapEach<Result>(
        on eventLoop: EventLoop,
        _ transform: @escaping (_ element: Value.Element) -> EventLoopFuture<Result>
    ) -> EventLoopFuture<[Result]> {
        self.flatMap { .reduce(into: [], $0.map(transform), on: eventLoop) { $0.append($1) } }
    }

    /// Calls a closure, which returns an `EventLoopFuture`, on each element
    /// in a sequence that is wrapped by an `EventLoopFuture`. No results from
    /// each future are expected.
    ///
    ///     let users = eventLoop.future([User(name: "Tanner", ...), ...])
    ///     let saved = users.flatMapEach(on: eventLoop) { $0.save(on: database) }
    ///
    /// - parameters:
    ///   - eventLoop: The `EventLoop` to flatten the resulting array of futures on.
    ///   - transform: The closure that each element in the sequence is passed into.
    ///   - element: The element from the sequence that you can operate on.
    /// - returns: A new `EventLoopFuture` that completes when all the returned
    ///   `EVentLoopFuture`s do.
    public func flatMapEach(
        on eventLoop: EventLoop,
        _ transform: @escaping (_ element: Value.Element) -> EventLoopFuture<Void>
    ) -> EventLoopFuture<Void> {
        self.flatMap { .andAllSucceed($0.map(transform), on: eventLoop) }
    }

    /// Calls a closure, which returns an `EventLoopFuture<Optional>`, on each element
    /// in a sequence that is wrapped by an `EventLoopFuture`.
    ///
    ///     let users = eventLoop.future([User(name: "Tanner", ...), ...])
    ///     let pets = users.flatMapEach(on: eventLoop) { $0.favoritePet(on: database) }
    ///
    /// - parameters:
    ///   - eventLoop: The `EventLoop` to flatten the resulting array of futures on.
    ///   - transform: The closure that each element in the sequence is passed into.
    ///   - element: The element from the sequence that you can operate on.
    /// - returns: A new `EventLoopFuture` that wraps the non-nil results
    ///   of all the `EventLoopFuture`s returned from the closure.
    public func flatMapEachCompact<Result>(
        on eventLoop: EventLoop,
        _ transform: @escaping (_ element: Value.Element) -> EventLoopFuture<Result?>
    ) -> EventLoopFuture<[Result]> {
        self.flatMap { .reduce(into: [], $0.map(transform), on: eventLoop) { res, elem in elem.map { res.append($0) } } }
    }

    /// Calls a closure on each element in the sequence that is wrapped by an `EventLoopFuture`.
    ///
    ///     let collection = eventLoop.future([1, 2, 3, 4, 5, 6, 7, 8, 9])
    ///     let times2 = collection.flatMapEachThrowing { int in
    ///         guard int < 10 else { throw RangeError.oops }
    ///         return int * 2
    ///     }
    ///     // times2: EventLoopFuture([2, 4, 6, 8, 10, 12, 14, 16, 18])
    ///
    /// If your callback function throws, the returned `EventLoopFuture` will error.
    ///
    /// - parameters:
    ///   - transform: The closure that each element in the sequence is passed into.
    ///   - element: The element from the sequence that you can operate on.
    /// - returns: A new `EventLoopFuture` that wraps that sequence of transformed elements.
    public func flatMapEachThrowing<Result>(_ transform: @escaping (_ element: Value.Element) throws -> Result) -> EventLoopFuture<[Result]> {
        return self.flatMapThrowing { sequence -> [Result] in
            return try sequence.map(transform)
        }
    }

    /// Calls a closure, which returns an `Optional`, on each element in the sequence that is wrapped by an `EventLoopFuture`.
    ///
    ///     let collection = eventLoop.future(["one", "2", "3", "4", "five", "^", "7"])
    ///     let times2 = collection.mapEachCompact { int in
    ///         return Int(int)
    ///     }
    ///     // times2: EventLoopFuture([2, 3, 4, 7])
    ///
    /// If your callback function throws, the returned `EventLoopFuture` will error.
    ///
    /// - parameters:
    ///   - transform: The closure that each element in the sequence is passed into.
    ///   - element: The element from the sequence that you can operate on.
    /// - returns: A new `EventLoopFuture` that wraps that sequence of transformed elements.
    public func flatMapEachCompactThrowing<Result>(
        _ transform: @escaping (_ element: Value.Element) throws -> Result?
    ) -> EventLoopFuture<[Result]> {
        return self.flatMapThrowing { sequence -> [Result] in
            return try sequence.compactMap(transform)
        }
    }

    /// A variant form of `flatMapEach(on:_:)` which guarantees:
    ///
    /// 1) Explicitly sequential execution of each future returned by the mapping
    ///    closure; the next future does not being executing until the previous one
    ///    has yielded a success result.
    ///
    /// 2) No further futures will be even partially executed if any one future
    ///    returns a failure result.
    ///
    /// Neither of these are provided by the original version of the method.
    public func sequencedFlatMapEach<Result>(_ transform: @escaping (_ element: Value.Element) -> EventLoopFuture<Result>) -> EventLoopFuture<[Result]> {
        var results: [Result] = []
        
        return self.flatMap {
            $0.reduce(self.eventLoop.future()) { fut, elem in
                fut.flatMap { transform(elem).map { results.append($0) } }
            }
        }.transform(to: results)
    }

    /// An overload of `sequencedFlatMapEach(_:)` which returns a `Void` future instead
    /// of `[Void]` when the result type of the transform closure is `Void`.
    public func sequencedFlatMapEach(_ transform: @escaping (_ element: Value.Element) -> EventLoopFuture<Void>) -> EventLoopFuture<Void> {
        return self.flatMap {
            $0.reduce(self.eventLoop.future()) { fut, elem in
                fut.flatMap { transform(elem) }
            }
        }
    }

    /// Variant of `sequencedFlatMapEach(_:)` which provides `compactMap()` semantics
    /// by allowing result values to be `nil`. Such results are not included in the
    /// output array.
    public func sequencedFlatMapEachCompact<Result>(_ transform: @escaping (_ element: Value.Element) -> EventLoopFuture<Result?>) -> EventLoopFuture<[Result]> {
        var results: [Result] = []
        
        return self.flatMap {
            $0.reduce(self.eventLoop.future()) { fut, elem in
                fut.flatMap { transform(elem).map {
                    $0.map { results.append($0) }
                } }
            }
        }.transform(to: results)
    }
    
}
