// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "async-kit",
    platforms: [
       .macOS(.v10_14)
    ],
    products: [
        .library(name: "AsyncKit", targets: ["AsyncKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.10.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "AsyncKit", dependencies: ["Logging", "NIO"]),
        .testTarget(name: "AsyncKitTests", dependencies: ["AsyncKit"]),
    ]
)
