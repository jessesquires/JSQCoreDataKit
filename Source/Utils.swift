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


/// Describes a child managed object context.
public typealias ChildContext = NSManagedObjectContext


/// Describes the initialization options for a persistent store.
public typealias PersistentStoreOptions = [AnyHashable : AnyObject]


/// Describes default persistent store options.
public let defaultStoreOptions: PersistentStoreOptions = [
    NSMigratePersistentStoresAutomaticallyOption: true as AnyObject,
    NSInferMappingModelAutomaticallyOption: true as AnyObject
]

/// The default directory used to initialize a `CoreDataModel`.
/// On tvOS, this is the caches directory. All other platforms use the document directory.
public func defaultDirectoryURL() -> URL {
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
