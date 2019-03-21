#if !canImport(ObjectiveC)
import XCTest

extension ConnectionPoolTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ConnectionPoolTests = [
        ("testConnectError", testConnectError),
        ("testFIFOWaiters", testFIFOWaiters),
        ("testPerformance", testPerformance),
        ("testPoolClose", testPoolClose),
        ("testPooling", testPooling),
    ]
}

extension FlattenTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__FlattenTests = [
        ("testCollectionFlatten", testCollectionFlatten),
        ("testELFlatten", testELFlatten),
    ]
}

extension FutureExtensionsTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__FutureExtensionsTests = [
        ("testGuard", testGuard),
    ]
}

extension FutureOperatorTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__FutureOperatorTests = [
        ("testAddition", testAddition),
        ("testAND", testAND),
        ("testBitshifts", testBitshifts),
        ("testComparison", testComparison),
        ("testDivision", testDivision),
        ("testModulo", testModulo),
        ("testMultiplication", testMultiplication),
        ("testNOT", testNOT),
        ("testOR", testOR),
        ("testSubtraction", testSubtraction),
        ("testXOR", testXOR),
    ]
}

extension FutureOptionalTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__FutureOptionalTests = [
        ("testOptionalFlatMap", testOptionalFlatMap),
        ("testOptionalFlatMapThrowing", testOptionalFlatMapThrowing),
        ("testOptionalMap", testOptionalMap),
    ]
}

extension NIOKitTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__NIOKitTests = [
        ("testUniverseSanity", testUniverseSanity),
    ]
}

extension TransformTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__TransformTests = [
        ("testTransforms", testTransforms),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ConnectionPoolTests.__allTests__ConnectionPoolTests),
        testCase(FlattenTests.__allTests__FlattenTests),
        testCase(FutureExtensionsTests.__allTests__FutureExtensionsTests),
        testCase(FutureOperatorTests.__allTests__FutureOperatorTests),
        testCase(FutureOptionalTests.__allTests__FutureOptionalTests),
        testCase(NIOKitTests.__allTests__NIOKitTests),
        testCase(TransformTests.__allTests__TransformTests),
    ]
}
#endif
