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

import ExampleModel
import JSQCoreDataKit
import UIKit

struct EmployeeCellConfig: FetchedResultsCellConfiguration {

    func configure(cell: CollectionViewCell, with object: Employee) {
        cell.configure(primaryText: object.name, secondaryText: "$\(object.salary).00")
    }
}
