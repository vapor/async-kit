// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "nio-kit",
    products: [
        .library(name: "nio-kit", targets: ["NIOKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.10.0")
    ],
    targets: [
        .target(name: "NIOKit", dependencies: ["NIO"]),
        .testTarget(name: "NIOKitTests", dependencies: ["NIOKit"]),
    ]
)
