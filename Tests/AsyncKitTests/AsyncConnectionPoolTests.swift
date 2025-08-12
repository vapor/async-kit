import Atomics
@preconcurrency import AsyncKit
import XCTest
import NIOConcurrencyHelpers
import Logging
import NIOCore
import NIOEmbedded

final class AsyncConnectionPoolTests: AsyncKitAsyncTestCase {
    func testPooling() async throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 2,
            on: self.group.any()
        )
        
        // make two connections
        let connA = try await pool.requestConnection().get()
        XCTAssertEqual(connA.isClosed, false)
        let connB = try await pool.requestConnection().get()
        XCTAssertEqual(connB.isClosed, false)
        XCTAssertEqual(foo.connectionsCreated.load(ordering: .relaxed), 2)
        
        // try to make a third, but pool only supports 2
        let futureC = pool.requestConnection()
        let connC = ManagedAtomic<FooConnection?>(nil)
        futureC.whenSuccess { connC.store($0, ordering: .relaxed) }
        XCTAssertNil(connC.load(ordering: .relaxed))
        XCTAssertEqual(foo.connectionsCreated.load(ordering: .relaxed), 2)
        
        // release one of the connections, allowing the third to be made
        pool.releaseConnection(connB)
        let connCRet = try await futureC.get()
        XCTAssertNotNil(connC.load(ordering: .relaxed))
        XCTAssert(connC.load(ordering: .relaxed) === connB)
        XCTAssert(connCRet === connC.load(ordering: .relaxed))
        XCTAssertEqual(foo.connectionsCreated.load(ordering: .relaxed), 2)
        
        // try to make a third again, with two active
        let futureD = pool.requestConnection()
        let connD = ManagedAtomic<FooConnection?>(nil)
        futureD.whenSuccess { connD.store($0, ordering: .relaxed) }
        XCTAssertNil(connD.load(ordering: .relaxed))
        XCTAssertEqual(foo.connectionsCreated.load(ordering: .relaxed), 2)
        
        // this time, close the connection before releasing it
        try await connCRet.close().get()
        pool.releaseConnection(connC.load(ordering: .relaxed)!)
        let connDRet = try await futureD.get()
        XCTAssert(connD.load(ordering: .relaxed) !== connB)
        XCTAssert(connDRet === connD.load(ordering: .relaxed))
        XCTAssertEqual(connD.load(ordering: .relaxed)?.isClosed, false)
        XCTAssertEqual(foo.connectionsCreated.load(ordering: .relaxed), 3)
        
        try! await pool.close().get()
    }

    func testFIFOWaiters() async throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 1,
            on: self.group.any()
        )

        // * User A makes a request for a connection, gets connection number 1.
        let a_1 = pool.requestConnection()
        let a = try await a_1.get()

        // * User B makes a request for a connection, they are exhausted so he gets a promise.
        let b_1 = pool.requestConnection()

        // * User A makes another request for a connection, they are still exhausted so he gets a promise.
        let a_2 = pool.requestConnection()

        // * User A returns connection number 1. His previous request is fulfilled with connection number 1.
        pool.releaseConnection(a)

        // * User B gets his connection
        let b = try await b_1.get()
        XCTAssert(a === b)

        // * User B releases his connection
        pool.releaseConnection(b)

        // * User A's second connection request is fulfilled
        let c = try await a_2.get()
        XCTAssert(a === c)
        
        try! await pool.close().get()
    }

    func testConnectError() async throws {
        let db = ErrorDatabase()
        let pool = EventLoopConnectionPool(
            source: db,
            maxConnections: 1,
            on: self.group.any()
        )

        do {
            _ = try await pool.requestConnection().get()
            XCTFail("should not have created connection")
        } catch _ as ErrorDatabase.Error {
            // pass
        }

        // test that we can still make another request even after a failed request
        do {
            _ = try await pool.requestConnection().get()
            XCTFail("should not have created connection")
        } catch _ as ErrorDatabase.Error {
            // pass
        }
        
        try! await pool.close().get()
    }

    func testPoolClose() async throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 1,
            on: self.group.any()
        )
        let _ = try await pool.requestConnection().get()
        let b = pool.requestConnection()
        try await pool.close().get()
        
        let c = pool.requestConnection()

        // check that waiters are failed
        do {
            _ = try await b.get()
            XCTFail("should not have created connection")
        } catch ConnectionPoolError.shutdown {
            // pass
        }

        // check that new requests fail
        do {
            _ = try await c.get()
            XCTFail("should not have created connection")
        } catch ConnectionPoolError.shutdown {
            // pass
        }
    }
    
    func testGracefulShutdownAsync() async throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 2,
            on: self.group
        )
        
        try await pool.shutdownAsync()
        var errorCaught = false
        
        do {
            try await pool.shutdownAsync()
        } catch {
            errorCaught = true
            XCTAssertEqual(error as? ConnectionPoolError, ConnectionPoolError.shutdown)
        }
        XCTAssertTrue(errorCaught)
    }

    func testShutdownWithHeldConnection() async throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 2,
            on: self.group
        )
        
        let connection = try await pool.requestConnection().get()
        
        try await pool.shutdownAsync()
        var errorCaught = false
        
        do {
            try await pool.shutdownAsync()
        } catch {
            errorCaught = true
            XCTAssertEqual(error as? ConnectionPoolError, ConnectionPoolError.shutdown)
        }
        XCTAssertTrue(errorCaught)
        
        let result1 = try await connection.eventLoop.submit { connection.isClosed }.get()
        XCTAssertFalse(result1)
        pool.releaseConnection(connection)
        let result2 = try await connection.eventLoop.submit { connection.isClosed }.get()
        XCTAssertTrue(result2)
    }

    func testEventLoopDelegation() async throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 1,
            on: self.group
        )
        
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
            _ = try await a.and(b).get()
        }
        
        try await pool.shutdownAsync()
    }
}
