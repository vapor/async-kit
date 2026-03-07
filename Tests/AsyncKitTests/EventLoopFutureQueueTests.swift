import AsyncKit
import Foundation
import NIOConcurrencyHelpers
import NIOCore
import Testing

@Suite
struct EventLoopFutureQueueTests {
    func testQueue() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let queue = EventLoopFutureQueue(eventLoop: eventLoop)
        var numbers: [Int] = []
        let lock = NIOLock()

        let one = queue.append(generator: {
            eventLoop.slowFuture(1, sleeping: .random(in: 0.01 ... 0.5)).map { number -> Int in
                lock.withLockVoid { numbers.append(number) }
                return number
            }
        })
        let two = queue.append(generator: {
            eventLoop.slowFuture(2, sleeping: .random(in: 0.01 ... 0.5)).map { number -> Int in
                lock.withLockVoid { numbers.append(number) }
                return number
            }
        })
        let three = queue.append(generator: {
            eventLoop.slowFuture(3, sleeping: .random(in: 0.01 ... 0.5)).map { number -> Int in
                lock.withLockVoid { numbers.append(number) }
                return number
            }
        })
        let four = queue.append(generator: {
            eventLoop.slowFuture(4, sleeping: .random(in: 0.01 ... 0.5)).map { number -> Int in
                lock.withLockVoid { numbers.append(number) }
                return number
            }
        })
        let five = queue.append(generator: {
            eventLoop.slowFuture(5, sleeping: .random(in: 0.01 ... 0.5)).map { number -> Int in
                lock.withLockVoid { numbers.append(number) }
                return number
            }
        })

        #expect(try await one.get() == 1)
        #expect(try await two.get() == 2)
        #expect(try await three.get() == 3)
        #expect(try await four.get() == 4)
        #expect(try await five.get() == 5)

        #expect(numbers == [1, 2, 3, 4, 5])
    }

    @Test
    func autoclosure() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let queue = EventLoopFutureQueue(eventLoop: eventLoop)
        var numbers: [Int] = []
        let lock = NIOLock()

        let one = queue.append(eventLoop.slowFuture(1, sleeping: 0.25).map { num in lock.withLockVoid { numbers.append(num) } })
        let two = queue.append(eventLoop.slowFuture(2, sleeping: 0).map { num in lock.withLockVoid { numbers.append(num) } })
        let three = queue.append(eventLoop.slowFuture(3, sleeping: 0).map { num in lock.withLockVoid { numbers.append(num) } })
        let four = queue.append(eventLoop.slowFuture(4, sleeping: 0.25).map { num in lock.withLockVoid { numbers.append(num) } })
        let five = queue.append(eventLoop.slowFuture(5, sleeping: 0.25).map { num in lock.withLockVoid { numbers.append(num) } })

        await #expect(throws: Never.self) { try await one.get() }
        await #expect(throws: Never.self) { try await two.get() }
        await #expect(throws: Never.self) { try await three.get() }
        await #expect(throws: Never.self) { try await four.get() }
        await #expect(throws: Never.self) { try await five.get() }

        #expect(numbers == [1, 2, 3, 4, 5])
    }

    @Test
    func continueOnSucceed() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let queue = EventLoopFutureQueue(eventLoop: eventLoop)

        let one = queue.append(eventLoop.slowFuture(1, sleeping: 0.25), runningOn: .success)
        let two = queue.append(eventLoop.slowFuture(2, sleeping: 0), runningOn: .success)
        let fail: EventLoopFuture<Int> = queue.append(
            eventLoop.makeFailedFuture(Failure.nope),
            runningOn: .success
        )
        let three = queue.append(eventLoop.slowFuture(3, sleeping: 0.25), runningOn: .success)

        #expect(try await one.get() == 1)
        #expect(try await two.get() == 2)

        await #expect(throws: Failure.nope) { try await fail.get() }
        await #expect(throws: EventLoopFutureQueue.ContinueError.self) { try await three.get() }
    }

    @Test
    func continueOnFail() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let queue = EventLoopFutureQueue(eventLoop: eventLoop)

        let fail: EventLoopFuture<Int> = queue.append(
            eventLoop.makeFailedFuture(Failure.nope),
            runningOn: .success
        )
        let one = queue.append(eventLoop.slowFuture(1, sleeping: 0.25), runningOn: .failure)
        let two = queue.append(eventLoop.slowFuture(2, sleeping: 0), runningOn: .success)
        let three = queue.append(eventLoop.slowFuture(3, sleeping: 0.25), runningOn: .failure)

        #expect(try await one.get() == 1)
        #expect(try await two.get() == 2)

        await #expect(throws: Failure.nope) { try await fail.get() }
        await #expect(throws: EventLoopFutureQueue.ContinueError.self) { try await three.get() }
    }

    @Test
    func simpleSequence() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let queue = EventLoopFutureQueue(eventLoop: eventLoop)
        let values = [1, 2, 3, 4, 5]
        
        let all = queue.append(each: values) { eventLoop.slowFuture($0, sleeping: 0.25) }

        #expect(try await all.get() == [1, 2, 3, 4, 5])
    }
    
    @Test
    func voidReturnSequence() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let queue = EventLoopFutureQueue(eventLoop: eventLoop)
        let values = 99..<135
        var output: [Int] = []
        let all = queue.append(each: values) { v in eventLoop.slowFuture((), sleeping: 0).map { output.append(v) } }

        await #expect(throws: Never.self) { try await all.get() }
        #expect(Array(values) == output)
    }

    @Test
    func sequenceWithFailure() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let queue = EventLoopFutureQueue(eventLoop: eventLoop)
        var completedResults: [Int] = []
        
        let all = queue.append(each: [1, 2, 3, 4, 5, 6]) { (v: Int) -> EventLoopFuture<Int> in
            guard v < 3 || v > 5 else {
                return eventLoop.future(error: Failure.nope)
            }
            completedResults.append(v)
            return eventLoop.slowFuture(v, sleeping: 0.25)
        }
        
        await #expect(throws: (any Error).self) { try await all.get() }
        #expect(completedResults == [1, 2]) // Make sure we didn't run with value 6
    }

    @Test
    func voidSequenceWithFailure() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let queue = EventLoopFutureQueue(eventLoop: eventLoop)
        let values = 99..<135
        var output: [Int] = []
        let all = queue.append(each: values) { v -> EventLoopFuture<Void> in
            guard v < 104 || v > 110 else {
                return eventLoop.future(error: Failure.nope)
            }
            return eventLoop.slowFuture((), sleeping: 0).map { output.append(v) }
        }

        await #expect(throws: (any Error).self) { try await all.get() }
        #expect(Array(values).prefix(while: { $0 < 104 }) == output)
    }

    @Test
    func emptySequence() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let queue = EventLoopFutureQueue(eventLoop: eventLoop)
        var count = 0
        
        _ = queue.append(onPrevious: .success) { queue.eventLoop.tryFuture { count = 1 } }
        let all = queue.append(each: Array<Int>(), { _ in queue.eventLoop.tryFuture { count = 99 } })
        
        await #expect(throws: Never.self) { try await all.get() }
        #expect(count == 1)
    }

    @Test
    func continueErrorPreviousErrorDescription() throws {
        let error = EventLoopFutureQueue.ContinueError.previousError(
            EventLoopFutureQueue.ContinueError.previousError(
                EventLoopFutureQueue.ContinueError.previousError(Failure.nope)
            )
        )

        #expect(error.description == "previousError(nope)")
    }
}

fileprivate extension EventLoop {
    func slowFuture<T>(_ value: T, sleeping: TimeInterval) -> EventLoopFuture<T> {
        Thread.sleep(forTimeInterval: sleeping)
        return self.future(value)
    }
}

fileprivate enum Failure: Error, Equatable {
    case nope
}
