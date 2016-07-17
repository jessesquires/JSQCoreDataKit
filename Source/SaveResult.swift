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
public enum SaveResult: Equatable {

    /// The success result.
    case success

    /// The failure result, containing an `NSError` instance that describes the error.
    case failure(NSError)


    // MARK: Methods

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
