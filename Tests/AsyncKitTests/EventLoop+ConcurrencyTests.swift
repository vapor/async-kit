import AsyncKit
import NIOCore
import Testing

@Suite
struct EventLoopConcurrencyTests {
    @Test
    func groupMakeFutureWithTask() async throws {
        @Sendable
        func getOne() async throws -> Int {
            return 1
        }
        let expectedOne = NIOSingletons.posixEventLoopGroup.makeFutureWithTask {
            try await getOne()
        }
        
        #expect(try await expectedOne.get() == 1)
    }
}

