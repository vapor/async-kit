import NIO

extension EventLoopFuture {
    /// Calls a closure on an optional value that is wrapped in an `EventLoopFuture` if it exists.
    ///
    ///     let optional = eventLoop.future(Optional<Int>.some(42))
    ///     let some = optional.optionalMap { int -> Float in
    ///         return int * 3.14
    ///     }
    ///     // some: EventLoopFuture(Optional(131.88))
    ///
    /// - parameters:
    ///   - closure: The closure function that the optional value will be passed into.
    ///   - unwrapped: The unwrapped optional value.
    /// - returns: The result of the closure passed into the method (or `nil`), wrapped in an `EventLoopFuture`.
    public func optionalMap<Wrapped, Result>(
        _ closure: @escaping (_ unwrapped: Wrapped) -> Result?
    ) -> EventLoopFuture<Result?> where Value == Optional<Wrapped> {
        return self.map { $0.flatMap(closure) }
    }
    
    /// Calls a closure on an optional value in an `EventLoopFuture` if it exists.
    ///
    ///     let optional = eventLoop.future(Optiona<Int>.some(42))
    ///     let some = optional.optionalFlatMap { int -> EventLoopFuture<Float> in
    ///         return int * 3.14
    ///     }
    ///     // some: EventLoopFuture(Optional(131.88))
    ///
    /// - parameters:
    ///   - closure: The closure to call on the unwrapped optional value.
    ///   - unwrapped: The optional's value, unwrapped.
    /// - returns: The result of the closure if the optional was unwrapped, or nil if it wasn't, wrapped in an `EventLoopFuture`.
    public func optionalFlatMap<Wrapped, Result>(
        _ closure: @escaping (_ unwrapped: Wrapped) -> EventLoopFuture<Result>
    ) -> EventLoopFuture<Result?> where Value == Optional<Wrapped> {
        return self.flatMap { optional in
            guard let future = optional.map(closure) else {
                return self.eventLoop.makeSucceededFuture(nil)
            }
            
            return future.map(Optional.init)
        }
    }
    
    /// Calls a closure that returns an optional future on an optional value in an `EventLoopFuture` if it exists.
    ///
    ///     let optional = eventLoop.future(Optiona<Int>.some(42))
    ///     let some = optional.optionalFlatMap { int -> EventLoopFuture<Float?> in
    ///         return int * Optional<Float>.some(3.14)
    ///     }
    ///     // some: EventLoopFuture(Optional(131.88))
    ///
    /// - parameters:
    ///   - closure: The closure to call on the unwrapped optional value.
    ///   - unwrapped: The optional's value, unwrapped.
    /// - returns: The result of the closure if the optional was unwrapped, or nil if it wasn't, wrapped in an `EventLoopFuture`.
    public func optionalFlatMap<Wrapped, Result>(
        _ closure: @escaping (_ unwrapped: Wrapped) -> EventLoopFuture<Result?>
    ) -> EventLoopFuture<Result?> where Value == Optional<Wrapped>
    {
        return self.flatMap { optional in
            return optional.flatMap(closure)?.map { $0 } ?? self.eventLoop.makeSucceededFuture(nil)
        }
    }
    
    /// Calls a throwing closure on an optional value in an `EventLoopFuture` if it exists.
    ///
    ///     let optional = eventLoop.future(Optional<Int>.some(42))
    ///     let some = optional.optionalFlatMapThrowing { int -> Float in
    ///         return int * 3.14
    ///     }
    ///     // some: EventLoopFuture(Optional(131.88))
    ///
    /// - parameters:
    ///   - closure: The closure to call on the unwrapped optional value.
    ///   - unwrapped: The optional's value, unwrapped.
    /// - returns: The result of the closure if the optional was unwrapped, or nil if it wasn't, wrapped in an `EventLoopFuture`.
    public func optionalFlatMapThrowing<Wrapped, Result>(
        _ closure: @escaping (_ unwrapped: Wrapped) throws -> Result?
    ) -> EventLoopFuture<Result?> where Value == Optional<Wrapped>
    {
        return self.flatMapThrowing { optional in
            return try optional.flatMap(closure)
        }
    }
}
