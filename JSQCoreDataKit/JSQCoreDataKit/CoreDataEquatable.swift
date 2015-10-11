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


/// :nodoc:
public func ==(lhs: CoreDataModel, rhs: CoreDataModel) -> Bool {
    return lhs.name == rhs.name
        && lhs.bundle.isEqual(rhs.bundle)
        && lhs.storeType == rhs.storeType
}


/// :nodoc:
public func ==(lhs: CoreDataStack, rhs: CoreDataStack) -> Bool {
    return lhs.model == rhs.model
}


/// :nodoc:
public func ==(lhs: CoreDataStackResult, rhs: CoreDataStackResult) -> Bool {
    switch (lhs, rhs) {
    case (let .Success(stack1), let .Success(stack2)):
        return stack1 == stack2

    case (let .Failure(error1), let .Failure(error2)):
        return error1 == error2

    default:
        return false
    }
}


/// :nodoc:
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


/// :nodoc:
public func==(lhs: CoreDataStackFactory, rhs: CoreDataStackFactory) -> Bool {
    return lhs.model == rhs.model
        && lhs.options == rhs.options
}


/// :nodoc:
public func ==(lhs: PersistentStoreOptions?, rhs: PersistentStoreOptions?) -> Bool {
    if lhs == nil && rhs == nil {
        return true
    }
    
    guard let lhs = lhs, let rhs = rhs else {
        return false
    }

    guard lhs.count == rhs.count else {
        return false
    }

    for (key, value) in lhs {
        guard let rhsValue = rhs[key] else {
            return false
        }

        if !rhsValue.isEqual(value) {
            return false
        }
    }

    return true
}
