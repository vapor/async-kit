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

        try XCTAssertNoThrow(one.wait())
        try XCTAssertNoThrow(two.wait())
        try XCTAssertNoThrow(three.wait())
        try XCTAssertNoThrow(four.wait())
        try XCTAssertNoThrow(five.wait())

        XCTAssertEqual(numbers, [1, 2, 3, 4, 5])
    }

    func testContinueOnSucceed() throws {
        let queue = EventLoopFutureQueue(eventLoop: self.eventLoop)

        let one = queue.append(self.eventLoop.slowFuture(1, sleeping: 1), runningOn: .success)
        let two = queue.append(self.eventLoop.slowFuture(2, sleeping: 0), runningOn: .success)
        let fail: EventLoopFuture<Int> = queue.append(
            self.eventLoop.makeFailedFuture(Failure.nope),
            runningOn: .success
        )
        let three = queue.append(self.eventLoop.slowFuture(3, sleeping: 1), runningOn: .success)

        try XCTAssertEqual(one.wait(), 1)
        try XCTAssertEqual(two.wait(), 2)

        try XCTAssertThrowsError(fail.wait()) { error in
            XCTAssertEqual(error as? Failure, .nope)
        }
        try XCTAssertThrowsError(three.wait()) { error in
            guard case let EventLoopFutureQueue.ContinueError.previousError(fail) = error else {
                return XCTFail("Unexpected error \(error.localizedDescription)")
            }

            XCTAssertEqual(fail as? Failure, .nope)
        }
    }

    func testContinueOnFail() throws {
        let queue = EventLoopFutureQueue(eventLoop: self.eventLoop)

        let fail: EventLoopFuture<Int> = queue.append(
            self.eventLoop.makeFailedFuture(Failure.nope),
            runningOn: .success
        )
        let one = queue.append(self.eventLoop.slowFuture(1, sleeping: 1), runningOn: .failure)
        let two = queue.append(self.eventLoop.slowFuture(2, sleeping: 0), runningOn: .success)
        let three = queue.append(self.eventLoop.slowFuture(3, sleeping: 1), runningOn: .failure)

        try XCTAssertEqual(one.wait(), 1)
        try XCTAssertEqual(two.wait(), 2)

        try XCTAssertThrowsError(fail.wait()) { error in
            XCTAssertEqual(error as? Failure, .nope)
        }
        try XCTAssertThrowsError(three.wait()) { error in
            guard case EventLoopFutureQueue.ContinueError.previousSuccess = error else {
                return XCTFail("Unexpected error \(error.localizedDescription)")
            }
        }
    }
    
    func testSimpleSequence() throws {
        let queue = EventLoopFutureQueue(eventLoop: self.eventLoop)
        let values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        let all = queue.append(each: values) { self.eventLoop.slowFuture($0, sleeping: 1) }

        try XCTAssertEqual(all.wait(), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }
    
    func testVoidReturnSequence() throws {
        let queue = EventLoopFutureQueue(eventLoop: self.eventLoop)
        let values = 99..<135
        var output: [Int] = []
        let all = queue.append(each: values) { v in self.eventLoop.slowFuture((), sleeping: 0).map { output.append(v) } }

        try XCTAssertNoThrow(all.wait())
        XCTAssertEqual(Array(values), output)
    }
    
    func testSequenceWithFailure() throws {
        let queue = EventLoopFutureQueue(eventLoop: self.eventLoop)
        
        let all = queue.append(each: [1, 2, 3, 4]) { (v: Int) -> EventLoopFuture<Int> in
            guard v < 3 else {
                return self.eventLoop.future(error: Failure.nope)
            }
            return self.eventLoop.slowFuture(v, sleeping: 1)
        }
        
        try XCTAssertThrowsError(all.wait())
    }

    func testVoidSequenceWithFailure() throws {
        let queue = EventLoopFutureQueue(eventLoop: self.eventLoop)
        let values = 99..<135
        var output: [Int] = []
        let all = queue.append(each: values) { v -> EventLoopFuture<Void> in
            guard v < 104 else {
                return self.eventLoop.future(error: Failure.nope)
            }
            return self.eventLoop.slowFuture((), sleeping: 0).map { output.append(v) }
        }

        try XCTAssertThrowsError(all.wait())
        XCTAssertEqual(Array(values).prefix(while: { $0 < 104 }), output)
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

fileprivate enum Failure: Error, Equatable {
    case nope
}
