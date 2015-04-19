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
import JSQCoreDataKit


public final class Band: NSManagedObject, CoreDataEntityType {

    public static let entityName: String = "Band"

    @NSManaged public var name: String

    @NSManaged public var dateFounded: NSDate

    @NSManaged public var city: String

    @NSManaged public var genre: String

    @NSManaged public var albums: NSSet

    public init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(Band.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
}
