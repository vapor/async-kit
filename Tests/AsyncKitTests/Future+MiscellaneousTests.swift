import AsyncKit
import class Foundation.Thread
import NIOCore
import Testing

@Suite
struct FutureMiscellaneousTests {
    @Test
    func `guard`() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let future1 = eventLoop.makeSucceededFuture(1)
        let guardedFuture1 = future1.guard({ $0 == 1 }, else: TestError.notEqualTo1)
        await #expect(throws: Never.self) { try await guardedFuture1.get() }

        let future2 = eventLoop.makeSucceededFuture("foo")
        let guardedFuture2 = future2.guard({ $0 == "bar" }, else: TestError.notEqualToBar)
        await #expect(throws: (any Error).self) { try await guardedFuture2.get() }
    }

    @Test
    func tryThrowing() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let future1: EventLoopFuture<String> = eventLoop.tryFuture { return "Hello" }
        let future2: EventLoopFuture<String> = eventLoop.tryFuture { throw TestError.notEqualTo1 }

        #expect(try await future1.get() == "Hello")
        await #expect(throws: (any Error).self) { try await future2.get() }
    }

    @Test
    func tryFutureThread() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let future = eventLoop.tryFuture { Thread.current.name }
        let name = try #require(try await future.get())

        #expect(name.starts(with: "NIO-SGL"), "'\(name)' is not a valid NIO ELT name")
    }
}
