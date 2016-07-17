//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://www.jessesquires.com/JSQCoreDataKit
//
//
//  GitHub
//  https://github.com/jessesquires/JSQCoreDataKit
//
//
//  License
//  Copyright © 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit
import CoreData

import JSQCoreDataKit

import ExampleModel


final class EmployeeViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var stack: CoreDataStack!
    var frc: NSFetchedResultsController<Employee>!
    var company: Company!


    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        setupFRC()
    }


    // MARK: Actions

    @IBAction func didTapAddButton(_ sender: UIBarButtonItem) {
        stack.mainContext.performAndWait {
            _ = Employee.newEmployee(self.stack.mainContext, company: self.company)
            saveContext(self.stack.mainContext)
        }
    }

    @IBAction func didTapTrashButton(_ sender: UIBarButtonItem) {
        let backgroundChildContext = stack.childContext()

        backgroundChildContext.performAndWait {
            let request = self.fetchRequest(backgroundChildContext)

            do {
                let objects = try backgroundChildContext.fetch(request: request)
                backgroundChildContext.delete(objects: objects)
                saveContext(backgroundChildContext)
            } catch {
                print("Error deleting objects: \(error)")
            }
        }
    }


    // MARK: Helpers

    func fetchRequest(_ context: NSManagedObjectContext) -> NSFetchRequest<Employee> {
        let fetch = NSFetchRequest<Employee>(entityName: Employee.entityName)
        fetch.predicate = Predicate(format: "company == %@", company)
        fetch.sortDescriptors = [SortDescriptor(key: "name", ascending: true)]
        return fetch
    }

    func setupFRC() {
        let request = fetchRequest(stack.mainContext)
        frc = NSFetchedResultsController(fetchRequest: request,
                                         managedObjectContext: stack.mainContext,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        frc.delegate = self
        fetchData()
    }

    func fetchData() {
        do {
            try frc.performFetch()
            tableView.reloadData()
        } catch {
            assertionFailure("Failed to fetch: \(error)")
        }
    }


    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc?.fetchedObjects?.count ?? 0
    }

    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let employee = frc.object(at: indexPath)
        cell.textLabel?.text = employee.name
        cell.detailTextLabel?.text = "$\(employee.salary).00"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return company.name
    }


    // MARK: Table view delegate

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let obj = frc.object(at: indexPath)
            stack.mainContext.delete(objects: [obj])
            saveContext(stack.mainContext)
        }
    }


    // MARK: Fetched results controller delegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: AnyObject,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
