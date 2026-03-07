import AsyncKit
import NIOCore
import Testing

@Suite
struct FutureNonemptyTests {
    @Test
    func nonempty() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()

        await #expect(throws: Never.self) { try await eventLoop.future([0]).nonempty(orError: TestError.notEqualTo1).get() }
        await #expect(throws: (any Error).self) { try await eventLoop.future([]).nonempty(orError: TestError.notEqualTo1).get() }

        #expect(try await eventLoop.future([0]).nonemptyMap(or: 1, { $0[0] }).get() == 0)
        #expect(try await eventLoop.future([]).nonemptyMap(or: 1, { $0[0] }).get() == 1)

        #expect(try await eventLoop.future([0]).nonemptyMap({ [$0[0]] }).get() == [0])
        #expect(try await eventLoop.future([Int]()).nonemptyMap({ [$0[0]] }).get() == [])

        #expect(try await eventLoop.future([0]).nonemptyFlatMapThrowing(or: 1, { (a) throws -> Int in a[0] }).get() == 0)
        #expect(try await eventLoop.future([]).nonemptyFlatMapThrowing(or: 1, { (a) throws -> Int in a[0] }).get() == 1)

        #expect(try await eventLoop.future([0]).nonemptyFlatMapThrowing({ (a) throws -> [Int] in [a[0]] }).get() == [0])
        #expect(try await eventLoop.future([Int]()).nonemptyFlatMapThrowing({ (a) throws -> [Int] in [a[0]] }).get() == [])

        #expect(try await eventLoop.future([0]).nonemptyFlatMap(or: 1, { eventLoop.future($0[0]) }).get() == 0)
        #expect(try await eventLoop.future([]).nonemptyFlatMap(or: 1, { eventLoop.future($0[0]) }).get() == 1)

        #expect(try await eventLoop.future([0]).nonemptyFlatMap(orFlat: eventLoop.future(1), { eventLoop.future($0[0]) }).get() == 0)
        #expect(try await eventLoop.future([]).nonemptyFlatMap(orFlat: eventLoop.future(1), { eventLoop.future($0[0]) }).get() == 1)

        #expect(try await eventLoop.future([0]).nonemptyFlatMap({ eventLoop.future([$0[0]]) }).get() == [0])
        #expect(try await eventLoop.future([Int]()).nonemptyFlatMap({ eventLoop.future([$0[0]]) }).get() == [])
    }
}
