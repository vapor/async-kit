import XCTest
import AsyncKit
import NIOCore
import NIOPosix
import Logging

enum TestError: Error {
    case generic
    case notEqualTo1
    case notEqualToBar
}

func env(_ name: String) -> String? {
    return ProcessInfo.processInfo.environment[name]
}

let isLoggingConfigured: Bool = {
    LoggingSystem.bootstrap { label in
        var handler = StreamLogHandler.standardOutput(label: label)
        handler.logLevel = env("LOG_LEVEL").flatMap { Logger.Level(rawValue: $0) } ?? .info
        return handler
    }
    return true
}()

class AsyncKitTestCase: XCTestCase {
    var group: (any EventLoopGroup)!
    var eventLoop: any EventLoop { self.group.any() }

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    override func tearDownWithError() throws {
        try self.group.syncShutdownGracefully()
        self.group = nil
        try super.tearDownWithError()
    }

    override class func setUp() {
        super.setUp()
        XCTAssertTrue(isLoggingConfigured)
    }
}

class AsyncKitAsyncTestCase: XCTestCase {
    var group: (any EventLoopGroup)!
    var eventLoop: any EventLoop { self.group.any() }

    override func setUp() async throws {
        try await super.setUp()
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        XCTAssertTrue(isLoggingConfigured)
    }
    
    override func tearDown() async throws {
        try await self.group.shutdownGracefully()
        self.group = nil
        try await super.tearDown()
    }
}
