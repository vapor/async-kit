import XCTest
import AsyncKit
import NIOCore
import NIOPosix

final class FutureNonemptyTests: XCTestCase {
    func testNonempty() {
        try XCTAssertNoThrow(self.eventLoop.future([0]).nonempty(orError: TestError.notEqualTo1).wait())
        try XCTAssertThrowsError(self.eventLoop.future([]).nonempty(orError: TestError.notEqualTo1).wait())
        
        XCTAssertEqual(try self.eventLoop.future([0]).nonemptyMap(or: 1, { $0[0] }).wait(), 0)
        XCTAssertEqual(try self.eventLoop.future([]).nonemptyMap(or: 1, { $0[0] }).wait(), 1)

        XCTAssertEqual(try self.eventLoop.future([0]).nonemptyMap({ [$0[0]] }).wait(), [0])
        XCTAssertEqual(try self.eventLoop.future([Int]()).nonemptyMap({ [$0[0]] }).wait(), [])

        XCTAssertEqual(try self.eventLoop.future([0]).nonemptyFlatMapThrowing(or: 1, { (a) throws -> Int in a[0] }).wait(), 0)
        XCTAssertEqual(try self.eventLoop.future([]).nonemptyFlatMapThrowing(or: 1, { (a) throws -> Int in a[0] }).wait(), 1)

        XCTAssertEqual(try self.eventLoop.future([0]).nonemptyFlatMapThrowing({ (a) throws -> [Int] in [a[0]] }).wait(), [0])
        XCTAssertEqual(try self.eventLoop.future([Int]()).nonemptyFlatMapThrowing({ (a) throws -> [Int] in [a[0]] }).wait(), [])

        XCTAssertEqual(try self.eventLoop.future([0]).nonemptyFlatMap(or: 1, { self.eventLoop.future($0[0]) }).wait(), 0)
        XCTAssertEqual(try self.eventLoop.future([]).nonemptyFlatMap(or: 1, { self.eventLoop.future($0[0]) }).wait(), 1)

        XCTAssertEqual(try self.eventLoop.future([0]).nonemptyFlatMap(orFlat: self.eventLoop.future(1), { self.eventLoop.future($0[0]) }).wait(), 0)
        XCTAssertEqual(try self.eventLoop.future([]).nonemptyFlatMap(orFlat: self.eventLoop.future(1), { self.eventLoop.future($0[0]) }).wait(), 1)

        XCTAssertEqual(try self.eventLoop.future([0]).nonemptyFlatMap({ self.eventLoop.future([$0[0]]) }).wait(), [0])
        XCTAssertEqual(try self.eventLoop.future([Int]()).nonemptyFlatMap({ self.eventLoop.future([$0[0]]) }).wait(), [])
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
