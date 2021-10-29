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

    func testTryFutureThread() throws {
        let future = self.eventLoop.tryFuture { Thread.current.name }
        let name = try XCTUnwrap(future.wait())

        #if swift(>=5.3)
        XCTAssert(name.starts(with: "NIO-ELT"), "'\(name)' is not a valid NIO ELT name")
        #else
        // There is a known bug in Swift 5.2 and earlier that causes this result.
        // Skip check because it's been resolved in later versions and theres
        // not a lot we can do about it.
        XCTAssertEqual(name, "")
        #endif
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
    
#if compiler(>=5.5) && canImport(_Concurrency)
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func testPerformWithTask() throws {
        @Sendable
        func getOne() async throws -> Int {
            return 1
        }
        let expectedOne = self.eventLoop.performWithTask {
            try await getOne()
        }
        
        XCTAssertEqual(try expectedOne.wait(), 1)
    }
#endif
    
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
