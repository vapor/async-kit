import XCTest

@testable import NIOKitTests

var tests = [
    testCase(NIOKitTests.allTests),
    testCase(TransformTests.allTests),
    testCase(FutureOperatorTests.allTests),
    testCase(ConnectionPoolTests.allTests)
]
XCTMain(tests)
