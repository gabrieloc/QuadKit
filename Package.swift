// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "QuadKit",
    platforms: [
        .macOS(.v10_14), .iOS(.v13), .tvOS(.v13)
    ],
    products: [
        .library(
            name: "QuadKit",
            targets: ["QuadKit"]),
    ],
    dependencies: [
         .package(url: "https://github.com/trisbee/SwiftSocket", from: "2.2.0"),
    ],
    targets: [
        .target(
            name: "QuadKit",
            dependencies: []),
        .testTarget(
            name: "QuadKitTests",
            dependencies: ["QuadKit"]),
    ]
)
