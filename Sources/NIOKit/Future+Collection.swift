import NIO

extension EventLoopFuture where Value: Sequence {
    func mapEach<Result>(_ transform: @escaping (Value.Element) -> Result) -> EventLoopFuture<[Result]> {
        return self.map { collection in
            return collection.map(transform)
        }
    }
}
