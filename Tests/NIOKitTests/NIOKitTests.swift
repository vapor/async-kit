import XCTest
import NIOKit

public final class NIOKitTests: NIOKitTestCase {
    func testUniverseSanity() {
        print(self.eventLoop)
        XCTAssert(true)
    }

    public static let allTests = [
        ("testUniverseSanity", testUniverseSanity)
    ]
}
