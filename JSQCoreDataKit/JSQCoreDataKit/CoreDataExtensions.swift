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


public typealias ContextSaveResult = (success: Bool, error: NSError?)


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


public func saveContext(context: NSManagedObjectContext, completion: (ContextSaveResult) -> Void) {
    if !context.hasChanges {
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
