//
//  NIOKitTestCase.swift
//
//  Created by Jari (LotU) on 09/11/2018.
//

import NIO
import XCTest

protocol NIOKitTestCaseProt: class {
    var group: EventLoopGroup! { get set }
}

extension NIOKitTestCaseProt {
    internal var eventLoop: EventLoop {
        return self.group.next()
    }
    
    internal func setupGroup() {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }
    
    internal func teardownGroup() {
        XCTAssertNoThrow(try self.group.syncShutdownGracefully())
        self.group = nil
    }
}

class NIOKitTestCase: XCTestCase, NIOKitTestCaseProt {
    var group: EventLoopGroup!
    
    override func setUp() {
        super.setUp()
        setupGroup()
    }
    
    override func tearDown() {
        teardownGroup()
        super.tearDown()
    }
}
