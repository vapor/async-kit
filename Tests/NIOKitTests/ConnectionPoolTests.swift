import NIOKit
import XCTest

public final class ConnectionPoolTests: XCTestCase {
    func testPooling() throws {
        let foo = FooDatabase()
        let pool = ConnectionPool(config: .init(maxConnections: 2), source: foo)
        
        // make two connections
        let connA = try pool.requestConnection().wait()
        XCTAssertEqual(connA.isClosed, false)
        let connB = try pool.requestConnection().wait()
        XCTAssertEqual(connB.isClosed, false)
        XCTAssertEqual(foo.connectionsCreated, 2)
        
        // try to make a third, but pool only supports 2
        var connC: FooConnection?
        pool.requestConnection().whenSuccess { connC = $0 }
        XCTAssertNil(connC)
        XCTAssertEqual(foo.connectionsCreated, 2)
        
        // release one of the connections, allowing the third to be made
        pool.releaseConnection(connB)
        XCTAssertNotNil(connC)
        XCTAssert(connC === connB)
        XCTAssertEqual(foo.connectionsCreated, 2)
        
        // try to make a third again, with two active
        var connD: FooConnection?
        pool.requestConnection().whenSuccess { connD = $0 }
        XCTAssertNil(connD)
        XCTAssertEqual(foo.connectionsCreated, 2)
        
        // this time, close the connection before releasing it
        connC!.close()
        pool.releaseConnection(connC!)
        XCTAssert(connD !== connB)
        XCTAssertEqual(connD?.isClosed, false)
        XCTAssertEqual(foo.connectionsCreated, 3)
    }
    
    func testFIFOWaiters() throws {
        let foo = FooDatabase()
        let pool = ConnectionPool(config: .init(maxConnections: 1), source: foo)
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
    
    func testPerformance() {
        guard performance(expected: 0.115) else { return }
        let foo = FooDatabase()
        let pool = ConnectionPool(config: .init(maxConnections: 10), source: foo)
        
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
    
    public static let allTests = [
        ("testPooling", testPooling),
        ("testFIFOWaiters", testFIFOWaiters),
        ("testPerformance", testPerformance),
    ]
}

private final class FooDatabase: ConnectionPoolSource {
    let eventLoop: EventLoop
    var connectionsCreated: Int
    init() {
        self.eventLoop = EmbeddedEventLoop()
        self.connectionsCreated = 0
    }
    
    func makeConnection() -> EventLoopFuture<FooConnection> {
        let conn = FooConnection()
        self.connectionsCreated += 1
        return self.eventLoop.makeSucceededFuture(conn)
    }
}

private final class FooConnection: ConnectionPoolItem {
    var isClosed: Bool
    init() {
        self.isClosed = false
    }
    
    func close() {
        self.isClosed = true
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
