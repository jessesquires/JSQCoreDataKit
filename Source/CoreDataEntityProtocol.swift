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

import CoreData
import Foundation


/// Describes an entity in Core Data.
public protocol CoreDataEntityProtocol: class {

    /// The name of the entity.
    static var entityName: String { get }

    /// The default sort descriptors for a fetch request.
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}


public extension CoreDataEntityProtocol where Self: NSManagedObject {

    /// Returns a default entity name for this managed object based on its class name.
    public static var entityName: String {
        return "\(Self.self)"
    }

    /// Returns a new fetch request with `defaultSortDescriptors`.
    public static var fetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request as! NSFetchRequest<Self>
    }

    /// Returns the entity with the specified name from the managed object model associated
    /// with the specified managed object context’s persistent store coordinator.
    ///
    /// - parameter context: The managed object context to use.
    ///
    /// - returns: Returns the entity description for this managed object.
    public static func entity(context: NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }
}
