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


///  Describes a child managed object context.
public typealias ChildManagedObjectContext = NSManagedObjectContext


public final class CoreDataStack: Printable {

    public let model: CoreDataModel

    public let managedObjectContext: NSManagedObjectContext

    public let persistentStoreCoordinator: NSPersistentStoreCoordinator

    public init(model: CoreDataModel,
        storeType: String = NSSQLiteStoreType,
        options: [NSObject : AnyObject]? = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true],
        concurrencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType) {

            self.model = model
            self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model.managedObjectModel)

            var error: NSError?
            let modelStoreURL: NSURL? = (storeType == NSInMemoryStoreType) ? nil : model.storeURL

            self.persistentStoreCoordinator.addPersistentStoreWithType(storeType, configuration: nil, URL: modelStoreURL, options: options, error: &error)
            assert(error == nil, "*** Error adding persistent store: \(error)")

            self.managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
            self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
    }

    public func childManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType,
        mergePolicyType: NSMergePolicyType = .MergeByPropertyObjectTrumpMergePolicyType) -> ChildManagedObjectContext {

            let childContext = NSManagedObjectContext(concurrencyType: concurrencyType)
            childContext.parentContext = managedObjectContext
            childContext.mergePolicy = NSMergePolicy(mergeType: mergePolicyType)
            return childContext
    }

    // MARK: Printable

    /// A string containing a textual representation of the `CoreDataStack`.
    public var description: String {
        get {
            return "<\(toString(CoreDataStack.self)): model=\(model)>"
        }
    }
    
}