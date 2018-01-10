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

/**
 A result object representing the result of saving an `NSManagedObjectContext`.
 */
public enum SaveResult {

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

extension SaveResult: Equatable {
    /// :nodoc:
    public static func == (lhs: SaveResult, rhs: SaveResult) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success):
            return true

        case (let .failure(error1), let .failure(error2)):
            return error1 == error2

        default:
            return false
        }
    }
}
