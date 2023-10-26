// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BlueStackDFPMediationAdapter",
    products: [
        .library(
            name: "BlueStackDFPMediationAdapter",
            targets: ["BlueStackDFPMediationAdapter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", .upToNextMajor(from: "10.10.0")),
        .package(url: "https://github.com/azerion/BlueStackSDK", .upToNextMajor(from: "4.3.0")),
    ],
    targets: [
        .binaryTarget(name: "BlueStackDFPMediationAdapter", path: "BlueStackDFPMediationAdapter.xcframework")
    ]
)
