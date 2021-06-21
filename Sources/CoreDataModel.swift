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

import CoreData
import Foundation

/**
 An instance of `CoreDataModel` represents a Core Data model — a `.xcdatamodeld` file package.
 It provides the model and store URLs as well as methods for interacting with the store.
 */
public struct CoreDataModel: Equatable {

    // MARK: Properties

    /// The name of the Core Data model resource.
    public let name: String

    /// The bundle in which the model is located.
    /// The default is the main bundle.
    public let bundle: Bundle

    /// The type of the Core Data persistent store for the model.
    /// The default is `.sqlite` with the user's documents directory.
    public let storeType: StoreType

    /**
     The file URL specifying the full path to the store.

     - note: If the store is in-memory, then this value will be `nil`.
     */
    public var storeURL: URL? {
        self.storeType.storeDirectory()?.appendingPathComponent(self.databaseFileName)
    }

    /// The file URL specifying the model file in the bundle specified by `bundle`.
    public var modelURL: URL {
        guard let url = self.bundle.url(forResource: self.name, withExtension: ModelFileExtension.bundle.rawValue) else {
            fatalError("*** Error loading model URL for model named \(self.name) in bundle: \(self.bundle)")
        }
        return url

    }

    /// The database file name for the store.
    public var databaseFileName: String {
        switch self.storeType {
        case .sqlite: return self.name + "." + ModelFileExtension.sqlite.rawValue
        default: return self.name
        }

    }

    /// The managed object model for the model specified by `name`.
    public var managedObjectModel: NSManagedObjectModel {
        guard let model = NSManagedObjectModel(contentsOf: self.modelURL) else {
            fatalError("*** Error loading managed object model at url: \(self.modelURL)")
        }
        return model

    }

    /**
     Queries the meta data for the persistent store specified by the receiver
     and returns whether or not a migration is needed.

     - returns: `true` if the store requires a migration, `false` otherwise.
     */
    public var needsMigration: Bool {
        guard let storeURL = self.storeURL else { return false }
        do {
            let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: self.storeType.type,
                                                                                       at: storeURL,
                                                                                       options: nil)
            return !self.managedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
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
     - parameter storeType: The store type for the Core Data model. The default is `.sqlite` with the user's documents directory.

     - returns: A new `CoreDataModel` instance.
     */
    public init(name: String, bundle: Bundle = .main, storeType: StoreType = .sqlite(defaultDirectoryURL())) {
        self.name = name
        self.bundle = bundle
        self.storeType = storeType
    }

    // MARK: Methods

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

    /**
     Removes the existing model store specfied by the receiver.

     - throws: If removing the store fails or errors, then this function throws an `NSError`.
     */
    public func removeExistingStore() throws {
        let fileManager = FileManager.default
        if let storePath = self.storeURL?.path,
           fileManager.fileExists(atPath: storePath) {
            try fileManager.removeItem(atPath: storePath)

            let writeAheadLog = storePath + "-wal"
            _ = try? fileManager.removeItem(atPath: writeAheadLog)

            let sharedMemoryfile = storePath + "-shm"
            _ = try? fileManager.removeItem(atPath: sharedMemoryfile)
        }
    }
}
