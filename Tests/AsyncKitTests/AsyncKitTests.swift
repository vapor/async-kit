import XCTest
import AsyncKit

final class AsyncKitTests: XCTestCase {
    func testUniverseSanity() {
        print(self.eventLoop)
        XCTAssert(true)
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
