import XCTest

import NIOKitTests

var tests = [
    testCase(NIOKitTests.allTests),
    testCase(FutureOperatorTests.allTests),
    testCase(ConnectionPoolTests.allTests)
]
XCTMain(tests)
