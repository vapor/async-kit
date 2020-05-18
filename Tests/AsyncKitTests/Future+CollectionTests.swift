import AsyncKit
import XCTest

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
