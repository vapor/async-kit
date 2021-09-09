import AsyncKit
import XCTest
import NIO
import NIOConcurrencyHelpers

extension EventLoopGroup {
    func spinAll(on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        assert(self.makeIterator().contains(where: { ObjectIdentifier($0) == ObjectIdentifier(eventLoop) }))
        
        return .andAllSucceed(self.makeIterator().map { $0.submit {} }, on: eventLoop)
    }
}

final class FutureCollectionTests: XCTestCase {
    func testMapEach() throws {
        let collection = eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6, 7, 8, 9])
        let times2 = collection.mapEach { int -> Int in int * 2 }
        
        try XCTAssertEqual(times2.wait(), [2, 4, 6, 8, 10, 12, 14, 16, 18])
    }
    
    func testCompactMapEach() throws {
        let collection = self.eventLoop.makeSucceededFuture(["one", "2", "3", "4", "five", "^", "7"])
        let times2 = collection.mapEachCompact(Int.init)
        
        try XCTAssertEqual(times2.wait(), [2, 3, 4, 7])
    }
    
    func testFlatMapEach() throws {
        let collection = eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6, 7, 8, 9])
        let times2 = collection.flatMapEach(on: self.eventLoop) { int -> EventLoopFuture<Int> in
            return self.eventLoop.makeSucceededFuture(int * 2)
        }
        
        try XCTAssertEqual(times2.wait(), [2, 4, 6, 8, 10, 12, 14, 16, 18])
    }

    func testFlatMapEachVoid() throws {
        let expectation = XCTestExpectation(description: "futures all succeeded")
        expectation.assertForOverFulfill = true
        expectation.expectedFulfillmentCount = 9
        
        let collection = self.eventLoop.makeSucceededFuture(1 ... 9)
        let nothing = collection.flatMapEach(on: self.eventLoop) { _ in expectation.fulfill(); return self.eventLoop.makeSucceededVoidFuture() }
        
        _ = try nothing.wait()
        XCTAssertEqual(XCTWaiter().wait(for: [expectation], timeout: 10.0), .completed)
    }
    
    func testFlatMapEachCompact() throws {
        let collection = self.eventLoop.makeSucceededFuture(["one", "2", "3", "4", "five", "^", "7"])
        let times2 = collection.flatMapEachCompact(on: self.eventLoop) { int -> EventLoopFuture<Int?> in
            return self.eventLoop.makeSucceededFuture(Int(int))
        }
        
        try XCTAssertEqual(times2.wait(), [2, 3, 4, 7])
    }
    
    func testFlatMapEachThrowing() throws {
        struct SillyRangeError: Error {}
        let collection = eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6, 7, 8, 9])
        let times2 = collection.flatMapEachThrowing { int -> Int in
            guard int < 8 else { throw SillyRangeError() }
            return int * 2
        }
        
        XCTAssertThrowsError(try times2.wait())
    }
    
    func testFlatMapEachCompactThrowing() throws {
        struct SillyRangeError: Error {}
        let collection = self.eventLoop.makeSucceededFuture(["one", "2", "3", "4", "five", "^", "7"])
        let times2 = collection.flatMapEachCompactThrowing { str -> Int? in Int(str) }
        let times2Badly = collection.flatMapEachCompactThrowing { str -> Int? in
            guard let result = Int(str) else { return nil }
            guard result < 4 else { throw SillyRangeError() }
            return result
        }
        
        try XCTAssertEqual(times2.wait(), [2, 3, 4, 7])
        XCTAssertThrowsError(try times2Badly.wait())
    }
    
    func testSequencedFlatMapEach() throws {
        struct SillyRangeError: Error {}
        var value = 0
        let lock = Lock()
        let collection = eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6, 7, 8, 9])
        let times2 = collection.sequencedFlatMapEach { int -> EventLoopFuture<Int> in
            lock.withLock { value = Swift.max(value, int) }
            guard int < 5 else { return self.group.spinAll(on: self.eventLoop).flatMapThrowing { throw SillyRangeError() } }
            return self.eventLoop.makeSucceededFuture(int * 2)
        }
        
        XCTAssertThrowsError(try times2.wait())
        XCTAssertLessThan(lock.withLock { value }, 6)
    }

    func testSequencedFlatMapVoid() throws {
        struct SillyRangeError: Error {}
        var value = 0
        let lock = Lock()
        let collection = eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6, 7, 8, 9])
        let times2 = collection.sequencedFlatMapEach { int -> EventLoopFuture<Void> in
            lock.withLock { value = Swift.max(value, int) }
            guard int < 5 else { return self.group.spinAll(on: self.eventLoop).flatMapThrowing { throw SillyRangeError() } }
            return self.eventLoop.makeSucceededFuture(())
        }
        
        XCTAssertThrowsError(try times2.wait())
        XCTAssertLessThan(lock.withLock { value }, 6)
    }

    func testSequencedFlatMapEachCompact() throws {
        struct SillyRangeError: Error {}
        var last = ""
        let lock = Lock()
        let collection = self.eventLoop.makeSucceededFuture(["one", "2", "3", "not", "4", "1", "five", "^", "7"])
        let times2 = collection.sequencedFlatMapEachCompact { val -> EventLoopFuture<Int?> in
            guard let int = Int(val) else { return self.eventLoop.makeSucceededFuture(nil) }
            guard int < 4 else { return self.group.spinAll(on: self.eventLoop).flatMapThrowing { throw SillyRangeError() } }
            lock.withLock { last = val }
            return self.eventLoop.makeSucceededFuture(int * 2)
        }
        
        XCTAssertThrowsError(try times2.wait())
        XCTAssertEqual(lock.withLock { last }, "3")
    }

    func testELSequencedFlatMapEach() throws {
        struct SillyRangeError: Error {}
        var value = 0
        let lock = Lock()
        let collection = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        let times2 = collection.sequencedFlatMapEach(on: self.eventLoop) { int -> EventLoopFuture<Int> in
            lock.withLock { value = Swift.max(value, int) }
            guard int < 5 else { return self.group.spinAll(on: self.eventLoop).flatMapThrowing { throw SillyRangeError() } }
            return self.eventLoop.makeSucceededFuture(int * 2)
        }
        
        XCTAssertThrowsError(try times2.wait())
        XCTAssertLessThan(lock.withLock { value }, 6)
    }

    func testELSequencedFlatMapVoid() throws {
        struct SillyRangeError: Error {}
        var value = 0
        let lock = Lock()
        let collection = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        let times2 = collection.sequencedFlatMapEach(on: self.eventLoop) { int -> EventLoopFuture<Void> in
            lock.withLock { value = Swift.max(value, int) }
            guard int < 5 else { return self.group.spinAll(on: self.eventLoop).flatMapThrowing { throw SillyRangeError() } }
            return self.eventLoop.makeSucceededFuture(())
        }
        
        XCTAssertThrowsError(try times2.wait())
        XCTAssertLessThan(lock.withLock { value }, 6)
    }

    func testELSequencedFlatMapEachCompact() throws {
        struct SillyRangeError: Error {}
        var last = ""
        let lock = Lock()
        let collection = ["one", "2", "3", "not", "4", "1", "five", "^", "7"]
        let times2 = collection.sequencedFlatMapEachCompact(on: self.eventLoop) { val -> EventLoopFuture<Int?> in
            guard let int = Int(val) else { return self.eventLoop.makeSucceededFuture(nil) }
            guard int < 4 else { return self.group.spinAll(on: self.eventLoop).flatMapThrowing { throw SillyRangeError() } }
            lock.withLock { last = val }
            return self.eventLoop.makeSucceededFuture(int * 2)
        }
        
        XCTAssertThrowsError(try times2.wait())
        XCTAssertEqual(lock.withLock { last }, "3")
    }

    /// This test case's EventLoopGroup
    var group: EventLoopGroup!
    
    /// Returns the next EventLoop from the `group`
    var eventLoop: EventLoop {
        return self.group.next()
    }
    
    /// Sets up the TestCase for use
    /// and initializes the EventLoopGroup
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
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
