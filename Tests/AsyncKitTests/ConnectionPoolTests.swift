import Atomics
import AsyncKit
import XCTest
import NIOConcurrencyHelpers
import Logging
import NIOCore
import NIOPosix
import NIOEmbedded

final class ConnectionPoolTests: XCTestCase {
    func testPooling() throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 2,
            on: EmbeddedEventLoop()
        )
        defer { try! pool.close().wait() }
        
        // make two connections
        let connA = try pool.requestConnection().wait()
        XCTAssertEqual(connA.isClosed, false)
        let connB = try pool.requestConnection().wait()
        XCTAssertEqual(connB.isClosed, false)
        XCTAssertEqual(foo.connectionsCreated.load(ordering: .relaxed), 2)
        
        // try to make a third, but pool only supports 2
        var connC: FooConnection?
        pool.requestConnection().whenSuccess { connC = $0 }
        XCTAssertNil(connC)
        XCTAssertEqual(foo.connectionsCreated.load(ordering: .relaxed), 2)
        
        // release one of the connections, allowing the third to be made
        pool.releaseConnection(connB)
        XCTAssertNotNil(connC)
        XCTAssert(connC === connB)
        XCTAssertEqual(foo.connectionsCreated.load(ordering: .relaxed), 2)
        
        // try to make a third again, with two active
        var connD: FooConnection?
        pool.requestConnection().whenSuccess { connD = $0 }
        XCTAssertNil(connD)
        XCTAssertEqual(foo.connectionsCreated.load(ordering: .relaxed), 2)
        
        // this time, close the connection before releasing it
        try connC!.close().wait()
        pool.releaseConnection(connC!)
        XCTAssert(connD !== connB)
        XCTAssertEqual(connD?.isClosed, false)
        XCTAssertEqual(foo.connectionsCreated.load(ordering: .relaxed), 3)
    }

    func testFIFOWaiters() throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 1,
            on: EmbeddedEventLoop()
        )
        defer { try! pool.close().wait() }

        // * User A makes a request for a connection, gets connection number 1.
        let a_1 = pool.requestConnection()
        let a = try a_1.wait()

        // * User B makes a request for a connection, they are exhausted so he gets a promise.
        let b_1 = pool.requestConnection()

        // * User A makes another request for a connection, they are still exhausted so he gets a promise.
        let a_2 = pool.requestConnection()

        // * User A returns connection number 1. His previous request is fulfilled with connection number 1.
        pool.releaseConnection(a)

        // * User B gets his connection
        let b = try b_1.wait()
        XCTAssert(a === b)

        // * User B releases his connection
        pool.releaseConnection(b)

        // * User A's second connection request is fulfilled
        let c = try a_2.wait()
        XCTAssert(a === c)
    }

    func testConnectError() throws {
        let db = ErrorDatabase()
        let pool = EventLoopConnectionPool(
            source: db,
            maxConnections: 1,
            on: EmbeddedEventLoop()
        )
        defer { try! pool.close().wait() }

        do {
            _ = try pool.requestConnection().wait()
            XCTFail("should not have created connection")
        } catch _ as ErrorDatabase.Error {
            // pass
        }

        // test that we can still make another request even after a failed request
        do {
            _ = try pool.requestConnection().wait()
            XCTFail("should not have created connection")
        } catch _ as ErrorDatabase.Error {
            // pass
        }
    }

    func testPoolClose() throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 1,
            on: self.group.any()
        )
        let _ = try pool.requestConnection().wait()
        let b = pool.requestConnection()
        try pool.close().wait()
        
        let c = pool.requestConnection()

        // check that waiters are failed
        do {
            _ = try b.wait()
            XCTFail("should not have created connection")
        } catch ConnectionPoolError.shutdown {
            // pass
        }

        // check that new requests fail
        do {
            _ = try c.wait()
            XCTFail("should not have created connection")
        } catch ConnectionPoolError.shutdown {
            // pass
        }
    }
    
    // https://github.com/vapor/async-kit/issues/63
    func testDeadlock() {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 1,
            requestTimeout: .milliseconds(100),
            on: self.group.any()
        )
        defer { try! pool.close().wait() }
        _ = pool.requestConnection()
        let start = Date()
        let a = pool.requestConnection()
        XCTAssertThrowsError(try a.wait(), "Connection should have deadlocked and thrown ConnectionPoolTimeoutError.connectionRequestTimeout") { (error) in
            let interval = Date().timeIntervalSince(start)
            XCTAssertGreaterThan(interval, 0.1)
            XCTAssertLessThan(interval, 0.25)
            XCTAssertEqual(error as? ConnectionPoolTimeoutError, ConnectionPoolTimeoutError.connectionRequestTimeout)
        }
    }

    func testPerformance() {
        guard performance(expected: 0.088) else { return }
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 3,
            on: self.group.any()
        )

        measure {
            for _ in 0..<10_000 {
                do {
                    let connA = try! pool.requestConnection().wait()
                    pool.releaseConnection(connA)
                }
                do {
                    let connA = try! pool.requestConnection().wait()
                    let connB = try! pool.requestConnection().wait()
                    let connC = try! pool.requestConnection().wait()
                    pool.releaseConnection(connB)
                    pool.releaseConnection(connC)
                    pool.releaseConnection(connA)
                }
                do {
                    let connA = try! pool.requestConnection().wait()
                    let connB = try! pool.requestConnection().wait()
                    pool.releaseConnection(connA)
                    pool.releaseConnection(connB)
                }
            }
        }
    }

    func testThreadSafety() throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 2,
            on: self.group
        )
        defer { pool.shutdown() }

        var futures: [EventLoopFuture<Void>] = []

        var eventLoops = group.makeIterator()
        while let eventLoop = eventLoops.next() {
            let promise = eventLoop.makePromise(of: Void.self)
            eventLoop.execute {
                (0 ..< 1_000).map { i in
                    return pool.withConnection(on: eventLoop) { conn in
                        return conn.eventLoop.makeSucceededFuture(i)
                    }
                }.flatten(on: eventLoop)
                    .map { XCTAssertEqual($0.count, 1_000) }
                    .cascade(to: promise)
            }
            futures.append(promise.futureResult)
        }

        try futures.flatten(on: group.any()).wait()
    }
    
    func testGracefulShutdownAsync() throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 2,
            on: self.group
        )
        
        let expectation1 = XCTestExpectation(description: "Shutdown completion")
        let expectation2 = XCTestExpectation(description: "Shutdown completion with error")
        
        pool.shutdownGracefully {
            XCTAssertNil($0)
            expectation1.fulfill()
        }
        XCTWaiter().wait(for: [expectation1], timeout: 5.0)
        
        pool.shutdownGracefully {
            XCTAssertEqual($0 as? ConnectionPoolError, ConnectionPoolError.shutdown)
            expectation2.fulfill()
        }
        XCTWaiter().wait(for: [expectation2], timeout: 5.0)
    }
    
    func testGracefulShutdownSync() throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 2,
            on: self.group
        )
        
        XCTAssertNoThrow(try pool.syncShutdownGracefully())
        XCTAssertThrowsError(try pool.syncShutdownGracefully()) {
            XCTAssertEqual($0 as? ConnectionPoolError, ConnectionPoolError.shutdown)
        }
    }

    func testGracefulShutdownWithHeldConnection() throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 2,
            on: self.group
        )
        
        let connection = try pool.requestConnection().wait()
        
        XCTAssertNoThrow(try pool.syncShutdownGracefully())
        XCTAssertThrowsError(try pool.syncShutdownGracefully()) {
            XCTAssertEqual($0 as? ConnectionPoolError, ConnectionPoolError.shutdown)
        }
        XCTAssertFalse(try connection.eventLoop.submit{ connection.isClosed }.wait())
        pool.releaseConnection(connection)
        XCTAssertTrue(try connection.eventLoop.submit{ connection.isClosed }.wait())
    }

    func testEventLoopDelegation() throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 1,
            on: self.group
        )
        defer { pool.shutdown() }
        
        for _ in 0..<500 {
            let eventLoop = self.group.any()
            let a = pool.requestConnection(
                on: eventLoop
            ).map { conn in
                XCTAssertTrue(eventLoop.inEventLoop)
                pool.releaseConnection(conn)
            }
            let b = pool.requestConnection(
                on: eventLoop
            ).map { conn in
                XCTAssertTrue(eventLoop.inEventLoop)
                pool.releaseConnection(conn)
            }
            _ = try a.and(b).wait()
        }
    }

    var group: EventLoopGroup!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    override func tearDownWithError() throws {
        try self.group.syncShutdownGracefully()
        self.group = nil
        try super.tearDownWithError()
    }

    override class func setUp() {
        super.setUp()
        XCTAssertTrue(isLoggingConfigured)
    }
}

private struct ErrorDatabase: ConnectionPoolSource {
    enum Error: Swift.Error {
        case test
    }
    
    func makeConnection(logger: Logger, on eventLoop: EventLoop) -> EventLoopFuture<FooConnection> {
        return eventLoop.makeFailedFuture(Error.test)
    }
}

private final class FooDatabase: ConnectionPoolSource {
    var connectionsCreated: ManagedAtomic<Int>

    init() {
        self.connectionsCreated = .init(0)
    }
    
    func makeConnection(logger: Logger, on eventLoop: EventLoop) -> EventLoopFuture<FooConnection> {
        let conn = FooConnection(on: eventLoop)
        self.connectionsCreated.wrappingIncrement(by: 1, ordering: .relaxed)
        return conn.eventLoop.makeSucceededFuture(conn)
    }
}

private final class FooConnection: ConnectionPoolItem {
    var isClosed: Bool
    let eventLoop: EventLoop

    init(on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.isClosed = false
    }
    
    func close() -> EventLoopFuture<Void> {
        self.isClosed = true
        return self.eventLoop.makeSucceededFuture(())
    }
}

func performance(expected seconds: Double, name: String = #function) -> Bool {
#if DEBUG
//    guard !_isDebugAssertConfiguration() else {
        print("[PERFORMANCE] Skipping \(name) in debug build mode")
        return false
//    }
#else
    print("[PERFORMANCE] \(name) expected: \(seconds) seconds")
    return true
#endif
}
