// swift-tools-version:5.10
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
        // TODO: SM: Update swift-nio version once NIOAsyncRuntime is available from swift-nio
        // .package(url: "https://github.com/apple/swift-nio.git", from: "2.89.0"),
        .package(url: "https://github.com/PassiveLogic/swift-nio.git", branch: "feat/addNIOAsyncRuntimeForWasm"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.5"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "AsyncKit",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOEmbedded", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AsyncKitTests",
            dependencies: [
                .target(name: "AsyncKit"),
                .product(name: "NIOEmbedded", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    //.enableUpcomingFeature("DisableOutwardActorInference"),
    .enableUpcomingFeature("MemberImportVisibility"),
    //.enableExperimentalFeature("StrictConcurrency=complete"),
] }
