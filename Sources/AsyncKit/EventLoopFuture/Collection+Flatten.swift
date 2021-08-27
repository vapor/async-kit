import NIO

extension Collection {
    /// Converts a collection of `EventLoopFuture`s to an `EventLoopFuture` that wraps an array with the future values.
    ///
    /// Acts as a helper for the `EventLoop.flatten(_:[EventLoopFuture<Value>])` method.
    ///
    ///     let futures = [el.future(1), el.future(2), el.future(3), el.future(4)]
    ///     let flattened = futures.flatten(on: el)
    ///     // flattened: EventLoopFuture([1, 2, 3, 4])
    ///
    /// - parameter eventLoop: The event-loop to succeed the futures on.
    /// - returns: The succeeded values in an array, wrapped in an `EventLoopFuture`.
    public func flatten<Value>(on eventLoop: EventLoop) -> EventLoopFuture<[Value]>
        where Element == EventLoopFuture<Value>
    {
        return eventLoop.flatten(Array(self))
    }
}

extension Array where Element == EventLoopFuture<Void> {
    /// Converts a collection of `EventLoopFuture<Void>`s to an `EventLoopFuture<Void>`.
    ///
    /// Acts as a helper for the `EventLoop.flatten(_:[EventLoopFuture<Value>])` method.
    ///
    ///     let futures = [el.future(1), el.future(2), el.future(3), el.future(4)]
    ///     let flattened = futures.flatten(on: el)
    ///     // flattened: EventLoopFuture<Void>
    ///
    /// - parameter eventLoop: The event-loop to succeed the futures on.
    /// - returns: The succeeded future.
    public func flatten(on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        return .andAllSucceed(self, on: eventLoop)
    }
}

extension Collection {
    /// Strictly sequentially transforms each element of the collection into an
    /// `EventLoopFuture`, collects the results of each future, and returns the
    /// overall result. Identical to `EventLoopFuture.sequencedFlatMapEach(_:)`,
    /// but does not require the initial collection to be wrapped by a future.
    public func sequencedFlatMapEach<Result>(
        on eventLoop: EventLoop,
        _ transform: @escaping (_ element: Element) -> EventLoopFuture<Result>
    ) -> EventLoopFuture<[Result]> {
        return self.reduce(eventLoop.future([])) { fut, elem in fut.flatMap { res in transform(elem).map { res + [$0] } } }
    }

    /// An overload of `sequencedFlatMapEach(on:_:)` which returns a `Void` future instead
    /// of `[Void]` when the result type of the transform closure is `Void`.
    public func sequencedFlatMapEach(
        on eventLoop: EventLoop,
        _ transform: @escaping (_ element: Element) -> EventLoopFuture<Void>
    ) -> EventLoopFuture<Void> {
        return self.reduce(eventLoop.future()) { fut, elem in fut.flatMap { transform(elem) } }
    }

    /// Variant of `sequencedFlatMapEach(on:_:)` which provides `compactMap()` semantics
    /// by allowing result values to be `nil`. Such results are not included in the
    /// output array.
    public func sequencedFlatMapEachCompact<Result>(
        on eventLoop: EventLoop,
        _ transform: @escaping (_ element: Element) -> EventLoopFuture<Result?>
    ) -> EventLoopFuture<[Result]> {
        return self.reduce(eventLoop.future([])) { fut, elem in fut.flatMap { res in transform(elem).map { res + [$0].compactMap { $0 } } } }
    }
}
