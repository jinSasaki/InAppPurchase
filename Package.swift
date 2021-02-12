// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "InAppPurchase",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "InAppPurchase", targets: ["InAppPurchase"]),
        .library(name: "InAppPurchaseStubs", targets: ["InAppPurchaseStubs"]),
    ],
    targets: [
        .target(name: "InAppPurchase", path: "Sources"),
        .target(name: "InAppPurchaseStubs", dependencies: ["InAppPurchase"], path: "InAppPurchaseStubs"),
        .testTarget(name: "InAppPurchaseTests", dependencies: ["InAppPurchase", "InAppPurchaseStubs"], path: "Tests"),
    ],
    swiftLanguageVersions: [.v5]
)
