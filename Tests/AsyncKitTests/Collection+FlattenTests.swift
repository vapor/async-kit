import AsyncKit
import NIOCore
import Testing

@Suite
struct CollectionFlattenTests {
    @Test
    func elFlatten() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let futures = [
            eventLoop.makeSucceededFuture(1),
            eventLoop.makeSucceededFuture(2),
            eventLoop.makeSucceededFuture(3),
            eventLoop.makeSucceededFuture(4),
            eventLoop.makeSucceededFuture(5),
            eventLoop.makeSucceededFuture(6),
            eventLoop.makeSucceededFuture(7)
        ]
        
        let flattened = eventLoop.flatten(futures)
        #expect(try await flattened.get() == [1, 2, 3, 4, 5, 6, 7])

        let voids = [
            eventLoop.makeSucceededFuture(()),
            eventLoop.makeSucceededFuture(()),
            eventLoop.makeSucceededFuture(()),
            eventLoop.makeSucceededFuture(()),
            eventLoop.makeSucceededFuture(()),
            eventLoop.makeSucceededFuture(()),
            eventLoop.makeSucceededFuture(())
        ]
        
        let void = eventLoop.flatten(voids)
        #expect(try await void.get() == ())
    }
    
    @Test
    func collectionFlatten() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let futures = [
            eventLoop.makeSucceededFuture(1),
            eventLoop.makeSucceededFuture(2),
            eventLoop.makeSucceededFuture(3),
            eventLoop.makeSucceededFuture(4),
            eventLoop.makeSucceededFuture(5),
            eventLoop.makeSucceededFuture(6),
            eventLoop.makeSucceededFuture(7)
        ]
        
        let flattened = futures.flatten(on: eventLoop)
        #expect(try await flattened.get() == [1, 2, 3, 4, 5, 6, 7])
    }
}
