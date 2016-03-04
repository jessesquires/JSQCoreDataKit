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


class StackResultTests: TestCase {
    
    func test_StackResult_Success() {
        let success = CoreDataStackResult.Success(inMemoryStack)
        XCTAssertNotNil(success.stack())
        XCTAssertNil(success.error())
    }

    func test_StackResult_Failure() {
        let failure = CoreDataStackResult.Failure(NSError(domain: "err", code: 0, userInfo: nil))
        XCTAssertNotNil(failure.error())
        XCTAssertNil(failure.stack())
    }

    func test_StackResult_Equality() {
        let success = CoreDataStackResult.Success(inMemoryStack)
        let failure = CoreDataStackResult.Failure(NSError(domain: "err", code: 0, userInfo: nil))
        XCTAssertNotEqual(success, failure)
    }

    func test_StackResult_Equality_Success() {
        let success1 = CoreDataStackResult.Success(inMemoryStack)
        let success2 = CoreDataStackResult.Success(inMemoryStack)
        XCTAssertEqual(success1, success2)

        let model = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .SQLite(DefaultDirectoryURL()))
        let factory = CoreDataStackFactory(model: model)
        let result = factory.createStack()
        let stack = result.stack()!
        let success3 = CoreDataStackResult.Success(stack)
        XCTAssertNotEqual(success1, success3)

        do {
            try model.removeExistingModelStore()
        } catch { }
    }

    func test_StackResult_Equality_Failure() {
        let err = NSError(domain: "err", code: 0, userInfo: nil)
        let failure1 = CoreDataStackResult.Failure(err)
        let failure2 = CoreDataStackResult.Failure(err)
        XCTAssertEqual(failure1, failure2)


        let failure3 = CoreDataStackResult.Failure(NSError(domain: "err3", code: 1, userInfo: nil))
        XCTAssertNotEqual(failure1, failure3)
    }

    func test_StackResult_Description() {
        print("\(__FUNCTION__)")

        let success = CoreDataStackResult.Success(inMemoryStack)
        print(success)

        let failure = CoreDataStackResult.Failure(NSError(domain: "err", code: 0, userInfo: nil))
        print(failure)
    }
    
}
