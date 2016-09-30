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
public func saveContext(_ context: NSManagedObjectContext, wait: Bool = true, completion: ((SaveResult) -> Void)? = nil) {
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
    wait ? context.performAndWait(block) : context.perform(block)
}
