import NIO

extension EventLoopFutureQueue {
    /// For each element of the provided collection, invoke the given generator
    /// and queue the returned future. Return a future whose value is an array
    /// containing the result of each generated future in the same order as the
    /// original sequence. The resulting array is intended to have semantics
    /// substantially similar to those provided by `EventLoop.flatten(_:on:)`.
    public func append<S: Sequence, Value>(each seq: S, _ generator: @escaping (S.Element) -> EventLoopFuture<Value>) -> EventLoopFuture<[Value]> {
        // For each element in the sequence, obtain a generated future, add the result of that future to the result
        // array, map the future to `Void`, and append the result to this queue. Left with the final future in the
        // chain (representing the result of the final element in the sequence) via `reduce()`, append to the queue
        // a last future whose value is the results array, which should now be complete. The in-order and immediate-
        // halt-on-fail guarantees of the queue itself negate any need to maintain a separate `Promise` or use
        // `enumerated()` to ensure consistency of the results array (see `EventLoopFuture.whenAllComplete(_:on:)` for
        // more information).
        var count: Int = 0 // used for debugging assertions
        var results: [Value] = []
        results.reserveCapacity(seq.underestimatedCount)
        
        seq.forEach {
            assert({ count += 1; return true }())
            _ = self.append(generator($0).map { results.append($0) }, runningOn: .success)
        }
        return self.append(onPrevious: .success) {
            assert(results.count == count, "Sequence completed, but we didn't get all the results, or got too many - EventLoopFutureQueue is broken.")
            return self.eventLoop.future(results)
        }
    }
    
    /// Same as `append(each:_:)` above, but assumes all futures return `Void`
    /// and returns a `Void` future instead of a result array.
    public func append<S: Sequence>(each seq: S, _ generator: @escaping (S.Element) -> EventLoopFuture<Void>) -> EventLoopFuture<Void> {
        seq.forEach { _ = self.append(generator($0), runningOn: .success) }
        return self.append(self.eventLoop.future(), runningOn: .success) // returns correct future in case of empty sequence
    }
}
