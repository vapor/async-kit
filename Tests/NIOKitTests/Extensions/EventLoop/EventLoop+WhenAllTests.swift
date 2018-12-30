import NIO
@testable import NIOKit
import XCTest

final class EventLoopWhenAllTests: XCTestCase {
    private var group: EventLoopGroup!
    private var eventLoop: EventLoop {
        return group.next()
    }

    override func setUp() {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    override func tearDown() {
        XCTAssertNoThrow(try self.group.syncShutdownGracefully())
        self.group = nil
    }

    func testFailuresStillSucceed() {
        let future: EventLoopFuture<[Result<Bool, Error>]> = eventLoop.whenAllComplete([
            eventLoop.makeSucceededFuture(result: true),
            eventLoop.makeFailedFuture(error: NSError(domain: "NIOKit", code: 1, userInfo: nil))
        ])
        XCTAssertNoThrow(try future.wait())
    }

    func testSuccessProvidesResults() throws {
        let results: [Result<Int, Error>] = try eventLoop.whenAllComplete([
            eventLoop.makeSucceededFuture(result: 3),
            eventLoop.makeFailedFuture(error: NSError(domain: "NIOKit", code: 1, userInfo: nil)),
            eventLoop.makeSucceededFuture(result: 10),
            eventLoop.makeFailedFuture(error: NSError(domain: "NIOKit", code: 3, userInfo: nil)),
            eventLoop.makeSucceededFuture(result: 5)
        ]).wait()

        for i in [0, 2, 4] {
            XCTAssertNoThrow(try results[i].get())
        }

        for i in [1, 3] {
            XCTAssertThrowsError(try results[i].get())
        }
    }

    func testSuccessMaintainsOrder() throws {
        func createExpensiveFuture(id: Int, result: Int) -> EventLoopFuture<Int> {
            let promise = eventLoop.makePromise(of: Int.self)

            DispatchQueue(label: "background_thread_\(id)").async {
                usleep(UInt32(id * 5 * 50_000))
                promise.succeed(result: result)
            }

            return promise.futureResult
        }

        let results: [Result<Int, Error>] = try eventLoop.whenAllComplete([
            createExpensiveFuture(id: 3, result: 3),
            createExpensiveFuture(id: 2, result: 10),
            eventLoop.makeFailedFuture(error: NSError(domain: "NIOKit", code: 1, userInfo: nil)),
            createExpensiveFuture(id: 1, result: 15)
        ]).wait()

        XCTAssertEqual(try results[0].get(), 3)
        XCTAssertEqual(try results[1].get(), 10)
        XCTAssertEqual(try results[3].get(), 15)
    }

    func testNotifyFailuresStillSucceed() {
        XCTAssertNoThrow(try eventLoop.whenAllComplete([
            eventLoop.makeSucceededFuture(result: true),
            eventLoop.makeFailedFuture(error: NSError(domain: "NIOKit", code: 1, userInfo: nil))
        ]).thenThrowing { }.wait())
    }
}

extension EventLoopWhenAllTests {
    static var allTests = [
        ("test_failures_stillSucceed", testFailuresStillSucceed),
        ("test_success_providesResults", testSuccessProvidesResults),
        ("test_success_maintainsOrder", testSuccessMaintainsOrder),
        ("test_notify_failures_stillSucceed", testNotifyFailuresStillSucceed),
    ]
}
