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



class CompanyViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var stack: CoreDataStack!

    var frc: NSFetchedResultsController?


    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        showSpinner()

        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let factory = CoreDataStackFactory(model: model)

        factory.createStackInBackground { (result: CoreDataStackResult) -> Void in
            switch result {
            case .Success(let s):
                self.stack = s
                self.setupFRC()

            case .Failure(let err):
                assertionFailure("Error creating stack: \(err)")
            }

            self.hideSpinner()
        }
    }


    // MARK: Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue" {
            let employeeVC = segue.destinationViewController as! EmployeeViewController
            let company = frc?.objectAtIndexPath(tableView.indexPathForSelectedRow!) as! Company
            employeeVC.stack = self.stack
            employeeVC.company = company
        }
    }


    // MARK: Helpers

    func fetchRequest(context: NSManagedObjectContext) -> FetchRequest<Company> {
        let e = entity(name: Company.entityName, context: context)
        let fetch = FetchRequest<Company>(entity: e)
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

    private func showSpinner() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
    }

    private func hideSpinner() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Add,
            target: self,
            action: "didTapAddButton:")
    }


    // MARK: Actions

    func didTapAddButton(sender: UIBarButtonItem) {
        stack.mainContext.performBlockAndWait {
            Company.newCompany(self.stack.mainContext)
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


    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.frc?.fetchedObjects?.count ?? 0
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let company = self.frc?.objectAtIndexPath(indexPath) as! Company
        cell.textLabel?.text = company.name
        cell.detailTextLabel?.text = "$\(company.profits).00"
        cell.accessoryType = .DisclosureIndicator
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Company"
    }


    // MARK: Table view delegate

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let obj = frc?.objectAtIndexPath(indexPath) as! Company
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
