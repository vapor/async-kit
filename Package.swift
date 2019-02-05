// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "nio-kit",
    products: [
        .library(name: "nio-kit", targets: ["NIOKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", .branch("master"))
    ],
    targets: [
        .target(name: "NIOKit", dependencies: ["NIO"]),
        .testTarget(name: "NIOKitTests", dependencies: ["NIOKit"]),
    ]
)
