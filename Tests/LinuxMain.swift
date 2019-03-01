import XCTest

import NIOKitTests

var tests = [
    testCase(NIOKitTests.allTests),
    testCase(TransformTests.allTests),
    testCase(FutureOperatorTests.allTests),
    testCase(ConnectionPoolTests.allTests),
    testCase(FutureExtensionsTests.allTests)
]
XCTMain(tests)
