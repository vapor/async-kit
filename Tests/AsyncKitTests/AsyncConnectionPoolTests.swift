@preconcurrency import AsyncKit
import Atomics
import Logging
import NIOConcurrencyHelpers
import NIOCore
import NIOEmbedded
import Testing

@Suite
struct AsyncConnectionPoolTests {
    @Test
    func pooling() async throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 2,
            on: NIOSingletons.posixEventLoopGroup.any()
        )
        
        // make two connections
        let connA = try await pool.requestConnection().get()
        #expect(!connA.isClosed)
        let connB = try await pool.requestConnection().get()
        #expect(!connB.isClosed)
        #expect(foo.connectionsCreated.load(ordering: .relaxed) == 2)

        // try to make a third, but pool only supports 2
        let futureC = pool.requestConnection()
        let connC = ManagedAtomic<FooConnection?>(nil)
        futureC.whenSuccess { connC.store($0, ordering: .relaxed) }
        #expect(connC.load(ordering: .relaxed) == nil)
        #expect(foo.connectionsCreated.load(ordering: .relaxed) == 2)

        // release one of the connections, allowing the third to be made
        pool.releaseConnection(connB)
        let connCRet = try await futureC.get()
        #expect(connC.load(ordering: .relaxed) != nil)
        #expect(connC.load(ordering: .relaxed) === connB)
        #expect(connCRet === connC.load(ordering: .relaxed))
        #expect(foo.connectionsCreated.load(ordering: .relaxed) == 2)

        // try to make a third again, with two active
        let futureD = pool.requestConnection()
        let connD = ManagedAtomic<FooConnection?>(nil)
        futureD.whenSuccess { connD.store($0, ordering: .relaxed) }
        #expect(connD.load(ordering: .relaxed) == nil)
        #expect(foo.connectionsCreated.load(ordering: .relaxed) == 2)

        // this time, close the connection before releasing it
        try await connCRet.close().get()
        pool.releaseConnection(connC.load(ordering: .relaxed)!)
        let connDRet = try await futureD.get()
        #expect(connD.load(ordering: .relaxed) !== connB)
        #expect(connDRet === connD.load(ordering: .relaxed))
        #expect(connD.load(ordering: .relaxed)?.isClosed == false)
        #expect(foo.connectionsCreated.load(ordering: .relaxed) == 3)

        try await pool.close().get()
    }

    func testFIFOWaiters() async throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 1,
            on: NIOSingletons.posixEventLoopGroup.any()
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
        #expect(a === b)

        // * User B releases his connection
        pool.releaseConnection(b)

        // * User A's second connection request is fulfilled
        let c = try await a_2.get()
        #expect(a === c)

        try await pool.close().get()
    }

    func testConnectError() async throws {
        let db = ErrorDatabase()
        let pool = EventLoopConnectionPool(
            source: db,
            maxConnections: 1,
            on: NIOSingletons.posixEventLoopGroup.any()
        )

        await #expect(throws: ErrorDatabase.Error.self) { try await pool.requestConnection().get() }

        // test that we can still make another request even after a failed request
        await #expect(throws: ErrorDatabase.Error.self) { try await pool.requestConnection().get() }

        try await pool.close().get()
    }

    func testPoolClose() async throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 1,
            on: NIOSingletons.posixEventLoopGroup.any()
        )
        let _ = try await pool.requestConnection().get()
        let b = pool.requestConnection()
        try await pool.close().get()
        
        let c = pool.requestConnection()

        // check that waiters are failed
        await #expect(throws: ConnectionPoolError.shutdown) { try await b.get() }

        // check that new requests fail
        await #expect(throws: ConnectionPoolError.shutdown) { try await c.get() }
    }
    
    func testGracefulShutdownAsync() async throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 2,
            on: NIOSingletons.posixEventLoopGroup
        )
        
        try await pool.shutdownAsync()

        await #expect(throws: ConnectionPoolError.shutdown) { try await pool.shutdownAsync() }
    }

    func testShutdownWithHeldConnection() async throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 2,
            on: NIOSingletons.posixEventLoopGroup
        )
        
        let connection = try await pool.requestConnection().get()
        
        try await pool.shutdownAsync()

        await #expect(throws: ConnectionPoolError.shutdown) { try await pool.shutdownAsync() }

        #expect(!(try await connection.eventLoop.submit { connection.isClosed }.get()))
        pool.releaseConnection(connection)
        #expect(try await connection.eventLoop.submit { connection.isClosed }.get())
    }

    func testEventLoopDelegation() async throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 1,
            on: NIOSingletons.posixEventLoopGroup
        )
        
        for _ in 0..<500 {
            let eventLoop = NIOSingletons.posixEventLoopGroup.any()
            let a = pool.requestConnection(on: eventLoop).map { conn in
                #expect(eventLoop.inEventLoop)
                pool.releaseConnection(conn)
            }
            let b = pool.requestConnection(on: eventLoop).map { conn in
                #expect(eventLoop.inEventLoop)
                pool.releaseConnection(conn)
            }
            _ = try await a.and(b).get()
        }
        
        try await pool.shutdownAsync()
    }
}
