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

import Foundation
import CoreData
import JSQCoreDataKit

public final class Company: NSManagedObject, CoreDataEntityProtocol {

    // MARK: CoreDataEntityProtocol

    public static let defaultSortDescriptors = [NSSortDescriptor(key: "profits", ascending: true),
                                                NSSortDescriptor(key: "name", ascending: true) ]

    // MARK: Properties

    @NSManaged public var name: String
    @NSManaged public var dateFounded: Date
    @NSManaged public var profits: NSDecimalNumber
    @NSManaged public var employees: NSSet

    // MARK: Init

    public init(context: NSManagedObjectContext,
                name: String,
                dateFounded: Date,
                profits: NSDecimalNumber) {
        super.init(entity: Company.entity(context: context), insertInto: context)
        self.name = name
        self.dateFounded = dateFounded
        self.profits = profits
    }

    public class func newCompany(_ context: NSManagedObjectContext) -> Company {
        let name = "Company " + String(UUID().uuidString.characters.split { $0 == "-" }.first!)
        return Company(context: context,
                       name: name,
                       dateFounded: Date.distantPast,
                       profits: NSDecimalNumber(value: arc4random_uniform(1_000_000)))
    }

    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
