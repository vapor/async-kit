import XCTest

@testable import NIOKitTests

var tests = [
    testCase(NIOKitTests.allTests),
    testCase(FutureOperatorTests.allTests),
    testCase(ConnectionPoolTests.allTests),
    testCase(FutureExtensionsTests.allTests)
]
XCTMain(tests)
