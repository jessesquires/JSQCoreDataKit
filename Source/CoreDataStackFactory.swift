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
 An instance of `CoreDataStackFactory` is responsible for creating instances of `CoreDataStack`.

 Because the adding of the persistent store to the persistent store coordinator during initialization
 of a `CoreDataStack` can take an unknown amount of time, you should not perform this operation on the main queue.

 See this [guide](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Conceptual/CoreData/IntegratingCoreData.html#//apple_ref/doc/uid/TP40001075-CH9-SW1) for more details.

 - warning: You should not create instances of `CoreDataStack` directly. Use a `CoreDataStackFactory` instead.
 */
public struct CoreDataStackFactory: CustomStringConvertible, Equatable {

    // MARK: Properties

    /// The model for the stack that the factory produces.
    public let model: CoreDataModel

    /**
     A dictionary that specifies options for the store that the factory produces.
     The default value is `DefaultStoreOptions`.
     */
    public let options: PersistentStoreOptions?


    // MARK: Initialization

    /**
     Constructs a new `CoreDataStackFactory` instance with the specified `model` and `options`.

     - parameter model:   The model describing the stack.
     - parameter options: Options for the persistent store.

     - returns: A new `CoreDataStackFactory` instance.
     */
    public init(model: CoreDataModel, options: PersistentStoreOptions? = defaultStoreOptions) {
        self.model = model
        self.options = options
    }


    // MARK: Creating a stack

    /**
     Asynchronously initializes a new `CoreDataStack` instance using the factory's `model` and `options`.

     - note: This operation is performed on a background queue.

     - parameter queue:      A background queue on which to initialize the stack. The default is a high priority background queue.
     - parameter completion: The closure to be called once initialization is complete.
     */
    public func createStackInBackground(
        queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
        completion: (result: StackResult) -> Void) {

        dispatch_async(queue) {
            precondition(!NSThread.isMainThread(), "*** Error: cannot create a stack on the main queue via \(#function)")

            let storeCoordinator: NSPersistentStoreCoordinator
            do {
                storeCoordinator = try self.createStoreCoordinator()
            } catch {
                dispatch_async(dispatch_get_main_queue()) {
                    completion(result: .failure(error as NSError))
                }
                return
            }

            let backgroundContext = self.createContext(.PrivateQueueConcurrencyType, name: "background")
            backgroundContext.persistentStoreCoordinator = storeCoordinator

            dispatch_async(dispatch_get_main_queue()) {
                let mainContext = self.createContext(.MainQueueConcurrencyType, name: "main")
                mainContext.persistentStoreCoordinator = storeCoordinator

                let stack = CoreDataStack(
                    model: self.model,
                    mainContext: mainContext,
                    backgroundContext: backgroundContext,
                    storeCoordinator: storeCoordinator)

                completion(result: .success(stack))
            }
        }
    }

    /**
     Synchronously initializes a new `CoreDataStack` instance using the factory's `model` and `options`.

     - warning: This method must be called on the main thread.

     - note: This method is primarily intended for unit testing purposes.

     - returns: A `StackResult` instance, describing the success or failure of creating the stack.
     */
    public func createStack() -> StackResult {
        precondition(NSThread.isMainThread(), "*** Error: \(#function) must be called on main thread")

        let storeCoordinator: NSPersistentStoreCoordinator
        do {
            storeCoordinator = try self.createStoreCoordinator()
        } catch {
            return .failure(error as NSError)
        }

        let backgroundContext = self.createContext(.PrivateQueueConcurrencyType, name: "background")
        backgroundContext.persistentStoreCoordinator = storeCoordinator

        let mainContext = self.createContext(.MainQueueConcurrencyType, name: "main")
        mainContext.persistentStoreCoordinator = storeCoordinator

        let stack = CoreDataStack(
            model: model,
            mainContext: mainContext,
            backgroundContext: backgroundContext,
            storeCoordinator: storeCoordinator)

        return .success(stack)
    }

    /**
     Resets the managed object contexts in the stack on their respective threads.
     Then, if the coordinator is connected to a persistent store, the store will be deleted and recreated on a background thread.
     The completion closure is executed on the main thread.

     - note: Removing and re-adding the persistent store is performed on a background queue.
     For binary and SQLite stores, this will also remove the store from disk.

     - parameter stack:      The stack to reset.
     - parameter queue:      A background queue on which to reset the stack. The default is a high priority background queue.
     - parameter completion: The closure to be called once resetting is complete.
     */
    public static func resetStack(stack: CoreDataStack,
                                  queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                                  completion: (result: StackResult) -> Void) {
        stack.mainContext.performBlockAndWait { stack.mainContext.reset() }
        stack.backgroundContext.performBlockAndWait { stack.backgroundContext.reset() }

        guard let store = stack.storeCoordinator.persistentStores.first else {
            dispatch_async(dispatch_get_main_queue()) {
                completion(result: .success(stack))
            }
            return
        }

        dispatch_async(queue) {
            precondition(!NSThread.isMainThread(), "*** Error: cannot reset a stack on the main queue")

            let storeCoordinator = stack.storeCoordinator
            let options = store.options
            let model = stack.model

            storeCoordinator.performBlockAndWait {
                do {
                    try model.removeExistingStore()
                    try storeCoordinator.removePersistentStore(store)
                    try storeCoordinator.addPersistentStoreWithType(model.storeType.type,
                        configuration: nil,
                        URL: model.storeURL,
                        options: options)
                }
                catch {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(result: .failure(error as NSError))
                    }
                    return
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(result: .success(stack))
                }
            }
        }
    }

    // MARK: Private

    private func createStoreCoordinator() throws -> NSPersistentStoreCoordinator {
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model.managedObjectModel)
        try storeCoordinator.addPersistentStoreWithType(model.storeType.type,
                                                        configuration: nil,
                                                        URL: model.storeURL,
                                                        options: options)
        return storeCoordinator
    }

    private func createContext(
        concurrencyType: NSManagedObjectContextConcurrencyType,
        name: String) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: concurrencyType)
        context.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyStoreTrumpMergePolicyType)

        let contextName = "JSQCoreDataKit.CoreDataStack.context."
        context.name = contextName + name

        return context
    }
    
    
    // MARK: CustomStringConvertible
    
    /// :nodoc:
    public var description: String {
        get {
            return "<\(CoreDataStackFactory.self): model=\(model.name); options=\(options)>"
        }
    }
}
