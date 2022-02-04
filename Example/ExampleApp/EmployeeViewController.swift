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

final class EmployeeViewController: CollectionViewController {

    let stack: CoreDataStack
    let company: Company

    lazy var coordinator: FetchedResultsCoordinator<Employee, EmployeeCellConfig> = {
        let supplementaryViews = [
            AnyFetchedResultsSupplementaryConfiguration(EmployeeHeaderConfig()),
            AnyFetchedResultsSupplementaryConfiguration(EmployeeFooterConfig())
        ]
        return FetchedResultsCoordinator(
            fetchRequest: Employee.fetchRequest(for: self.company),
            context: self.stack.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil,
            collectionView: self.collectionView,
            cellConfiguration: EmployeeCellConfig(),
            supplementaryConfigurations: supplementaryViews
        )
    }()

    // MARK: Init

    init(stack: CoreDataStack, company: Company) {
        self.stack = stack
        self.company = company
        super.init()
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.company.name
        self.collectionView.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.coordinator.performFetch()
    }

    // MARK: Actions

    override func addAction() {
        self.stack.mainContext.performAndWait {
            _ = Employee.newEmployee(self.stack.mainContext, company: self.company)
            self.stack.mainContext.saveSync()
        }
    }

    override func deleteAction() {
        let backgroundChildContext = self.stack.childContext()
        backgroundChildContext.performAndWait {
            do {
                let objects = try backgroundChildContext.fetch(Employee.fetchRequest(for: self.company))
                for each in objects {
                    backgroundChildContext.delete(each)
                }
                backgroundChildContext.saveSync()
            } catch {
                print("Error deleting objects: \(error)")
            }
        }
    }
}
