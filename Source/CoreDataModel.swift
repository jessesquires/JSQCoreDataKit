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
//  Copyright © 2015 Jesse Squires
//  Released under an MIT license: https://opensource.org/licenses/MIT
//

import CoreData
import Foundation

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

/**
 An instance of `CoreDataModel` represents a Core Data model — a `.xcdatamodeld` file package.
 It provides the model and store URLs as well as methods for interacting with the store.
 */
public struct CoreDataModel {

    // MARK: Properties

    /// The name of the Core Data model resource.
    public let name: String

    /// The bundle in which the model is located.
    public let bundle: Bundle

    /// The type of the Core Data persistent store for the model.
    public let storeType: StoreType

    /**
     The file URL specifying the full path to the store.

     - note: If the store is in-memory, then this value will be `nil`.
     */
    public var storeURL: URL? {
        return storeType.storeDirectory()?.appendingPathComponent(databaseFileName)
    }

    /// The file URL specifying the model file in the bundle specified by `bundle`.
    public var modelURL: URL {
        guard let url = bundle.url(forResource: name, withExtension: ModelFileExtension.bundle.rawValue) else {
            fatalError("*** Error loading model URL for model named \(name) in bundle: \(bundle)")
        }
        return url

    }

    /// The database file name for the store.
    public var databaseFileName: String {
        switch storeType {
        case .sqlite: return name + "." + ModelFileExtension.sqlite.rawValue
        default: return name
        }

    }

    /// The managed object model for the model specified by `name`.
    public var managedObjectModel: NSManagedObjectModel {
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("*** Error loading managed object model at url: \(modelURL)")
        }
        return model

    }

    /**
     Queries the meta data for the persistent store specified by the receiver
     and returns whether or not a migration is needed.

     - returns: `true` if the store requires a migration, `false` otherwise.
     */
    public var needsMigration: Bool {
        guard let storeURL = storeURL else { return false }
        do {
            let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: storeType.type,
                                                                                       at: storeURL,
                                                                                       options: nil)
            return !managedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        } catch {
            debugPrint("*** Error checking persistent store coordinator meta data: \(error)")
            return false
        }

    }

    // MARK: Initialization

    /**
     Constructs a new `CoreDataModel` instance with the specified name and bundle.

     - parameter name:      The name of the Core Data model.
     - parameter bundle:    The bundle in which the model is located. The default is the main bundle.
     - parameter storeType: The store type for the Core Data model. The default is `.sqlite`, with the user's documents directory.

     - returns: A new `CoreDataModel` instance.
     */
    public init(name: String, bundle: Bundle = .main, storeType: StoreType = .sqlite(defaultDirectoryURL())) {
        self.name = name
        self.bundle = bundle
        self.storeType = storeType
    }

    // MARK: Methods

    /**
     Removes the existing model store specfied by the receiver.

     - throws: If removing the store fails or errors, then this function throws an `NSError`.
     */
    public func removeExistingStore() throws {
        let fm = FileManager.default
        if let storePath = storeURL?.path,
            fm.fileExists(atPath: storePath) {
            try fm.removeItem(atPath: storePath)

            let writeAheadLog = storePath + "-wal"
            _ = try? fm.removeItem(atPath: writeAheadLog)

            let sharedMemoryfile = storePath + "-shm"
            _ = try? fm.removeItem(atPath: sharedMemoryfile)
        }
    }

    /// The default directory used to initialize a `CoreDataModel`.
    /// On tvOS, this is the caches directory. All other platforms use the document directory.
    public static func defaultDirectoryURL() -> URL {
        do {
            #if os(tvOS)
            let searchPathDirectory = FileManager.SearchPathDirectory.cachesDirectory
            #else
            let searchPathDirectory = FileManager.SearchPathDirectory.documentDirectory
            #endif

            return try FileManager.default.url(for: searchPathDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: true)
        } catch {
            fatalError("*** Error finding default directory: \(error)")
        }
    }
}

extension CoreDataModel: Equatable {
    /// :nodoc:
    public static func == (lhs: CoreDataModel, rhs: CoreDataModel) -> Bool {
        return lhs.name == rhs.name
            && lhs.bundle.isEqual(rhs.bundle)
            && lhs.storeType == rhs.storeType
    }
}
