import NIO
import XCTest

protocol NIOKitTestCaseProtocol: class {
    var group: EventLoopGroup! { get set }
}

extension NIOKitTestCaseProtocol {
    public func setupGroup() {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }
    
    public func teardownGroup() {
        XCTAssertNoThrow(try self.group.syncShutdownGracefully())
        self.group = nil
    }
}

open class NIOKitTestCase: XCTestCase, NIOKitTestCaseProtocol {
    open var group: EventLoopGroup!
    
    open var eventLoop: EventLoop {
        return self.group.next()
    }
    
    override open func setUp() {
        super.setUp()
        setupGroup()
    }
    
    override open func tearDown() {
        teardownGroup()
        super.tearDown()
    }
}
