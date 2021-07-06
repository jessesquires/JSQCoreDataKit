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

#if os(iOS) || os(tvOS)

import CoreData
import Foundation
import UIKit

public final class FetchedResultsCoordinator<
    Object,
    CellConfig: FetchedResultsCellConfiguration
>: NSObject, NSFetchedResultsControllerDelegate where CellConfig.Object == Object {

    public let controller: FetchedResultsController<Object>

    public let cellConfiguration: CellConfig

    public let supplementaryConfigurations: [AnyFetchedResultsSupplementaryConfiguration<Object>]

    public var animateUpdates = true

    private let _dataSource: _FetchedResultsDiffableDataSource

    private unowned var _collectionView: UICollectionView

    public init(fetchRequest: NSFetchRequest<Object>,
                context: NSManagedObjectContext,
                sectionNameKeyPath: String?,
                cacheName: String?,
                cellConfiguration: CellConfig,
                supplementaryConfigurations: [AnyFetchedResultsSupplementaryConfiguration<Object>] = [],
                collectionView: UICollectionView) {
        let controller = FetchedResultsController(
            fetchRequest: fetchRequest,
            context: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: cacheName
        )

        self.controller = controller
        self.cellConfiguration = cellConfiguration
        self.supplementaryConfigurations = supplementaryConfigurations
        self._dataSource = _FetchedResultsDiffableDataSource(
            collectionView: collectionView,
            controller: controller,
            cellConfig: cellConfiguration,
            supplementaryConfigs: supplementaryConfigurations
        )
        self._collectionView = collectionView
        super.init()
        controller.delegate = self
        collectionView.dataSource = self._dataSource
    }

    // MARK: Subscripts

    public subscript (indexPath: IndexPath) -> Object {
        self.controller[indexPath]
    }

    // MARK: Methods

    public func performFetch() {
        do {
            try self.controller.performFetch()
        } catch {
            assertionFailure("FetchedResultsController failed to perform fetch: \(error)")
        }
    }

    public func object(at indexPath: IndexPath) -> Object {
        self.controller.object(at: indexPath)
    }

    // MARK: NSFetchedResultsControllerDelegate

    /// :nodoc:
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var fetchedSnapshot = snapshot as _FetchedResultsDiffableSnapshot
        let currentSnapshot = self._dataSource.snapshot()

        // Ensure updated managed objects get reloaded
        // Taken from: https://www.avanderlee.com/swift/diffable-data-sources-core-data/
        let itemsToReload: [NSManagedObjectID] = fetchedSnapshot.itemIdentifiers.compactMap { itemId in
            // the item is at the same index
            guard let currentIndex = currentSnapshot.indexOfItem(itemId),
                  let fetchedIndex = fetchedSnapshot.indexOfItem(itemId),
                  fetchedIndex == currentIndex else {
                      return nil
                  }
            // the item has been updated
            guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemId),
                  existingObject.isUpdated else {
                      return nil
                  }
            return itemId
        }

        if #available(iOS 15.0, *) {
            fetchedSnapshot.reconfigureItems(itemsToReload)
        } else {
            fetchedSnapshot.reloadItems(itemsToReload)
        }

        // Fix issue with "empty sections" appearing.
        // If a section has no items, delete it.
        let sections = fetchedSnapshot.sectionIdentifiers.filter {
            fetchedSnapshot.numberOfItems(inSection: $0) == 0
        }
        fetchedSnapshot.deleteSections(sections)

        // If current snapshot is empty, this is our first load.
        // Don't animate a diff, just reload.
        if currentSnapshot.isEmpty {
            if #available(iOS 15.0, *) {
                self._dataSource.applySnapshotUsingReloadData(fetchedSnapshot, completion: nil)
            } else {
                // prior to iOS 15, passing false means reload data
                // https://jessesquires.github.io/wwdc-notes/2021/10252_blazing_fast_collection_views.html
                self._dataSource.apply(fetchedSnapshot, animatingDifferences: false)
            }
        } else {
            self._dataSource.apply(fetchedSnapshot, animatingDifferences: self.animateUpdates)
        }

        self.supplementaryConfigurations.forEach { config in
            let kind = config.kind
            let visibleIndexPaths = self._collectionView.indexPathsForVisibleSupplementaryElements(ofKind: kind)

            visibleIndexPaths.forEach { indexPath in
                guard let view = self._collectionView.supplementaryView(forElementKind: kind, at: indexPath) else {
                    return
                }

                var object: Object?
                if self.controller.hasObject(at: indexPath) {
                    object = self.controller.object(at: indexPath)
                }
                let sectionInfo = self.controller.section(at: indexPath.section)
                config.configure(view: view, with: object, in: sectionInfo)
            }
        }
    }
}

#endif
