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


/// Describes default persistent store options.
public let DefaultStoreOptions: PersistentStoreOptions = [
    NSMigratePersistentStoresAutomaticallyOption: true,
    NSInferMappingModelAutomaticallyOption: true
]


/**
An instance of `CoreDataStackFactory` is responsible for creating instances of `CoreDataStack.` 

Because the adding of the persistent store to the persistent store coordinator during a `CoreDataStack` 
initialization can take an unknown amount of time, you should not perform this operation on the main queue.

See this [guide](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Conceptual/CoreData/IntegratingCoreData.html#//apple_ref/doc/uid/TP40001075-CH9-SW1) for more details.

- Note: You should not create instances of `CoreDataStack` directly. Use a `CoreDataStackFactory` instead.
*/
public struct CoreDataStackFactory: CustomStringConvertible, Equatable {

    // MARK: Typealiases

    /// The completion handler for initializing a `CoreDataStack`.
    public typealias CompletionHandler = (result: CoreDataStackResult) -> Void


    // MARK: Properties

    /// The model for the stack that the factory produces.
    public let model: CoreDataModel

    /**
    A dictionary that specifies options for the store that the factory produces.
    The default value is `DefaultStoreOptions`.
    */
    public let options: PersistentStoreOptions?


    // MARK: Initialization
    
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


    // MARK: Methods 

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


    // MARK: CustomStringConvertible

    /// :nodoc:
    public var description: String {
        get {
            return "<\(CoreDataStackFactory.self): model=\(model.name); options=\(options)>"
        }
    }
}
