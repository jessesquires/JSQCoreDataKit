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
 Both are connected to the persistent store coordinator and data between them is perpetually kept in sync.

 Changes to a child context are propagated to its parent context and eventually the persistent store when saving.

 - warning: **You cannot create a `CoreDataStack` instance directly. Instead, use a `CoreDataStackFactory` for initialization.**
 */
public final class CoreDataStack: CustomStringConvertible, Equatable {

    // MARK: Properties

    /// The model for the stack.
    public let model: CoreDataModel

    /**
     The main managed object context for the stack, which operates on the main queue.
     This context is a root level context that is connected to the `storeCoordinator`.
     It is kept in sync with `backgroundContext`.
     */
    public let mainContext: NSManagedObjectContext

    /**
     The background managed object context for the stack, which operates on a background queue.
     This context is a root level context that is connected to the `storeCoordinator`.
     It is kept in sync with `mainContext`.
     */
    public let backgroundContext: NSManagedObjectContext

    /**
     The persistent store coordinator for the stack. Both contexts are connected to this coordinator.
     */
    public let storeCoordinator: NSPersistentStoreCoordinator


    // MARK: Initialization

    internal init(model: CoreDataModel,
                  mainContext: NSManagedObjectContext,
                  backgroundContext: NSManagedObjectContext,
                  storeCoordinator: NSPersistentStoreCoordinator) {
        self.model = model
        self.mainContext = mainContext
        self.backgroundContext = backgroundContext
        self.storeCoordinator = storeCoordinator

        let notificationCenter = NotificationCenter.default()
        notificationCenter.addObserver(self,
                                       selector: #selector(didReceiveMainContextDidSave(notification:)),
                                       name: NSNotification.Name.NSManagedObjectContextDidSave,
                                       object: mainContext)
        notificationCenter.addObserver(self,
                                       selector: #selector(didReceiveBackgroundContextDidSave(notification:)),
                                       name: NSNotification.Name.NSManagedObjectContextDidSave,
                                       object: backgroundContext)
    }

    /// :nodoc:
    deinit {
        NotificationCenter.default().removeObserver(self)
    }

    // MARK: Child contexts

    /**
     Creates a new child context with the specified `concurrencyType` and `mergePolicyType`.

     The parent context is either `mainContext` or `backgroundContext` dependending on the specified `concurrencyType`:
     * `.PrivateQueueConcurrencyType` will set `backgroundContext` as the parent.
     * `.MainQueueConcurrencyType` will set `mainContext` as the parent.

     Saving the returned context will propagate changes through the parent context and then to the persistent store.

     - parameter concurrencyType: The concurrency pattern to use. The default is `.MainQueueConcurrencyType`.
     - parameter mergePolicyType: The merge policy to use. The default is `.MergeByPropertyObjectTrumpMergePolicyType`.

     - returns: A new child managed object context.
     */
    public func childContext(concurrencyType: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType,
                             mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) -> ChildContext {

        let childContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        childContext.mergePolicy = NSMergePolicy(merge: mergePolicyType)

        switch concurrencyType {
        case .mainQueueConcurrencyType:
            childContext.parent = mainContext
        case .privateQueueConcurrencyType:
            childContext.parent = backgroundContext
        case .confinementConcurrencyType:
            fatalError("*** Error: ConfinementConcurrencyType is not supported because it is being deprecated in iOS 9.0")
        }

        if let name = childContext.parent?.name {
            childContext.name = name + ".child"
        }

        NotificationCenter.default().addObserver(self,
                                                 selector: #selector(didReceiveChildContextDidSave(notification:)),
                                                 name: NSNotification.Name.NSManagedObjectContextDidSave,
                                                 object: childContext)
        return childContext
    }

    /**
     Resets the managed object contexts in the stack on their respective threads.
     Then, if the coordinator is connected to a persistent store, the store will be deleted and recreated on a background thread.
     The completion closure is executed on the main thread.

     - note: Removing and re-adding the persistent store is performed on a background queue.
     For binary and SQLite stores, this will also remove the store from disk.

     - parameter queue: A background queue on which to reset the stack.
     The default is a background queue with a "user initiated" quality of service class.

     - parameter completion: The closure to be called once resetting is complete. This is called on the main queue.
     */
    public func reset(onQueue queue: DispatchQueue = .global(attributes: .qosUserInitiated),
                      completion: (result: StackResult) -> Void) {

        mainContext.performAndWait { self.mainContext.reset() }
        backgroundContext.performAndWait { self.backgroundContext.reset() }

        guard let store = storeCoordinator.persistentStores.first else {
            DispatchQueue.main.async {
                completion(result: .success(self))
            }
            return
        }

        queue.async {
            precondition(!Thread.isMainThread(), "*** Error: cannot reset a stack on the main queue")

            let storeCoordinator = self.storeCoordinator
            let options = store.options
            let model = self.model

            storeCoordinator.performAndWait {
                do {
                    try model.removeExistingStore()
                    try storeCoordinator.remove(store)
                    try storeCoordinator.addPersistentStore(ofType: model.storeType.type,
                                                            configurationName: nil,
                                                            at: model.storeURL,
                                                            options: options)
                }
                catch {
                    DispatchQueue.main.async {
                        completion(result: .failure(error as NSError))
                    }
                    return
                }

                DispatchQueue.main.async {
                    completion(result: .success(self))
                }
            }
        }
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
    private func didReceiveChildContextDidSave(notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else {
            assertionFailure("*** Error: \(notification.name) posted from object of type \(notification.object.self). "
                + "Expected \(NSManagedObjectContext.self) instead.")
            return
        }

        guard let parentContext = context.parent else {
            // have reached the root context, nothing to do
            return
        }

        saveContext(parentContext)
    }

    @objc
    private func didReceiveBackgroundContextDidSave(notification: Notification) {
        mainContext.perform {
            self.mainContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc
    private func didReceiveMainContextDidSave(notification: Notification) {
        backgroundContext.perform {
            self.backgroundContext.mergeChanges(fromContextDidSave: notification)
        }
    }
}
