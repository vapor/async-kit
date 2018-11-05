// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "nio-kit",
    products: [
        .library(name: "nio-kit", targets: ["nio-kit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.10.0")
    ],
    targets: [
        .target(name: "nio-kit", dependencies: ["NIO"]),
        .testTarget(name: "nio-kitTests", dependencies: ["nio-kit"]),
    ]
)