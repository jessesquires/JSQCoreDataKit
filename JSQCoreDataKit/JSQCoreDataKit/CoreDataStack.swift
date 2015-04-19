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


///  An instance of `CoreDataStack` encapsulates the entire Core Data stack for a SQLite store type.
///  It manages the managed object model, the persistent store coordinator, and the main managed object context.
///  It provides convenience methods for initializing a stack for common use-cases as well as creating child contexts.
public final class CoreDataStack: Printable {

    // MARK: Properties

    ///  The model for the stack.
    public let model: CoreDataModel

    ///  The main managed object context for the stack.
    public let managedObjectContext: NSManagedObjectContext

    ///  The persistent store coordinator for the stack.
    public let persistentStoreCoordinator: NSPersistentStoreCoordinator

    // MARK: Initialization

    ///  Constructs a new `CoreDataStack` instance with the specified model, storeType, options, and concurrencyType.
    ///
    ///  :param: model           The model describing the stack.
    ///  :param: storeType       A string constant that specifies the store type. The default parameter value is `NSSQLiteStoreType`.
    ///  :param: options         A dictionary containing key-value pairs that specify options for the store. 
    ///                          The default parameter value contains `true` for the following keys: `NSMigratePersistentStoresAutomaticallyOption`, `NSInferMappingModelAutomaticallyOption`.
    ///  :param: concurrencyType The concurrency pattern with which the managed object context will be used. The default parameter value is `.MainQueueConcurrencyType`.
    ///
    ///  :returns: A new `CoreDataStack` instance.
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

    // MARK: Child contexts

    ///  Creates a new child managed object context with the specified concurrencyType and mergePolicyType.
    ///
    ///  :param: concurrencyType The concurrency pattern with which the managed object context will be used.
    ///                          The default parameter value is `.MainQueueConcurrencyType`.
    ///  :param: mergePolicyType The merge policy with which the manged object context will be used.
    ///                          The default parameter value is `.MergeByPropertyObjectTrumpMergePolicyType`.
    ///
    ///  :returns: A new child managed object context initialized with the given concurrency type and merge policy type.
    public func childManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType,
        mergePolicyType: NSMergePolicyType = .MergeByPropertyObjectTrumpMergePolicyType) -> ChildManagedObjectContext {

            let childContext = NSManagedObjectContext(concurrencyType: concurrencyType)
            childContext.parentContext = managedObjectContext
            childContext.mergePolicy = NSMergePolicy(mergeType: mergePolicyType)
            return childContext
    }

    // MARK: Printable

    /// :nodoc:
    public var description: String {
        get {
            return "<\(toString(CoreDataStack.self)): model=\(model)>"
        }
    }
    
}