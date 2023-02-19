import AsyncKit
import XCTest
import NIOCore
import NIOPosix

final class FutureOptionalTests: XCTestCase {
    func testOptionalMap() throws {
        let future = self.eventLoop.makeSucceededFuture(Optional<Int>.some(1))
        let null = self.eventLoop.makeSucceededFuture(Optional<Int>.none)
        
        let times2 = future.optionalMap { $0 * 2 }
        let null2 = null.optionalMap { $0 * 2 }
        let nullResult = future.optionalMap { _ in Optional<Int>.none }
        
        try XCTAssertEqual(2, times2.wait())
        try XCTAssertEqual(nil, null2.wait())
        try XCTAssertEqual(nil, nullResult.wait())
    }
    
    func testOptionalFlatMapThrowing() throws {
        let future = self.eventLoop.makeSucceededFuture(Optional<Int>.some(1))
        
        let times2 = future.optionalFlatMapThrowing { $0 * 2 }
        let null2 = future.optionalFlatMapThrowing { return $0 % 2 == 0 ? $0 : nil }
        let error = future.optionalFlatMapThrowing { _ in throw TestError.generic }
        
        try XCTAssertEqual(2, times2.wait())
        try XCTAssertEqual(nil, null2.wait())
        try XCTAssertThrowsError(error.wait())
    }
    
    func testOptionalFlatMap() throws {
        let future = self.eventLoop.makeSucceededFuture(Optional<Int>.some(1))
        let null = self.eventLoop.makeSucceededFuture(Optional<Int>.none)
        
        var times2 = future.optionalFlatMap { self.multiply($0, 2) }
        var null2 = null.optionalFlatMap { self.multiply($0, 2) }
        
        try XCTAssertEqual(2, times2.wait())
        try XCTAssertEqual(nil, null2.wait())

        
        times2 = future.optionalFlatMap { self.multiply($0, Optional<Int>.some(2)) }
        null2 = future.optionalFlatMap { self.multiply($0, nil) }
        
        try XCTAssertEqual(2, times2.wait())
        try XCTAssertEqual(nil, null2.wait())
    }
    
    func multiply(_ a: Int, _ b: Int) -> EventLoopFuture<Int> {
        return self.group.any().makeSucceededFuture(a * b)
    }
    
    func multiply(_ a: Int, _ b: Int?) -> EventLoopFuture<Int?> {
        return self.group.any().makeSucceededFuture(b == nil ? nil : a * b!)
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
