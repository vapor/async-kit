import NIO

extension EventLoopFuture {
    public func tryFlatMap<NewValue>(
        file _: StaticString = #file, line _: UInt = #line,
        _ callback: @escaping (Value) throws -> EventLoopFuture<NewValue>
    ) -> EventLoopFuture<NewValue> {
        /// When the current `EventLoopFuture<Value>` is fulfilled, run the provided callback,
        /// which will provide a new `EventLoopFuture`.
        ///
        /// This allows you to dynamically dispatch new asynchronous tasks as phases in a
        /// longer series of processing steps. Note that you can use the results of the
        /// current `EventLoopFuture<Value>` when determining how to dispatch the next operation.
        ///
        /// The key difference between this method and the regular `flatMap` is  error handling.
        ///
        /// With `tryFlatMap`, the provided callback _may_ throw Errors, causing the returned `EventLoopFuture<Value>`
        /// to report failure immediately after the completion of the original `EventLoopFuture`.
        return self.flatMap() { [eventLoop] value in
            do {
                return try callback(value)
            } catch {
                return eventLoop.makeFailedFuture(error)
            }
        }
    }
}
