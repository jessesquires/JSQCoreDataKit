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


/**
- parameter lhs: A `StoreType` instance.
- parameter rhs: A `StoreType` instance.

- returns: True if `lhs` is equal to `rhs`, false otherwise.
*/
public func ==(lhs: StoreType, rhs: StoreType) -> Bool {
    switch (lhs, rhs) {
    case let (.SQLite(left), .SQLite(right)) where left == right:
        return true
    case let (.Binary(left), .Binary(right)) where left == right:
        return true
    case (.InMemory, .InMemory):
        return true
    default:
        return false
    }
}


/// Describes a Core Data persistent store type.
public enum StoreType: CustomStringConvertible, Equatable {

    /// The SQLite database store type. The associated file URL specifies the directory for the store.
    case SQLite (NSURL)

    /// The binary store type. The associated file URL specifies the directory for the store.
    case Binary (NSURL)

    /// The in-memory store type.
    case InMemory

    /**
    - returns: The file URL specifying the directory in which the store is located.
    - Note: If the store is in-memory, then this value will be `nil`.
    */
    public func storeDirectory() -> NSURL? {
        switch self {
        case let .SQLite(url): return url
        case let .Binary(url): return url
        case .InMemory: return nil
        }
    }

    /// :nodoc:
    public var description: String {
        get {
            switch self {
            case .SQLite: return NSSQLiteStoreType
            case .Binary: return NSBinaryStoreType
            case .InMemory: return NSInMemoryStoreType
            }
        }
    }
}
