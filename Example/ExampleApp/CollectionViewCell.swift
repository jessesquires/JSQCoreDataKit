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

import UIKit

final class CollectionViewCell: UICollectionViewListCell {

    func configure(primaryText: String, secondaryText: String) {
        var contentConfiguration = UIListContentConfiguration.subtitleCell()
        contentConfiguration.text = primaryText
        contentConfiguration.secondaryText = secondaryText
        self.contentConfiguration = contentConfiguration
    }
}
