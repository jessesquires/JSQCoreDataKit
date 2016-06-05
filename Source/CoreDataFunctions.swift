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
 Attempts to commit unsaved changes to registered objects in the context.
 This function is performed in a block on the context's queue. If the context has no changes,
 then this function returns immediately and the completion block is not called.

 - parameter context:    The managed object context to save.
 - parameter wait:       If `true` (the default), saves synchronously. If `false`, saves asynchronously.
 - parameter completion: The closure to be executed when the save operation completes.
 */
public func saveContext(context: NSManagedObjectContext, wait: Bool = true, completion: ((SaveResult) -> Void)? = nil) {
    let block = {
        guard context.hasChanges else { return }
        do {
            try context.save()
            completion?(.success)
        }
        catch {
            completion?(.failure(error as NSError))
        }
    }
    wait ? context.performBlockAndWait(block) : context.performBlock(block)
}

public extension NSManagedObject {
/**
 Returns the entity of the managed object model associated with
 the specified managed object context’s persistent store coordinator.

 - parameter context: The managed object context to use.

 - returns: The entity with the specified name from the managed object
 model associated with context’s persistent store coordinator.
 */
    public class func entity(context: NSManagedObjectContext) -> NSEntityDescription {
        let className = "\(self.self)"
        return NSEntityDescription.entityForName(className, inManagedObjectContext: context)!
    }
}

/**
 An instance of `FetchRequest` describes search criteria used to retrieve data from a persistent store.
 This is a subclass of `NSFetchRequest` that adds a type parameter specifying the type of managed objects for the fetch request.
 The type parameter acts as a phantom type.
 */
public class FetchRequest<T: NSManagedObject>: NSFetchRequest {

    // MARK: Initialization

    /**
     Constructs a new `FetchRequest` instance.
     - parameter context: The managed object context to use.
     - returns: A new `FetchRequest` instance.
     */
    public init(context: NSManagedObjectContext) {
        super.init()
        self.entity = T.entity(context)
    }
}
