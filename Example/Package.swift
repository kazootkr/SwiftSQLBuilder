// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SwiftSQLBuilderExample",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "MyBuilderExample", targets: ["MyBuilderExample"]),
    ],
    dependencies: [
        .package(name: "SwiftSQLBuilder", path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "MyBuilderExample",
            dependencies: [
                .product(name: "SwiftSQLBuilder", package: "SwiftSQLBuilder"),
            ],
            path: "."
        ),
    ]
)

