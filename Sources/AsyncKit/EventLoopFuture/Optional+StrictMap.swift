import NIO

/// Given one or more optionals as inputs, checks whether each input is `nil`. If _any_ input is `nil`, `nil` is
/// immediately returned as an overall results. If all of the inputs have values, the `transform` callback is invoked
/// with all of the unwrapped values as parameters.
///
/// - Note: This "baseline", single-item version of the function is trivially re-expressible using the `??` operator or
///   `Optional.map(_:)`, but this is not the case for any of the other overloads.
@inlinable
public func strictMap<A, Res>(
    _ a: A?,
    _ transform: (A) throws -> Res
) rethrows -> Res? {
    guard let a = a else { return nil }
    return try transform(a)
}

/// `strictMap(_:_:)` over 2 optionals.
@inlinable
public func strictMap<A, B, Res>(
    _ a: A?, _ b: B?,
    _ transform: (A, B) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b else { return nil }
    return try transform(a, b)
}

/// `strictMap(_:_:)` over 3 optionals.
@inlinable
public func strictMap<A, B, C, Res>(
    _ a: A?, _ b: B?, _ c: C?,
    _ transform: (A, B, C) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c else { return nil }
    return try transform(a, b, c)
}

/// `strictMap(_:_:)` over 4 optionals.
@inlinable
public func strictMap<A, B, C, D, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?,
    _ transform: (A, B, C, D) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d else { return nil }
    return try transform(a, b, c, d)
}

/// `strictMap(_:_:)` over 5 optionals.
@inlinable
public func strictMap<A, B, C, D, E, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?,
    _ transform: (A, B, C, D, E) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e else { return nil }
    return try transform(a, b, c, d, e)
}

/// `strictMap(_:_:)` over 6 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?,
    _ transform: (A, B, C, D, E, F) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f else { return nil }
    return try transform(a, b, c, d, e, f)
}

/// `strictMap(_:_:)` over 7 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?,
    _ transform: (A, B, C, D, E, F, G) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g else { return nil }
    return try transform(a, b, c, d, e, f, g)
}

/// `strictMap(_:_:)` over 8 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, H, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?, _ h: H?,
    _ transform: (A, B, C, D, E, F, G, H) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g, let h = h else { return nil }
    return try transform(a, b, c, d, e, f, g, h)
}

/// `strictMap(_:_:)` over 9 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, H, I, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?, _ h: H?, _ i: I?,
    _ transform: (A, B, C, D, E, F, G, H, I) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g, let h = h, let i = i else { return nil }
    return try transform(a, b, c, d, e, f, g, h, i)
}

/// `strictMap(_:_:)` over 10 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, H, I, J, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?, _ h: H?, _ i: I?, _ j: J?,
    _ transform: (A, B, C, D, E, F, G, H, I, J) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g, let h = h, let i = i, let j = j else { return nil }
    return try transform(a, b, c, d, e, f, g, h, i, j)
}

/// `strictMap(_:_:)` over 11 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, H, I, J, K, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?, _ h: H?, _ i: I?, _ j: J?, _ k: K?,
    _ transform: (A, B, C, D, E, F, G, H, I, J, K) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g, let h = h, let i = i, let j = j, let k = k else { return nil }
    return try transform(a, b, c, d, e, f, g, h, i, j, k)
}

/// `strictMap(_:_:)` over 12 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, H, I, J, K, L, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?, _ h: H?, _ i: I?, _ j: J?, _ k: K?, _ l: L?,
    _ transform: (A, B, C, D, E, F, G, H, I, J, K, L) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g, let h = h, let i = i, let j = j, let k = k, let l = l else { return nil }
    return try transform(a, b, c, d, e, f, g, h, i, j, k, l)
}

/// `strictMap(_:_:)` over 13 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, H, I, J, K, L, M, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?, _ h: H?, _ i: I?, _ j: J?, _ k: K?, _ l: L?, _ m: M?,
    _ transform: (A, B, C, D, E, F, G, H, I, J, K, L, M) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g, let h = h, let i = i, let j = j, let k = k, let l = l, let m = m else { return nil }
    return try transform(a, b, c, d, e, f, g, h, i, j, k, l, m)
}

/// `strictMap(_:_:)` over 14 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, H, I, J, K, L, M, N, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?, _ h: H?, _ i: I?, _ j: J?, _ k: K?, _ l: L?, _ m: M?, _ n: N?,
    _ transform: (A, B, C, D, E, F, G, H, I, J, K, L, M, N) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g, let h = h, let i = i, let j = j, let k = k, let l = l, let m = m, let n = n else { return nil }
    return try transform(a, b, c, d, e, f, g, h, i, j, k, l, m, n)
}

/// `strictMap(_:_:)` over 15 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?, _ h: H?, _ i: I?, _ j: J?, _ k: K?, _ l: L?, _ m: M?, _ n: N?, _ o: O?,
    _ transform: (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g, let h = h, let i = i, let j = j, let k = k, let l = l, let m = m, let n = n, let o = o else { return nil }
    return try transform(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o)
}

/// `strictMap(_:_:)` over 16 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?, _ h: H?, _ i: I?, _ j: J?, _ k: K?, _ l: L?, _ m: M?, _ n: N?, _ o: O?, _ p: P?,
    _ transform: (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g, let h = h, let i = i, let j = j, let k = k, let l = l, let m = m, let n = n, let o = o, let p = p else { return nil }
    return try transform(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p)
}

/// `strictMap(_:_:)` over 17 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?, _ h: H?, _ i: I?, _ j: J?, _ k: K?, _ l: L?, _ m: M?, _ n: N?, _ o: O?, _ p: P?, _ q: Q?,
    _ transform: (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g, let h = h, let i = i, let j = j, let k = k, let l = l, let m = m, let n = n, let o = o, let p = p, let q = q else { return nil }
    return try transform(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q)
}

/// `strictMap(_:_:)` over 18 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?, _ h: H?, _ i: I?, _ j: J?, _ k: K?, _ l: L?, _ m: M?, _ n: N?, _ o: O?, _ p: P?, _ q: Q?, _ r: R?,
    _ transform: (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g, let h = h, let i = i, let j = j, let k = k, let l = l, let m = m, let n = n, let o = o, let p = p, let q = q, let r = r else { return nil }
    return try transform(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r)
}

/// `strictMap(_:_:)` over 19 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?, _ h: H?, _ i: I?, _ j: J?, _ k: K?, _ l: L?, _ m: M?, _ n: N?, _ o: O?, _ p: P?, _ q: Q?, _ r: R?, _ s: S?,
    _ transform: (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g, let h = h, let i = i, let j = j, let k = k, let l = l, let m = m, let n = n, let o = o, let p = p, let q = q, let r = r, let s = s else { return nil }
    return try transform(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s)
}

/// `strictMap(_:_:)` over 20 optionals.
@inlinable
public func strictMap<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, Res>(
    _ a: A?, _ b: B?, _ c: C?, _ d: D?, _ e: E?, _ f: F?, _ g: G?, _ h: H?, _ i: I?, _ j: J?, _ k: K?, _ l: L?, _ m: M?, _ n: N?, _ o: O?, _ p: P?, _ q: Q?, _ r: R?, _ s: S?, _ t: T?,
    _ transform: (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T) throws -> Res
) rethrows -> Res? {
    guard let a = a, let b = b, let c = c, let d = d, let e = e, let f = f, let g = g, let h = h, let i = i, let j = j, let k = k, let l = l, let m = m, let n = n, let o = o, let p = p, let q = q, let r = r, let s = s, let t = t else { return nil }
    return try transform(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t)
}
