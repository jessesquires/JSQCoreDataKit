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

/// Describes the initialization options for a persistent store.
public typealias PersistentStoreOptions = [NSObject : AnyObject]


/// Describes default persistent store options.
public let DefaultStoreOptions = [
    NSMigratePersistentStoresAutomaticallyOption : true,
    NSInferMappingModelAutomaticallyOption : true
]


/**
- parameter lhs: A `CoreDataStackResult` instance.
- parameter rhs: A `CoreDataStackResult` instance.

- returns: True if `lhs` is equal to `rhs`, false otherwise.
*/
public func ==(lhs: CoreDataStackResult, rhs: CoreDataStackResult) -> Bool {
    switch (lhs, rhs) {
    case (let .Success(stack1), let .Success(stack2)):
        return stack1 == stack2

    case (let .Failure(error1), let .Failure(error2)):
        return error1 == error2

    default:
        return false
    }
}


/**
The result of creating a `CoreDataStack` via a `CoreDataStackFactory`.

- Success: Initializing the `CoreDataStack` succeeded.
- Failure: Initializing the `CoreDataStack` failed, with the specified error.
*/
public enum CoreDataStackResult {
    case Success(CoreDataStack)
    case Failure(NSError)

    public func stack() -> CoreDataStack? {
        if case .Success(let stack) = self {
            return stack
        }
        return nil
    }

    public func error() -> NSError? {
        if case .Failure(let error) = self {
            return error
        }
        return nil
    }
}


/**
An instance of `CoreDataStackFactory` is responsible for creating instances of `CoreDataStack.` 

Because the adding of the persistent store to the persistent store coordinator during a `CoreDataStack` 
initialization can take an unknown amount of time, you should not perform this operation on the main queue.

See this [guide](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Conceptual/CoreData/IntegratingCoreData.html#//apple_ref/doc/uid/TP40001075-CH9-SW1) for more details.

- Note: You should not create instances of `CoreDataStack` directly. Use a `CoreDataStackFactory` instead.
*/
public struct CoreDataStackFactory {

    /// The completion handler for initializing a `CoreDataStack`.
    public typealias CompletionHandler = (result: CoreDataStackResult) -> Void

    /// The model for the stack that the factory produces.
    public let model: CoreDataModel

    /**
    A dictionary that specifies options for the store that the factory produces.
    The default value is `DefaultStoreOptions`.
    */
    public let options: PersistentStoreOptions?

    /**
    Constructs a new `CoreDataStackFactory` instance with the specified `model` and `options`.

    - parameter model:   The model describing the stack.
    - parameter options: Options for the persistent store.

    - returns: A new `CoreDataStackFactory` instance.
    */
    public init(model: CoreDataModel, options: PersistentStoreOptions? = DefaultStoreOptions) {
        self.model = model
        self.options = options
    }

    /**
    Initializes a new `CoreDataStack` instance using the factory's `model` and `options`.
    
    - Note: This operation is executed on a high priority background queue.

    - parameter completion: The closure to be called when initialization is complete. 
    This closure is dispatched to the main queue.
    */
    public func createStackInBackground(completion: CompletionHandler) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let stack = CoreDataStack(model: self.model, options: self.options)

            dispatch_async(dispatch_get_main_queue()) {
                completion(result: .Success(stack))
            }
        }
    }

    // TODO: function to reset stack?

}
