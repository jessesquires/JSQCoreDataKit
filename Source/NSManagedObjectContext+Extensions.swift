//
//  Created by Jesse Squires
//  https://www.jessesquires.com
//
//
//  Documentation
//  https://jessesquires.github.io/JSQCoreDataKit
//
//
//  GitHub
//  https://github.com/jessesquires/JSQCoreDataKit
//
//
//  License
//  Copyright © 2015-present Jesse Squires
//  Released under an MIT license: https://opensource.org/licenses/MIT
//

import CoreData
import Foundation

extension NSManagedObjectContext {

    /// Describes a child managed object context.
    public typealias ChildContext = NSManagedObjectContext

    /**
     Attempts to commit unsaved changes to registered objects in the context.
     This function is performed in a block on the context's queue. If the context has no changes,
     then this function returns immediately and the completion block is not called.

     - parameter wait:       If `true` (the default), saves synchronously. If `false`, saves asynchronously.
     - parameter completion: The closure to be executed when the save operation completes.
     */
    public func save(wait: Bool = true, completion: ((SaveResult) -> Void)? = nil) {
        let block = {
            guard self.hasChanges else { return }
            do {
                try self.save()
                completion?(.success)
            } catch {
                completion?(.failure(error as NSError))
            }
        }
        wait ? performAndWait(block) : perform(block)
    }
}
