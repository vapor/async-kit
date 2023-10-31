#if swift(>=5.8)

@_documentation(visibility: internal) @_exported import class NIOEmbedded.EmbeddedEventLoop
@_documentation(visibility: internal) @_exported import protocol NIOCore.EventLoop
@_documentation(visibility: internal) @_exported import protocol NIOCore.EventLoopGroup
@_documentation(visibility: internal) @_exported import class NIOCore.EventLoopFuture
@_documentation(visibility: internal) @_exported import struct NIOCore.EventLoopPromise
@_documentation(visibility: internal) @_exported import class NIOPosix.MultiThreadedEventLoopGroup

#else

@_exported import class NIOEmbedded.EmbeddedEventLoop
@_exported import protocol NIOCore.EventLoop
@_exported import protocol NIOCore.EventLoopGroup
@_exported import class NIOCore.EventLoopFuture
@_exported import struct NIOCore.EventLoopPromise
@_exported import class NIOPosix.MultiThreadedEventLoopGroup

#endif
