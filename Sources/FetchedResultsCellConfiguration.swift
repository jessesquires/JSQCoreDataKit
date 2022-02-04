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

public protocol FetchedResultsCellConfiguration {

    associatedtype CellType: UICollectionViewCell

    associatedtype Object: NSManagedObject

    typealias Registration = UICollectionView.CellRegistration<CellType, Object>

    func configure(cell: CellType, with object: Object)
}

extension FetchedResultsCellConfiguration {

    public var registration: Registration {
        Registration { cell, _, object in
            self.configure(cell: cell, with: object)
        }
    }
}

#endif
