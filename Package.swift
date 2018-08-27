// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "APNS",
    products: [
        .library(name: "APNS", targets: ["APNS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),
    ],
    targets: [
        .target(name: "APNS", dependencies: ["Vapor", "JWT"]),
        .testTarget(name: "APNSTests", dependencies: ["APNS"]),
    ]
)
