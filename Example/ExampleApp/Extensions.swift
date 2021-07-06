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

import Foundation
import UIKit

extension UICollectionViewCompositionalLayout {

    static func list() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, layoutEnvironment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            configuration.headerMode = .supplementary
            configuration.footerMode = .supplementary
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            return section
        }
    }
}

extension UIBarButtonItem {

    static func add(target: Any, selector: Selector) -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .add, target: target, action: selector)
    }

    static func trash(target: Any, selector: Selector) -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .trash, target: target, action: selector)
    }
}
