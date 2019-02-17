import XCTest
import NIO
@testable import NIOKit

final class TransformTests: NIOKitTestCase {
    func testTransforms() throws {
        let future = eventLoop.newSucceededFuture(result: Int.random(in: 0...100))
        
        XCTAssert(try future.transform(to: true).wait())
        
        let futureA = eventLoop.newSucceededFuture(result: Int.random(in: 0...100))
        let futureB = eventLoop.newSucceededFuture(result: Int.random(in: 0...100))
        
        XCTAssert(try futureA.and(futureB).transform(to: true).wait())
        
        let futureBool = eventLoop.newSucceededFuture(result: true)
        
        XCTAssert(try future.transform(to: futureBool).wait())
        
        XCTAssert(try futureA.and(futureB).transform(to: futureBool).wait())
    }
    
    static var allTests = [
        ("testTransforms", testTransforms)
    ]
}
