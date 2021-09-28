import NIO
import AsyncKit
import XCTest

final class FutureTryTests: XCTestCase {
    private let eventLoop = EmbeddedEventLoop()

    private enum NIOError: Error {
        case testError
    }

    func testTryFlatMapPropagatesCallbackError() {
        let future = eventLoop.future(0)
            .tryFlatMap { _ -> EventLoopFuture<String> in
                throw NIOError.testError
            }

        XCTAssertThrowsError(try future.wait()) { error in
            guard case NIOError.testError = error else {
                XCTFail("Received an unexpected error: \(error)")
                return
            }
        }
    }

    func testTryFlatMapPropagatesInnerError() {
        let future = eventLoop.future(0)
            .tryFlatMap { _ -> EventLoopFuture<String> in
                self.eventLoop.makeFailedFuture(NIOError.testError)
            }

        XCTAssertThrowsError(try future.wait()) { error in
            guard case NIOError.testError = error else {
                XCTFail("Received an unexpected error: \(error)")
                return
            }
        }
    }

    func testTryFlatMapPropagatesResult() throws {
        let future = eventLoop.future(0)
            .tryFlatMap { value -> EventLoopFuture<String> in
                self.eventLoop.makeSucceededFuture(String(describing: value))
            }

        try XCTAssertEqual("0", future.wait())
    }
}
