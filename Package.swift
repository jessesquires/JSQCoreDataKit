// swift-tools-version:5.2
// The swift-tools-version declares the minimum version
// of Swift required to build this package.
// ----------------------------------------------------
//
//  Created by Jesse Squires
//  https://www.jessesquires.com
//
//  Documentation
//  https://jessesquires.github.io/JSQCoreDataKit
//
//  GitHub
//  https://github.com/jessesquires/JSQCoreDataKit
//
//  Copyright © 2020-present Jesse Squires
//

import PackageDescription

let package = Package(
    name: "JSQCoreDataKit",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v4),
        .macOS(.v10_12)
    ],
    products: [
        .library(
            name: "JSQCoreDataKit",
            targets: ["JSQCoreDataKit"])
    ],
    targets: [
        .target(
            name: "JSQCoreDataKit",
            path: "Sources"),
        .testTarget(name: "JSQCoreDataKitTests",
                    dependencies: ["JSQCoreDataKit"],
                    path: "Tests")
    ],
    swiftLanguageVersions: [.v5]
)
