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


public struct CoreDataModel: Printable {

    public let name: String

    public let bundle: NSBundle

    public var storeURL: NSURL {
        get {
            var error: NSError?
            let documentsDirectoryURL = NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: &error)
            assert(documentsDirectoryURL != nil, "*** Error finding documents directory: \(error)")
            return documentsDirectoryURL!.URLByAppendingPathComponent(databaseFileName)
        }
    }

    public var modelURL: NSURL {
        get {
            let url = bundle.URLForResource(name, withExtension: "momd")
            assert(url != nil, "*** Error loading resource for model: \(name)")
            return url!
        }
    }

    public var databaseFileName: String {
        get {
            return name + ".sqlite"
        }
    }

    public var managedObjectModel: NSManagedObjectModel {
        get {
            let model = NSManagedObjectModel(contentsOfURL: modelURL)
            assert(model != nil, "*** Error loading managed object model at url: \(modelURL)")
            return model!
        }
    }

    public var modelStoreNeedsMigration: Bool {
        get {
            var error: NSError?
            if let sourceMetaData = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(nil, URL: storeURL, error: &error) {
                return !managedObjectModel.isConfiguration(nil, compatibleWithStoreMetadata: sourceMetaData)
            }
            println("*** Error checking persistent store coordinator meta data: \(error)\nstoreURL: \(storeURL)")
            return false
        }
    }

    public func removeExistingModelStore() -> Bool {
        var error: NSError?
        let fileManager = NSFileManager.defaultManager()

        if let storePath = storeURL.path {
            if fileManager.fileExistsAtPath(storePath) {
                let success = fileManager.removeItemAtURL(storeURL, error: &error)
                if !success {
                    println("*** Error removing model store at url: \(storeURL)")
                }
                return success
            }
        }

        return false
    }

    public init(name: String, bundle: NSBundle = NSBundle.mainBundle()) {
        self.name = name
        self.bundle = bundle
    }

    // MARK: printable

    public var description: String {
        get {
            return "<\(toString(CoreDataModel.self)): name=\(name), needsMigration=\(modelStoreNeedsMigration), databaseFileName=\(databaseFileName), modelURL=\(modelURL), storeURL=\(storeURL)>"
        }
    }

}
