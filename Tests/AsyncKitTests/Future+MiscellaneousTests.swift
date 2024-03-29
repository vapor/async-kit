import XCTest
import AsyncKit
import NIOCore

final class FutureMiscellaneousTests: AsyncKitTestCase {
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
        let future = self.eventLoop.tryFuture { Thread.current.name }
        let name = try XCTUnwrap(future.wait())

        XCTAssert(name.starts(with: "NIO-ELT"), "'\(name)' is not a valid NIO ELT name")
    }
}
