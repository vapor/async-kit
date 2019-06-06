import AsyncKit
import XCTest

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
    
    /// This TestCases EventLoopGroup
    var group: EventLoopGroup!
    
    /// Returns the next EventLoop from the `group`
    var eventLoop: EventLoop {
        return self.group.next()
    }
    
    /// Sets up the TestCase for use
    /// and initializes the EventLoopGroup
    override func setUp() {
        super.setUp()
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }
    
    /// Tears down the TestCase and
    /// shuts down the EventLoopGroup
    override func tearDown() {
        XCTAssertNoThrow(try self.group.syncShutdownGracefully())
        self.group = nil
        super.tearDown()
    }
}

