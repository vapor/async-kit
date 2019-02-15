import NIO

extension EventLoopFuture where Value: Sequence {
    
    /// Calls a closure on each element in the sequence that an `EventLoopFuture` wraps.
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
    func mapEach<Result>(_ transform: @escaping (_ element: Value.Element) -> Result) -> EventLoopFuture<[Result]> {
        return self.map { collection in
            return collection.map(transform)
        }
    }
}
