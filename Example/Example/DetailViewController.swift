//
//  DetailViewController.swift
//  Example
//
//  Created by  Artem Kalinovsky on 8/7/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

import Foundation
import UIKit
import ExampleModel
import CoreData
import JSQCoreDataKit

class DetailViewController: UIViewController {
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    internal var detailItem: Album!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.albumTitleLabel.text! = self.detailItem.description
        self.artistLabel.text! = self.detailItem.band.description
    }
    
    @IBAction func tapOnTrashBarButtonItem(sender: UIBarButtonItem) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // JSQCoreDataKit POWER DELETE ACTION!
        deleteObjects([detailItem], inContext: appDelegate.stack!.managedObjectContext)
        
        // JSQCoreDataKit saving changes in ManagedObjectContext to PersistentStoreCoordinator
        saveContextAndWait(appDelegate.stack!.managedObjectContext)
        
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}