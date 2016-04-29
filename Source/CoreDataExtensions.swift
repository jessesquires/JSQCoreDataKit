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

public extension NSManagedObjectContext {
    /**
     Deletes the objects from the context.
     You must save the context after calling this function to remove objects from their persistent store.

     - note: This function is performed synchronously in a block on the context's queue.

     - parameter objects: The managed objects to be deleted.
     */
    public func deleteObjects <T: NSManagedObject>(objects: [T]) {
        guard objects.count != 0 else { return }

        self.performBlockAndWait {
            for each in objects {
                self.deleteObject(each)
            }
        }
    }

    /**
     Executes the fetch request in the context and returns the result.

     - note: This function is performed synchronously in a block on the context's queue.

     - parameter request: A fetch request that specifies the search criteria for the fetch.

     - throws: If the fetch fails or errors, then this function throws an `NSError`.

     - returns: An array of objects that meet the criteria specified by the fetch request. This array may be empty.
     */
    public func fetch <T: NSManagedObject>(request request: FetchRequest<T>) throws -> [T] {
        var results = [AnyObject]()
        var caughtError: NSError?

        performBlockAndWait {
            do {
                results = try self.executeFetchRequest(request)
            }
            catch {
                caughtError = error as NSError
            }
        }
        
        guard caughtError == nil else { throw caughtError! }
        
        return results as! [T]
    }

}
