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
    
    /// This TestCases EventLoopGroup
    var group: EventLoopGroup!
    
    /// Returns the next EventLoop from the `group`
    var eventLoop: EventLoop {
        return self.group.next()
    }
    
    /// Sets up the TestCase for use
    /// and initializes the EventLoopGroup
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    /// Tears down the TestCase and
    /// shuts down the EventLoopGroup
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

enum TestError: Error {
    case notEqualTo1
    case notEqualToBar
}
