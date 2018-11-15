import NIO
import XCTest

protocol NIOKitTestCaseProt: class {
    var group: EventLoopGroup! { get set }
}

extension NIOKitTestCaseProt {
    public var eventLoop: EventLoop {
        return self.group.next()
    }
    
    public func setupGroup() {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }
    
    public func teardownGroup() {
        XCTAssertNoThrow(try self.group.syncShutdownGracefully())
        self.group = nil
    }
}

open class NIOKitTestCase: XCTestCase, NIOKitTestCaseProt {
    open var group: EventLoopGroup!
    
    override open func setUp() {
        super.setUp()
        setupGroup()
    }
    
    override open func tearDown() {
        teardownGroup()
        super.tearDown()
    }
}
