import NIO

extension EventLoopFuture {
    /// Returns a new `EventLoopFuture` that succeeds only if all of the provided fs succeed.
    /// The new `EventLoopFuture` will contain all of the values fulfilled by the fs.
    ///
    /// The returned `EventLoopFuture` will fail as soon as any of the fs fails.
    ///
    /// - Parameters:
    ///     - fA...: A series of heterogenous `EventLoopFuture`s to wait on for fulfilled values.
    ///     - on: The `EventLoop` on which the new `EventLoopFuture` callbacks will fire.
    /// - Returns: A new `EventLoopFuture` with all of the values fulfilled by the provided fs, as a tuple.
    ///
    /// - Note: This is esssentially just a heterogenous version of `.whenAllSucceed()`.
    @inlinable
    public static func whenTheySucceed<A, B>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B)> where Value == (A, B) {
        return fA.and(fB)
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 3.
    @inlinable
    public static func whenTheySucceed<A, B, C>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C)> where Value == (A, B, C) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b, _c) { (a, $0, $1) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a, _c) { ($0, b, $1) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a, _b) { ($0, $1, c) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 4.
    @inlinable
    public static func whenTheySucceed<A, B, C, D>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D)> where Value == (A, B, C, D) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b, _c, _d) { (a, $0, $1, $2) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a, _c, _d) { ($0, b, $1, $2) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a, _b, _d) { ($0, $1, c, $2) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a, _b, _c) { ($0, $1, $2, d) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 5.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E)> where Value == (A, B, C, D, E) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b, _c, _d, _e) { (a, $0, $1, $2, $3) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a, _c, _d, _e) { ($0, b, $1, $2, $3) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a, _b, _d, _e) { ($0, $1, c, $2, $3) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a, _b, _c, _e) { ($0, $1, $2, d, $3) } })
            .whenTheySucceed0(fE, { _e = $0 }, { e in strictMap(_a, _b, _c, _d) { ($0, $1, $2, $3, e) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 6.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F)> where Value == (A, B, C, D, E, F) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b, _c, _d, _e, _f) { (a, $0, $1, $2, $3, $4) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a, _c, _d, _e, _f) { ($0, b, $1, $2, $3, $4) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a, _b, _d, _e, _f) { ($0, $1, c, $2, $3, $4) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a, _b, _c, _e, _f) { ($0, $1, $2, d, $3, $4) } })
            .whenTheySucceed0(fE, { _e = $0 }, { e in strictMap(_a, _b, _c, _d, _f) { ($0, $1, $2, $3, e, $4) } })
            .whenTheySucceed0(fF, { _f = $0 }, { f in strictMap(_a, _b, _c, _d, _e) { ($0, $1, $2, $3, $4, f) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 7.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G)> where Value == (A, B, C, D, E, F, G) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b, _c, _d, _e, _f, _g) { (a, $0, $1, $2, $3, $4, $5) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a, _c, _d, _e, _f, _g) { ($0, b, $1, $2, $3, $4, $5) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a, _b, _d, _e, _f, _g) { ($0, $1, c, $2, $3, $4, $5) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a, _b, _c, _e, _f, _g) { ($0, $1, $2, d, $3, $4, $5) } })
            .whenTheySucceed0(fE, { _e = $0 }, { e in strictMap(_a, _b, _c, _d, _f, _g) { ($0, $1, $2, $3, e, $4, $5) } })
            .whenTheySucceed0(fF, { _f = $0 }, { f in strictMap(_a, _b, _c, _d, _e, _g) { ($0, $1, $2, $3, $4, f, $5) } })
            .whenTheySucceed0(fG, { _g = $0 }, { g in strictMap(_a, _b, _c, _d, _e, _f) { ($0, $1, $2, $3, $4, $5, g) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 8.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G, H>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>, _ fH: EventLoopFuture<H>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G, H)> where Value == (A, B, C, D, E, F, G, H) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G, H).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?, _h: H?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b, _c, _d, _e, _f, _g, _h) { (a, $0, $1, $2, $3, $4, $5, $6) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a, _c, _d, _e, _f, _g, _h) { ($0, b, $1, $2, $3, $4, $5, $6) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a, _b, _d, _e, _f, _g, _h) { ($0, $1, c, $2, $3, $4, $5, $6) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a, _b, _c, _e, _f, _g, _h) { ($0, $1, $2, d, $3, $4, $5, $6) } })
            .whenTheySucceed0(fE, { _e = $0 }, { e in strictMap(_a, _b, _c, _d, _f, _g, _h) { ($0, $1, $2, $3, e, $4, $5, $6) } })
            .whenTheySucceed0(fF, { _f = $0 }, { f in strictMap(_a, _b, _c, _d, _e, _g, _h) { ($0, $1, $2, $3, $4, f, $5, $6) } })
            .whenTheySucceed0(fG, { _g = $0 }, { g in strictMap(_a, _b, _c, _d, _e, _f, _h) { ($0, $1, $2, $3, $4, $5, g, $6) } })
            .whenTheySucceed0(fH, { _h = $0 }, { h in strictMap(_a, _b, _c, _d, _e, _f, _g) { ($0, $1, $2, $3, $4, $5, $6, h) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 9.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G, H, I>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>, _ fH: EventLoopFuture<H>, _ fI: EventLoopFuture<I>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G, H, I)> where Value == (A, B, C, D, E, F, G, H, I) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G, H, I).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?, _h: H?, _i: I?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b, _c, _d, _e, _f, _g, _h, _i) { (a, $0, $1, $2, $3, $4, $5, $6, $7) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a, _c, _d, _e, _f, _g, _h, _i) { ($0, b, $1, $2, $3, $4, $5, $6, $7) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a, _b, _d, _e, _f, _g, _h, _i) { ($0, $1, c, $2, $3, $4, $5, $6, $7) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a, _b, _c, _e, _f, _g, _h, _i) { ($0, $1, $2, d, $3, $4, $5, $6, $7) } })
            .whenTheySucceed0(fE, { _e = $0 }, { e in strictMap(_a, _b, _c, _d, _f, _g, _h, _i) { ($0, $1, $2, $3, e, $4, $5, $6, $7) } })
            .whenTheySucceed0(fF, { _f = $0 }, { f in strictMap(_a, _b, _c, _d, _e, _g, _h, _i) { ($0, $1, $2, $3, $4, f, $5, $6, $7) } })
            .whenTheySucceed0(fG, { _g = $0 }, { g in strictMap(_a, _b, _c, _d, _e, _f, _h, _i) { ($0, $1, $2, $3, $4, $5, g, $6, $7) } })
            .whenTheySucceed0(fH, { _h = $0 }, { h in strictMap(_a, _b, _c, _d, _e, _f, _g, _i) { ($0, $1, $2, $3, $4, $5, $6, h, $7) } })
            .whenTheySucceed0(fI, { _i = $0 }, { i in strictMap(_a, _b, _c, _d, _e, _f, _g, _h) { ($0, $1, $2, $3, $4, $5, $6, $7, i) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 10.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G, H, I, J>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>, _ fH: EventLoopFuture<H>, _ fI: EventLoopFuture<I>, _ fJ: EventLoopFuture<J>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G, H, I, J)> where Value == (A, B, C, D, E, F, G, H, I, J) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G, H, I, J).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?, _h: H?, _i: I?, _j: J?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b, _c, _d, _e, _f, _g, _h, _i, _j) { (a, $0, $1, $2, $3, $4, $5, $6, $7, $8) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a, _c, _d, _e, _f, _g, _h, _i, _j) { ($0, b, $1, $2, $3, $4, $5, $6, $7, $8) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a, _b, _d, _e, _f, _g, _h, _i, _j) { ($0, $1, c, $2, $3, $4, $5, $6, $7, $8) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a, _b, _c, _e, _f, _g, _h, _i, _j) { ($0, $1, $2, d, $3, $4, $5, $6, $7, $8) } })
            .whenTheySucceed0(fE, { _e = $0 }, { e in strictMap(_a, _b, _c, _d, _f, _g, _h, _i, _j) { ($0, $1, $2, $3, e, $4, $5, $6, $7, $8) } })
            .whenTheySucceed0(fF, { _f = $0 }, { f in strictMap(_a, _b, _c, _d, _e, _g, _h, _i, _j) { ($0, $1, $2, $3, $4, f, $5, $6, $7, $8) } })
            .whenTheySucceed0(fG, { _g = $0 }, { g in strictMap(_a, _b, _c, _d, _e, _f, _h, _i, _j) { ($0, $1, $2, $3, $4, $5, g, $6, $7, $8) } })
            .whenTheySucceed0(fH, { _h = $0 }, { h in strictMap(_a, _b, _c, _d, _e, _f, _g, _i, _j) { ($0, $1, $2, $3, $4, $5, $6, h, $7, $8) } })
            .whenTheySucceed0(fI, { _i = $0 }, { i in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _j) { ($0, $1, $2, $3, $4, $5, $6, $7, i, $8) } })
            .whenTheySucceed0(fJ, { _j = $0 }, { j in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, j) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 11.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G, H, I, J, K>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>, _ fH: EventLoopFuture<H>, _ fI: EventLoopFuture<I>, _ fJ: EventLoopFuture<J>, _ fK: EventLoopFuture<K>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G, H, I, J, K)> where Value == (A, B, C, D, E, F, G, H, I, J, K) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G, H, I, J, K).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?, _h: H?, _i: I?, _j: J?, _k: K?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b, _c, _d, _e, _f, _g, _h, _i, _j, _k) { (a, $0, $1, $2, $3, $4, $5, $6, $7, $8, $9) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a, _c, _d, _e, _f, _g, _h, _i, _j, _k) { ($0, b, $1, $2, $3, $4, $5, $6, $7, $8, $9) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a, _b, _d, _e, _f, _g, _h, _i, _j, _k) { ($0, $1, c, $2, $3, $4, $5, $6, $7, $8, $9) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a, _b, _c, _e, _f, _g, _h, _i, _j, _k) { ($0, $1, $2, d, $3, $4, $5, $6, $7, $8, $9) } })
            .whenTheySucceed0(fE, { _e = $0 }, { e in strictMap(_a, _b, _c, _d, _f, _g, _h, _i, _j, _k) { ($0, $1, $2, $3, e, $4, $5, $6, $7, $8, $9) } })
            .whenTheySucceed0(fF, { _f = $0 }, { f in strictMap(_a, _b, _c, _d, _e, _g, _h, _i, _j, _k) { ($0, $1, $2, $3, $4, f, $5, $6, $7, $8, $9) } })
            .whenTheySucceed0(fG, { _g = $0 }, { g in strictMap(_a, _b, _c, _d, _e, _f, _h, _i, _j, _k) { ($0, $1, $2, $3, $4, $5, g, $6, $7, $8, $9) } })
            .whenTheySucceed0(fH, { _h = $0 }, { h in strictMap(_a, _b, _c, _d, _e, _f, _g, _i, _j, _k) { ($0, $1, $2, $3, $4, $5, $6, h, $7, $8, $9) } })
            .whenTheySucceed0(fI, { _i = $0 }, { i in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _j, _k) { ($0, $1, $2, $3, $4, $5, $6, $7, i, $8, $9) } })
            .whenTheySucceed0(fJ, { _j = $0 }, { j in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _k) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, j, $9) } })
            .whenTheySucceed0(fK, { _k = $0 }, { k in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, k) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 12.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G, H, I, J, K, L>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>, _ fH: EventLoopFuture<H>, _ fI: EventLoopFuture<I>, _ fJ: EventLoopFuture<J>, _ fK: EventLoopFuture<K>, _ fL: EventLoopFuture<L>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G, H, I, J, K, L)> where Value == (A, B, C, D, E, F, G, H, I, J, K, L) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G, H, I, J, K, L).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?, _h: H?, _i: I?, _j: J?, _k: K?, _l: L?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l) { (a, $0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l) { ($0, b, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a, _b, _d, _e, _f, _g, _h, _i, _j, _k, _l) { ($0, $1, c, $2, $3, $4, $5, $6, $7, $8, $9, $10) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a, _b, _c, _e, _f, _g, _h, _i, _j, _k, _l) { ($0, $1, $2, d, $3, $4, $5, $6, $7, $8, $9, $10) } })
            .whenTheySucceed0(fE, { _e = $0 }, { e in strictMap(_a, _b, _c, _d, _f, _g, _h, _i, _j, _k, _l) { ($0, $1, $2, $3, e, $4, $5, $6, $7, $8, $9, $10) } })
            .whenTheySucceed0(fF, { _f = $0 }, { f in strictMap(_a, _b, _c, _d, _e, _g, _h, _i, _j, _k, _l) { ($0, $1, $2, $3, $4, f, $5, $6, $7, $8, $9, $10) } })
            .whenTheySucceed0(fG, { _g = $0 }, { g in strictMap(_a, _b, _c, _d, _e, _f, _h, _i, _j, _k, _l) { ($0, $1, $2, $3, $4, $5, g, $6, $7, $8, $9, $10) } })
            .whenTheySucceed0(fH, { _h = $0 }, { h in strictMap(_a, _b, _c, _d, _e, _f, _g, _i, _j, _k, _l) { ($0, $1, $2, $3, $4, $5, $6, h, $7, $8, $9, $10) } })
            .whenTheySucceed0(fI, { _i = $0 }, { i in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l) { ($0, $1, $2, $3, $4, $5, $6, $7, i, $8, $9, $10) } })
            .whenTheySucceed0(fJ, { _j = $0 }, { j in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _k, _l) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, j, $9, $10) } })
            .whenTheySucceed0(fK, { _k = $0 }, { k in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _l) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, k, $10) } })
            .whenTheySucceed0(fL, { _l = $0 }, { l in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, l) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 13.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G, H, I, J, K, L, M>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>, _ fH: EventLoopFuture<H>, _ fI: EventLoopFuture<I>, _ fJ: EventLoopFuture<J>, _ fK: EventLoopFuture<K>, _ fL: EventLoopFuture<L>, _ fM: EventLoopFuture<M>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G, H, I, J, K, L, M)> where Value == (A, B, C, D, E, F, G, H, I, J, K, L, M) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G, H, I, J, K, L, M).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?, _h: H?, _i: I?, _j: J?, _k: K?, _l: L?, _m: M?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m) { (a, $0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m) { ($0, b, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a, _b, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m) { ($0, $1, c, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a, _b, _c, _e, _f, _g, _h, _i, _j, _k, _l, _m) { ($0, $1, $2, d, $3, $4, $5, $6, $7, $8, $9, $10, $11) } })
            .whenTheySucceed0(fE, { _e = $0 }, { e in strictMap(_a, _b, _c, _d, _f, _g, _h, _i, _j, _k, _l, _m) { ($0, $1, $2, $3, e, $4, $5, $6, $7, $8, $9, $10, $11) } })
            .whenTheySucceed0(fF, { _f = $0 }, { f in strictMap(_a, _b, _c, _d, _e, _g, _h, _i, _j, _k, _l, _m) { ($0, $1, $2, $3, $4, f, $5, $6, $7, $8, $9, $10, $11) } })
            .whenTheySucceed0(fG, { _g = $0 }, { g in strictMap(_a, _b, _c, _d, _e, _f, _h, _i, _j, _k, _l, _m) { ($0, $1, $2, $3, $4, $5, g, $6, $7, $8, $9, $10, $11) } })
            .whenTheySucceed0(fH, { _h = $0 }, { h in strictMap(_a, _b, _c, _d, _e, _f, _g, _i, _j, _k, _l, _m) { ($0, $1, $2, $3, $4, $5, $6, h, $7, $8, $9, $10, $11) } })
            .whenTheySucceed0(fI, { _i = $0 }, { i in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l, _m) { ($0, $1, $2, $3, $4, $5, $6, $7, i, $8, $9, $10, $11) } })
            .whenTheySucceed0(fJ, { _j = $0 }, { j in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _k, _l, _m) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, j, $9, $10, $11) } })
            .whenTheySucceed0(fK, { _k = $0 }, { k in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _l, _m) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, k, $10, $11) } })
            .whenTheySucceed0(fL, { _l = $0 }, { l in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _m) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, l, $11) } })
            .whenTheySucceed0(fM, { _m = $0 }, { m in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, m) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 14.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G, H, I, J, K, L, M, N>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>, _ fH: EventLoopFuture<H>, _ fI: EventLoopFuture<I>, _ fJ: EventLoopFuture<J>, _ fK: EventLoopFuture<K>, _ fL: EventLoopFuture<L>, _ fM: EventLoopFuture<M>, _ fN: EventLoopFuture<N>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G, H, I, J, K, L, M, N)> where Value == (A, B, C, D, E, F, G, H, I, J, K, L, M, N) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G, H, I, J, K, L, M, N).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?, _h: H?, _i: I?, _j: J?, _k: K?, _l: L?, _m: M?, _n: N?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n) { (a, $0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n) { ($0, b, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a, _b, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n) { ($0, $1, c, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a, _b, _c, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n) { ($0, $1, $2, d, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) } })
            .whenTheySucceed0(fE, { _e = $0 }, { e in strictMap(_a, _b, _c, _d, _f, _g, _h, _i, _j, _k, _l, _m, _n) { ($0, $1, $2, $3, e, $4, $5, $6, $7, $8, $9, $10, $11, $12) } })
            .whenTheySucceed0(fF, { _f = $0 }, { f in strictMap(_a, _b, _c, _d, _e, _g, _h, _i, _j, _k, _l, _m, _n) { ($0, $1, $2, $3, $4, f, $5, $6, $7, $8, $9, $10, $11, $12) } })
            .whenTheySucceed0(fG, { _g = $0 }, { g in strictMap(_a, _b, _c, _d, _e, _f, _h, _i, _j, _k, _l, _m, _n) { ($0, $1, $2, $3, $4, $5, g, $6, $7, $8, $9, $10, $11, $12) } })
            .whenTheySucceed0(fH, { _h = $0 }, { h in strictMap(_a, _b, _c, _d, _e, _f, _g, _i, _j, _k, _l, _m, _n) { ($0, $1, $2, $3, $4, $5, $6, h, $7, $8, $9, $10, $11, $12) } })
            .whenTheySucceed0(fI, { _i = $0 }, { i in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l, _m, _n) { ($0, $1, $2, $3, $4, $5, $6, $7, i, $8, $9, $10, $11, $12) } })
            .whenTheySucceed0(fJ, { _j = $0 }, { j in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _k, _l, _m, _n) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, j, $9, $10, $11, $12) } })
            .whenTheySucceed0(fK, { _k = $0 }, { k in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _l, _m, _n) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, k, $10, $11, $12) } })
            .whenTheySucceed0(fL, { _l = $0 }, { l in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _m, _n) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, l, $11, $12) } })
            .whenTheySucceed0(fM, { _m = $0 }, { m in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, m, $12) } })
            .whenTheySucceed0(fN, { _n = $0 }, { n in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m) { ($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, n) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 15.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>, _ fH: EventLoopFuture<H>, _ fI: EventLoopFuture<I>, _ fJ: EventLoopFuture<J>, _ fK: EventLoopFuture<K>, _ fL: EventLoopFuture<L>, _ fM: EventLoopFuture<M>, _ fN: EventLoopFuture<N>, _ fO: EventLoopFuture<O>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O)> where Value == (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?, _h: H?, _i: I?, _j: J?, _k: K?, _l: L?, _m: M?, _n: N?, _o: O?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o) { (a,$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o) { ($0,b,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a, _b, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o) { ($0,$1,c,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a, _b, _c, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o) { ($0,$1,$2,d,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13) } })
            .whenTheySucceed0(fE, { _e = $0 }, { e in strictMap(_a, _b, _c, _d, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o) { ($0,$1,$2,$3,e,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13) } })
            .whenTheySucceed0(fF, { _f = $0 }, { f in strictMap(_a, _b, _c, _d, _e, _g, _h, _i, _j, _k, _l, _m, _n, _o) { ($0,$1,$2,$3,$4,f,$5,$6,$7,$8,$9,$10,$11,$12,$13) } })
            .whenTheySucceed0(fG, { _g = $0 }, { g in strictMap(_a, _b, _c, _d, _e, _f, _h, _i, _j, _k, _l, _m, _n, _o) { ($0,$1,$2,$3,$4,$5,g,$6,$7,$8,$9,$10,$11,$12,$13) } })
            .whenTheySucceed0(fH, { _h = $0 }, { h in strictMap(_a, _b, _c, _d, _e, _f, _g, _i, _j, _k, _l, _m, _n, _o) { ($0,$1,$2,$3,$4,$5,$6,h,$7,$8,$9,$10,$11,$12,$13) } })
            .whenTheySucceed0(fI, { _i = $0 }, { i in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l, _m, _n, _o) { ($0,$1,$2,$3,$4,$5,$6,$7,i,$8,$9,$10,$11,$12,$13) } })
            .whenTheySucceed0(fJ, { _j = $0 }, { j in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _k, _l, _m, _n, _o) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,j,$9,$10,$11,$12,$13) } })
            .whenTheySucceed0(fK, { _k = $0 }, { k in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _l, _m, _n, _o) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,k,$10,$11,$12,$13) } })
            .whenTheySucceed0(fL, { _l = $0 }, { l in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _m, _n, _o) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,l,$11,$12,$13) } })
            .whenTheySucceed0(fM, { _m = $0 }, { m in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,m,$12,$13) } })
            .whenTheySucceed0(fN, { _n = $0 }, { n in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _o) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,n,$13) } })
            .whenTheySucceed0(fO, { _o = $0 }, { o in strictMap(_a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,o) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 16.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>, _ fH: EventLoopFuture<H>, _ fI: EventLoopFuture<I>, _ fJ: EventLoopFuture<J>, _ fK: EventLoopFuture<K>, _ fL: EventLoopFuture<L>, _ fM: EventLoopFuture<M>, _ fN: EventLoopFuture<N>, _ fO: EventLoopFuture<O>, _ fP: EventLoopFuture<P>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P)> where Value == (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?, _h: H?, _i: I?, _j: J?, _k: K?, _l: L?, _m: M?, _n: N?, _o: O?, _p: P?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p) { (a,$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p) { ($0,b,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a,_b,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p) { ($0,$1,c,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a,_b,_c,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p) { ($0,$1,$2,d,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14) } })
            .whenTheySucceed0(fE, { _e = $0 }, { e in strictMap(_a,_b,_c,_d,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p) { ($0,$1,$2,$3,e,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14) } })
            .whenTheySucceed0(fF, { _f = $0 }, { f in strictMap(_a,_b,_c,_d,_e,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p) { ($0,$1,$2,$3,$4,f,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14) } })
            .whenTheySucceed0(fG, { _g = $0 }, { g in strictMap(_a,_b,_c,_d,_e,_f,_h,_i,_j,_k,_l,_m,_n,_o,_p) { ($0,$1,$2,$3,$4,$5,g,$6,$7,$8,$9,$10,$11,$12,$13,$14) } })
            .whenTheySucceed0(fH, { _h = $0 }, { h in strictMap(_a,_b,_c,_d,_e,_f,_g,_i,_j,_k,_l,_m,_n,_o,_p) { ($0,$1,$2,$3,$4,$5,$6,h,$7,$8,$9,$10,$11,$12,$13,$14) } })
            .whenTheySucceed0(fI, { _i = $0 }, { i in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_j,_k,_l,_m,_n,_o,_p) { ($0,$1,$2,$3,$4,$5,$6,$7,i,$8,$9,$10,$11,$12,$13,$14) } })
            .whenTheySucceed0(fJ, { _j = $0 }, { j in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_k,_l,_m,_n,_o,_p) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,j,$9,$10,$11,$12,$13,$14) } })
            .whenTheySucceed0(fK, { _k = $0 }, { k in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_l,_m,_n,_o,_p) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,k,$10,$11,$12,$13,$14) } })
            .whenTheySucceed0(fL, { _l = $0 }, { l in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_m,_n,_o,_p) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,l,$11,$12,$13,$14) } })
            .whenTheySucceed0(fM, { _m = $0 }, { m in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_n,_o,_p) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,m,$12,$13,$14) } })
            .whenTheySucceed0(fN, { _n = $0 }, { n in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_o,_p) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,n,$13,$14) } })
            .whenTheySucceed0(fO, { _o = $0 }, { o in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_p) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,o,$14) } })
            .whenTheySucceed0(fP, { _p = $0 }, { p in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,p) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 17.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>, _ fH: EventLoopFuture<H>, _ fI: EventLoopFuture<I>, _ fJ: EventLoopFuture<J>, _ fK: EventLoopFuture<K>, _ fL: EventLoopFuture<L>, _ fM: EventLoopFuture<M>, _ fN: EventLoopFuture<N>, _ fO: EventLoopFuture<O>, _ fP: EventLoopFuture<P>, _ fQ: EventLoopFuture<Q>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q)> where Value == (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?, _h: H?, _i: I?, _j: J?, _k: K?, _l: L?, _m: M?, _n: N?, _o: O?, _p: P?, _q: Q?

        return promise
            .whenTheySucceed0(fA, { _a = $0 }, { a in strictMap(_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q) { (a,$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) } })
            .whenTheySucceed0(fB, { _b = $0 }, { b in strictMap(_a,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q) { ($0,b,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) } })
            .whenTheySucceed0(fC, { _c = $0 }, { c in strictMap(_a,_b,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q) { ($0,$1,c,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) } })
            .whenTheySucceed0(fD, { _d = $0 }, { d in strictMap(_a,_b,_c,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q) { ($0,$1,$2,d,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) } })
            .whenTheySucceed0(fE, { _e = $0 }, { e in strictMap(_a,_b,_c,_d,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q) { ($0,$1,$2,$3,e,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) } })
            .whenTheySucceed0(fF, { _f = $0 }, { f in strictMap(_a,_b,_c,_d,_e,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q) { ($0,$1,$2,$3,$4,f,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) } })
            .whenTheySucceed0(fG, { _g = $0 }, { g in strictMap(_a,_b,_c,_d,_e,_f,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q) { ($0,$1,$2,$3,$4,$5,g,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) } })
            .whenTheySucceed0(fH, { _h = $0 }, { h in strictMap(_a,_b,_c,_d,_e,_f,_g,_i,_j,_k,_l,_m,_n,_o,_p,_q) { ($0,$1,$2,$3,$4,$5,$6,h,$7,$8,$9,$10,$11,$12,$13,$14,$15) } })
            .whenTheySucceed0(fI, { _i = $0 }, { i in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_j,_k,_l,_m,_n,_o,_p,_q) { ($0,$1,$2,$3,$4,$5,$6,$7,i,$8,$9,$10,$11,$12,$13,$14,$15) } })
            .whenTheySucceed0(fJ, { _j = $0 }, { j in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_k,_l,_m,_n,_o,_p,_q) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,j,$9,$10,$11,$12,$13,$14,$15) } })
            .whenTheySucceed0(fK, { _k = $0 }, { k in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_l,_m,_n,_o,_p,_q) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,k,$10,$11,$12,$13,$14,$15) } })
            .whenTheySucceed0(fL, { _l = $0 }, { l in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_m,_n,_o,_p,_q) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,l,$11,$12,$13,$14,$15) } })
            .whenTheySucceed0(fM, { _m = $0 }, { m in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_n,_o,_p,_q) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,m,$12,$13,$14,$15) } })
            .whenTheySucceed0(fN, { _n = $0 }, { n in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_o,_p,_q) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,n,$13,$14,$15) } })
            .whenTheySucceed0(fO, { _o = $0 }, { o in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_p,_q) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,o,$14,$15) } })
            .whenTheySucceed0(fP, { _p = $0 }, { p in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_q) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,p,$15) } })
            .whenTheySucceed0(fQ, { _q = $0 }, { q in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p) { ($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,q) } })
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 18.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>, _ fH: EventLoopFuture<H>, _ fI: EventLoopFuture<I>, _ fJ: EventLoopFuture<J>, _ fK: EventLoopFuture<K>, _ fL: EventLoopFuture<L>, _ fM: EventLoopFuture<M>, _ fN: EventLoopFuture<N>, _ fO: EventLoopFuture<O>, _ fP: EventLoopFuture<P>, _ fQ: EventLoopFuture<Q>, _ fR: EventLoopFuture<R>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R)> where Value == (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?, _h: H?, _i: I?, _j: J?, _k: K?, _l: L?, _m: M?, _n: N?, _o: O?, _p: P?, _q: Q?, _r: R?

        return promise
            .whenTheySucceed0(fA, {_a = $0}, {a in strictMap(_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r) {(a,$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)}})
            .whenTheySucceed0(fB, {_b = $0}, {b in strictMap(_a,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r) {($0,b,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)}})
            .whenTheySucceed0(fC, {_c = $0}, {c in strictMap(_a,_b,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r) {($0,$1,c,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)}})
            .whenTheySucceed0(fD, {_d = $0}, {d in strictMap(_a,_b,_c,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r) {($0,$1,$2,d,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)}})
            .whenTheySucceed0(fE, {_e = $0}, {e in strictMap(_a,_b,_c,_d,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r) {($0,$1,$2,$3,e,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)}})
            .whenTheySucceed0(fF, {_f = $0}, {f in strictMap(_a,_b,_c,_d,_e,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r) {($0,$1,$2,$3,$4,f,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)}})
            .whenTheySucceed0(fG, {_g = $0}, {g in strictMap(_a,_b,_c,_d,_e,_f,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r) {($0,$1,$2,$3,$4,$5,g,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)}})
            .whenTheySucceed0(fH, {_h = $0}, {h in strictMap(_a,_b,_c,_d,_e,_f,_g,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r) {($0,$1,$2,$3,$4,$5,$6,h,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)}})
            .whenTheySucceed0(fI, {_i = $0}, {i in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_j,_k,_l,_m,_n,_o,_p,_q,_r) {($0,$1,$2,$3,$4,$5,$6,$7,i,$8,$9,$10,$11,$12,$13,$14,$15,$16)}})
            .whenTheySucceed0(fJ, {_j = $0}, {j in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_k,_l,_m,_n,_o,_p,_q,_r) {($0,$1,$2,$3,$4,$5,$6,$7,$8,j,$9,$10,$11,$12,$13,$14,$15,$16)}})
            .whenTheySucceed0(fK, {_k = $0}, {k in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_l,_m,_n,_o,_p,_q,_r) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,k,$10,$11,$12,$13,$14,$15,$16)}})
            .whenTheySucceed0(fL, {_l = $0}, {l in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_m,_n,_o,_p,_q,_r) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,l,$11,$12,$13,$14,$15,$16)}})
            .whenTheySucceed0(fM, {_m = $0}, {m in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_n,_o,_p,_q,_r) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,m,$12,$13,$14,$15,$16)}})
            .whenTheySucceed0(fN, {_n = $0}, {n in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_o,_p,_q,_r) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,n,$13,$14,$15,$16)}})
            .whenTheySucceed0(fO, {_o = $0}, {o in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_p,_q,_r) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,o,$14,$15,$16)}})
            .whenTheySucceed0(fP, {_p = $0}, {p in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_q,_r) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,p,$15,$16)}})
            .whenTheySucceed0(fQ, {_q = $0}, {q in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_r) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,q,$16)}})
            .whenTheySucceed0(fR, {_r = $0}, {r in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,r)}})
            .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 19.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>, _ fH: EventLoopFuture<H>, _ fI: EventLoopFuture<I>, _ fJ: EventLoopFuture<J>, _ fK: EventLoopFuture<K>, _ fL: EventLoopFuture<L>, _ fM: EventLoopFuture<M>, _ fN: EventLoopFuture<N>, _ fO: EventLoopFuture<O>, _ fP: EventLoopFuture<P>, _ fQ: EventLoopFuture<Q>, _ fR: EventLoopFuture<R>, _ fS: EventLoopFuture<S>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S)> where Value == (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?, _h: H?, _i: I?, _j: J?, _k: K?, _l: L?, _m: M?, _n: N?, _o: O?, _p: P?, _q: Q?, _r: R?, _s: S?

        return promise
        .whenTheySucceed0(fA, {_a = $0}, {a in strictMap(_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s) {(a,$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fB, {_b = $0}, {b in strictMap(_a,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s) {($0,b,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fC, {_c = $0}, {c in strictMap(_a,_b,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s) {($0,$1,c,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fD, {_d = $0}, {d in strictMap(_a,_b,_c,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s) {($0,$1,$2,d,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fE, {_e = $0}, {e in strictMap(_a,_b,_c,_d,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s) {($0,$1,$2,$3,e,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fF, {_f = $0}, {f in strictMap(_a,_b,_c,_d,_e,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s) {($0,$1,$2,$3,$4,f,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fG, {_g = $0}, {g in strictMap(_a,_b,_c,_d,_e,_f,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s) {($0,$1,$2,$3,$4,$5,g,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fH, {_h = $0}, {h in strictMap(_a,_b,_c,_d,_e,_f,_g,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s) {($0,$1,$2,$3,$4,$5,$6,h,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fI, {_i = $0}, {i in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s) {($0,$1,$2,$3,$4,$5,$6,$7,i,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fJ, {_j = $0}, {j in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_k,_l,_m,_n,_o,_p,_q,_r,_s) {($0,$1,$2,$3,$4,$5,$6,$7,$8,j,$9,$10,$11,$12,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fK, {_k = $0}, {k in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_l,_m,_n,_o,_p,_q,_r,_s) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,k,$10,$11,$12,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fL, {_l = $0}, {l in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_m,_n,_o,_p,_q,_r,_s) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,l,$11,$12,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fM, {_m = $0}, {m in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_n,_o,_p,_q,_r,_s) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,m,$12,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fN, {_n = $0}, {n in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_o,_p,_q,_r,_s) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,n,$13,$14,$15,$16,$17)}})
        .whenTheySucceed0(fO, {_o = $0}, {o in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_p,_q,_r,_s) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,o,$14,$15,$16,$17)}})
        .whenTheySucceed0(fP, {_p = $0}, {p in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_q,_r,_s) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,p,$15,$16,$17)}})
        .whenTheySucceed0(fQ, {_q = $0}, {q in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_r,_s) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,q,$16,$17)}})
        .whenTheySucceed0(fR, {_r = $0}, {r in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_s) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,r,$17)}})
        .whenTheySucceed0(fS, {_s = $0}, {s in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r) {($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,s)}})
        .futureResult
    }

    /// ``EventLoopFuture.whenTheySucceed(_:_:file:line:)`` of order 20.
    @inlinable
    public static func whenTheySucceed<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>(
        _ fA: EventLoopFuture<A>, _ fB: EventLoopFuture<B>, _ fC: EventLoopFuture<C>, _ fD: EventLoopFuture<D>, _ fE: EventLoopFuture<E>, _ fF: EventLoopFuture<F>, _ fG: EventLoopFuture<G>, _ fH: EventLoopFuture<H>, _ fI: EventLoopFuture<I>, _ fJ: EventLoopFuture<J>, _ fK: EventLoopFuture<K>, _ fL: EventLoopFuture<L>, _ fM: EventLoopFuture<M>, _ fN: EventLoopFuture<N>, _ fO: EventLoopFuture<O>, _ fP: EventLoopFuture<P>, _ fQ: EventLoopFuture<Q>, _ fR: EventLoopFuture<R>, _ fS: EventLoopFuture<S>, _ fT: EventLoopFuture<T>,
        file: StaticString = #file, line: UInt = #line
    ) -> EventLoopFuture<(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T)> where Value == (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T) {
        let promise = fA.eventLoop.makePromise(of: (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T).self, file: file, line: line)
        var _a: A?, _b: B?, _c: C?, _d: D?, _e: E?, _f: F?, _g: G?, _h: H?, _i: I?, _j: J?, _k: K?, _l: L?, _m: M?, _n: N?, _o: O?, _p: P?, _q: Q?, _r: R?, _s: S?, _t: T?

        return promise
        .whenTheySucceed0(fA,{_a=$0},{a in strictMap(_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s,_t){(a,$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fB,{_b=$0},{b in strictMap(_a,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s,_t){($0,b,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fC,{_c=$0},{c in strictMap(_a,_b,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s,_t){($0,$1,c,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fD,{_d=$0},{d in strictMap(_a,_b,_c,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s,_t){($0,$1,$2,d,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fE,{_e=$0},{e in strictMap(_a,_b,_c,_d,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s,_t){($0,$1,$2,$3,e,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fF,{_f=$0},{f in strictMap(_a,_b,_c,_d,_e,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s,_t){($0,$1,$2,$3,$4,f,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fG,{_g=$0},{g in strictMap(_a,_b,_c,_d,_e,_f,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s,_t){($0,$1,$2,$3,$4,$5,g,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fH,{_h=$0},{h in strictMap(_a,_b,_c,_d,_e,_f,_g,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s,_t){($0,$1,$2,$3,$4,$5,$6,h,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fI,{_i=$0},{i in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s,_t){($0,$1,$2,$3,$4,$5,$6,$7,i,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fJ,{_j=$0},{j in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_k,_l,_m,_n,_o,_p,_q,_r,_s,_t){($0,$1,$2,$3,$4,$5,$6,$7,$8,j,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fK,{_k=$0},{k in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_l,_m,_n,_o,_p,_q,_r,_s,_t){($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,k,$10,$11,$12,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fL,{_l=$0},{l in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_m,_n,_o,_p,_q,_r,_s,_t){($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,l,$11,$12,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fM,{_m=$0},{m in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_n,_o,_p,_q,_r,_s,_t){($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,m,$12,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fN,{_n=$0},{n in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_o,_p,_q,_r,_s,_t){($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,n,$13,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fO,{_o=$0},{o in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_p,_q,_r,_s,_t){($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,o,$14,$15,$16,$17,$18)}})
        .whenTheySucceed0(fP,{_p=$0},{p in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_q,_r,_s,_t){($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,p,$15,$16,$17,$18)}})
        .whenTheySucceed0(fQ,{_q=$0},{q in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_r,_s,_t){($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,q,$16,$17,$18)}})
        .whenTheySucceed0(fR,{_r=$0},{r in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_s,_t){($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,r,$17,$18)}})
        .whenTheySucceed0(fS,{_s=$0},{s in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_t){($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,s,$18)}})
        .whenTheySucceed0(fT,{_t=$0},{t in strictMap(_a,_b,_c,_d,_e,_f,_g,_h,_i,_j,_k,_l,_m,_n,_o,_p,_q,_r,_s){($0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,t)}})
        .futureResult
    }
}

extension EventLoopPromise {
    /// When the given future completes, hop back to our `EventLoop`. If the future failed, forward that failure onward
    /// immediately. Otherwise, see if the check callback returns a completed result, and forward that result onward if
    /// so. If not, just give the `put` callback the future's value. `self` is returned to simplify chaining multiple
    /// invocations.
    ///
    /// This is really just the reuslt of extracting as much of `.and()`'s implementation details as possible into a
    /// common implementation to simplify the already absurd tuple element count overloads.
    @inlinable
    internal/*private*/ func whenTheySucceed0<V>(_ future: EventLoopFuture<V>, _ put: @escaping (V) -> Void, _ check: @escaping (V) -> Value?) -> EventLoopPromise<Value> {
        future.hop(to: self.futureResult.eventLoop).whenComplete {
            switch $0 {
                case .failure(let error):
                    self.completeWith(.failure(error))
                case .success(let value):
                    if let output = check(value) {
                        self.completeWith(.success(output))
                    } else {
                        put(value)
                    }
            }
        }
        return self
    }
}
