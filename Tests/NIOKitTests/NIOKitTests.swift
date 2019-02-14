import XCTest
@testable import NIOKit

public final class NIOKitTests: XCTestCase {
    func testUniverseSanity() {
        XCTAssert(true)
    }

    public static let allTests = [
        ("testUniverseSanity", testUniverseSanity)
    ]
}
