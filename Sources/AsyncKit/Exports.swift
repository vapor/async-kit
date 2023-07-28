#if swift(>=5.8)

@_documentation(visibility: internal) @_exported import class NIO.EmbeddedEventLoop
@_documentation(visibility: internal) @_exported import protocol NIO.EventLoop
@_documentation(visibility: internal) @_exported import protocol NIO.EventLoopGroup
@_documentation(visibility: internal) @_exported import class NIO.EventLoopFuture
@_documentation(visibility: internal) @_exported import struct NIO.EventLoopPromise
@_documentation(visibility: internal) @_exported import class NIO.MultiThreadedEventLoopGroup

#else

@_exported import class NIO.EmbeddedEventLoop
@_exported import protocol NIO.EventLoop
@_exported import protocol NIO.EventLoopGroup
@_exported import class NIO.EventLoopFuture
@_exported import struct NIO.EventLoopPromise
@_exported import class NIO.MultiThreadedEventLoopGroup

#endif
