import XCTest
import AsyncKit
import NIOCore
import NIOPosix

final class EventLoopConcurrencyTests: XCTestCase {
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

