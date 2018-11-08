import XCTest

@testable import NIOKit

var tests = [XCTestCaseEntry]()
tests += NIOKitTests.allTests()
XCTMain(tests)