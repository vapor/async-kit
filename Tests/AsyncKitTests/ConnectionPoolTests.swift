import AsyncKit
import XCTest
import NIOConcurrencyHelpers

final class ConnectionPoolTests: XCTestCase {
    func testPooling() throws {
        let foo = FooDatabase()
        let pool = ConnectionPool(configuration: .init(maxConnections: 2), source: foo)
        defer { pool.shutdown() }
        
        // make two connections
        let connA = try pool.requestConnection(on: EmbeddedEventLoop()).wait()
        XCTAssertEqual(connA.isClosed, false)
        let connB = try pool.requestConnection(on: EmbeddedEventLoop()).wait()
        XCTAssertEqual(connB.isClosed, false)
        XCTAssertEqual(foo.connectionsCreated.load(), 2)
        
        // try to make a third, but pool only supports 2
        var connC: FooConnection?
        pool.requestConnection(on: EmbeddedEventLoop()).whenSuccess { connC = $0 }
        XCTAssertNil(connC)
        XCTAssertEqual(foo.connectionsCreated.load(), 2)
        
        // release one of the connections, allowing the third to be made
        pool.releaseConnection(connB)
        XCTAssertNotNil(connC)
        XCTAssert(connC === connB)
        XCTAssertEqual(foo.connectionsCreated.load(), 2)
        
        // try to make a third again, with two active
        var connD: FooConnection?
        pool.requestConnection(on: EmbeddedEventLoop()).whenSuccess { connD = $0 }
        XCTAssertNil(connD)
        XCTAssertEqual(foo.connectionsCreated.load(), 2)
        
        // this time, close the connection before releasing it
        try connC!.close().wait()
        pool.releaseConnection(connC!)
        XCTAssert(connD !== connB)
        XCTAssertEqual(connD?.isClosed, false)
        XCTAssertEqual(foo.connectionsCreated.load(), 3)
    }

    func testFIFOWaiters() throws {
        let foo = FooDatabase()
        let pool = ConnectionPool(configuration: .init(maxConnections: 1), source: foo)
        defer { pool.shutdown() }

        // * User A makes a request for a connection, gets connection number 1.
        let a_1 = pool.requestConnection(on: EmbeddedEventLoop())
        let a = try a_1.wait()

        // * User B makes a request for a connection, they are exhausted so he gets a promise.
        let b_1 = pool.requestConnection(on: EmbeddedEventLoop())

        // * User A makes another request for a connection, they are still exhausted so he gets a promise.
        let a_2 = pool.requestConnection(on: EmbeddedEventLoop())

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
        let pool = ConnectionPool(configuration: .init(maxConnections: 1), source: db)
        defer { pool.shutdown() }

        do {
            _ = try pool.requestConnection(on: EmbeddedEventLoop()).wait()
            XCTFail("should not have created connection")
        } catch _ as ErrorDatabase.Error {
            // pass
        }

        // test that we can still make another request even after a failed request
        do {
            _ = try pool.requestConnection(on: EmbeddedEventLoop()).wait()
            XCTFail("should not have created connection")
        } catch _ as ErrorDatabase.Error {
            // pass
        }
    }

    func testPoolClose() throws {
        let foo = FooDatabase()
        let pool = ConnectionPool(configuration: .init(maxConnections: 1), source: foo)
        let _ = try pool.requestConnection(on: EmbeddedEventLoop()).wait()
        let b = pool.requestConnection(on: EmbeddedEventLoop())
        pool.shutdown()
        let c = pool.requestConnection(on: EmbeddedEventLoop())

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

    func testPerformance() {
        guard performance(expected: 0.088) else { return }
        let foo = FooDatabase()
        let pool = ConnectionPool(configuration: .init(maxConnections: 10), source: foo)

        measure {
            for _ in 0..<10_000 {
                do {
                    let connA = try! pool.requestConnection(on: EmbeddedEventLoop()).wait()
                    pool.releaseConnection(connA)
                }
                do {
                    let connA = try! pool.requestConnection(on: EmbeddedEventLoop()).wait()
                    let connB = try! pool.requestConnection(on: EmbeddedEventLoop()).wait()
                    let connC = try! pool.requestConnection(on: EmbeddedEventLoop()).wait()
                    pool.releaseConnection(connB)
                    pool.releaseConnection(connC)
                    pool.releaseConnection(connA)
                }
                do {
                    let connA = try! pool.requestConnection(on: EmbeddedEventLoop()).wait()
                    let connB = try! pool.requestConnection(on: EmbeddedEventLoop()).wait()
                    pool.releaseConnection(connA)
                    pool.releaseConnection(connB)
                }
            }
        }
    }

    func testThreadSafety() throws {
        let foo = FooDatabase()
        let pool = ConnectionPool(configuration: .init(maxConnections: 10), source: foo)
        defer { pool.shutdown() }

        var futures: [EventLoopFuture<Void>] = []

        var eventLoops = eventLoopGroup.makeIterator()
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

        try futures.flatten(on: eventLoopGroup.next()).wait()
    }

    var eventLoopGroup: EventLoopGroup!

    override func setUp() {
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 4)
    }

    override func tearDown() {
        try! self.eventLoopGroup.syncShutdownGracefully()
    }
}

private struct ErrorDatabase: ConnectionPoolSource {
    enum Error: Swift.Error {
        case test
    }
    
    func makeConnection(on eventLoop: EventLoop) -> EventLoopFuture<FooConnection> {
        return eventLoop.makeFailedFuture(Error.test)
    }
}

private final class FooDatabase: ConnectionPoolSource {
    var connectionsCreated: Atomic<Int>

    init() {
        self.connectionsCreated = .init(value: 0)
    }
    
    func makeConnection(on eventLoop: EventLoop) -> EventLoopFuture<FooConnection> {
        let conn = FooConnection(on: eventLoop)
        _ = self.connectionsCreated.add(1)
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
    guard !_isDebugAssertConfiguration() else {
        print("[PERFORMANCE] Skipping \(name) in debug build mode")
        return false
    }
    print("[PERFORMANCE] \(name) expected: \(seconds) seconds")
    return true
}
