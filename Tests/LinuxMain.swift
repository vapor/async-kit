import XCTest

@testable import NIOKitTests

var tests = [
    testCase(NIOKitTests.allTests)
]
XCTMain(tests)