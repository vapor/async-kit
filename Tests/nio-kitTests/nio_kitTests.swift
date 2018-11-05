import XCTest
@testable import nio_kit

final class nio_kitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(nio_kit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
