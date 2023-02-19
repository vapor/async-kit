import AsyncKit
import XCTest
import NIOCore
import NIOPosix

final class EventLoopGroupFutureTests: XCTestCase {
    func testFutureVoid() throws {
        try XCTAssertNoThrow(self.group.future().wait())
        try XCTAssertNoThrow(self.eventLoop.future().wait())
    }
    
    func testFuture() throws {
        try XCTAssertEqual(self.group.future(1).wait(), 1)
        try XCTAssertEqual(self.eventLoop.future(1).wait(), 1)
        
        try XCTAssertEqual(self.group.future(true).wait(), true)
        try XCTAssertEqual(self.eventLoop.future("foo").wait(), "foo")
    }
    
    func testFutureError() throws {
        let groupErr: EventLoopFuture<Int> = self.group.future(error: TestError.notEqualTo1)
        let eventLoopErr: EventLoopFuture<String> = self.eventLoop.future(error: TestError.notEqualToBar)
        
        try XCTAssertThrowsError(groupErr.wait())
        try XCTAssertThrowsError(eventLoopErr.wait())
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
