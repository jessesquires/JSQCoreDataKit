//
//  Created by Jesse Squires
//  https://www.jessesquires.com
//
//
//  Documentation
//  https://jessesquires.github.io/JSQCoreDataKit
//
//
//  GitHub
//  https://github.com/jessesquires/JSQCoreDataKit
//
//
//  License
//  Copyright © 2015-present Jesse Squires
//  Released under an MIT license: https://opensource.org/licenses/MIT
//

/**
 Describes a Core Data model file exention type based on the
 [Model File Format and Versions](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreDataVersioning/Articles/vmModelFormat.html)
 documentation.
 */
public enum ModelFileExtension: String {
    /// The extension for a model bundle, or a `.xcdatamodeld` file package.
    case bundle = "momd"

    /// The extension for a versioned model file, or a `.xcdatamodel` file.
    case versionedFile = "mom"

    /// The extension for a mapping model file, or a `.xcmappingmodel` file.
    case mapping = "cdm"

    /// The extension for a sqlite store.
    case sqlite = "sqlite"
}
