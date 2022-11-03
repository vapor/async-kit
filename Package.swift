// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "async-kit",
    platforms: [
       .macOS(.v10_15),
       .iOS(.v11)
    ],
    products: [
        .library(name: "AsyncKit", targets: ["AsyncKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.42.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "AsyncKit", dependencies: [
            .product(name: "Logging", package: "swift-log"),
            .product(name: "NIO", package: "swift-nio"),
        ]),
        .testTarget(name: "AsyncKitTests", dependencies: [
            .product(name: "Atomics", package: "swift-atomics"),
            .target(name: "AsyncKit"),
        ]),
    ]
)
