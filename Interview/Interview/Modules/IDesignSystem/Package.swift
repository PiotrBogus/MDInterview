// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IDesignSystem",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "IDesignSystem",
            targets: ["IDesignSystem"]
        ),
    ],
    targets: [
        .target(
            name: "IDesignSystem"
        ),
        .testTarget(
            name: "IDesignSystemTests",
            dependencies: ["IDesignSystem"]
        )
    ],
    swiftLanguageModes: [.v6]
)
