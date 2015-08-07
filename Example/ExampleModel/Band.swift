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
import CoreData

public final class Band: NSManagedObject {

    @NSManaged public var name: String

    @NSManaged public var dateFounded: NSDate

    @NSManaged public var city: String

    @NSManaged public var genre: String

    @NSManaged public var albums: NSSet

    public convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("Band", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
    
    override public var description: String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        let foundedDateString = formatter.stringFromDate(self.dateFounded)
        
        return "Band: '\(self.name)', \(self.city), \(self.genre), \(foundedDateString)"
    }
}
