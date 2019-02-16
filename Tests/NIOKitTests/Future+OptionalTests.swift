import NIOKit
import XCTest

final class FutureOptionalTests: NIOKitTestCase {
    func testMapOptional() throws {
        let future = self.eventLoop.makeSucceededFuture(Optional<Int>.some(1))
        let null = self.eventLoop.makeSucceededFuture(Optional<Int>.none)
        
        let times2 = future.mapOptional { $0 * 2 }
        let null2 = null.mapOptional { $0 * 2 }
        
        try XCTAssertEqual(2, times2.wait())
        try XCTAssertEqual(nil, null2.wait())
    }
    
    func testCompactMap() throws {
        let future = self.eventLoop.makeSucceededFuture(Optional<Int>.some(1))
        
        let times2 = future.compactMap { $0 * 2 }
        let null2 = future.compactMap { return $0 % 2 == 0 ? $0 : nil }
        
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
        ("testMapOptional", testMapOptional),
        ("testCompactMap", testCompactMap),
        ("testFlatMapOptional", testFlatMapOptional),
        ("testCompactFlatMap", testCompactFlatMap)
    ]
}
