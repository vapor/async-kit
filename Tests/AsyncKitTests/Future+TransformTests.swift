import XCTest
import AsyncKit
import NIOCore
import NIOPosix

class FutureTransformTests: XCTestCase {
    func testTransforms() throws {
        let future = eventLoop.makeSucceededFuture(Int.random(in: 0...100))
        
        XCTAssert(try future.transform(to: true).wait())
        
        let futureA = eventLoop.makeSucceededFuture(Int.random(in: 0...100))
        let futureB = eventLoop.makeSucceededFuture(Int.random(in: 0...100))
        
        XCTAssert(try futureA.and(futureB).transform(to: true).wait())
        
        let futureBool = eventLoop.makeSucceededFuture(true)
        
        XCTAssert(try future.transform(to: futureBool).wait())
        
        XCTAssert(try futureA.and(futureB).transform(to: futureBool).wait())
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
