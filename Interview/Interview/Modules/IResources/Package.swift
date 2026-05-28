// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IResources",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "IResources",
            targets: ["IResources"]
        ),
    ],
    targets: [
        .target(
            name: "IResources",
            path: "Sources/Resources",
            resources: [
                .process("Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "IResourcesTests",
            dependencies: ["IResources"]
        )
    ],
    swiftLanguageModes: [.v6]
)
