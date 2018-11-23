import XCTest
import NIO
@testable import NIOKit

final class TransformTests: NIOKitTestCase {
    func testTransforms() throws {
        let future = eventLoop.newSucceededFuture(result: Int.random(in: 0...100))
        
        XCTAssert(try future.transform(to: true).wait())
        
        let futureA = eventLoop.newSucceededFuture(result: Int.random(in: 0...100))
        let futureB = eventLoop.newSucceededFuture(result: Int.random(in: 0...100))
        let futureC = eventLoop.newSucceededFuture(result: Int.random(in: 0...100))
        let futureD = eventLoop.newSucceededFuture(result: Int.random(in: 0...100))
        let futureE = eventLoop.newSucceededFuture(result: Int.random(in: 0...100))
        
        XCTAssert(try transform(futureA, futureB, to: true).wait())
        XCTAssert(try transform(futureA, futureB, futureC, to: true).wait())
        XCTAssert(try transform(futureA, futureB, futureC, futureD, to: true).wait())
        XCTAssert(try transform(futureA, futureB, futureC, futureD, futureE, to: true).wait())
    }
    
    static var allTests = [
        ("testTransforms", testTransforms)
    ]
}
