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



/**
 Attempts to commit unsaved changes to registered objects in the context.
 This function is performed in a block on the context's queue. If the context has no changes,
 then this function returns immediately and the completion block is not called.

 - parameter context:    The managed object context to save.
 - parameter wait:       If true (the default), saves synchronously. If false, saves asynchronously.
 - parameter completion: The closure to be executed when the save operation completes.
 */
public func saveContext(context: NSManagedObjectContext, wait: Bool = true, completion: ((CoreDataSaveResult) -> Void)? = nil) {
    guard context.hasChanges else { return }

    let block = { () -> Void in
        do {
            try context.save()
            completion?(.Success)
        }
        catch {
            completion?(.Failure(error as NSError))
        }
    }

    wait ? context.performBlockAndWait(block) : context.performBlock(block)
}


/**
 Returns the entity with the specified name from the managed object model associated with
 the specified managed object context’s persistent store coordinator.

 - parameter name:    The name of an entity.
 - parameter context: The managed object context to use.

 - returns: The entity with the specified name from the managed object
 model associated with context’s persistent store coordinator.
 */
public func entity(name name: String, context: NSManagedObjectContext) -> NSEntityDescription {
    return NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
}


/**
 An instance of `FetchRequest` describes search criteria used to retrieve data from a persistent store.
 This is a subclass of `NSFetchRequest` that adds a type parameter specifying the type of managed objects for the fetch request.
 The type parameter acts as a phantom type.
 */
public class FetchRequest <T: NSManagedObject>: NSFetchRequest {

    // MARK: Initialization

    /**
    Constructs a new `FetchRequest` instance.

    - parameter entity: The entity description for the entities that this request fetches.

    - returns: A new `FetchRequest` instance.
    */
    public init(entity: NSEntityDescription) {
        super.init()
        self.entity = entity
    }
}


/**
 Executes the fetch request in the given context and returns the result.
 
 - note: This function is performed synchronously in a block on the context's queue.

 - parameter request: A fetch request that specifies the search criteria for the fetch.
 - parameter context: The managed object context in which to search.

 - throws: If the fetch fails or errors, then this function throws an `NSError`.

 - returns: An array of objects that meet the criteria specified by the fetch request. This array may be empty.
 */
public func fetch <T: NSManagedObject>(request request: FetchRequest<T>, inContext context: NSManagedObjectContext) throws -> [T] {
    var results = [AnyObject]()
    var caughtError: NSError?

    context.performBlockAndWait { () -> Void in
        do {
            results = try context.executeFetchRequest(request)
        }
        catch {
            caughtError = error as NSError
        }
    }

    guard caughtError == nil else {
        throw caughtError!
    }

    return results as! [T]
}


/**
 Deletes the objects from the specified context.
 You must save the context after calling this function to remove objects from their persistent store.

 - note: This function is performed synchronously in a block on the context's queue.

 - parameter objects: The managed objects to be deleted.
 - parameter context: The context to which the objects belong.
 */
public func deleteObjects <T: NSManagedObject>(objects: [T], inContext context: NSManagedObjectContext) {
    guard objects.count != 0 else { return }

    context.performBlockAndWait { () -> Void in
        for each in objects {
            context.deleteObject(each)
        }
    }
}

/**
 Asynchronously resets a `CoreDataStack` instance.
 Resets the managed object contexts in the stack, then deletes and recreates the persistent store connected to the coordinator.
 For binary and SQLite stores, this will also remove the store from disk.

 - note: This operation is performed on a background queue.

 - parameter stack:      The `CoreDataStack` instance to be reset.
 - parameter queue:      A background queue on which to reset the stack. The default is a high priority background queue.
 - parameter completion: The closure to be called once resetting is complete.
 */
public func resetStackInBackground(
    stack: CoreDataStack,
    queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
    completion: CoreDataStackFactory.CompletionHandler) {

    dispatch_async(queue) {
        assert(!NSThread.isMainThread(), "*** Error: cannot reset a stack on the main queue via \(__FUNCTION__)")

        stack.mainContext.performBlockAndWait {
            stack.mainContext.reset()
        }

        stack.backgroundContext.performBlockAndWait {
            stack.backgroundContext.reset()
        }

        guard let store = stack.storeCoordinator.persistentStores.first else {
            dispatch_async(dispatch_get_main_queue()) {
                completion(result: .Success(stack))
            }
            return
        }

        let storeCoordinator = stack.storeCoordinator
        let model = stack.model

        storeCoordinator.performBlockAndWait {
            do {
                try storeCoordinator.removePersistentStore(store)
                try model.removeExistingModelStore()

                try storeCoordinator.addPersistentStoreWithType(model.storeType.type,
                    configuration: nil,
                    URL: model.storeURL,
                    options: store.options)
            }
            catch {
                dispatch_async(dispatch_get_main_queue()) {
                    completion(result: .Failure(error as NSError))
                }
            }
        }

        dispatch_async(dispatch_get_main_queue()) {
            completion(result: .Success(stack))
        }
    }
}