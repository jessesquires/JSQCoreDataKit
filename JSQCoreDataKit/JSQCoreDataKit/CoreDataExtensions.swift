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
///  :param: success A boolean value indicating whether the save succeeded. `true` if successful, otherwise `false`.
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
