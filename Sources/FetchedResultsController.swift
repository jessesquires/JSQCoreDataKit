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

/// A generic `NSFetchedResultsController`.
public final class FetchedResultsController<ObjectType: NSManagedObject>: NSFetchedResultsController<NSFetchRequestResult> {

    // MARK: Init

    /// Returns a fetch request controller initialized using the given arguments.
    ///
    /// - Parameters:
    ///   - fetchRequest: The fetch request used to get the objects.
    ///   - context: The managed object against which `fetchRequest` is executed.
    ///   - sectionNameKeyPath: A key path on result objects that returns the section name.
    ///   - cacheName: The name of the cache file the receiver should use.
    ///
    /// - Returns: An initialized fetch request controller.
    public init(fetchRequest: NSFetchRequest<ObjectType>,
                context: NSManagedObjectContext,
                sectionNameKeyPath: String?,
                cacheName: String?) {
        super.init(
            fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>,
            managedObjectContext: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: cacheName
        )
    }

    // MARK: Subscripts

    /// - Parameter indexPath: An index path of an object.
    /// - Returns: The object at `indexPath`.
    public subscript (indexPath: IndexPath) -> ObjectType {
        self.object(at: indexPath)
    }

    // MARK: Methods

    public func deleteCache() {
        FetchedResultsController.deleteCache(withName: self.cacheName)
    }

    public func numberOfSections() -> Int {
        self.sections().count
    }

    public func sections() -> [NSFetchedResultsSectionInfo] {
        self.sections ?? []
    }

    public func numberOfItems(in section: Int) -> Int {
        self.sections?[section].numberOfObjects ?? 0
    }

    public func fetchedObjects() -> [ObjectType] {
        (self.fetchedObjects ?? []) as! [ObjectType]
    }

    public func object(at indexPath: IndexPath) -> ObjectType {
        super.object(at: indexPath) as! ObjectType
    }

    public func indexPath(for object: ObjectType) -> IndexPath? {
        self.indexPath(forObject: object)
    }
}
