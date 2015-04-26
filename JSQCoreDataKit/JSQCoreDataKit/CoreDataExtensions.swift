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

///  A tuple value that describes the results of saving a managed object context.
///
///  :param: success A boolean value indicating whether the save succeeded. It is `true` if successful, otherwise `false`.
///  :param: error   An error object if an error occurred, otherwise `nil`.
public typealias ContextSaveResult = (success: Bool, error: NSError?)


///  Attempts to commit unsaved changes to registered objects to the specified context's parent store.
///  This method is performed *synchronously* in a block on the context's queue.
///  If the context returns `false` from `hasChanges`, this function returns immediately.
///
///  :param: context The managed object context to save.
///
///  :returns: A `ContextSaveResult` instance indicating the result from saving the context.
public func saveContextAndWait(context: NSManagedObjectContext) -> ContextSaveResult {
    if !context.hasChanges {
        return (true, nil)
    }

    var success = false
    var error: NSError?

    context.performBlockAndWait { () -> Void in
        success = context.save(&error)

        if !success {
            println("*** ERROR: [\(__LINE__)] \(__FUNCTION__) Could not save managed object context: \(error)")
        }
    }

    return (success, error)
}


///  Attempts to commit unsaved changes to registered objects to the specified context's parent store.
///  This method is performed *asynchronously* in a block on the context's queue.
///  If the context returns `false` from `hasChanges`, this function returns immediately.
///
///  :param: context    The managed object context to save.
///  :param: completion The closure to be executed when the save operation completes.
public func saveContext(context: NSManagedObjectContext, completion: (ContextSaveResult) -> Void) {
    if !context.hasChanges {
        completion((true, nil))
        return
    }

    context.performBlock { () -> Void in
        var error: NSError?
        let success = context.save(&error)

        if !success {
            println("*** ERROR: [\(__LINE__)] \(__FUNCTION__) Could not save managed object context: \(error)")
        }

        completion((success, error))
    }
}


///  Returns the entity with the specified name from the managed object model associated with the specified managed object context’s persistent store coordinator.
///
///  :param: name    The name of an entity.
///  :param: context The managed object context to use.
///
///  :returns: The entity with the specified name from the managed object model associated with context’s persistent store coordinator.
public func entity(#name: String, #context: NSManagedObjectContext) -> NSEntityDescription {
    return NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
}


///  An instance of `FetchRequest <T: NSManagedObject>` describes search criteria used to retrieve data from a persistent store.
///  This is a subclass of `NSFetchRequest` that adds a type parameter specifying the type of managed objects for the fetch request.
///  The type parameter acts as a phantom type.
public class FetchRequest <T: NSManagedObject>: NSFetchRequest {

    ///  Constructs a new `FetchRequest` instance.
    ///
    ///  :param: entity The entity description for the entities that this request fetches.
    ///
    ///  :returns: A new `FetchRequest` instance.
    public init(entity: NSEntityDescription) {
        super.init()
        self.entity = entity
    }
}


///  A `FetchResult` represents the result of executing a fetch request.
///  It has one type parameter that specifies the type of managed objects that were fetched.
public struct FetchResult <T: NSManagedObject> {

    ///  Specifies whether or not the fetch succeeded.
    public let success: Bool

    ///  An array of objects that meet the criteria specified by the fetch request.
    ///  If the fetch is unsuccessful, this array will be empty.
    public let objects: [T]

    ///  If unsuccessful, specifies an error that describes the problem executing the fetch. Otherwise, this value is `nil`.
    public let error: NSError?
}


///  Executes the fetch request in the given context and returns the result.
///
///  :param: request A fetch request that specifies the search criteria for the fetch.
///  :param: context The managed object context in which to search.
///
///  :returns: A instance of `FetchResult` describing the results of executing the request.
public func fetch <T: NSManagedObject>(#request: FetchRequest<T>, inContext context: NSManagedObjectContext) -> FetchResult<T> {

    var error: NSError?
    var results: [AnyObject]?

    context.performBlockAndWait { () -> Void in
        results = context.executeFetchRequest(request, error: &error)
    }

    if let results = results {
        return FetchResult(success: true, objects: results as! [T], error: error)
    }
    else {
        println("*** ERROR: [\(__LINE__)] \(__FUNCTION__) Error while executing fetch request: \(error)")
    }
    
    return FetchResult(success: false, objects: [], error: error)
}


///  Deletes the objects from the specified context.
///  When changes are committed, the objects will be removed from their persistent store.
///  You must save the context after calling this function to remove objects from the store.
///
///  :param: objects The managed objects to be deleted.
///  :param: context The context to which the objects belong.
public func deleteObjects <T: NSManagedObject>(objects: [T], inContext context: NSManagedObjectContext) {
    
    if objects.count == 0 {
        return
    }
    
    context.performBlockAndWait { () -> Void in
        for each in objects {
            context.deleteObject(each)
        }
    }
}
