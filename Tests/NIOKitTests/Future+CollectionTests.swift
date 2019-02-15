import NIOKit
import XCTest

final class FutureCollectionTests: XCTestCase {
    private var group: EventLoopGroup!
    private var eventLoop: EventLoop {
        return group.next()
    }
    
    override func setUp() {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
    }
    
    func testMapEach() throws {
        let collection = eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6, 7, 8, 9])
        let times2 = collection.mapEach { int in int * 2 }
        
        try XCTAssertEqual(times2.wait(), [2, 4, 6, 8, 10, 12, 14, 16, 18])
    }
    
    let allTests = [
        ("testMapEach", testMapEach)
    ]
}
