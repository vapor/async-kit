import NIOKit
import XCTest

final class FutureOptionalTests: NIOKitTestCase {
    func testFlatMapOptionalThrowing() throws {
        let future = self.eventLoop.makeSucceededFuture(Optional<Int>.some(1))
        let null = self.eventLoop.makeSucceededFuture(Optional<Int>.none)
        
        var times2 = future.flatMapOptionalThrowing { $0 * 2 }
        var null2 = null.flatMapOptionalThrowing { $0 * 2 }
        
        try XCTAssertEqual(2, times2.wait())
        try XCTAssertEqual(nil, null2.wait())
        
        
        times2 = future.flatMapOptionalThrowing { $0 * 2 }
        null2 = future.flatMapOptionalThrowing { return $0 % 2 == 0 ? $0 : nil }
        
        try XCTAssertEqual(2, times2.wait())
        try XCTAssertEqual(nil, null2.wait())
    }
    
    func testFlatMapOptional() throws {
        let future = self.eventLoop.makeSucceededFuture(Optional<Int>.some(1))
        let null = self.eventLoop.makeSucceededFuture(Optional<Int>.none)
        
        let times2 = future.flatMapOptional { self.multiply($0, 2) }
        let null2 = null.flatMapOptional { self.multiply($0, 2) }
        
        try XCTAssertEqual(2, times2.wait())
        try XCTAssertEqual(nil, null2.wait())
    }
    
    func testCompactFlatMap() throws {
        let future = self.eventLoop.makeSucceededFuture(Optional<Int>.some(1))
        
        let times2 = future.compactFlatMap { self.multiply($0, Optional<Int>.some(2)) }
        let null2 = future.compactFlatMap { self.multiply($0, nil) }
        
        try XCTAssertEqual(2, times2.wait())
        try XCTAssertEqual(nil, null2.wait())
    }
    
    func multiply(_ a: Int, _ b: Int) -> EventLoopFuture<Int> {
        return self.group.next().makeSucceededFuture(a * b)
    }
    
    func multiply(_ a: Int, _ b: Int?) -> EventLoopFuture<Int?> {
        return self.group.next().makeSucceededFuture(b == nil ? nil : a * b!)
    }
    
    static let allTests = [
        ("testFlatMapOptionalThrowing", testFlatMapOptionalThrowing),
        ("testFlatMapOptional", testFlatMapOptional),
        ("testCompactFlatMap", testCompactFlatMap)
    ]
}
