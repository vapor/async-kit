import NIO

extension EventLoop {
    /// Returns a new `EventLoopFuture` that succeeds when all of the provided `EventLoopFutures` complete.
    /// The new `EventLoopFuture` will contain an array of results, maintaining ordering
    /// for each of the completed `EventLoopFutures`.
    ///
    /// The returned `EventLoopFuture` always succeeds, regardless of any failures from the provided futures.
    ///
    /// If it is desired to flatten them into a single `EventLoopFuture` that fails on any `EventLoopFuture` failure,
    /// use `EventLoop.flatten(_:)` or other methods.
    /// - Parameter futures: An array of futures to gather results from.
    /// - Returns: A new `EventLoopFuture` with all the results of the provided futures.
    public func whenAllComplete<T>(_ futures: [EventLoopFuture<T>]) -> EventLoopFuture<[Result<T, Error>]> {
        let promise: EventLoopPromise<[Result<T, Error>]> = self.newPromise()

        var results = [(Int, Result<T, Error>)]()
        var remaining = futures.count

        // add callback to each future that stores the error or value result in the same ordering as the futures
        for (index, future) in futures.enumerated() {
            future.addAwaitier { result in
                remaining -= 1

                results.append((index, result))

                if remaining == 0 {
                    let orderedResults = results
                        .sorted(by: { return $0.0 < $1.0 })
                        .map { $0.1 }
                    promise.succeed(result: orderedResults)
                }
            }
        }

        return promise.futureResult
    }

    /// Returns a new `EventLoopFuture` that succeeds when all of the provided `EventLoopFutures` complete.
    ///
    /// The returned `EventLoopFuture` always succeeds, regardless of any failures from the provided futures.
    ///
    /// If it is desired to flatten them into a single `EventLoopFuture` that fails on any `EventLoopFuture` failure,
    /// use `EventLoop.flatten(_:)` or other methods.
    /// - Parameter futures: An array of futures to gather results from.
    /// - Returns: A new `EventLoopFuture` that succeeds after the providied futures complete.
    public func whenAllComplete<T>(_ futures: [EventLoopFuture<T>]) -> EventLoopFuture<Void> {
        let promise: EventLoopPromise<Void> = newPromise()

        var remaining = futures.count

        // attach a callback that checks to see if it was the last future to complete to succeed the top-level future
        futures.forEach {
            $0.whenComplete {
                remaining -= 1

                guard remaining == 0 else { return }

                promise.succeed(result: ())
            }
        }

        return promise.futureResult
    }
}
