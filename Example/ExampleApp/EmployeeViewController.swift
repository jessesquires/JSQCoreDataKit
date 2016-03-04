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



class EmployeeViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var stack: CoreDataStack!

    var frc: NSFetchedResultsController?

    var company: Company!

    
    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        setupFRC()
    }


    // MARK: Actions

    @IBAction func didTapAddButton(sender: UIBarButtonItem) {
        stack.mainContext.performBlockAndWait {
            Employee.newEmployee(self.stack.mainContext, company: self.company)
            saveContext(self.stack.mainContext)
        }
    }

    @IBAction func didTapTrashButton(sender: UIBarButtonItem) {
        let backgroundChildContext = self.stack.childContext()

        backgroundChildContext.performBlockAndWait {
            let request = self.fetchRequest(backgroundChildContext)

            do {
                let objects = try fetch(request: request, inContext: backgroundChildContext)
                deleteObjects(objects, inContext: backgroundChildContext)
                saveContext(backgroundChildContext)
            } catch {
                print("Error deleting objects: \(error)")
            }
        }
    }
    

    // MARK: Helpers

    func fetchRequest(context: NSManagedObjectContext) -> FetchRequest<Employee> {
        let e = entity(name: Employee.entityName, context: context)
        let fetch = FetchRequest<Employee>(entity: e)
        fetch.predicate = NSPredicate(format: "company == %@", company)
        fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return fetch
    }

    func setupFRC() {
        let request = fetchRequest(self.stack.mainContext)

        self.frc = NSFetchedResultsController(fetchRequest: request,
            managedObjectContext: self.stack.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        self.frc?.delegate = self

        fetchData()
    }

    func fetchData() {
        do {
            try self.frc?.performFetch()
            tableView.reloadData()
        } catch {
            assertionFailure("Failed to fetch: \(error)")
        }
    }


    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.frc?.fetchedObjects?.count ?? 0
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let employee = self.frc?.objectAtIndexPath(indexPath) as! Employee
        cell.textLabel?.text = employee.name
        cell.detailTextLabel?.text = "$\(employee.salary).00"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return company.name
    }


    // MARK: Table view delegate

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let obj = frc?.objectAtIndexPath(indexPath) as! Employee
            deleteObjects([obj], inContext: self.stack.mainContext)
            saveContext(self.stack.mainContext)
        }
    }
    

    // MARK: Fetched results controller delegate

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    func controller(
        controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            switch type {
            case .Insert:
                tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                break
            }
    }

    func controller(
        controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

}
