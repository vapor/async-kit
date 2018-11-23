import XCTest

@testable import NIOKitTests

var tests = [
    testCase(NIOKitTests.allTests),
    testCase(FutureOperatorTests.allTests),
    testCase(TransformTests.allTests)
]
XCTMain(tests)