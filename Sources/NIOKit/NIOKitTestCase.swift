import NIO
import XCTest

/// Utilitarian class to create tests that need an EventLoop
///
///     class MyTestCase: NIOKitTestCase {
///         
///         func testSomeFuture() throws {
///             XCTAssertEqual(self.eventLoop.makeSucceededFuture(8).wait(), 8)
///         }
///     }
///
open class NIOKitTestCase: XCTestCase {
    /// This TestCases EventLoopGroup
    open var group: EventLoopGroup!
    
    /// Returns the next EventLoop from the `group`
    open var eventLoop: EventLoop {
        return self.group.next()
    }
    
    /// Sets up the TestCase for use
    /// and initializes the EventLoopGroup
    override open func setUp() {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        setupGroup()
    }
    
    /// Tears down the TestCase and
    /// shuts down the EventLoopGroup
    override open func tearDown() {
        XCTAssertNoThrow(try self.group.syncShutdownGracefully())
        self.group = nil
        super.tearDown()
    }
}
