import AsyncKit
import NIOCore
import Testing

@Suite
struct FutureTryTests {
    @Test
    func tryFlatMapPropagatesCallbackError() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let future = eventLoop.future(0)
            .tryFlatMap { _ -> EventLoopFuture<String> in
                throw TestError.generic
            }

        await #expect(throws: TestError.generic) { try await future.get() }
    }

    @Test
    func tryFlatMapPropagatesInnerError() async {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let future = eventLoop.future(0)
            .tryFlatMap { _ -> EventLoopFuture<String> in
                eventLoop.makeFailedFuture(TestError.generic)
            }

        await #expect(throws: TestError.generic) { try await future.get() }
    }

    @Test
    func tryFlatMapPropagatesResult() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let future = eventLoop.future(0)
            .tryFlatMap { value -> EventLoopFuture<String> in
                eventLoop.makeSucceededFuture(String(describing: value))
            }

        #expect(try await future.get() == "0")
    }
}
