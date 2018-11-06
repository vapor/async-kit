//
//  FutureOperatorsTests.swift
//  NIOKitTests
//
//  Created by Jari (LotU) on 06/11/2018.
//

import XCTest
import NIO
@testable import NIOKit

final class FutureOperatorTests: XCTestCase {
    
    private var eventLoop: EventLoop!
    
    override func setUp() {
        self.eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1).next()
    }
    
    func testComparison() throws {
        let future1 = eventLoop.newSucceededFuture(result: 8)
        let future2 = eventLoop.newSucceededFuture(result: 5)
        
        let x = try (future2 < future1).wait()
        
        XCTAssert(true)
    }
}
