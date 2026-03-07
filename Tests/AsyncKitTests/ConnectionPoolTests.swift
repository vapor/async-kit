@testable import AsyncKit
import Atomics
import Logging
import NIOConcurrencyHelpers
import NIOCore
import NIOEmbedded
import Testing

@Suite
struct ConnectionPoolTests {
    @Test
    func pooling() async throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 2,
            on: NIOSingletons.posixEventLoopGroup.any()
        )

        do {
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
        } catch {
            try? await pool.close().get()
            throw error
        }
    }

    @Test
    func connectionPruning() async throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 5,
            pruneInterval: .milliseconds(200),
            maxIdleTimeBeforePruning: .milliseconds(300),
            on: MultiThreadedEventLoopGroup(numberOfThreads: 1).next()
        )

        do {
            let connA = try await pool.requestConnection().get()

            let anotherConnection1 = try await pool.requestConnection().get()
            let anotherConnection2 = try await pool.requestConnection().get()

            pool.releaseConnection(connA)

            let connA1 = try await pool.requestConnection().get()
            #expect(connA === connA1)
            pool.releaseConnection(connA1)

            // Keeping connection alive by using it and closing it
            for _ in 0..<3 {
                try await Task.sleep(nanoseconds: 200_000_000)
                let connA2 = try await pool.requestConnection().get()
                #expect(connA === connA2)
                pool.releaseConnection(connA2)
            }

            pool.releaseConnection(anotherConnection1)
            pool.releaseConnection(anotherConnection2)

            try await Task.sleep(nanoseconds: 700_000_000)
            let (knownConnections, activeConnections, openConnections) = try await pool.poolState().get()
            #expect(knownConnections == 0)
            #expect(activeConnections == 0)
            #expect(openConnections == 0)

            let connB = try await pool.requestConnection().get()
            #expect(connA !== connB)
            #expect(try await pool.poolState().get().active == 1)

            try await pool.close().get()
        } catch {
            try? await pool.close().get()
            throw error
        }
    }

    @Test
    func fifoWaiters() async throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 1,
            on: NIOSingletons.posixEventLoopGroup.any()
        )

        do {
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
        } catch {
            try? await pool.close().get()
            throw error
        }
    }

    @Test
    func connectError() async throws {
        let db = ErrorDatabase()
        let pool = EventLoopConnectionPool(
            source: db,
            maxConnections: 1,
            on: NIOSingletons.posixEventLoopGroup.any()
        )

        do {
            await #expect(throws: ErrorDatabase.Error.self) { try await pool.requestConnection().get() }

            // test that we can still make another request even after a failed request
            await #expect(throws: ErrorDatabase.Error.self) { try await pool.requestConnection().get() }

            try await pool.close().get()
        } catch {
            try? await pool.close().get()
            throw error
        }
    }

    @Test
    func poolClose() async throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 1,
            on: NIOSingletons.posixEventLoopGroup.any()
        )

        _ = try await pool.requestConnection().get()
        let b = pool.requestConnection()
        try await pool.close().get()

        let c = pool.requestConnection()

        // check that waiters are failed
        await #expect(throws: ConnectionPoolError.shutdown) { try await b.get() }

        // check that new requests fail
        await #expect(throws: ConnectionPoolError.shutdown) { try await c.get() }
    }

    // https://github.com/vapor/async-kit/issues/63
    @Test
    func deadlock() async throws {
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 1,
            requestTimeout: .milliseconds(100),
            on: NIOSingletons.posixEventLoopGroup.any()
        )

        _ = pool.requestConnection()
        let a = pool.requestConnection()
        await #expect(throws: ConnectionPoolTimeoutError.connectionRequestTimeout) { try await a.get() }
        try await pool.close().get()
    }

    /*func testPerformance() {
        guard performance(expected: 0.088) else { return }
        let foo = FooDatabase()
        let pool = EventLoopConnectionPool(
            source: foo,
            maxConnections: 3,
            on: NIOSingletons.posixEventLoopGroup.any()
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
    }*/

    @Test
    func threadSafety() async throws {
        let foo = FooDatabase()
        nonisolated(unsafe) let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 2,
            on: NIOSingletons.posixEventLoopGroup
        )

        do {
            var futures: [EventLoopFuture<Void>] = []

            var eventLoops = NIOSingletons.posixEventLoopGroup.makeIterator()
            while let eventLoop = eventLoops.next() {
                let promise = eventLoop.makePromise(of: Void.self)
                eventLoop.execute {
                    (0 ..< 1_000).map { i in
                        pool.withConnection(on: eventLoop) { $0.eventLoop.makeSucceededFuture(i) }
                    }.flatten(on: eventLoop)
                        .map { #expect($0.count == 1_000) }
                        .cascade(to: promise)
                }
                futures.append(promise.futureResult)
            }

            try await futures.flatten(on: NIOSingletons.posixEventLoopGroup.any()).get()

            try await pool.shutdownAsync()
        } catch {
            try? await pool.shutdownAsync()
            throw error
        }
    }

    // Not clear how to test this with SwiftTesting
    /*
    @Test
    func gracefulShutdownAsync() async throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 2,
            on: NIOSingletons.posixEventLoopGroup
        )

        await confirmation("Shutdown completion") { completion in
            pool.shutdownGracefully {
                #expect($0 == nil)
                completion()
            }
        }

        await confirmation("Shutdown completion with error") { completion in
            pool.shutdownGracefully {
                #expect($0 as? ConnectionPoolError == ConnectionPoolError.shutdown)
                completion()
            }
        }
    }
    */

    @Test
    func gracefulShutdownSync() async throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 2,
            on: NIOSingletons.posixEventLoopGroup
        )

        #expect(throws: Never.self) { try pool.syncShutdownGracefully() }
        #expect(throws: ConnectionPoolError.shutdown) { try pool.syncShutdownGracefully() }
    }

    func testGracefulShutdownWithHeldConnection() async throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 2,
            on: NIOSingletons.posixEventLoopGroup
        )

        let connection = try await pool.requestConnection().get()

        #expect(throws: Never.self) { try pool.syncShutdownGracefully() }
        #expect(throws: ConnectionPoolError.shutdown) { try pool.syncShutdownGracefully() }
        #expect(!(try await connection.eventLoop.submit { connection.isClosed }.get()))
        pool.releaseConnection(connection)
        #expect(try await connection.eventLoop.submit { connection.isClosed }.get())
    }

    func testEventLoopDelegation() throws {
        let foo = FooDatabase()
        let pool = EventLoopGroupConnectionPool(
            source: foo,
            maxConnectionsPerEventLoop: 1,
            on: NIOSingletons.posixEventLoopGroup
        )
        defer { pool.shutdown() }

        for _ in 0..<500 {
            let eventLoop = NIOSingletons.posixEventLoopGroup.any()
            let a = pool.requestConnection(
                on: eventLoop
            ).map { conn in
                #expect(eventLoop.inEventLoop)
                pool.releaseConnection(conn)
            }
            let b = pool.requestConnection(
                on: eventLoop
            ).map { conn in
                #expect(eventLoop.inEventLoop)
                pool.releaseConnection(conn)
            }
            _ = try a.and(b).wait()
        }
    }
}

struct ErrorDatabase: ConnectionPoolSource {
    enum Error: Swift.Error {
        case test
    }

    func makeConnection(logger: Logger, on eventLoop: any EventLoop) -> EventLoopFuture<FooConnection> {
        return eventLoop.makeFailedFuture(Error.test)
    }
}

final class FooDatabase: ConnectionPoolSource, Sendable {
    let connectionsCreated: ManagedAtomic<Int>

    init() {
        self.connectionsCreated = .init(0)
    }

    func makeConnection(logger: Logger, on eventLoop: any EventLoop) -> EventLoopFuture<FooConnection> {
        let conn = FooConnection(on: eventLoop)
        self.connectionsCreated.wrappingIncrement(by: 1, ordering: .relaxed)
        return conn.eventLoop.makeSucceededFuture(conn)
    }
}

final class FooConnection: ConnectionPoolItem, AtomicReference, @unchecked Sendable {
    var isClosed: Bool
    let eventLoop: any EventLoop

    init(on eventLoop: any EventLoop) {
        self.eventLoop = eventLoop
        self.isClosed = false
    }

    func close() -> EventLoopFuture<Void> {
        self.isClosed = true
        return self.eventLoop.makeSucceededFuture(())
    }
}

/*func performance(expected seconds: Double, name: String = #function) -> Bool {
    #if DEBUG
        //    guard !_isDebugAssertConfiguration() else {
        print("[PERFORMANCE] Skipping \(name) in debug build mode")
        return false
    //    }
    #else
        print("[PERFORMANCE] \(name) expected: \(seconds) seconds")
        return true
    #endif
}*/
