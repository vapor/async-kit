import XCTest

#if !os(macOS)
public func allTests() -> [(String, (XCTestCase) -> ()throws -> ())] {
    return [
        testCase(NIOKitTests.allTests),
    ]
}
#endif
