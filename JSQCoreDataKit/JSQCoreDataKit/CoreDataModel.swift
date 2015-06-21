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


/// Describes a Core Data persistent store type.
public enum StoreType: CustomStringConvertible {

    /// The SQLite database store type.
    case SQLite

    /// The binary store type.
    case Binary

    /// The in-memory store type.
    case InMemory

    /// :nodoc:
    public var description: String {
        get {
            switch self {
            case .SQLite: return NSSQLiteStoreType
            case .Binary: return NSBinaryStoreType
            case .InMemory: return NSInMemoryStoreType
            }
        }
    }
}


/**
An instance of `CoreDataModel` represents a Core Data model.
It provides the model and store URLs as well as methods for interacting with the store.
*/
public struct CoreDataModel: CustomStringConvertible {

    // MARK: Properties

    /// The name of the Core Data model resource.
    public let name: String

    /// The type of the Core Data persistent store for the model.
    public let storeType: StoreType

    /// The bundle in which the model is located.
    public let bundle: NSBundle

    /**
    The file URL specifying the directory in which the store is located.
    If the store is in-memory, then this value will be `nil`.
    */
    public let storeDirectory: NSURL?

    /**
    The file URL specifying the full path to the store.
    If the store is in-memory, then this value will be `nil`.
    */
    public var storeURL: NSURL? {
        get {
            return storeDirectory?.URLByAppendingPathComponent(databaseFileName)
        }
    }

    /// The file URL specifying the model file in the bundle specified by `bundle`.
    public var modelURL: NSURL {
        get {
            guard let url = bundle.URLForResource(name, withExtension: "momd") else {
                fatalError("*** Error loading model URL for model named \(name) in bundle: \(bundle)")
            }
            return url
        }
    }

    /// The database file name for the store.
    public var databaseFileName: String {
        get {
            switch storeType {
            case .SQLite: return name + ".sqlite"
            default: return name
            }
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
            guard let storeURL = storeURL else { return false }

            do {
                let sourceMetaData = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(storeType.description, URL: storeURL, options: nil)
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
    Constructs a new `CoreDataModel` instance with the specified name and bundle.

    - parameter name:           The name of the Core Data model.
    - parameter storeType:      The store type for the Core Data model. The default is `.SQLite`.
    - parameter bundle:         The bundle in which the model is located. The default is the main bundle.
    - parameter storeDirectory: The directory in which the model is located. The default is the user's documents directory.

    - returns: A new `CoreDataModel` instance.
    */
    public init(name: String, storeType: StoreType = .SQLite, bundle: NSBundle = NSBundle.mainBundle(), storeDirectory: NSURL? = documentsDirectoryURL()) {
        self.name = name
        self.storeType = storeType
        self.bundle = bundle
        self.storeDirectory = storeDirectory
    }

    /**
    Constructs a new in-memory `CoreDataModel` instance with the specified name and bundle.

    - parameter inMemoryName: The name of the Core Data model.
    - parameter bundle:       The bundle in which the model is located. The default is the main bundle.

    - returns: A new `CoreDataModel` instance.
    */
    public init(inMemoryName name: String, bundle: NSBundle = NSBundle.mainBundle()) {
        self.init(name: name, storeType: .InMemory, bundle: bundle, storeDirectory: nil)
    }

    // MARK: Methods

    /**
    Removes the existing model store specfied by the receiver.

    **Note:** In cases of failure, this function throws an `NSError`.
    */
    public func removeExistingModelStore() throws {
        let fileManager = NSFileManager.defaultManager()
        if let storePath = storeURL?.path where fileManager.fileExistsAtPath(storePath) {
            try fileManager.removeItemAtPath(storePath)
        }
    }

    // MARK: CustomStringConvertible

    /// :nodoc:
    public var description: String {
        get {
            return "<\(CoreDataModel.self): name=\(name), needsMigration=\(needsMigration), modelURL=\(modelURL), storeURL=\(storeURL)>"
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
