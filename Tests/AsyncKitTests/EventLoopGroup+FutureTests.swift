import AsyncKit
import XCTest
import NIOCore

final class EventLoopGroupFutureTests: AsyncKitTestCase {
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
}
