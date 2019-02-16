import NIOKit
import XCTest

final class FutureOptionalTests: NIOKitTestCase {
    func testMapOptional() throws {
        let future = self.group.next().makeSucceededFuture(Optional<Int>.some(1))
        let null = self.group.next().makeSucceededFuture(Optional<Int>.none)
        
        let times2 = future.mapOptional { $0 * 2 }
        let null2 = null.mapOptional { $0 * 2 }
        
        try XCTAssertEqual(2, times2.wait())
        try XCTAssertEqual(nil, null2.wait())
    }
    
    func testFlatMapOptional() throws {
        let future = self.group.next().makeSucceededFuture(Optional<Int>.some(1))
        let null = self.group.next().makeSucceededFuture(Optional<Int>.none)
        
        let times2 = future.flatMapOptional { self.multiply($0, 2) }
        let null2 = null.flatMapOptional { self.multiply($0, 2) }
        
        try XCTAssertEqual(2, times2.wait())
        try XCTAssertEqual(nil, null2.wait())
    }
    
    func multiply(_ a: Int, _ b: Int) -> EventLoopFuture<Int> {
        return self.group.next().makeSucceededFuture(a * b)
    }
    
    static let allTests = [
        ("testMapOptional", testMapOptional),
        ("testFlatMapOptional", testFlatMapOptional)
    ]
}
