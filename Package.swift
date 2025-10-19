// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GithubExplorerStorage",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "GithubExplorerStorage",
            targets: ["GithubExplorerStorage"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/malikghani/astro-github-explorer-utils",
            from: "0.0.1"
        )
    ],
    targets: [
        .target(
            name: "GithubExplorerStorage",
            dependencies: [
                .product(
                    name: "GithubExplorerUtils",
                    package: "astro-github-explorer-utils"
                )
            ]
        ),
        .testTarget(
            name: "GithubExplorerStorageTests",
            dependencies: ["GithubExplorerStorage"]
        ),
    ]
)
