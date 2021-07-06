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
import UIKit

typealias _FetchedResultsDiffableDataSource = UICollectionViewDiffableDataSource<String, NSManagedObjectID>

typealias _FetchedResultsDiffableSnapshot = NSDiffableDataSourceSnapshot<String, NSManagedObjectID>

extension _FetchedResultsDiffableDataSource {

    convenience init<Object, CellConfig: FetchedResultsCellConfiguration>(
        collectionView: UICollectionView,
        controller: FetchedResultsController<Object>,
        cellConfig: CellConfig,
        supplementaryConfigs: [AnyFetchedResultsSupplementaryConfiguration<Object>]
    ) where CellConfig.Object == Object {
        let cellRegistration = cellConfig.registration

        self.init(collectionView: collectionView) { collectionView, indexPath, objectID in
            let object = controller.object(at: indexPath)
            precondition(object.objectID == objectID)
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: object)
        }

        if supplementaryConfigs.isEmpty {
            return
        }

        supplementaryConfigs.forEach {
            $0.registerWith(collectionView: collectionView)
        }

        let allKinds = supplementaryConfigs.map { $0.kind }
        let configMap = Dictionary(uniqueKeysWithValues: zip(allKinds, supplementaryConfigs))

        self.supplementaryViewProvider = { collectionView, kind, indexPath in
            precondition(configMap[kind] != nil, "A SupplementaryConfiguration should exist for kind: \(kind)")

            var object: Object?
            if controller.hasObject(at: indexPath) {
                object = controller.object(at: indexPath)
            }
            let sectionInfo = controller.section(at: indexPath.section)
            let config = configMap[kind]!
            let view = config._dequeueAndConfigureViewFor(
                collectionView: collectionView,
                at: indexPath,
                with: object,
                in: sectionInfo
            )
            return view
        }
    }
}

extension NSDiffableDataSourceSnapshot {
    var isEmpty: Bool {
        self.numberOfItems == 0
    }
}

#endif
