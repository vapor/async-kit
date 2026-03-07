import AsyncKit
import NIOCore
import Testing

@Suite
struct EventLoopGroupFutureTests {
    @Test
    func futureVoid() async throws {
        await #expect(throws: Never.self) { try await NIOSingletons.posixEventLoopGroup.future().get() }
        await #expect(throws: Never.self) { try await NIOSingletons.posixEventLoopGroup.any().future().get() }
    }

    @Test
    func future() async throws {
        #expect(try await NIOSingletons.posixEventLoopGroup.future(1).get() == 1)
        #expect(try await NIOSingletons.posixEventLoopGroup.any().future(1).get() == 1)

        #expect(try await NIOSingletons.posixEventLoopGroup.future(true).get() == true)
        #expect(try await NIOSingletons.posixEventLoopGroup.any().future("foo").get() == "foo")
    }

    @Test
    func futureError() async throws {
        let groupErr: EventLoopFuture<Int> = NIOSingletons.posixEventLoopGroup.future(error: TestError.notEqualTo1)
        let eventLoopErr: EventLoopFuture<String> = NIOSingletons.posixEventLoopGroup.any().future(error: TestError.notEqualToBar)

        await #expect(throws: (any Error).self) { try await groupErr.get() }
        await #expect(throws: (any Error).self) { try await eventLoopErr.get() }
    }
}
