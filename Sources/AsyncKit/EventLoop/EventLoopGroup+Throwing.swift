import NIO

extension EventLoopGroup {
    /// An alternate name for this would be `future(catching:)`, but with that
    /// name, trailing closure syntax just looks like `el.future { ... }`, which
    /// does not indicate to readers of the code that it is the error-capturing
    /// version. Since such an indication is highly desirable, a slightly less
    /// idiomatic name is used instead.
    ///
    /// This method replaces this code:
    ///
    /// ```swift
    /// return something.eventLoop.future().flatMapThrowing {
    /// ```
    ///
    /// With this code:
    ///
    /// ```swift
    /// return something.eventLoop.tryFuture {
    /// ```
    ///
    /// That's pretty much it. It's sugar.
    ///
    /// - Parameter work: The potentially throwing closure to execute as a
    ///   future. If the closure throws, a failed future is returned.
    public func tryFuture<T>(_ work: @escaping () throws -> T) -> EventLoopFuture<T> {
        return self.any().submit(work)
    }
}
