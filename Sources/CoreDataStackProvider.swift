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

/**
 An instance of `CoreDataStackProvider` is responsible for creating instances of `CoreDataStack`.

 Because the adding of the persistent store to the persistent store coordinator during initialization
 of a `CoreDataStack` can take an unknown amount of time, you should not perform this operation on the main queue.

 See this [guide](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Conceptual/CoreData/IntegratingCoreData.html#//apple_ref/doc/uid/TP40001075-CH9-SW1) for more details.

 - warning: You should not create instances of `CoreDataStack` directly. Use a `CoreDataStackProvider` instead.
 */
public struct CoreDataStackProvider {

    // MARK: Typealiases

    /// Describes the initialization options for a persistent store.
    public typealias PersistentStoreOptions = [AnyHashable: Any]

    // MARK: Properties

    /// Describes default persistent store options.
    public static let defaultStoreOptions: PersistentStoreOptions = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]

    /// The model for the stack that the factory produces.
    public let model: CoreDataModel

    /**
     A dictionary that specifies options for the store that the factory produces.
     The default value is `DefaultStoreOptions`.
     */
    public let options: PersistentStoreOptions?

    // MARK: Initialization

    /**
     Constructs a new `CoreDataStackProvider` instance with the specified `model` and `options`.

     - parameter model:   The model describing the stack.
     - parameter options: Options for the persistent store.

     - returns: A new `CoreDataStackProvider` instance.
     */
    public init(model: CoreDataModel, options: PersistentStoreOptions? = defaultStoreOptions) {
        self.model = model
        self.options = options
    }

    // MARK: Creating a stack

    /**
     Initializes a new `CoreDataStack` instance using the factory's `model` and `options`.

     - warning: If a queue is provided, this operation is performed asynchronously on the specified queue,
     and the completion closure is executed asynchronously on the main queue.
     If `queue` is `nil`, then this method and the completion closure execute synchronously on the current queue.

     - parameter queue: The queue on which to initialize the stack.
     The default is a background queue with a "user initiated" quality of service class.
     If passing `nil`, this method is executed synchronously on the queue from which the method was called.

     - parameter completion: The closure to be called once initialization is complete.
     If a queue is provided, this is called asynchronously on the main queue.
     Otherwise, this is executed on the thread from which the method was originally called.
     */
    public func createStack(onQueue queue: DispatchQueue? = .global(qos: .userInitiated),
                            completion: @escaping (CoreDataStack.StackResult) -> Void) {
        let isAsync = (queue != nil)

        let creationClosure = {
            let storeCoordinator: NSPersistentStoreCoordinator
            do {
                storeCoordinator = try self._createStoreCoordinator()
            } catch {
                if isAsync {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(error))
                }
                return
            }

            let backgroundContext = self._createContext(.privateQueueConcurrencyType, name: "background")
            backgroundContext.persistentStoreCoordinator = storeCoordinator

            let mainContext = self._createContext(.mainQueueConcurrencyType, name: "main")
            mainContext.persistentStoreCoordinator = storeCoordinator

            let stack = CoreDataStack(model: self.model,
                                      mainContext: mainContext,
                                      backgroundContext: backgroundContext,
                                      storeCoordinator: storeCoordinator)

            if isAsync {
                DispatchQueue.main.async {
                    completion(.success(stack))
                }
            } else {
                completion(.success(stack))
            }
        }

        if let queue {
            queue.async(execute: creationClosure)
        } else {
            creationClosure()
        }
    }

    // MARK: Private

    private func _createStoreCoordinator() throws -> NSPersistentStoreCoordinator {
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model.managedObjectModel)
        try storeCoordinator.addPersistentStore(ofType: self.model.storeType.type,
                                                configurationName: nil,
                                                at: self.model.storeURL,
                                                options: self.options)
        return storeCoordinator
    }

    private func _createContext(_ concurrencyType: NSManagedObjectContextConcurrencyType,
                                name: String) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: concurrencyType)
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)

        let contextName = "JSQCoreDataKit.CoreDataStack.context."
        context.name = contextName + name

        return context
    }
}
extension CoreDataStackProvider: Equatable {
    /// :nodoc:
    public static func == (lhs: CoreDataStackProvider, rhs: CoreDataStackProvider) -> Bool {
        lhs.model == rhs.model
    }
}
