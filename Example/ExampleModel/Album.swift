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

public final class Album: NSManagedObject {

    @NSManaged public var title: String

    @NSManaged public var dateReleased: NSDate

    @NSManaged public var price: NSDecimalNumber

    @NSManaged public var band: Band

    public convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName("Album", inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
    
    override public var description: String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        let releasedDateString = formatter.stringFromDate(self.dateReleased)
        
        return "Album: '\(self.title)', \(releasedDateString), $\(self.price.stringValue)"
    }
    
}
