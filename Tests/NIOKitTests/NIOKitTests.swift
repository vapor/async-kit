import XCTest
@testable import NIOKit

final class NIOKitTests: XCTestCase {
    func testUniverseSanity() {
        XCTAssert(true)
    }

    static let allTests = [
        ("testUniverseSanity", testUniverseSanity)
    ]
}
