import XCTest

@testable import NIOKitTests

var tests = [XCTestCaseEntry]()
tests += NIOKitTests.allTests
XCTMain(tests)