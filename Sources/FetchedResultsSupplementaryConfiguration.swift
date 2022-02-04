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

public protocol FetchedResultsSupplementaryConfiguration {

    associatedtype ViewType: UICollectionReusableView

    associatedtype Object: NSManagedObject

    var reuseIdentifier: String { get }

    var kind: String { get }

    func registerWith(collectionView: UICollectionView)

    func configure(view: ViewType, with object: Object?, in section: NSFetchedResultsSectionInfo)
}

extension FetchedResultsSupplementaryConfiguration {
    public var viewClass: AnyClass { ViewType.self }

    public var reuseIdentifier: String { "\(Self.self)" }

    public func registerWith(collectionView: UICollectionView) {
        collectionView.register(
            self.viewClass,
            forSupplementaryViewOfKind: self.kind,
            withReuseIdentifier: self.reuseIdentifier
        )
    }

    func _dequeueAndConfigureViewFor(
        collectionView: UICollectionView,
        at indexPath: IndexPath,
        with object: Object?,
        in section: NSFetchedResultsSectionInfo) -> ViewType {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: self.kind,
            withReuseIdentifier: self.reuseIdentifier,
            for: indexPath) as! ViewType
        self.configure(view: view, with: object, in: section)
        return view
    }
}

public struct AnyFetchedResultsSupplementaryConfiguration<T: NSManagedObject>: FetchedResultsSupplementaryConfiguration {

    // MARK: FetchedResultsSupplementaryConfiguration

    public typealias ViewType = UICollectionReusableView

    public typealias Object = T

    public var reuseIdentifier: String { self._reuseIdentifier }

    public var kind: String { self._kind }

    public func registerWith(collectionView: UICollectionView) {
        self._register(collectionView)
    }

    public func configure(view: ViewType, with object: Object?, in section: NSFetchedResultsSectionInfo) {
        self._configure(view, object, section)
    }

    // MARK: Private

    private let _reuseIdentifier: String
    private let _kind: String
    private let _register: (UICollectionView) -> Void
    private let _configure: (ViewType, Object?, NSFetchedResultsSectionInfo) -> Void

    // MARK: Init

    public init<Config: FetchedResultsSupplementaryConfiguration>(_ config: Config) where Config.Object == T {
        self._reuseIdentifier = config.reuseIdentifier
        self._kind = config.kind
        self._register = { collectionView in
            config.registerWith(collectionView: collectionView)
        }
        self._configure = { view, object, section in
            precondition(
                view is Config.ViewType,
                "View must be of type \(Config.ViewType.self). Found \(view.self)"
            )
            config.configure(view: view as! Config.ViewType, with: object, in: section)
        }
    }
}

#endif
