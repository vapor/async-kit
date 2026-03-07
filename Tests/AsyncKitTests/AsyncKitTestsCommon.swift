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
        handler.logLevel = env("LOG_LEVEL").flatMap { .init(rawValue: $0) } ?? .info
        return handler
    }
    return true
}()
