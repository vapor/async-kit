import AsyncKit
import NIOCore
import Testing

@Suite
struct FutureOptionalTests {
    @Test
    func optionalMap() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let future = eventLoop.makeSucceededFuture(Optional<Int>.some(1))
        let null = eventLoop.makeSucceededFuture(Optional<Int>.none)
        
        let times2 = future.optionalMap { $0 * 2 }
        let null2 = null.optionalMap { $0 * 2 }
        let nullResult = future.optionalMap { _ in Optional<Int>.none }
        
        #expect(try await 2 == times2.get())
        #expect(try await nil == null2.get())
        #expect(try await nil == nullResult.get())
    }
    
    @Test
    func optionalFlatMapThrowing() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let future = eventLoop.makeSucceededFuture(Optional<Int>.some(1))
        
        let times2 = future.optionalFlatMapThrowing { $0 * 2 }
        let null2 = future.optionalFlatMapThrowing { return $0 % 2 == 0 ? $0 : nil }
        let error = future.optionalFlatMapThrowing { _ in throw TestError.generic }
        
        #expect(try await 2 == times2.get())
        #expect(try await nil == null2.get())
        await #expect(throws: (any Error).self) { try await error.get() }
    }
    
    @Test
    func optionalFlatMap() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let future = eventLoop.makeSucceededFuture(Optional<Int>.some(1))
        let null = eventLoop.makeSucceededFuture(Optional<Int>.none)
        
        var times2 = future.optionalFlatMap { self.multiply($0, 2) }
        var null2 = null.optionalFlatMap { self.multiply($0, 2) }
        
        #expect(try await 2 == times2.get())
        #expect(try await nil == null2.get())

        
        times2 = future.optionalFlatMap { self.multiply($0, Optional<Int>.some(2)) }
        null2 = future.optionalFlatMap { self.multiply($0, nil) }
        
        #expect(try await 2 == times2.get())
        #expect(try await nil == null2.get())
    }
    
    func multiply(_ a: Int, _ b: Int) -> EventLoopFuture<Int> {
        return NIOSingletons.posixEventLoopGroup.any().makeSucceededFuture(a * b)
    }
    
    func multiply(_ a: Int, _ b: Int?) -> EventLoopFuture<Int?> {
        return NIOSingletons.posixEventLoopGroup.any().makeSucceededFuture(b == nil ? nil : a * b!)
    }
}
