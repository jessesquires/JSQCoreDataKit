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
        super.init(entity: Self.entity(context: context), insertInto: context)
        self.name = name
        self.dateFounded = dateFounded
        self.profits = profits
    }

    @objc
    override private init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public static func newCompany(_ context: NSManagedObjectContext) -> Company {
        let name = "Company " + String(UUID().uuidString.split { $0 == "-" }.first!)
        return Self(context: context,
                    name: name,
                    dateFounded: Date.distantPast,
                    profits: NSDecimalNumber(value: Int.random(in: 0...1_000_000)))
    }
}
