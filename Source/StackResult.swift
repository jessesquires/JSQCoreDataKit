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


/**
 A result object representing the result of creating a `CoreDataStack` via a `CoreDataStackFactory`.
 */
public enum StackResult: Equatable {

    /// The success result, containing the successfully initialized `CoreDataStack`.
    case success(CoreDataStack)

    /// The failure result, containing an `NSError` instance that describes the error.
    case failure(NSError)


    // MARK: Methods

    /**
     - returns: The result's `CoreDataStack` if `.Success`, otherwise `nil`.
     */
    public func stack() -> CoreDataStack? {
        if case .success(let stack) = self {
            return stack
        }
        return nil
    }

    /**
     - returns: The result's `NSError` if `.Failure`, otherwise `nil`.
     */
    public func error() -> NSError? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}
