import XCTest
import NIO
@testable import NIOKit

public final class FutureExtensionsTests: NIOKitTestCase {
    func testGuard() {
        let future1 = eventLoop.makeSucceededFuture(1)
        let guardedFuture1 = future1.guard({ $0 == 1 }, else: TestError.notEqualTo1)
        XCTAssertNoThrow(try guardedFuture1.wait())
        
        let future2 = eventLoop.makeSucceededFuture("foo")
        let guardedFuture2 = future2.guard({ $0 == "bar" }, else: TestError.notEqualToBar)
        XCTAssertThrowsError(try guardedFuture2.wait())
    }
    
    public static var allTests = [
        ("testGuard", testGuard),
    ]
}

enum TestError: Error {
    case notEqualTo1
    case notEqualToBar
}
