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

    public init(context: NSManagedObjectContext,
        title: String,
        dateReleased: NSDate,
        price: NSDecimalNumber,
        band: Band) {

            let entity = NSEntityDescription.entityForName(ExampleModelEntity.Album, inManagedObjectContext: context)!
            super.init(entity: entity, insertIntoManagedObjectContext: context)
            
            self.title = title
            self.dateReleased = dateReleased
            self.price = price
            self.band = band
    }
}
