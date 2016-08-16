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
//  Copyright © 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import CoreData
import Foundation


/// Describes a child managed object context.
public typealias ChildContext = NSManagedObjectContext


/// Describes the initialization options for a persistent store.
public typealias PersistentStoreOptions = [NSObject : AnyObject]


/// Describes default persistent store options.
public let defaultStoreOptions: PersistentStoreOptions = [
    NSMigratePersistentStoresAutomaticallyOption as NSObject: true as AnyObject,
    NSInferMappingModelAutomaticallyOption as NSObject: true as AnyObject
]

// MARK: Internal

internal func defaultDirectoryURL() -> URL {
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
    }
    catch {
        fatalError("*** Error finding default directory: \(error)")
    }
}
