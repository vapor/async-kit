import AsyncKit
import NIOCore
import Testing

@Suite
struct FutureConjunctionTests {
    @Test
    func trivialStrictMapCorrectness() {
        #expect(strictMap(()) { $0 } != nil)
        #expect(strictMap(Void?.none) { _ in () } == nil)
        
        #expect(strictMap((), ()) { $1 } != nil)
        #expect(strictMap(Void?.none, ()) { $1 } == nil)
        #expect(strictMap((), Void?.none) { $1 } == nil)
        #expect(strictMap(Void?.none, Void?.none) { $1 } == nil)

        #expect(strictMap((), (), ()) { $2 } != nil)
        #expect(strictMap(Void?.none, (), ()) { $2 } == nil)
        #expect(strictMap((), Void?.none, ()) { $2 } == nil)
        #expect(strictMap((), (), Void?.none) { $2 } == nil)
        #expect(strictMap(Void?.none, Void?.none, ()) { $2 } == nil)
        #expect(strictMap(Void?.none, (), Void?.none) { $2 } == nil)
        #expect(strictMap((), Void?.none, Void?.none) { $2 } == nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none) { $2 } == nil)

        #expect(strictMap((), (), (), ()) { $3 } != nil)
        #expect(strictMap(Void?.none, (), (), ()) { $3 } == nil)
        #expect(strictMap((), Void?.none, (), ()) { $3 } == nil)
        #expect(strictMap((), (), Void?.none, ()) { $3 } == nil)
        #expect(strictMap((), (), (), Void?.none) { $3 } == nil)
        #expect(strictMap(Void?.none, Void?.none, (), ()) { $3 } == nil)
        #expect(strictMap(Void?.none, (), Void?.none, ()) { $3 } == nil)
        #expect(strictMap(Void?.none, (), (), Void?.none) { $3 } == nil)
        #expect(strictMap((), Void?.none, Void?.none, ()) { $3 } == nil)
        #expect(strictMap((), Void?.none, (), Void?.none) { $3 } == nil)
        #expect(strictMap((), (), Void?.none, Void?.none) { $3 } == nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, ()) { $3 } == nil)
        #expect(strictMap(Void?.none, Void?.none, (), Void?.none) { $3 } == nil)
        #expect(strictMap(Void?.none, (), Void?.none, Void?.none) { $3 } == nil)
        #expect(strictMap((), Void?.none, Void?.none, Void?.none) { $3 } == nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none) { $3 } == nil)

        // The full test set gets absurd after more or less this point so just do the minimums to satisfy test coverage
        #expect(strictMap((), (), (), (), ()) { $4 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $4 } == nil)
        #expect(strictMap((), (), (), (), (), ()) { $5 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $5 } == nil)
        #expect(strictMap((), (), (), (), (), (), ()) { $6 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $6 } == nil)
        #expect(strictMap((), (), (), (), (), (), (), ()) { $7 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $7 } == nil)
        #expect(strictMap((), (), (), (), (), (), (), (), ()) { $8 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $8 } == nil)
        #expect(strictMap((), (), (), (), (), (), (), (), (), ()) { $9 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $9 } == nil)
        #expect(strictMap((), (), (), (), (), (), (), (), (), (), ()) { $10 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $10 } == nil)
        #expect(strictMap((), (), (), (), (), (), (), (), (), (), (), ()) { $11 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $11 } == nil)
        #expect(strictMap((), (), (), (), (), (), (), (), (), (), (), (), ()) { $12 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $12 } == nil)
        #expect(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $13 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $13 } == nil)
        #expect(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $14 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $14 } == nil)
        #expect(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $15 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $15 } == nil)
        #expect(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $16 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $16 } == nil)
        #expect(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $17 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $17 } == nil)
        #expect(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $18 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $18 } == nil)
        #expect(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $19 } != nil)
        #expect(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $19 } == nil)
    }

    @Test
    func trivialWhenTheySucceedCorectness() async throws {
        let el1 = NIOSingletons.posixEventLoopGroup.any()
        let el2 = NIOSingletons.posixEventLoopGroup.any()
        
        let f1 = el1.submit { return "string value" }
        let f2 = el1.submit { return Int.min }
        let f3 = el2.submit { return true }
        
        let result = try await EventLoopFuture.whenTheySucceed(f1, f2, f3).get()

        #expect(result.0 == "string value")
        #expect(result.1 == Int.min)
        #expect(result.2 == true)
    }
    
    func testInvokingAllVariantsOfWhenTheySucceed() async throws {
        // Yes, this test is using futures that are all the same type and thus could be passed to
        // `whenAllSucceed()` instead of `whenTheySucceed()`. Doesn't matter - the point in this
        // test is to cover all the variants for minimum correctness, not test full functionality.
        do {
            let f = (0 ..< 2).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1]).get()
            #expect(r.0 == 0 && r.1 == 1)
        }
        do {
            let f = (0 ..< 3).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2)
        }
        do {
            let f = (0 ..< 4).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3)
        }
        do {
            let f = (0 ..< 5).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4)
        }
        do {
            let f = (0 ..< 6).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5)
        }
        do {
            let f = (0 ..< 7).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6)
        }
        do {
            let f = (0 ..< 8).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7)
        }
        do {
            let f = (0 ..< 9).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8)
        }
        do {
            let f = (0 ..< 10).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9)
        }
        do {
            let f = (0 ..< 11).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10)
        }
        do {
            let f = (0 ..< 12).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11)
        }
        do {
            let f = (0 ..< 13).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12)
        }
        do {
            let f = (0 ..< 14).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13)
        }
        do {
            let f = (0 ..< 15).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13], f[14]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13 && r.14 == 14)
        }
        do {
            let f = (0 ..< 16).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13], f[14], f[15]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13 && r.14 == 14 && r.15 == 15)
        }
        do {
            let f = (0 ..< 17).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13], f[14], f[15], f[16]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13 && r.14 == 14 && r.15 == 15 && r.16 == 16)
        }
        do {
            let f = (0 ..< 18).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13], f[14], f[15], f[16], f[17]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13 && r.14 == 14 && r.15 == 15 && r.16 == 16 && r.17 == 17)
        }
        do {
            let f = (0 ..< 19).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13], f[14], f[15], f[16], f[17], f[18]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13 && r.14 == 14 && r.15 == 15 && r.16 == 16 && r.17 == 17 && r.18 == 18)
        }
        do {
            let f = (0 ..< 20).map { n in NIOSingletons.posixEventLoopGroup.any().submit { n } }
            let r = try await EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13], f[14], f[15], f[16], f[17], f[18], f[19]).get()
            #expect(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13 && r.14 == 14 && r.15 == 15 && r.16 == 16 && r.17 == 17 && r.18 == 18 && r.19 == 19)
        }
    }
}
