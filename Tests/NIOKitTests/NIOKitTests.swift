import XCTest
@testable import NIOKit

final class NIOKitTests: NIOKitTestCase {
    func testUniverseSanity() {
        print(self.eventLoop)
        XCTAssert(true)
    }

    static let allTests = [
        ("testUniverseSanity", testUniverseSanity)
    ]
}
