// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "INetwork",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "INetwork",
            targets: ["INetwork"]
        ),
    ],
    targets: [
        .target(
            name: "INetwork"
        ),
        .testTarget(
            name: "INetworkTests",
            dependencies: ["INetwork"]
        )
    ],
    swiftLanguageModes: [.v6],
)
