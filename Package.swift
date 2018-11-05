// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "nio-kit",
    products: [
        .library(name: "nio-kit", targets: ["nio-kit"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "nio-kit", dependencies: []),
        .testTarget(name: "nio-kitTests", dependencies: ["nio-kit"]),
    ]
)