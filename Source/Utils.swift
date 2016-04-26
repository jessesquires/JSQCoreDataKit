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
    NSMigratePersistentStoresAutomaticallyOption: true,
    NSInferMappingModelAutomaticallyOption: true
]

/// Describes a type of child context parenting.
public enum ChildContextType {
    /// Use main context as parent.
    case main

    /// Use background context as parent.
    case background
}

// MARK: Internal

internal func defaultDirectoryURL() -> NSURL {
    do {
        #if os(tvOS)
            let searchPathDirectory = NSSearchPathDirectory.CachesDirectory
        #else
            let searchPathDirectory = NSSearchPathDirectory.DocumentDirectory
        #endif

        return try NSFileManager.defaultManager().URLForDirectory(
            searchPathDirectory,
            inDomain: .UserDomainMask,
            appropriateForURL: nil,
            create: true)
    }
    catch {
        fatalError("*** Error finding default directory: \(error)")
    }
}
