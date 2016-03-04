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

public final class Employee: NSManagedObject {

    static public let entityName = "Employee"

    @NSManaged public var name: String

    @NSManaged public var birthDate: NSDate

    @NSManaged public var salary: NSDecimalNumber

    @NSManaged public var company: Company?

    public init(context: NSManagedObjectContext,
        name: String,
        birthDate: NSDate,
        salary: NSDecimalNumber,
        company: Company? = nil) {
            let entity = NSEntityDescription.entityForName(Employee.entityName, inManagedObjectContext: context)!
            super.init(entity: entity, insertIntoManagedObjectContext: context)

            self.name = name
            self.birthDate = birthDate
            self.salary = salary
            self.company = company
    }

    public class func newEmployee(context: NSManagedObjectContext, company: Company? = nil) -> Employee {
        let name = "Employee " + String(NSUUID().UUIDString.characters.split { $0 == "-" }.first!)

        return Employee(context: context,
            name: name,
            birthDate: NSDate.distantPast(),
            salary: NSDecimalNumber(unsignedInt: arc4random_uniform(100_000)),
            company: company)
    }

    @objc
    private override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
}
