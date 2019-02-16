import NIO

extension EventLoopFuture {
    
    /// Calls a closure on an optional value in an `EventLoopFuture` if it exists.
    ///
    ///     let optional = eventLoop.future(Optiona<Int>.some(42))
    ///     let some = optional.mapOptional { int -> Float in
    ///         return int * 3.14
    ///     }
    ///     // some: EventLoopFuture(Optional(131.88))
    ///
    /// - parameters:
    ///   - closure: The closure to call on the unwrapped optional value.
    ///   - unwrapped: The optional's value, unwrapped.
    /// - returns: The result of the closure if the optional was unwrapped, or nil if it wasn't, wrapped in an `EventLoopFuture`.
    public func mapOptional<Wrapped, Result>(_ closure: @escaping (_ unwrapped: Wrapped)throws -> Result) -> EventLoopFuture<Result?>
        where Value == Optional<Wrapped>
    {
        return self.flatMapThrowing { optional in
            return try optional.map(closure)
        }
    }
    
    /// Calls a closure on an optional value in an `EventLoopFuture` if it exists.
    ///
    ///     let optional = eventLoop.future(Optiona<Int>.some(42))
    ///     let some = optional.mapOptional { int -> Float in
    ///         return int * 3.14
    ///     }
    ///     // some: EventLoopFuture(Optional(131.88))
    ///
    /// - parameters:
    ///   - closure: The closure to call on the unwrapped optional value.
    ///   - unwrapped: The optional's value, unwrapped.
    /// - returns: The result of the closure if the optional was unwrapped, or nil if it wasn't, wrapped in an `EventLoopFuture`.
    public func flatMapOptional<Wrapped, Result>(
        _ closure: @escaping (_ unwrapped: Wrapped)throws -> EventLoopFuture<Result>
    ) -> EventLoopFuture<Result?> where Value == Optional<Wrapped>
    {
        return self.flatMap { optional -> EventLoopFuture<Result?> in
            do {
                return try optional.map(closure)?.map { $0 } ?? self.eventLoop.makeSucceededFuture(Optional<Result>.none)
            } catch let error {
                return self.eventLoop.makeFailedFuture(error)
            }
        }
    }
}
