import XCTest

import NIOKit

var tests = [XCTestCaseEntry]()
tests += NIOKitTests.allTests()
XCTMain(tests)