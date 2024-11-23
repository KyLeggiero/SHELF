// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription



let package = Package(
    name: "SHELF",
    
    platforms: [
        .macOS(.v15),//.macOS(.v13),
        .iOS(.v18),//.iOS(.v16),
        .tvOS(.v18),//.tvOS(.v16),
    ],
    
    products: [
        .library(
            name: "SHELF",
            targets: ["SHELF"]),
    ],
    
    dependencies: [
        .package(url: "https://github.com/RougeWare/Swift-Safe-Pointer.git", from: "2.1.3"),
        .package(url: "https://github.com/RougeWare/Swift-SerializationTools.git", from: "1.1.1"),
        .package(url: "https://github.com/RougeWare/Swift-String-Integer-Access.git", from: "2.1.0"),
        .package(url: "https://github.com/RougeWare/Swift-TODO.git", from: "1.1.0"),
        .package(url: "https://github.com/RougeWare/UuidTools.git", from: "0.2.1"),
    ],
    
    targets: [
        .target(
            name: "SHELF",
            dependencies: [
                .product(name: "SafePointer", package: "Swift-Safe-Pointer"),
                .product(name: "SerializationTools", package: "Swift-SerializationTools"),
                .product(name: "SafeStringIntegerAccess", package: "Swift-String-Integer-Access"),
                .product(name: "TODO", package: "Swift-TODO"),
                .product(name: "UuidTools", package: "UuidTools"),
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "SHELFTests",
            dependencies: ["SHELF"]
        ),
    ]
)
