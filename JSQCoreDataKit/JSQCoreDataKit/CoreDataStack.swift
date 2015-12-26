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


/**
 An instance of `CoreDataStack` encapsulates the entire Core Data stack.
 It manages the managed object model, the persistent store coordinator, and managed object contexts.

 It is composed of a main context and a background context.
 These two contexts operate on the main queue and a private background queue, respectively.
 The background context is the root level context, which is connected to the persistent store coordinator.
 The main context is a child of the background context.

 Data between these two primary contexts and child contexts is kept in sync.
 Changes to a context are propagated to its parent context and eventually the persistent store when saving.

 - warning: **You cannot create a `CoreDataStack` instance directly. Instead, use a `CoreDataStackFactory` for initialization.**
 */
public final class CoreDataStack: CustomStringConvertible, Equatable {


    // MARK: Properties

    /// The model for the stack.
    public let model: CoreDataModel

    /**
     The main managed object context for the stack, which operates on the main queue.
     This context is a child context of `backgroundContext`.
     */
    public let mainContext: NSManagedObjectContext

    /**
     The background managed object context for the stack, which operates on a background queue.
     This context is the root level context that is connected to the `storeCoordinator`.
     */
    public let backgroundContext: NSManagedObjectContext

    /**
     The persistent store coordinator for the stack. The `backgroundContext` is connected to this coordinator.
     */
    public let storeCoordinator: NSPersistentStoreCoordinator


    // MARK: Initialization

    internal init(
        model: CoreDataModel,
        mainContext: NSManagedObjectContext,
        backgroundContext: NSManagedObjectContext,
        storeCoordinator: NSPersistentStoreCoordinator) {
            self.model = model
            self.mainContext = mainContext
            self.backgroundContext = backgroundContext
            self.storeCoordinator = storeCoordinator

            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: Selector("didReceiveChildContextDidSaveNotification:"),
                name: NSManagedObjectContextDidSaveNotification,
                object: mainContext)
    }

    /// :nodoc:
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    // MARK: Child contexts

    /**
    Creates a new child context whose parent is `mainContext` and has the specified `concurrencyType` and `mergePolicyType`.
    Saving the returned context will propagate changes through `mainContext`, `backgroundContext`,
    and finally the persistent store.

    - parameter concurrencyType: The concurrency pattern to use. The default is `.PrivateQueueConcurrencyType`.
    - parameter mergePolicyType: The merge policy to use. The default is `.MergeByPropertyObjectTrumpMergePolicyType`.

    - returns: A new child managed object context whose parent is `mainContext`.
    */
    public func childContext(
        concurrencyType concurrencyType: NSManagedObjectContextConcurrencyType = .PrivateQueueConcurrencyType,
        mergePolicyType: NSMergePolicyType = .MergeByPropertyObjectTrumpMergePolicyType) -> ChildContext {

            let childContext = NSManagedObjectContext(concurrencyType: concurrencyType)
            childContext.parentContext = mainContext
            childContext.mergePolicy = NSMergePolicy(mergeType: mergePolicyType)

            if let name = mainContext.name {
                childContext.name = name + ".child"
            }

            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: Selector("didReceiveChildContextDidSaveNotification:"),
                name: NSManagedObjectContextDidSaveNotification,
                object: childContext)

            return childContext
    }


    // MARK: CustomStringConvertible

    /// :nodoc:
    public var description: String {
        get {
            return "<\(CoreDataStack.self): model=\(model.name); mainContext=\(mainContext); backgroundContext=\(backgroundContext)>"
        }
    }


    // MARK: Private

    @objc
    private func didReceiveChildContextDidSaveNotification(notification: NSNotification) {
        guard let context = notification.object as? NSManagedObjectContext else {
            assertionFailure("*** Error: \(notification.name) posted from object of type \(notification.object.self). "
                + "Expected \(NSManagedObjectContext.self) instead.")
            return
        }

        guard let parentContext = context.parentContext else {
            // have reached the root context, nothing to do
            return
        }
        
        saveContext(parentContext)
    }
    
}
