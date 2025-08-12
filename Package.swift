// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Metawear",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Metawear",
            targets: ["MetaWearPluginPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0"),
        .package(url: "https://github.com/mbientlab/MetaWear-SDK-iOS-macOS.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "MetaWearPluginPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "MetaWear", package: "MetaWear-SDK-iOS-macOS")
            ],
            path: "ios/Sources/MetaWearPluginPlugin"),
        .testTarget(
            name: "MetaWearPluginPluginTests",
            dependencies: ["MetaWearPluginPlugin"],
            path: "ios/Tests/MetaWearPluginPluginTests")
    ]
)