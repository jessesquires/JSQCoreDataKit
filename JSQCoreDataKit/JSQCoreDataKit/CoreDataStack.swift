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

import CoreData
import Foundation


/**
An instance of `CoreDataStack` encapsulates the entire Core Data stack.
It manages the managed object model, the persistent store coordinator, and managed object contexts.

It is composed of a main context and a background context, both of which are connected to the same persistent store coordinator.
These two contexts operate on the main queue and a private background queue, respectively.

Data between the two contexts is kept in sync.
*/
public final class CoreDataStack: CustomStringConvertible, Equatable {


    // MARK: Properties

    /// The model for the stack.
    public let model: CoreDataModel

    /// The main managed object context for the stack, which operates on the main queue.
    public let mainContext: NSManagedObjectContext

    /// The background managed object context for the stack, which operates on a background queue.
    public let backgroundContext: NSManagedObjectContext

    /**
    The persistent store coordinator for the stack.
    Both the `mainContext` and `backgroundContext` are connected to this coordinator.
    */
    public let storeCoordinator: NSPersistentStoreCoordinator


    // MARK: Initialization

    /**
    Constructs a new `CoreDataStack` instance with the specified `model` and `options`.

    - parameter model:   The model describing the stack.
    - parameter options: A dictionary that specifies options for the store. The default is `nil`.

    - returns: A new `CoreDataStack` instance.

    - Warning: You should not create a `CoreDataStack` directly. Instead, use a `CoreDataStackFactory` for initialization.
    */
    public init(model: CoreDataModel, options: PersistentStoreOptions? = nil) {
        self.model = model
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model.managedObjectModel)

        let name = "JSQCoreDataKit.CoreDataStack.context"

        var tempMainContext: NSManagedObjectContext!
        let setupMainContext: () -> Void = {
            tempMainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            tempMainContext.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyStoreTrumpMergePolicyType)
            tempMainContext.name = name + ".main"
        }

        if !NSThread.isMainThread() {
            dispatch_sync(dispatch_get_main_queue()) {
                setupMainContext()
            }
        }
        else {
            setupMainContext()
        }

        mainContext = tempMainContext
        mainContext.persistentStoreCoordinator = storeCoordinator

        backgroundContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        backgroundContext.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyStoreTrumpMergePolicyType)
        backgroundContext.persistentStoreCoordinator = storeCoordinator
        backgroundContext.name = name + ".background"

        do {
            try storeCoordinator.addPersistentStoreWithType(model.storeType.type,
                configuration: nil,
                URL: model.storeURL,
                options: options)
        } catch {
            fatalError("everything is broken")
        }

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("didReceiveMainContextDidSaveNotification:"),
            name: NSManagedObjectContextDidSaveNotification,
            object: mainContext)

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("didReceiveBackgroundContextDidSaveNotification:"),
            name: NSManagedObjectContextDidSaveNotification,
            object: backgroundContext)
    }

    /// :nodoc:
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    // MARK: Child contexts

    /**
    Creates a new child context whose parent is `mainContext` and has the specified `concurrencyType` and `mergePolicyType`.

    - parameter concurrencyType: The concurrency pattern to use. The default is `.PrivateQueueConcurrencyType`.
    - parameter mergePolicyType: The merge policy to use. The default is `.MergeByPropertyObjectTrumpMergePolicyType`.

    - returns: A new child managed object context whose parent is `mainContext`.
    */
    public func childContextFromMain(
        concurrencyType concurrencyType: NSManagedObjectContextConcurrencyType = .PrivateQueueConcurrencyType,
        mergePolicyType: NSMergePolicyType = .MergeByPropertyObjectTrumpMergePolicyType) -> ChildContext {

            return childContext(
                fromParent: mainContext,
                concurrencyType: concurrencyType,
                mergePolicyType: mergePolicyType)
    }

    /**
    Creates a new child context whose parent is `backgroundContext` and has the specified `concurrencyType` and `mergePolicyType`.

    - parameter concurrencyType: The concurrency pattern to use. The default is `.PrivateQueueConcurrencyType`.
    - parameter mergePolicyType: The merge policy to use. The default is `.MergeByPropertyObjectTrumpMergePolicyType`.

    - returns: A new child managed object context whose parent is `backgroundContext`.
    */
    public func childContextFromBackground(
        concurrencyType concurrencyType: NSManagedObjectContextConcurrencyType = .PrivateQueueConcurrencyType,
        mergePolicyType: NSMergePolicyType = .MergeByPropertyObjectTrumpMergePolicyType) -> ChildContext {

            return childContext(
                fromParent: backgroundContext,
                concurrencyType: concurrencyType,
                mergePolicyType: mergePolicyType)
    }


    // MARK: CustomStringConvertible

    /// :nodoc:
    public var description: String {
        get {
            return "<\(CoreDataStack.self): model=\(model.name); mainContext=\(mainContext); backgroundContext=\(backgroundContext)>"
        }
    }


    // MARK: Private

    private func childContext(
        fromParent parent: NSManagedObjectContext,
        concurrencyType: NSManagedObjectContextConcurrencyType,
        mergePolicyType: NSMergePolicyType) -> ChildContext {

            let childContext = NSManagedObjectContext(concurrencyType: concurrencyType)
            childContext.parentContext = parent
            childContext.mergePolicy = NSMergePolicy(mergeType: mergePolicyType)

            if let name = parent.name {
                childContext.name = name + ".child"
            }

            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: Selector("didReceiveChildContextDidSaveNotification:"),
                name: NSManagedObjectContextDidSaveNotification,
                object: childContext)

            return childContext
    }

    @objc
    private func didReceiveMainContextDidSaveNotification(notification: NSNotification) {
        backgroundContext.mergeChangesFromContextDidSaveNotification(notification)
    }

    @objc
    private func didReceiveBackgroundContextDidSaveNotification(notifcation: NSNotification) {
        mainContext.mergeChangesFromContextDidSaveNotification(notifcation)
    }

    @objc
    private func didReceiveChildContextDidSaveNotification(notification: NSNotification) {
        guard let context = notification.object as? NSManagedObjectContext else {
            assertionFailure("\(notification.name) posted from object of type \(notification.object.self). "
                + "Expected \(NSManagedObjectContext.self) instead.")
            return
        }

        guard let parentContext = context.parentContext else {
            debugPrint("*** Warning: child context saved without a parent context from notification: \(notification)")
            return
        }

        saveContext(parentContext)
    }
    
}
