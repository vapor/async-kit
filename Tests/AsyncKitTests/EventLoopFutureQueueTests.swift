import NIOConcurrencyHelpers
import AsyncKit
import XCTest

final class EventLoopFutureQueueTests: XCTestCase {
    func testQueue() throws {
        let queue = EventLoopFutureQueue(eventLoop: self.eventLoop)
        var numbers: [Int] = []
        let lock = Lock()

        let one = queue.append(generator: {
            self.eventLoop.slowFuture(1).map { number -> Int in
                lock.withLockVoid { numbers.append(number) }
                return number
            }
        })
        let two = queue.append(generator: {
            self.eventLoop.slowFuture(2).map { number -> Int in
                lock.withLockVoid { numbers.append(number) }
                return number
            }
        })
        let three = queue.append(generator: {
            self.eventLoop.slowFuture(3).map { number -> Int in
                lock.withLockVoid { numbers.append(number) }
                return number
            }
        })
        let four = queue.append(generator: {
            self.eventLoop.slowFuture(4).map { number -> Int in
                lock.withLockVoid { numbers.append(number) }
                return number
            }
        })
        let five = queue.append(generator: {
            self.eventLoop.slowFuture(5).map { number -> Int in
                lock.withLockVoid { numbers.append(number) }
                return number
            }
        })

        try XCTAssertNoThrow(queue.future.wait())

        try XCTAssertEqual(one.wait(), 1)
        try XCTAssertEqual(two.wait(), 2)
        try XCTAssertEqual(three.wait(), 3)
        try XCTAssertEqual(four.wait(), 4)
        try XCTAssertEqual(five.wait(), 5)

        XCTAssertEqual(numbers, [1, 2, 3, 4, 5])
    }

    func testAutoclosure() throws {
        let queue = EventLoopFutureQueue(eventLoop: self.eventLoop)
        var numbers: [Int] = []
        let lock = Lock()

        let one = queue.append(self.eventLoop.slowFuture(1, sleeping: 2).map { num in lock.withLockVoid { numbers.append(num) } })
        let two = queue.append(self.eventLoop.slowFuture(2, sleeping: 0).map { num in lock.withLockVoid { numbers.append(num) } })
        let three = queue.append(self.eventLoop.slowFuture(3, sleeping: 0).map { num in lock.withLockVoid { numbers.append(num) } })
        let four = queue.append(self.eventLoop.slowFuture(4, sleeping: 4).map { num in lock.withLockVoid { numbers.append(num) } })
        let five = queue.append(self.eventLoop.slowFuture(5, sleeping: 1).map { num in lock.withLockVoid { numbers.append(num) } })

        try XCTAssertNoThrow(queue.future.wait())

        try XCTAssertNoThrow(one.wait())
        try XCTAssertNoThrow(two.wait())
        try XCTAssertNoThrow(three.wait())
        try XCTAssertNoThrow(four.wait())
        try XCTAssertNoThrow(five.wait())

        XCTAssertEqual(numbers, [1, 2, 3, 4, 5])
    }

    /// This TestCases EventLoopGroup
    var group: EventLoopGroup!

    /// Returns the next EventLoop from the `group`
    var eventLoop: EventLoop {
        return self.group.next()
    }

    /// Sets up the TestCase for use
    /// and initializes the EventLoopGroup
    override func setUp() {
        super.setUp()
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    /// Tears down the TestCase and
    /// shuts down the EventLoopGroup
    override func tearDown() {
        XCTAssertNoThrow(try self.group.syncShutdownGracefully())
        self.group = nil
        super.tearDown()
    }
}

fileprivate extension EventLoop {
    func slowFuture<T>(_ value: T, sleeping: UInt32? = nil) -> EventLoopFuture<T> {
        sleep(sleeping ?? UInt32.random(in: 0...2))
        return self.future(value)
    }
}
