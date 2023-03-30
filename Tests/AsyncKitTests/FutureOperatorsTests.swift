import XCTest
import AsyncKit
import NIOCore
import NIOPosix

final class FutureOperatorTests: XCTestCase {
    func testAddition() throws {
        var future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)

        XCTAssertEqual(try (future1 + future2).wait(), 13)
        
        future1 += future2
        XCTAssertEqual(try future1.wait(), 13)
        
        var arrayFuture1 = eventLoop.makeSucceededFuture([1, 2, 3])
        let arrayFuture2 = eventLoop.makeSucceededFuture([4, 5, 6])
        
        XCTAssertEqual(try (arrayFuture1 + arrayFuture2).wait(), [1, 2, 3, 4, 5, 6])
        XCTAssertNotEqual(try (arrayFuture1 + arrayFuture2).wait(), try (arrayFuture2 + arrayFuture1).wait())
        
        arrayFuture1 += arrayFuture2
        XCTAssertEqual(try arrayFuture1.wait(), [1, 2, 3, 4, 5, 6])
    }
    
    func testSubtraction() throws {
        var future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)
        
        XCTAssertEqual(try (future1 - future2).wait(), 3)
        
        future1 -= future2
        XCTAssertEqual(try future1.wait(), 3)
        
        var arrayFuture1 = eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6])
        let arrayFuture2 = eventLoop.makeSucceededFuture([4, 5, 6])
        
        XCTAssertEqual(try (arrayFuture1 - arrayFuture2).wait(), [1, 2, 3])
        
        arrayFuture1 -= arrayFuture2
        XCTAssertEqual(try arrayFuture1.wait(), [1, 2, 3])
    }
    
    func testMultiplication() throws {
        var future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)
        
        XCTAssertEqual(try (future1 * future2).wait(), 40)
        
        future1 *= future2
        XCTAssertEqual(try future1.wait(), 40)
    }
    
    func testModulo() throws {
        var future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)
        
        XCTAssertEqual(try (future1 % future2).wait(), 3)
        
        future1 %= future2
        XCTAssertEqual(try future1.wait(), 3)
    }
    
    func testDivision() throws {
        var future1 = eventLoop.makeSucceededFuture(40)
        let future2 = eventLoop.makeSucceededFuture(5)
        
        XCTAssertEqual(try (future1 / future2).wait(), 8)
        
        future1 /= future2
        XCTAssertEqual(try future1.wait(), 8)
    }
    
    func testComparison() throws {
        let future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)
        let future3 = eventLoop.makeSucceededFuture(5)
        
        XCTAssert(try (future2 < future1).wait())
        XCTAssert(try (future2 <= future3).wait())
        XCTAssert(try (future2 >= future3).wait())
        XCTAssert(try (future1 > future3).wait())
    }

    func testBitshifts() throws {
        var future1 = eventLoop.makeSucceededFuture(255)
        let future2 = eventLoop.makeSucceededFuture(16)

        XCTAssertEqual(try (future1 << future2).wait(), 16711680)
        
        future1 <<= future2
        XCTAssertEqual(try future1.wait(), 16711680)
        
        var future3 = eventLoop.makeSucceededFuture(16711680)
        let future4 = eventLoop.makeSucceededFuture(16)
        
        XCTAssertEqual(try (future3 >> future4).wait(), 255)
        
        future3 >>= future4
        XCTAssertEqual(try future3.wait(), 255)
    }
    
    func testAND() throws {
        var future1 = eventLoop.makeSucceededFuture(200)
        let future2 = eventLoop.makeSucceededFuture(500)
        
        XCTAssertEqual(try (future1 & future2).wait(), 192)
        
        future1 &= future2
        XCTAssertEqual(try future1.wait(), 192)
    }
    
    func testXOR() throws {
        var future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)
        
        XCTAssertEqual(try (future1 ^ future2).wait(), 13)
        
        future1 ^= future2
        XCTAssertEqual(try future1.wait(), 13)
    }
    
    func testOR() throws {
        var future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)
        
        XCTAssertEqual(try (future1 | future2).wait(), 13)
        
        future1 |= future2
        XCTAssertEqual(try future1.wait(), 13)
    }
    
    func testNOT() throws {
        let future1: EventLoopFuture<UInt8> = eventLoop.makeSucceededFuture(0b00001111)
        XCTAssertEqual(try ~future1.wait(), 0b11110000)
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
