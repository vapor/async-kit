import XCTest

@testable import NIOKitTests

var tests = [
    testCase(NIOKitTests.allTests),
    testCase(FutureOptionalTests.allTests),
    testCase(FutureOperatorTests.allTests),
    testCase(ConnectionPoolTests.allTests)
]
XCTMain(tests)
