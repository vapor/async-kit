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
    public func flatten<Value>(on eventLoop: EventLoop) -> EventLoopFuture<[Value]> where Element == EventLoopFuture<Value> {
        return eventLoop.flatten(Array(self))
    }
}
