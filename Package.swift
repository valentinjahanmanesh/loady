// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "loady", platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Loady",
            targets: ["Loady"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    
    targets: [
        .target(
            name: "Loady",
            dependencies: [],
            path: "Loady/Classes/V2"),
        .testTarget(name: "LoadyTests", dependencies: ["Loady"], path: "Loady/Tests")
    ]
)
