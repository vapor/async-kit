// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "nio-kit",
    products: [
        .library(name: "NIOKit", targets: ["NIOKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0-convergence"),
    ],
    targets: [
        .target(name: "NIOKit", dependencies: ["NIO"]),
        .testTarget(name: "NIOKitTests", dependencies: ["NIOKit"]),
    ]
)
