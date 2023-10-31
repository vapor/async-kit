import XCTest
import AsyncKit
import NIOCore

class FutureTransformTests: AsyncKitTestCase {
    func testTransforms() throws {
        let future = eventLoop.makeSucceededFuture(Int.random(in: 0...100))
        
        XCTAssert(try future.transform(to: true).wait())
        
        let futureA = eventLoop.makeSucceededFuture(Int.random(in: 0...100))
        let futureB = eventLoop.makeSucceededFuture(Int.random(in: 0...100))
        
        XCTAssert(try futureA.and(futureB).transform(to: true).wait())
        
        let futureBool = eventLoop.makeSucceededFuture(true)
        
        XCTAssert(try future.transform(to: futureBool).wait())
        
        XCTAssert(try futureA.and(futureB).transform(to: futureBool).wait())
    }
}
