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

struct EmployeeCellConfig: FetchedResultsCellConfiguration {

    func configure(cell: CollectionViewCell, with object: Employee) {
        cell.configure(primaryText: object.name, secondaryText: "$\(object.salary).00")
    }
}

struct EmployeeHeaderConfig: FetchedResultsSupplementaryConfiguration {
    let kind = UICollectionView.elementKindSectionHeader

    func configure(view: UICollectionViewCell, with object: Employee?, in section: NSFetchedResultsSectionInfo) {
        var contentConfiguration = UIListContentConfiguration.groupedHeader()
        contentConfiguration.text = "All Employees"
        view.contentConfiguration = contentConfiguration
        view.isHidden = (section.numberOfObjects == 0)
    }
}

struct EmployeeFooterConfig: FetchedResultsSupplementaryConfiguration {
    let kind = UICollectionView.elementKindSectionFooter

    func configure(view: UICollectionViewCell, with object: Employee?, in section: NSFetchedResultsSectionInfo) {
        var contentConfiguration = UIListContentConfiguration.groupedFooter()
        contentConfiguration.text = "There are \(section.numberOfObjects) employees."
        view.contentConfiguration = contentConfiguration
        view.isHidden = (section.numberOfObjects == 0)
    }
}
