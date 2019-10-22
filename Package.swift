// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "async-kit",
    products: [
        .library(name: "AsyncKit", targets: ["AsyncKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "AsyncKit", dependencies: ["Logging", "NIO"]),
        .testTarget(name: "AsyncKitTests", dependencies: ["AsyncKit"]),
    ]
)
