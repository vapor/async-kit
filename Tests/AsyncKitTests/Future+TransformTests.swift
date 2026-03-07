import AsyncKit
import NIOCore
import Testing

@Suite
struct FutureTransformTests {
    @Test
    func transforms() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let future = eventLoop.makeSucceededFuture(Int.random(in: 0...100))
        
        #expect(try await future.transform(to: true).get())

        let futureA = eventLoop.makeSucceededFuture(Int.random(in: 0...100))
        let futureB = eventLoop.makeSucceededFuture(Int.random(in: 0...100))
        
        #expect(try await futureA.and(futureB).transform(to: true).get())

        let futureBool = eventLoop.makeSucceededFuture(true)
        
        #expect(try await future.transform(to: futureBool).get())

        #expect(try await futureA.and(futureB).transform(to: futureBool).get())
    }
}
