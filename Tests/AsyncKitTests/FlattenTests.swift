import AsyncKit
import XCTest

final class FlattenTests: XCTestCase {
    func testELFlatten()throws {
        let futures = [
            self.eventLoop.makeSucceededFuture(1),
            self.eventLoop.makeSucceededFuture(2),
            self.eventLoop.makeSucceededFuture(3),
            self.eventLoop.makeSucceededFuture(4),
            self.eventLoop.makeSucceededFuture(5),
            self.eventLoop.makeSucceededFuture(6),
            self.eventLoop.makeSucceededFuture(7)
        ]
        
        let flattened = self.eventLoop.flatten(futures)
        try XCTAssertEqual(flattened.wait(), [1, 2, 3, 4, 5, 6, 7])
        
        let voids = [
            self.eventLoop.makeSucceededFuture(()),
            self.eventLoop.makeSucceededFuture(()),
            self.eventLoop.makeSucceededFuture(()),
            self.eventLoop.makeSucceededFuture(()),
            self.eventLoop.makeSucceededFuture(()),
            self.eventLoop.makeSucceededFuture(()),
            self.eventLoop.makeSucceededFuture(())
        ]
        
        let void = self.eventLoop.flatten(voids)
        try XCTAssert(void.wait() == ())
    }
    
    func testCollectionFlatten()throws {
        let futures = [
            self.eventLoop.makeSucceededFuture(1),
            self.eventLoop.makeSucceededFuture(2),
            self.eventLoop.makeSucceededFuture(3),
            self.eventLoop.makeSucceededFuture(4),
            self.eventLoop.makeSucceededFuture(5),
            self.eventLoop.makeSucceededFuture(6),
            self.eventLoop.makeSucceededFuture(7)
        ]
        
        let flattened = futures.flatten(on: self.eventLoop)
        try XCTAssertEqual(flattened.wait(), [1, 2, 3, 4, 5, 6, 7])
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
