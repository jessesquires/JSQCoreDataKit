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
import ExampleModel
import JSQCoreDataKit
import UIKit

struct CompanyCellConfig: FetchedResultsCellConfiguration {

    func configure(cell: CollectionViewCell, with object: Company) {
        cell.configure(primaryText: object.name, secondaryText: "$\(object.profits).00")
        cell.accessories = [.disclosureIndicator()]
    }
}

struct CompanyHeaderConfig: FetchedResultsSupplementaryConfiguration {
    let kind = UICollectionView.elementKindSectionHeader

    func configure(view: UICollectionViewCell, with object: Company?, in section: NSFetchedResultsSectionInfo) {
        var contentConfiguration = UIListContentConfiguration.groupedHeader()
        contentConfiguration.text = "All Companies"
        view.contentConfiguration = contentConfiguration
        view.isHidden = (section.numberOfObjects == 0)
    }
}

struct CompanyFooterConfig: FetchedResultsSupplementaryConfiguration {
    let kind = UICollectionView.elementKindSectionFooter

    func configure(view: UICollectionViewCell, with object: Company?, in section: NSFetchedResultsSectionInfo) {
        var contentConfiguration = UIListContentConfiguration.groupedFooter()
        contentConfiguration.text = "There are \(section.numberOfObjects) companies."
        view.contentConfiguration = contentConfiguration
        view.isHidden = (section.numberOfObjects == 0)
    }
}
