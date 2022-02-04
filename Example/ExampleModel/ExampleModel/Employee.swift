//
//  Created by Jesse Squires
//  https://www.jessesquires.com
//
//
//  Documentation
//  https://jessesquires.github.io/JSQCoreDataKit
//
//
//  GitHub
//  https://github.com/jessesquires/JSQCoreDataKit
//
//
//  License
//  Copyright © 2015-present Jesse Squires
//  Released under an MIT license: https://opensource.org/licenses/MIT
//

import CoreData
import Foundation
import JSQCoreDataKit

public final class Employee: NSManagedObject, CoreDataEntityProtocol {

    // MARK: CoreDataEntityProtocol

    public static let defaultSortDescriptors = [ NSSortDescriptor(key: "name", ascending: true) ]

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
        super.init(entity: Self.entity(context: context), insertInto: context)
        self.name = name
        self.birthDate = birthDate
        self.salary = salary
        self.company = company
    }

    @objc
    override private init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public static func newEmployee(_ context: NSManagedObjectContext, company: Company? = nil) -> Employee {
        let name = "Employee " + String(UUID().uuidString.split { $0 == "-" }.first!)
        return Employee(context: context,
                        name: name,
                        birthDate: Date.distantPast,
                        salary: NSDecimalNumber(value: Int.random(in: 0...100_000)),
                        company: company)
    }

    public static func fetchRequest(for company: Company) -> NSFetchRequest<Employee> {
        let fetch = self.fetchRequest
        fetch.predicate = NSPredicate(format: "company == %@", company)
        return fetch
    }
}
