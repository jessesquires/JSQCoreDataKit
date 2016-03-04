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
public enum CoreDataStackResult: CustomStringConvertible, Equatable {

    /// The success result, containing the successfully initialized `CoreDataStack`.
    case Success(CoreDataStack)

    /// The failure result, containing an `NSError` instance that describes the error.
    case Failure(NSError)


    // MARK: Methods

    /**
    - returns: The result's `CoreDataStack` if `.Success`, otherwise `nil`.
    */
    public func stack() -> CoreDataStack? {
        if case .Success(let stack) = self {
            return stack
        }
        return nil
    }

    /**
     - returns: The result's `NSError` if `.Failure`, otherwise `nil`.
     */
    public func error() -> NSError? {
        if case .Failure(let error) = self {
            return error
        }
        return nil
    }


    // MARK: CustomStringConvertible

    /// :nodoc:
    public var description: String {
        get {
            var str = "<\(CoreDataStackResult.self): "
            switch self {
            case .Success(let s):
                str += ".Success(\(s)"
            case .Failure(let e):
                str += ".Failure(\(e))"
            }
            return str + ">"
        }
    }
}
