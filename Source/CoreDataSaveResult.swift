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
 A result object representing the result of saving an `NSManagedObjectContext`.
 */
public enum CoreDataSaveResult: CustomStringConvertible, Equatable {

    /// The success result.
    case Success

    /// The failure result, containing an `NSError` instance that describes the error.
    case Failure(NSError)


    // MARK: Methods

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
            var str = "<\(CoreDataSaveResult.self): "
            switch self {
            case .Success:
                str += ".Success"
            case .Failure(let e):
                str += ".Failure(\(e))"
            }
            return str + ">"
        }
    }
}
