// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Authentication",
    platforms: [.macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Authentication",
            targets: ["Authentication", "PermissionsKit"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Authentication",
            dependencies: []
        ),
        .binaryTarget(
            name: "PermissionsKit",
            url: "https://github.com/MacPaw/PermissionsKit/releases/download/1.0.5/PermissionsKit.xcframework.zip",
            checksum: "c912c743db518b6d9cd431d69410e7f7d183349f881fc4493e8fa8e8abee9905"
        ),
        .testTarget(
            name: "AuthenticationTests",
            dependencies: ["Authentication"]
        ),
    ]
)
