// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SHELF",
    
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
    ],
    
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SHELF",
            targets: ["SHELF"]),
    ],
    
    dependencies: [
        .package(url: "https://github.com/RougeWare/UuidTools.git", from: "0.2.1"),
        .package(url: "https://github.com/RougeWare/Swift-Safe-Pointer.git", from: "2.1.3"),
    ],
    
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SHELF",
            dependencies: [
                .product(name: "UuidTools", package: "UuidTools"),
                .product(name: "SafePointer", package: "Swift-Safe-Pointer"),
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "SHELFTests",
            dependencies: ["SHELF"]
        ),
    ]
)
