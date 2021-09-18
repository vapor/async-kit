extension EventLoopFuture {
    // MARK: - Guard
    
    /// Guards that the future's value satisfies the callback's condition or
    /// fails with the given error.
    ///
    ///
    /// Example usage:
    ///
    ///     future.guard({ $0.userID == user.id }, else: AccessError.unauthorized)
    ///
    /// - parameters:
    ///   - callback: Callback that asynchronously executes a condition.
    ///   - error: The error to fail with if condition isn't met.
    /// - returns: A future containing the original future's result.
    public func `guard`(_ callback: @escaping ((Value) -> Bool), else error: @escaping @autoclosure () -> Error) -> EventLoopFuture<Value> {
        let promise = self.eventLoop.makePromise(of: Value.self)
        self.whenComplete { result in
            switch result {
            case .success(let value):
                if callback(value) {
                    promise.succeed(value)
                } else {
                    promise.fail(error())
                }
            case .failure(let error): promise.fail(error)
            }
        }
        return promise.futureResult
    }

    // MARK: - flatMapAlways
    
    /// When the current `EventLoopFuture` receives any result, run the provided callback, which will provide a new
    /// `EventLoopFuture`. Essentially combines the behaviors of `.always(_:)` and `.flatMap(file:line:_:)`.
    ///
    /// This is useful when some work must be done for both success and failure states, especially work that requires
    /// temporarily extending the lifetime of one or more objects.
    public func flatMapAlways<NewValue>(
        file: StaticString = #file, line: UInt = #line,
        _ callback: @escaping (Result<Value, Error>) -> EventLoopFuture<NewValue>
    ) -> EventLoopFuture<NewValue> {
        let promise = self.eventLoop.makePromise(of: NewValue.self, file: file, line: line)
        self.whenComplete { result in callback(result).cascade(to: promise) }
        return promise.futureResult
    }
    
    // MARK: - nonempty
    
    /// Checks that the future's value (if any) returns `false` for `.isEmpty`. If the check fails, the provided error
    /// is thrown.
    public func nonempty(orError error: @escaping @autoclosure () -> Error) -> EventLoopFuture<Value> where Value: Collection {
        return self.guard({ !$0.isEmpty }, else: error())
    }

    /// Checks that the future's value (if any) returns `false` for `.isEmpty`. If the check fails, a new future with
    /// the provided alternate value is returned. Otherwise, the provided normal `map()` callback is invoked.
    public func nonemptyMap<NewValue>(
        or alternate: @escaping @autoclosure () -> NewValue,
        _ transform: @escaping (Value) -> NewValue
    ) -> EventLoopFuture<NewValue> where Value: Collection {
        return self.map { !$0.isEmpty ? transform($0) : alternate() }
    }

    /// Checks that the future's value (if any) returns `false` for `.isEmpty`. If the check fails, a new future with
    /// an empty array as its value is returned. Otherwise, the provided normal `map()` callback is invoked. The
    /// callback's return type must be an `Array` or a `RangeReplaceableCollection`.
    public func nonemptyMap<NewValue>(
        _ transform: @escaping (Value) -> NewValue
    ) -> EventLoopFuture<NewValue> where Value: Collection, NewValue: RangeReplaceableCollection {
        return self.nonemptyMap(or: .init(), transform)
    }

    /// Checks that the future's value (if any) returns `false` for `.isEmpty`. If the check fails, a new future with
    /// the provided alternate value is returned. Otherwise, the provided normal `flatMapThrowing()` callback is
    /// invoked.
    public func nonemptyFlatMapThrowing<NewValue>(
        or alternate: @escaping @autoclosure () -> NewValue,
        _ transform: @escaping (Value) throws -> NewValue
    ) -> EventLoopFuture<NewValue> where Value: Collection {
        return self.flatMapThrowing { !$0.isEmpty ? try transform($0) : alternate() }
    }

    /// Checks that the future's value (if any) returns `false` for `.isEmpty`. If the check fails, a new future with
    /// an empty array as its value is returned. Otherwise, the provided normal `flatMapThrowing()` callback is
    /// invoked. The callback's return type must be an `Array` or a `RangeReplaceableCollection`.
    public func nonemptyFlatMapThrowing<NewValue>(
        _ transform: @escaping (Value) throws -> NewValue
    ) -> EventLoopFuture<NewValue> where Value: Collection, NewValue: RangeReplaceableCollection {
        return self.nonemptyFlatMapThrowing(or: .init(), transform)
    }

    /// Checks that the future's value (if any) returns `false` for `.isEmpty`. If the check fails, a new future with
    /// the provided alternate value is returned. Otherwise, the provided normal `flatMap()` callback is invoked.
    public func nonemptyFlatMap<NewValue>(
        or alternate: @escaping @autoclosure () -> NewValue,
        _ transform: @escaping (Value) -> EventLoopFuture<NewValue>
    ) -> EventLoopFuture<NewValue> where Value: Collection {
        return self.nonemptyFlatMap(orFlat: self.eventLoop.makeSucceededFuture(alternate()), transform)
    }

    /// Checks that the future's value (if any) returns `false` for `.isEmpty`. If the check fails, the provided
    /// alternate future is returned. Otherwise, the provided normal `flatMap()` callback is invoked.
    public func nonemptyFlatMap<NewValue>(
        orFlat alternate: @escaping @autoclosure () -> EventLoopFuture<NewValue>,
        _ transform: @escaping (Value) -> EventLoopFuture<NewValue>
    ) -> EventLoopFuture<NewValue> where Value: Collection {
        return self.flatMap { !$0.isEmpty ? transform($0) : alternate() }
    }

    /// Checks that the future's value (if any) returns `false` for `.isEmpty`. If the check fails, a new future with
    /// an empty array as its value is returned. Otherwise, the provided normal `flatMap()` callback is invoked. The
    /// callback's returned future must have a value type that is an `Array` or a `RangeReplaceableCollection`.
    public func nonemptyFlatMap<NewValue>(
        _ transform: @escaping (Value) -> EventLoopFuture<NewValue>
    ) -> EventLoopFuture<NewValue> where Value: Collection, NewValue: RangeReplaceableCollection {
        return self.nonemptyFlatMap(or: .init(), transform)
    }

}
