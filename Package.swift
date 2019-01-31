// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftSDL2",
  products: [
    .library(name: "SwiftSDL2", targets: ["SwiftSDL2"])
  ],
  targets: [
    .systemLibrary(name: "CSDL2", pkgConfig: "sdl2"),
    .target(name: "SwiftSDL2", dependencies: ["CSDL2"]),
    .target(name: "SwiftSDL2Demo", dependencies: ["SwiftSDL2"]),
    .target(name: "SwiftSDL2ThreadDemo", dependencies: ["SwiftSDL2"]),
    .testTarget(name: "SwiftSDL2Tests", dependencies: ["SwiftSDL2"])
  ]
)
