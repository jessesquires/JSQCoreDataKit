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

import XCTest
import CoreData

import ExampleModel

@testable
import JSQCoreDataKit


class SaveResultTests: XCTestCase {

    func test_SaveResult_Error() {
        let success = CoreDataSaveResult.Success
        XCTAssertNil(success.error())

        let failure = CoreDataSaveResult.Failure(NSError(domain: "err", code: 0, userInfo: nil))
        XCTAssertNotNil(failure.error())
    }

    func test_SaveResult_Equality() {
        let success = CoreDataSaveResult.Success
        let failure = CoreDataSaveResult.Failure(NSError(domain: "err", code: 0, userInfo: nil))
        XCTAssertNotEqual(success, failure)
    }

    func test_SaveResult_Equality_Success() {
        let success1 = CoreDataSaveResult.Success
        let success2 = CoreDataSaveResult.Success
        XCTAssertEqual(success1, success2)
    }

    func test_SaveResult_Equality_Failure() {
        let err = NSError(domain: "err", code: 0, userInfo: nil)
        let failure1 = CoreDataSaveResult.Failure(err)
        let failure2 = CoreDataSaveResult.Failure(err)
        XCTAssertEqual(failure1, failure2)

        let failure3 = CoreDataSaveResult.Failure(NSError(domain: "err2", code: 2, userInfo: nil))
        XCTAssertNotEqual(failure1, failure3)
    }

    func test_SaveResult_Description() {
        print("\(__FUNCTION__)")

        let success = CoreDataSaveResult.Success
        print(success)

        let failure = CoreDataSaveResult.Failure(NSError(domain: "err", code: 0, userInfo: nil))
        print(failure)
    }
}
