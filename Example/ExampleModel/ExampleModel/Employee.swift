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

public final class Employee: NSManagedObject, CoreDataEntityProtocol {

    // MARK: CoreDataEntityProtocol

    public static let defaultSortDescriptors = [ SortDescriptor(key: "name", ascending: true) ]

    // MARK: Properties

    @NSManaged public var name: String
    @NSManaged public var birthDate: Date
    @NSManaged public var salary: NSDecimalNumber
    @NSManaged public var company: Company?

    // MARK: Init

    public init(context: NSManagedObjectContext,
                name: String,
                birthDate: Date,
                salary: NSDecimalNumber,
                company: Company? = nil) {
        super.init(entity: Employee.entity(context: context), insertInto: context)
        self.name = name
        self.birthDate = birthDate
        self.salary = salary
        self.company = company
    }

    public class func newEmployee(_ context: NSManagedObjectContext, company: Company? = nil) -> Employee {
        let name = "Employee " + String(UUID().uuidString.characters.split { $0 == "-" }.first!)
        return Employee(context: context,
                        name: name,
                        birthDate: Date.distantPast,
                        salary: NSDecimalNumber(value: arc4random_uniform(100_000)),
                        company: company)
    }

    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
