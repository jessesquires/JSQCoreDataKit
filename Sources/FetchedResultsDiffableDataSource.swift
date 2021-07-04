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
        cellConfig: CellConfig) where CellConfig.Object == Object {
        let registration = cellConfig.registration

        self.init(collectionView: collectionView) { collectionView, indexPath, objectID in
            let object = controller.object(at: indexPath)
            precondition(object.objectID == objectID)
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: object)
        }
    }
}

#endif
