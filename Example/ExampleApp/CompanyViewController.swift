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

final class CompanyViewController: CollectionViewController {

    var stack: CoreDataStack!

    var coordinator: FetchedResultsCoordinator<Company, CompanyCellConfig>?

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "JSQCoreDataKit"

        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let provider = CoreDataStackProvider(model: model)
        provider.createStack { result in
            switch result {
            case .success(let stack):
                self.stack = stack
                self.setupCoordinator()
                self.coordinator?.performFetch()

            case .failure(let err):
                assertionFailure("Error creating stack: \(err)")
            }
        }
    }

    // MARK: Actions

    override func addAction() {
        self.stack.mainContext.performAndWait {
            _ = Company.newCompany(self.stack.mainContext)
            self.stack.mainContext.saveSync()
        }
    }

    override func deleteAction() {
        let backgroundChildContext = stack.childContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundChildContext.performAndWait {
            do {
                let objects = try backgroundChildContext.fetch(Company.fetchRequest)
                for each in objects {
                    backgroundChildContext.delete(each)
                }
                backgroundChildContext.saveSync()
            } catch {
                print("Error deleting objects: \(error)")
            }
        }
    }

    // MARK: Helpers

    func setupCoordinator() {
        let supplementaryViews = [
            AnyFetchedResultsSupplementaryConfiguration(CompanyHeaderConfig()),
            AnyFetchedResultsSupplementaryConfiguration(CompanyFooterConfig())
        ]

        self.coordinator = FetchedResultsCoordinator(
            fetchRequest: Company.fetchRequest,
            context: self.stack.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil,
            collectionView: self.collectionView,
            cellConfiguration: CompanyCellConfig(),
            supplementaryConfigurations: supplementaryViews
        )
    }

    // MARK: Collection view delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let company = self.coordinator![indexPath]
        let employeeVC = EmployeeViewController(stack: self.stack, company: company)
        self.navigationController?.pushViewController(employeeVC, animated: true)
    }
}
