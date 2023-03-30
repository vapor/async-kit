import AsyncKit
import XCTest
import NIO

final class FutureConjunctionTests: XCTestCase {
    func testTrivialStrictMapCorrectness() throws {
        XCTAssertNotNil(strictMap(()) { $0 })
        XCTAssertNil(strictMap(Void?.none) { _ in () })
        
        XCTAssertNotNil(strictMap((), ()) { $1 })
        XCTAssertNil(strictMap(Void?.none, ()) { $1 })
        XCTAssertNil(strictMap((), Void?.none) { $1 })
        XCTAssertNil(strictMap(Void?.none, Void?.none) { $1 })

        XCTAssertNotNil(strictMap((), (), ()) { $2 })
        XCTAssertNil(strictMap(Void?.none, (), ()) { $2 })
        XCTAssertNil(strictMap((), Void?.none, ()) { $2 })
        XCTAssertNil(strictMap((), (), Void?.none) { $2 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, ()) { $2 })
        XCTAssertNil(strictMap(Void?.none, (), Void?.none) { $2 })
        XCTAssertNil(strictMap((), Void?.none, Void?.none) { $2 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none) { $2 })

        XCTAssertNotNil(strictMap((), (), (), ()) { $3 })
        XCTAssertNil(strictMap(Void?.none, (), (), ()) { $3 })
        XCTAssertNil(strictMap((), Void?.none, (), ()) { $3 })
        XCTAssertNil(strictMap((), (), Void?.none, ()) { $3 })
        XCTAssertNil(strictMap((), (), (), Void?.none) { $3 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, (), ()) { $3 })
        XCTAssertNil(strictMap(Void?.none, (), Void?.none, ()) { $3 })
        XCTAssertNil(strictMap(Void?.none, (), (), Void?.none) { $3 })
        XCTAssertNil(strictMap((), Void?.none, Void?.none, ()) { $3 })
        XCTAssertNil(strictMap((), Void?.none, (), Void?.none) { $3 })
        XCTAssertNil(strictMap((), (), Void?.none, Void?.none) { $3 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, ()) { $3 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, (), Void?.none) { $3 })
        XCTAssertNil(strictMap(Void?.none, (), Void?.none, Void?.none) { $3 })
        XCTAssertNil(strictMap((), Void?.none, Void?.none, Void?.none) { $3 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none) { $3 })

        // The full test set gets absurd after more or less this point so just do the minimums to satisfy test coverage
        XCTAssertNotNil(strictMap((), (), (), (), ()) { $4 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $4 })
        XCTAssertNotNil(strictMap((), (), (), (), (), ()) { $5 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $5 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), ()) { $6 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $6 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), (), ()) { $7 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $7 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), (), (), ()) { $8 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $8 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), (), (), (), ()) { $9 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $9 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), (), (), (), (), ()) { $10 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $10 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), (), (), (), (), (), ()) { $11 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $11 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), (), (), (), (), (), (), ()) { $12 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $12 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $13 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $13 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $14 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $14 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $15 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $15 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $16 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $16 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $17 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $17 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $18 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $18 })
        XCTAssertNotNil(strictMap((), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), ()) { $19 })
        XCTAssertNil(strictMap(Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none, Void?.none) { $19 })
    }
    
    func testTrivialWhenTheySucceedCorectness() throws {
        let el1 = self.group.any()
        let el2 = self.group.any()
        
        let f1 = el1.submit { return "string value" }
        let f2 = el1.submit { return Int.min }
        let f3 = el2.submit { return true }
        
        let result = try EventLoopFuture.whenTheySucceed(f1, f2, f3).wait()
        
        XCTAssertEqual(result.0, "string value")
        XCTAssertEqual(result.1, Int.min)
        XCTAssertEqual(result.2, true)
    }
    
    func testInvokingAllVariantsOfWhenTheySucceed() throws {
        // Yes, this test is using futures that are all the same type and thus could be passed to
        // `whenAllSucceed()` instead of `whenTheySucceed()`. Doesn't matter - the point in this
        // test is to cover all the variants for minimum correctness, not test full functionality.
        do {
            let f = (0 ..< 2).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1)
        }
        do {
            let f = (0 ..< 3).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2)
        }
        do {
            let f = (0 ..< 4).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3)
        }
        do {
            let f = (0 ..< 5).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4)
        }
        do {
            let f = (0 ..< 6).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5)
        }
        do {
            let f = (0 ..< 7).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6)
        }
        do {
            let f = (0 ..< 8).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7)
        }
        do {
            let f = (0 ..< 9).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8)
        }
        do {
            let f = (0 ..< 10).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9)
        }
        do {
            let f = (0 ..< 11).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10)
        }
        do {
            let f = (0 ..< 12).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11)
        }
        do {
            let f = (0 ..< 13).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12)
        }
        do {
            let f = (0 ..< 14).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13)
        }
        do {
            let f = (0 ..< 15).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13], f[14]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13 && r.14 == 14)
        }
        do {
            let f = (0 ..< 16).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13], f[14], f[15]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13 && r.14 == 14 && r.15 == 15)
        }
        do {
            let f = (0 ..< 17).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13], f[14], f[15], f[16]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13 && r.14 == 14 && r.15 == 15 && r.16 == 16)
        }
        do {
            let f = (0 ..< 18).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13], f[14], f[15], f[16], f[17]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13 && r.14 == 14 && r.15 == 15 && r.16 == 16 && r.17 == 17)
        }
        do {
            let f = (0 ..< 19).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13], f[14], f[15], f[16], f[17], f[18]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13 && r.14 == 14 && r.15 == 15 && r.16 == 16 && r.17 == 17 && r.18 == 18)
        }
        do {
            let f = (0 ..< 20).map { n in self.eventLoop.submit { n } }
            let r = try EventLoopFuture.whenTheySucceed(f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11], f[12], f[13], f[14], f[15], f[16], f[17], f[18], f[19]).wait()
            XCTAssert(r.0 == 0 && r.1 == 1 && r.2 == 2 && r.3 == 3 && r.4 == 4 && r.5 == 5 && r.6 == 6 && r.7 == 7 && r.8 == 8 && r.9 == 9 && r.10 == 10 && r.11 == 11 && r.12 == 12 && r.13 == 13 && r.14 == 14 && r.15 == 15 && r.16 == 16 && r.17 == 17 && r.18 == 18 && r.19 == 19)
        }
    }

    var group: EventLoopGroup!
    var eventLoop: EventLoop { self.group.any() }

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    override func tearDownWithError() throws {
        try self.group.syncShutdownGracefully()
        self.group = nil
        try super.tearDownWithError()
    }

    override class func setUp() {
        super.setUp()
        XCTAssertTrue(isLoggingConfigured)
    }
}
