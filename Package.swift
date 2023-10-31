// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "async-kit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(name: "AsyncKit", targets: ["AsyncKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.61.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.5"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.1.0"),
    ],
    targets: [
        .target(name: "AsyncKit", dependencies: [
            .product(name: "Logging", package: "swift-log"),
            .product(name: "NIOCore", package: "swift-nio"),
            .product(name: "NIOEmbedded", package: "swift-nio"),
            .product(name: "NIOPosix", package: "swift-nio"),
            .product(name: "Collections", package: "swift-collections"),
            .product(name: "Algorithms", package: "swift-algorithms"),
        ]),
        .testTarget(name: "AsyncKitTests", dependencies: [
            .target(name: "AsyncKit"),
        ]),
    ]
)
