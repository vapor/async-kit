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
        let collection1 = self.eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6, 7, 8, 9])
        let times2 = collection1.mapEach { int -> Int in int * 2 }
        
        try XCTAssertEqual(times2.wait(), [2, 4, 6, 8, 10, 12, 14, 16, 18])
        
        let collection2 = self.eventLoop.makeSucceededFuture(["a", "bb", "ccc", "dddd", "eeeee"])
        let lengths = collection2.mapEach(\.count)
        
        try XCTAssertEqual(lengths.wait(), [1, 2, 3, 4, 5])
    
    }
    
    func testMapEachCompact() throws {
        let collection1 = self.eventLoop.makeSucceededFuture(["one", "2", "3", "4", "five", "^", "7"])
        let times2 = collection1.mapEachCompact(Int.init)
        
        try XCTAssertEqual(times2.wait(), [2, 3, 4, 7])
        
        let collection2 = self.eventLoop.makeSucceededFuture(["asdf", "qwer", "zxcv", ""])
        let letters = collection2.mapEachCompact(\.first)
        try XCTAssertEqual(letters.wait(), ["a", "q", "z"])
    }
    
    func testMapEachFlat() throws {
        let collection1 = self.eventLoop.makeSucceededFuture([[1, 2, 3], [9, 8, 7], [], [0]])
        let flat1 = collection1.mapEachFlat { $0 }
        
        try XCTAssertEqual(flat1.wait(), [1, 2, 3, 9, 8, 7, 0])

        let collection2 = self.eventLoop.makeSucceededFuture(["ABC", "123", "👩‍👩‍👧‍👧"])
        let flat2 = collection2.mapEachFlat(\.utf8CString).mapEach(UInt8.init)
        
        try XCTAssertEqual(flat2.wait(), [
            0x41, 0x42, 0x43, 0x00, 0x31, 0x32, 0x33, 0x00, 0xf0, 0x9f, 0x91, 0xa9,
            0xe2, 0x80, 0x8d, 0xf0, 0x9f, 0x91, 0xa9, 0xe2, 0x80, 0x8d, 0xf0, 0x9f,
            0x91, 0xa7, 0xe2, 0x80, 0x8d, 0xf0, 0x9f, 0x91, 0xa7, 0x00
        ])

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
        let lock = NIOLock()
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
        let lock = NIOLock()
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
        let lock = NIOLock()
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
        let lock = NIOLock()
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
        let lock = NIOLock()
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
        let lock = NIOLock()
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
