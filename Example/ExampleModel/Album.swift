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


public final class Album: NSManagedObject, CoreDataEntityType {

    public static let entityName: String = "Album"

    @NSManaged public var title: String

    @NSManaged public var dateReleased: NSDate

    @NSManaged public var price: NSDecimalNumber

    @NSManaged public var band: Band

    public init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName(Album.entityName, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
}
