// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "nio-kit",
    products: [
        .library(name: "nio-kit", targets: ["NIOKit"]),
    ],
    dependencies: [
        // TODO: Pin to semver release
        // Pulling in SwiftNIO 'master' should only happen during beta development!
        .package(url: "https://github.com/apple/swift-nio.git", .branch("master"))
    ],
    targets: [
        .target(name: "NIOKit", dependencies: ["NIO"]),
        .testTarget(name: "NIOKitTests", dependencies: ["NIOKit"]),
    ]
)
