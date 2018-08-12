// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSDL2",
    products: [
        .library(
            name: "SwiftSDL2",
            targets: ["SwiftSDL2"]
        ),
        .executable(
            name: "SwiftSDL2Demo",
            targets: ["SwiftSDL2Demo"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sunlubo/CSDL2", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftSDL2"
        ),
        .target(
            name: "SwiftSDL2Demo",
            dependencies: ["SwiftSDL2"],
            path: "Sources/Demo"
        ),
        .testTarget(
            name: "SwiftSDL2Tests",
            dependencies: ["SwiftSDL2"]
        )
    ]
)
