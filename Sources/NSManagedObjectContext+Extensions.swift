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

extension NSManagedObjectContext {

    /// Describes a child managed object context.
    public typealias ChildContext = NSManagedObjectContext

    /// Describes the result type for saving a managed object context.
    public typealias SaveResult = Result<NSManagedObjectContext, Error>

    /// Attempts to **asynchronously** commit unsaved changes to registered objects in the context.
    /// This function is performed in a block on the context's queue. If the context has no changes,
    /// then this function returns immediately and the completion block is not called.
    ///
    /// - Parameter completion: The closure to be executed when the save operation completes.
    public func saveAsync(completion: ((SaveResult) -> Void)? = nil) {
        self._save(wait: false, completion: completion)
    }

    /// Attempts to **synchronously** commit unsaved changes to registered objects in the context.
    /// This function is performed in a block on the context's queue. If the context has no changes,
    /// then this function returns immediately and the completion block is not called.
    ///
    /// - Parameter completion: The closure to be executed when the save operation completes.
    public func saveSync(completion: ((SaveResult) -> Void)? = nil) {
        self._save(wait: true, completion: completion)
    }

    /// Attempts to commit unsaved changes to registered objects in the context.
    ///
    /// - Parameter wait: If `true`, saves synchronously. If `false`, saves asynchronously.
    /// - Parameter completion: The closure to be executed when the save operation completes.
    private func _save(wait: Bool, completion: ((SaveResult) -> Void)? = nil) {

        let block = {
            guard self.hasChanges else { return }
            do {
                try self.save()
                completion?(.success(self))
            } catch {
                completion?(.failure(error))
            }
        }

        // swiftlint:disable:next void_function_in_ternary
        wait ? self.performAndWait(block) : self.perform(block)
    }
}
