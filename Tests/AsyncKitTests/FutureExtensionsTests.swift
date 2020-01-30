import XCTest
import AsyncKit

final class FutureExtensionsTests: XCTestCase {
    func testGuard() {
        let future1 = eventLoop.makeSucceededFuture(1)
        let guardedFuture1 = future1.guard({ $0 == 1 }, else: TestError.notEqualTo1)
        XCTAssertNoThrow(try guardedFuture1.wait())
        
        let future2 = eventLoop.makeSucceededFuture("foo")
        let guardedFuture2 = future2.guard({ $0 == "bar" }, else: TestError.notEqualToBar)
        XCTAssertThrowsError(try guardedFuture2.wait())
    }
    
    func testTryThrowing() {
        let future1: EventLoopFuture<String> = eventLoop.tryFuture { return "Hello" }
        let future2: EventLoopFuture<String> = eventLoop.tryFuture { throw TestError.notEqualTo1 }
        var value: String = ""
        
        try XCTAssertNoThrow(value = future1.wait())
        XCTAssertEqual(value, "Hello")
        try XCTAssertThrowsError(future2.wait())
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

enum TestError: Error {
    case notEqualTo1
    case notEqualToBar
}
