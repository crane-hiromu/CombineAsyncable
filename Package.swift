// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CombineAsyncable",
    products: [
        .library(
            name: "CombineAsyncable",
            targets: ["CombineAsyncable"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CombineAsyncable",
            dependencies: []),
        .testTarget(
            name: "CombineAsyncableTests",
            dependencies: ["CombineAsyncable"]),
    ]
)
