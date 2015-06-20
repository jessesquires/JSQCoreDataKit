//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://www.jessesquires.com/JSQCoreDataKit
//
//
//  GitHub
//  https://github.com/jessesquires/JSQCoreDataKit
//
//
//  License
//  Copyright (c) 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation
import CoreData

/**
An instance of `CoreDataModel` represents a Core Data model.
It provides the model and store URLs as well as functions for interacting with the store.
*/
public struct CoreDataModel: CustomStringConvertible {

    // MARK: Properties

    /// The name of the Core Data model resource.
    public let name: String

    /// The bundle in which the model is located.
    public let bundle: NSBundle

    /// The file URL specifying the directory in which the store is located.
    public let storeDirectory: NSURL

    /// The file URL specifying the full path to the store.
    public var storeURL: NSURL {
        get {
            return storeDirectory.URLByAppendingPathComponent(databaseFileName)
        }
    }

    /// The file URL specifying the model file in the bundle specified by `bundle`.
    public var modelURL: NSURL {
        get {
            guard let url = bundle.URLForResource(name, withExtension: "momd") else {
                fatalError("*** Error loading modelURL for model named \(name) in bundle: \(bundle)")
            }
            return url
        }
    }

    /// The database file name for the store.
    public var databaseFileName: String {
        get {
            return name + ".sqlite"
        }
    }

    /// The managed object model for the model specified by `name`.
    public var managedObjectModel: NSManagedObjectModel {
        get {
            guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
                fatalError("*** Error loading managed object model at url: \(modelURL)")
            }
            return model
        }
    }

    /**
    Queries the meta data for the persistent store specified by the receiver 
    and returns whether or not a migration is needed.
    Returns `true` if the store requires a migration, `false` otherwise.
    */
    public var needsMigration: Bool {
        get {
            do {
                let sourceMetaData = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(NSSQLiteStoreType, URL: storeURL, options: nil)
                return !managedObjectModel.isConfiguration(nil, compatibleWithStoreMetadata: sourceMetaData)
            }
            catch {
                print("*** Error checking persistent store coordinator meta data: \(error)")
                return false
            }
        }
    }

    // MARK: Initialization

    /**
    Constructs new `CoreDataModel` instance with the specified name and bundle.

    - parameter name:           The name of the Core Data model.
    - parameter bundle:         The bundle in which the model is located. The default is the main bundle.
    - parameter storeDirectory: The directory in which the model is located. The default is the user's documents directory.
    
    - returns: A new `CoreDataModel` instance.
    */
    public init(name: String, bundle: NSBundle = NSBundle.mainBundle(), storeDirectory: NSURL = documentsDirectoryURL()) {
        self.name = name
        self.bundle = bundle
        self.storeDirectory = storeDirectory
    }

    // MARK: Methods

    /**
    Removes the existing model store specfied by the receiver.
    
    **Note:** In cases of failure, this function throws an `NSError`.
    */
    public func removeExistingModelStore() throws {
        let fileManager = NSFileManager.defaultManager()
        if let storePath = storeURL.path where fileManager.fileExistsAtPath(storePath) {
            try fileManager.removeItemAtURL(storeURL)
        }
    }

    // MARK: CustomStringConvertible

    /// :nodoc:
    public var description: String {
        get {
            return "<\(CoreDataModel.self): name=\(name), needsMigration=\(needsMigration), databaseFileName=\(databaseFileName), modelURL=\(modelURL), storeURL=\(storeURL)>"
        }
    }

}

// MARK: Private

private func documentsDirectoryURL() -> NSURL {
    do {
        return try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    }
    catch {
        fatalError("*** Error finding documents directory: \(error)")
    }
}
