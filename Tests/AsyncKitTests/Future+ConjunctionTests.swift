import AsyncKit
import XCTest
import NIO

final class FutureConjunctionTests: XCTestCase {
    var group: EventLoopGroup!
    
    var eventLoop: EventLoop { self.group.next() }
        
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 2)
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
    }
    
    func testTrivialWhenTheySucceedCorectness() throws {
        let el1 = self.group.next()
        let el2 = self.group.next()
        
        let f1 = el1.submit { return "string value" }
        let f2 = el1.submit { return Int.min }
        let f3 = el2.submit { return true }
        
        let result = try EventLoopFuture.whenTheySucceed(f1, f2, f3).wait()
        
        XCTAssertEqual(result.0, "string value")
        XCTAssertEqual(result.1, Int.min)
        XCTAssertEqual(result.2, true)
    }
}
