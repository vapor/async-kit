import NIOCore

extension EventLoopFuture {
    /// Checks that the future's value (if any) returns `false` for `.isEmpty`. If the check fails, the provided error
    /// is thrown.
    public func nonempty<E: Error>(orError error: @escaping @autoclosure () -> E) -> EventLoopFuture<Value> where Value: Collection {
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
