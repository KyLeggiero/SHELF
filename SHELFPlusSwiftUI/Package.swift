// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SHELFPlusSwiftUI",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SHELFPlusSwiftUI",
            targets: ["SHELFPlusSwiftUI"]),
    ],
    
    dependencies: [
        .package(name: "SHELF", path: "../"),
        .package(url: "https://github.com/OpenSwiftUIProject/OpenSwiftUI.git", revision: "bbcd8bef2ca031103ad6c23805d5245d13c6ea8e"),
    ],
    
    targets: [
        .target(
            name: "SHELFPlusSwiftUI",
            dependencies: [
                .product(name: "SHELF", package: "SHELF"),
                .product(name: "OpenSwiftUI", package: "OpenSwiftUI")
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "SHELFPlusSwiftUITests",
            dependencies: ["SHELFPlusSwiftUI"]
        ),
    ]
)
