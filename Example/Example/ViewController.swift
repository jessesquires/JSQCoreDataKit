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
//  Copyright (c) 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation
import UIKit
import CoreData
import JSQCoreDataKit
import ExampleModel

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var albums: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch albums from persistent store
        self.albums = self.fetchAlbums()
        
        // Refresh UI
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albums!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("albumCellReuseIdentifier") as? UITableViewCell
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "albumCellReuseIdentifier")
        }
        
        var album = self.albums![indexPath.row] as! Album
        
        cell!.textLabel!.text = album.description
        cell!.detailTextLabel!.text = album.band.description
        
        return cell!
    }
    
    // MARK: - Navigation
    
    override internal func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destVC = segue.destinationViewController as! DetailViewController
        let cell = sender as? UITableViewCell
        let indexPath = self.tableView.indexPathForCell(cell!)
        destVC.detailItem = self.albums![indexPath!.row] as! Album
    }
    
    // MARK: - IBActions
    
    @IBAction func tapOnPlusBarButtonItem(sender: UIBarButtonItem) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Create some fake data
        for var i = 0; i < 10; i++ {
            var fakeBand = newFakeBand(appDelegate.stack!.managedObjectContext)
            var fakeAlbum =  newFakeAlbum(appDelegate.stack!.managedObjectContext, fakeBand)
        }
        
        // Save data to persistent store
        saveContextAndWait(appDelegate.stack!.managedObjectContext)
        
        // Update UI
        self.albums = self.fetchAlbums()
        self.tableView.reloadData()
    }
    
    // MARK: - Private
    
    func fetchAlbums() -> [Album] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let albumEntity = entity(name: "Album", context: appDelegate.stack!.managedObjectContext)
        let request = FetchRequest<Album>(entity: albumEntity)
        
        // JSQCoreDataKit POWER FETCH ACTION!
        let result = fetch(request: request, inContext: appDelegate.stack!.managedObjectContext)
        if !result.success {
            println("Error = \(result.error)")
        }
        return result.objects
    }
    
}

