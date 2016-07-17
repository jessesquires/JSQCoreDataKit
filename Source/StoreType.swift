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


/// Describes a Core Data persistent store type.
public enum StoreType: CustomStringConvertible, Equatable {

    /// The SQLite database store type. The associated file URL specifies the directory for the store.
    case sqlite(URL)

    /// The binary store type. The associated file URL specifies the directory for the store.
    case binary(URL)

    /// The in-memory store type.
    case inMemory


    // MARK: Properties

    /// Returns the type string description for the store type.
    public var type: String {
        get {
            switch self {
            case .sqlite: return NSSQLiteStoreType
            case .binary: return NSBinaryStoreType
            case .inMemory: return NSInMemoryStoreType
            }
        }
    }


    // MARK: Methods

    /**
     - note: If the store is in-memory, then this value will be `nil`.
     - returns: The file URL specifying the directory in which the store is located.
     */
    public func storeDirectory() -> URL? {
        switch self {
        case let .sqlite(url): return url
        case let .binary(url): return url
        case .inMemory: return nil
        }
    }


    // MARK: CustomStringConvertible

    /// :nodoc:
    public var description: String {
        get {
            return "<\(StoreType.self): \(type); directory=\(storeDirectory()?.lastPathComponent)>"
        }
    }
}
