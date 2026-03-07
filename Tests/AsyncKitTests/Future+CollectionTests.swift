import AsyncKit
import NIOConcurrencyHelpers
import NIOCore
import Testing

extension EventLoopGroup {
    func spinAll(on eventLoop: any EventLoop) -> EventLoopFuture<Void> {
        assert(self.makeIterator().contains(where: { ObjectIdentifier($0) == ObjectIdentifier(eventLoop) }))
        
        return .andAllSucceed(self.makeIterator().map { $0.submit {} }, on: eventLoop)
    }
}

struct FutureCollectionTests {
    @Test
    func mapEach() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let collection1 = eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6, 7, 8, 9])
        let times2 = collection1.mapEach { int -> Int in int * 2 }
        
        #expect(try await times2.get() == [2, 4, 6, 8, 10, 12, 14, 16, 18])
        
        let collection2 = eventLoop.makeSucceededFuture(["a", "bb", "ccc", "dddd", "eeeee"])
        let lengths = collection2.mapEach(\.count)
        
        #expect(try await lengths.get() == [1, 2, 3, 4, 5])
    
    }
    
    @Test
    func mapEachCompact() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let collection1 = eventLoop.makeSucceededFuture(["one", "2", "3", "4", "five", "^", "7"])
        let times2 = collection1.mapEachCompact(Int.init)
        
        #expect(try await times2.get() == [2, 3, 4, 7])
        
        let collection2 = eventLoop.makeSucceededFuture(["asdf", "qwer", "zxcv", ""])
        let letters = collection2.mapEachCompact(\.first)
        #expect(try await letters.get() == ["a", "q", "z"])
    }
    
    @Test
    func mapEachFlat() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let collection1 = eventLoop.makeSucceededFuture([[1, 2, 3], [9, 8, 7], [], [0]])
        let flat1 = collection1.mapEachFlat { $0 }
        
        #expect(try await flat1.get() == [1, 2, 3, 9, 8, 7, 0])

        let collection2 = eventLoop.makeSucceededFuture(["ABC", "123", "👩‍👩‍👧‍👧"])
        let flat2 = collection2.mapEachFlat(\.utf8CString).mapEach(UInt8.init)
        
        #expect(try await flat2.get() == [
            0x41, 0x42, 0x43, 0x00, 0x31, 0x32, 0x33, 0x00, 0xf0, 0x9f, 0x91, 0xa9,
            0xe2, 0x80, 0x8d, 0xf0, 0x9f, 0x91, 0xa9, 0xe2, 0x80, 0x8d, 0xf0, 0x9f,
            0x91, 0xa7, 0xe2, 0x80, 0x8d, 0xf0, 0x9f, 0x91, 0xa7, 0x00
        ])

    }
    
    @Test
    func flatMapEach() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let collection = eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6, 7, 8, 9])
        let times2 = collection.flatMapEach(on: eventLoop) { int -> EventLoopFuture<Int> in
            return eventLoop.makeSucceededFuture(int * 2)
        }
        
        #expect(try await times2.get() == [2, 4, 6, 8, 10, 12, 14, 16, 18])
    }

    @Test
    func flatMapEachVoid() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()

        try await confirmation("futures all succeeded", expectedCount: 9) { confirm in
            let collection = eventLoop.makeSucceededFuture(1 ... 9)
            let nothing = collection.flatMapEach(on: eventLoop) { _ in confirm(); return eventLoop.makeSucceededVoidFuture() }

            try await nothing.get()
        }
    }
    
    @Test
    func flatMapEachCompact() async throws {
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let collection = eventLoop.makeSucceededFuture(["one", "2", "3", "4", "five", "^", "7"])
        let times2 = collection.flatMapEachCompact(on: eventLoop) { int -> EventLoopFuture<Int?> in
            return eventLoop.makeSucceededFuture(Int(int))
        }
        
        #expect(try await times2.get() == [2, 3, 4, 7])
    }
    
    @Test
    func flatMapEachThrowing() async throws {
        struct SillyRangeError: Error {}
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let collection = eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6, 7, 8, 9])
        let times2 = collection.flatMapEachThrowing { int -> Int in
            guard int < 8 else { throw SillyRangeError() }
            return int * 2
        }
        
        await #expect(throws: (any Error).self) { try await times2.get() }
    }
    
    @Test
    func flatMapEachCompactThrowing() async throws {
        struct SillyRangeError: Error {}
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let collection = eventLoop.makeSucceededFuture(["one", "2", "3", "4", "five", "^", "7"])
        let times2 = collection.flatMapEachCompactThrowing { str -> Int? in Int(str) }
        let times2Badly = collection.flatMapEachCompactThrowing { str -> Int? in
            guard let result = Int(str) else { return nil }
            guard result < 4 else { throw SillyRangeError() }
            return result
        }
        
        #expect(try await times2.get() == [2, 3, 4, 7])
        await #expect(throws: (any Error).self) { try await times2Badly.get() }
    }
    
    @Test
    func sequencedFlatMapEach() async throws {
        struct SillyRangeError: Error {}
        var value = 0
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let lock = NIOLock()
        let collection = eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6, 7, 8, 9])
        let times2 = collection.sequencedFlatMapEach { int -> EventLoopFuture<Int> in
            lock.withLock { value = Swift.max(value, int) }
            guard int < 5 else { return NIOSingletons.posixEventLoopGroup.spinAll(on: eventLoop).flatMapThrowing { throw SillyRangeError() } }
            return eventLoop.makeSucceededFuture(int * 2)
        }
        
        await #expect(throws: (any Error).self) { try await times2.get() }
        #expect(lock.withLock { value } < 6)
    }

    @Test
    func sequencedFlatMapVoid() async throws {
        struct SillyRangeError: Error {}
        var value = 0
        let lock = NIOLock()
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let collection = eventLoop.makeSucceededFuture([1, 2, 3, 4, 5, 6, 7, 8, 9])
        let times2 = collection.sequencedFlatMapEach { int -> EventLoopFuture<Void> in
            lock.withLock { value = Swift.max(value, int) }
            guard int < 5 else { return NIOSingletons.posixEventLoopGroup.spinAll(on: eventLoop).flatMapThrowing { throw SillyRangeError() } }
            return eventLoop.makeSucceededFuture(())
        }
        
        await #expect(throws: (any Error).self) { try await times2.get() }
        #expect(lock.withLock { value } < 6)
    }

    @Test
    func sequencedFlatMapEachCompact() async throws {
        struct SillyRangeError: Error {}
        var last = ""
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let lock = NIOLock()
        let collection = eventLoop.makeSucceededFuture(["one", "2", "3", "not", "4", "1", "five", "^", "7"])
        let times2 = collection.sequencedFlatMapEachCompact { val -> EventLoopFuture<Int?> in
            guard let int = Int(val) else { return eventLoop.makeSucceededFuture(nil) }
            guard int < 4 else { return NIOSingletons.posixEventLoopGroup.spinAll(on: eventLoop).flatMapThrowing { throw SillyRangeError() } }
            lock.withLock { last = val }
            return eventLoop.makeSucceededFuture(int * 2)
        }
        
        await #expect(throws: (any Error).self) { try await times2.get() }
        #expect(lock.withLock { last } == "3")
    }

    @Test
    func elSequencedFlatMapEach() async throws {
        struct SillyRangeError: Error {}
        var value = 0
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let lock = NIOLock()
        let collection = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        let times2 = collection.sequencedFlatMapEach(on: eventLoop) { int -> EventLoopFuture<Int> in
            lock.withLock { value = Swift.max(value, int) }
            guard int < 5 else { return NIOSingletons.posixEventLoopGroup.spinAll(on: eventLoop).flatMapThrowing { throw SillyRangeError() } }
            return eventLoop.makeSucceededFuture(int * 2)
        }
        
        await #expect(throws: (any Error).self) { try await times2.get() }
        #expect(lock.withLock { value } < 6)
    }

    @Test
    func elSequencedFlatMapVoid() async throws {
        struct SillyRangeError: Error {}
        var value = 0
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let lock = NIOLock()
        let collection = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        let times2 = collection.sequencedFlatMapEach(on: eventLoop) { int -> EventLoopFuture<Void> in
            lock.withLock { value = Swift.max(value, int) }
            guard int < 5 else { return NIOSingletons.posixEventLoopGroup.spinAll(on: eventLoop).flatMapThrowing { throw SillyRangeError() } }
            return eventLoop.makeSucceededFuture(())
        }
        
        await #expect(throws: (any Error).self) { try await times2.get() }
        #expect(lock.withLock { value } < 6)
    }

    @Test
    func elSequencedFlatMapEachCompact() async throws {
        struct SillyRangeError: Error {}
        var last = ""
        let eventLoop = NIOSingletons.posixEventLoopGroup.any()
        let lock = NIOLock()
        let collection = ["one", "2", "3", "not", "4", "1", "five", "^", "7"]
        let times2 = collection.sequencedFlatMapEachCompact(on: eventLoop) { val -> EventLoopFuture<Int?> in
            guard let int = Int(val) else { return eventLoop.makeSucceededFuture(nil) }
            guard int < 4 else { return NIOSingletons.posixEventLoopGroup.spinAll(on: eventLoop).flatMapThrowing { throw SillyRangeError() } }
            lock.withLock { last = val }
            return eventLoop.makeSucceededFuture(int * 2)
        }
        
        await #expect(throws: (any Error).self) { try await times2.get() }
        #expect(lock.withLock { last } == "3")
    }
}
