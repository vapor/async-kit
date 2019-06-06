import XCTest
import AsyncKit

class TransformTests: XCTestCase {
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

    /// This TestCases EventLoopGroup
    var group: EventLoopGroup!
    
    /// Returns the next EventLoop from the `group`
    var eventLoop: EventLoop {
        return self.group.next()
    }
    
    /// Sets up the TestCase for use
    /// and initializes the EventLoopGroup
    override func setUp() {
        super.setUp()
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }
    
    /// Tears down the TestCase and
    /// shuts down the EventLoopGroup
    override func tearDown() {
        XCTAssertNoThrow(try self.group.syncShutdownGracefully())
        self.group = nil
        super.tearDown()
    }
}
