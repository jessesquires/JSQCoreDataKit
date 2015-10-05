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

import CoreData
import Foundation

public struct StackInitializer {

    public typealias StackInitHandler = (Void) -> CoreDataStack?
    
    public typealias StackCompletionHandler = (CoreDataStack?) -> Void

    public static func Create(initialize: StackInitHandler, completion: StackCompletionHandler) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let stack = initialize()

            dispatch_async(dispatch_get_main_queue()) {
                completion(stack)
            }
        }
    }

}