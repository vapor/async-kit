import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NIOKitTests.allTests),
        testCae(FutureOperatorsTests.allTests)
    ]
}
#endif
