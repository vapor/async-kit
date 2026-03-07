import AsyncKit
import NIOCore
import Testing

@Suite
struct FutureOperatorTests {
    @Test
    func addition() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        var future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)

        #expect(try await (future1 + future2).get() == 13)
        
        future1 += future2
        #expect(try await future1.get() == 13)
        
        var arrayFuture1 = eventLoop.makeSucceededFuture([1, 2, 3])
        let arrayFuture2 = eventLoop.makeSucceededFuture([4, 5, 6])
        
        #expect(try await (arrayFuture1 + arrayFuture2).get() == [1, 2, 3, 4, 5, 6])
        #expect(try await (arrayFuture1 + arrayFuture2).get() != (arrayFuture2 + arrayFuture1).get())
        
        arrayFuture1 += arrayFuture2
        #expect(try await arrayFuture1.get() == [1, 2, 3, 4, 5, 6])
    }
    
    @Test
    func subtraction() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        var future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)
        
        #expect(try await (future1 - future2).get() == 3)
        
        future1 -= future2
        #expect(try await future1.get() == 3)
        
        var arrayFuture1 = eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6])
        let arrayFuture2 = eventLoop.makeSucceededFuture([4, 5, 6])
        
        #expect(try await (arrayFuture1 - arrayFuture2).get() == [1, 2, 3])
        
        arrayFuture1 -= arrayFuture2
        #expect(try await arrayFuture1.get() == [1, 2, 3])
    }
    
    @Test
    func multiplication() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        var future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)
        
        #expect(try await (future1 * future2).get() == 40)
        
        future1 *= future2
        #expect(try await future1.get() == 40)
    }
    
    @Test
    func modulo() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        var future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)
        
        #expect(try await (future1 % future2).get() == 3)
        
        future1 %= future2
        #expect(try await future1.get() == 3)
    }
    
    @Test
    func division() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        var future1 = eventLoop.makeSucceededFuture(40)
        let future2 = eventLoop.makeSucceededFuture(5)
        
        #expect(try await (future1 / future2).get() == 8)
        
        future1 /= future2
        #expect(try await future1.get() == 8)
    }
    
    @Test
    func comparison() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)
        let future3 = eventLoop.makeSucceededFuture(5)
        
        #expect(try await (future2 < future1).get())
        #expect(try await (future2 <= future3).get())
        #expect(try await (future2 >= future3).get())
        #expect(try await (future1 > future3).get())
    }

    @Test
    func bitshifts() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        var future1 = eventLoop.makeSucceededFuture(255)
        let future2 = eventLoop.makeSucceededFuture(16)

        #expect(try await (future1 << future2).get() == 16711680)
        
        future1 <<= future2
        #expect(try await future1.get() == 16711680)
        
        var future3 = eventLoop.makeSucceededFuture(16711680)
        let future4 = eventLoop.makeSucceededFuture(16)
        
        #expect(try await (future3 >> future4).get() == 255)
        
        future3 >>= future4
        #expect(try await future3.get() == 255)
    }
    
    @Test
    func and() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        var future1 = eventLoop.makeSucceededFuture(200)
        let future2 = eventLoop.makeSucceededFuture(500)
        
        #expect(try await (future1 & future2).get() == 192)
        
        future1 &= future2
        #expect(try await future1.get() == 192)
    }
    
    @Test
    func xor() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        var future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)
        
        #expect(try await (future1 ^ future2).get() == 13)
        
        future1 ^= future2
        #expect(try await future1.get() == 13)
    }
    
    @Test
    func or() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        var future1 = eventLoop.makeSucceededFuture(8)
        let future2 = eventLoop.makeSucceededFuture(5)
        
        #expect(try await (future1 | future2).get() == 13)
        
        future1 |= future2
        #expect(try await future1.get() == 13)
    }
    
    @Test
    func not() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let future1: EventLoopFuture<UInt8> = eventLoop.makeSucceededFuture(0b00001111)
        #expect(try await ~future1.get() == 0b11110000)
    }
}
