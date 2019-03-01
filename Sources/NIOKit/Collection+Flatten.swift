import NIO

extension Collection {
    func flatten<Value>(on eventLoop: EventLoop) -> EventLoopFuture<[Value]> where Element == EventLoopFuture<Value> {
        return eventLoop.flatten(Array(self))
    }
}
