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


/// :nodoc:
public func ==(lhs: StoreType, rhs: StoreType) -> Bool {
    switch (lhs, rhs) {
    case let (.SQLite(left), .SQLite(right)) where left == right: return true
    case let (.Binary(left), .Binary(right)) where left == right: return true
    case (.InMemory, .InMemory): return true
    default: return false
    }
}


/// Describes a Core Data persistent store type.
public enum StoreType: CustomStringConvertible, Equatable {

    /// The SQLite database store type. The associated file URL specifies the directory for the store.
    case SQLite (NSURL)

    /// The binary store type. The associated file URL specifies the directory for the store.
    case Binary (NSURL)

    /// The in-memory store type.
    case InMemory

    /**
    - returns: The file URL specifying the directory in which the store is located. 
    - Note: If the store is in-memory, then this value will be `nil`.
    */
    public func storeDirectory() -> NSURL? {
        switch self {
        case let .SQLite(url): return url
        case let .Binary(url): return url
        case .InMemory: return nil
        }
    }

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

    /// The bundle in which the model is located.
    public let bundle: NSBundle
    
    /// The type of the Core Data persistent store for the model.
    public let storeType: StoreType

    /**
    The file URL specifying the full path to the store.
    - Note: If the store is in-memory, then this value will be `nil`.
    */
    public var storeURL: NSURL? {
        get {
            return storeType.storeDirectory()?.URLByAppendingPathComponent(databaseFileName)
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

    - returns: `true` if the store requires a migration, `false` otherwise.
    */
    public var needsMigration: Bool {
        get {
            guard let storeURL = storeURL else { return false }

            do {
                let sourceMetaData = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(
                    storeType.description,
                    URL: storeURL,
                    options: nil)
                return !managedObjectModel.isConfiguration(nil, compatibleWithStoreMetadata: sourceMetaData)
            }
            catch {
                debugPrint("*** Error checking persistent store coordinator meta data: \(error)")
                return false
            }
        }
    }

    // MARK: Initialization

    /**
    Constructs a new `CoreDataModel` instance with the specified name and bundle.

    - parameter name:           The name of the Core Data model.
    - parameter bundle:         The bundle in which the model is located. The default is the main bundle.
    - parameter storeType:      The store type for the Core Data model. The default is `.SQLite`, with the user's documents directory.

    - returns: A new `CoreDataModel` instance.
    */
    public init(name: String, bundle: NSBundle = .mainBundle(), storeType: StoreType = .SQLite(DocumentsDirectoryURL())) {
        self.name = name
        self.bundle = bundle
        self.storeType = storeType
    }

    // MARK: Methods

    /**
    Removes the existing model store specfied by the receiver.

    - throws: If removing the store fails or errors, then this function throws an `NSError`.
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
            return "<\(CoreDataModel.self): name=\(name), storeType=\(storeType) needsMigration=\(needsMigration), modelURL=\(modelURL), storeURL=\(storeURL)>"
        }
    }

}

// MARK: Private

private func DocumentsDirectoryURL() -> NSURL {
    do {
        return try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    }
    catch {
        fatalError("*** Error finding documents directory: \(error)")
    }
}
