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
//  Copyright © 2015 Jesse Squires
//  Released under an MIT license: https://opensource.org/licenses/MIT
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
public func ==(lhs: StackResult, rhs: StackResult) -> Bool {
    switch (lhs, rhs) {
    case (let .success(stack1), let .success(stack2)):
        return stack1 == stack2
        
    case (let .failure(error1), let .failure(error2)):
        return error1 == error2
        
    default:
        return false
    }
}


/// :nodoc:
public func ==(lhs: SaveResult, rhs: SaveResult) -> Bool {
    switch (lhs, rhs) {
    case (.success, .success):
        return true
        
    case (let .failure(error1), let .failure(error2)):
        return error1 == error2
        
    default:
        return false
    }
}


/// :nodoc:
public func ==(lhs: StoreType, rhs: StoreType) -> Bool {
    switch (lhs, rhs) {
    case let (.sqlite(left), .sqlite(right)) where left == right:
        return true
    case let (.binary(left), .binary(right)) where left == right:
        return true
    case (.inMemory, .inMemory):
        return true
    default:
        return false
    }
}


/// :nodoc:
public func ==(lhs: CoreDataStackFactory, rhs: CoreDataStackFactory) -> Bool {
    let equalModels = (lhs.model == rhs.model)
    
    if let lhsOptions = lhs.options, let rhsOptions = rhs.options {
        return equalModels
            && lhsOptions == rhsOptions
    }
    
    if lhs.options == nil && rhs.options == nil {
        return equalModels
    }
    
    return false
}


/// :nodoc:
public func ==(lhs: PersistentStoreOptions, rhs: PersistentStoreOptions) -> Bool {
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
