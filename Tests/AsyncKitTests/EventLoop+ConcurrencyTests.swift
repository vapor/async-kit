import XCTest
import AsyncKit
import NIOCore

final class EventLoopConcurrencyTests: AsyncKitTestCase {
    func testGroupMakeFutureWithTask() throws {
        @Sendable
        func getOne() async throws -> Int {
            return 1
        }
        let expectedOne = self.group.makeFutureWithTask {
            try await getOne()
        }
        
        XCTAssertEqual(try expectedOne.wait(), 1)
    }
}

