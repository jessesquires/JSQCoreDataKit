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

// swiftlint:disable:next colon
public final class FetchedResultsCoordinator<Object, CellConfig: FetchedResultsCellConfiguration>:
    NSObject, NSFetchedResultsControllerDelegate where CellConfig.Object == Object {

    public let controller: FetchedResultsController<Object>

    public let cellConfiguration: CellConfig

    public var animateUpdates = true

    private let _dataSource: _FetchedResultsDiffableDataSource

    private unowned var _collectionView: UICollectionView

    public init(fetchRequest: NSFetchRequest<Object>,
                context: NSManagedObjectContext,
                sectionNameKeyPath: String?,
                cacheName: String?,
                cellConfiguration: CellConfig,
                collectionView: UICollectionView) {
        let controller = FetchedResultsController(
            fetchRequest: fetchRequest,
            context: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: cacheName
        )

        self.controller = controller
        self.cellConfiguration = cellConfiguration
        self._collectionView = collectionView
        self._dataSource = _FetchedResultsDiffableDataSource(
            collectionView: collectionView,
            controller: controller,
            cellConfig: cellConfiguration
        )

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

        // taken from: https://www.avanderlee.com/swift/diffable-data-sources-core-data/
        let reloadIdentifiers: [NSManagedObjectID] = fetchedSnapshot.itemIdentifiers.compactMap { itemIdentifier in
            guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier),
                  let index = fetchedSnapshot.indexOfItem(itemIdentifier),
                  index == currentIndex else {
                      return nil
                  }
            guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier),
                  existingObject.isUpdated else {
                      return nil
                  }
            return itemIdentifier
        }
        fetchedSnapshot.reloadItems(reloadIdentifiers)

        let shouldAnimate = self.animateUpdates && self._collectionView.numberOfSections != 0
        self._dataSource.apply(fetchedSnapshot, animatingDifferences: shouldAnimate)
    }
}

#endif
