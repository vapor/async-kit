import XCTest
import AsyncKit

final class FutureMiscellaneousTests: XCTestCase {
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

    func testTryFutureThread() throws {
        // There is a known bug in Swift 5.2 and earlier that causes this result.
        // Skip check because it's been resolved in later versions and there's
        // not a lot we can do about it.
        #if swift(<5.3)
        try XCTSkipIf(true, "Thread.current.name is broken in Swift 5.2")
        #endif
        
        let future = self.eventLoop.tryFuture { Thread.current.name }
        let name = try XCTUnwrap(future.wait())

        XCTAssert(name.starts(with: "NIO-ELT"), "'\(name)' is not a valid NIO ELT name")
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
