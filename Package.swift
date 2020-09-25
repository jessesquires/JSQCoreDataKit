// swift-tools-version:5.3
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
        .library(name: "JSQCoreDataKit", targets: ["JSQCoreDataKit"])
    ],
    targets: [
        .target(name: "JSQCoreDataKit", path: "Sources", exclude: ["Info.plist"])

        // Unfortunately, we cannot include tests right now.
        // The test target depends on a fixture project, `ExampleModel`.
        // There is not a great way to model that in SwiftPM.
        // We do not want to include `ExampleModel` in our package.
        // However, this is not that bad.
        // We still run tests via the main Xcode project.

        // .testTarget(name: "JSQCoreDataKitTests", dependencies: ["JSQCoreDataKit"], path: "Tests")
    ],
    swiftLanguageVersions: [.v5]
)
