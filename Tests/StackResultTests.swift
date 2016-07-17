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

final class StackResultTests: TestCase {

    func test_StackResult_Success() {
        let success = StackResult.success(inMemoryStack)
        XCTAssertNotNil(success.stack())
        XCTAssertNil(success.error())
    }

    func test_StackResult_Failure() {
        let failure = StackResult.failure(NSError(domain: "err", code: 0, userInfo: nil))
        XCTAssertNotNil(failure.error())
        XCTAssertNil(failure.stack())
    }

    func test_StackResult_Equality() {
        let success = StackResult.success(inMemoryStack)
        let failure = StackResult.failure(NSError(domain: "err", code: 0, userInfo: nil))
        XCTAssertNotEqual(success, failure)
    }

    func test_StackResult_Equality_Success() {
        let success1 = StackResult.success(inMemoryStack)
        let success2 = StackResult.success(inMemoryStack)
        XCTAssertEqual(success1, success2)

        let model = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .sqlite(defaultDirectoryURL()))
        let factory = CoreDataStackFactory(model: model)
        let result = factory.createStack()
        let stack = result.stack()!
        let success3 = StackResult.success(stack)
        XCTAssertNotEqual(success1, success3)

        _ = try? model.removeExistingStore()
    }

    func test_StackResult_Equality_Failure() {
        let err = NSError(domain: "err", code: 0, userInfo: nil)
        let failure1 = StackResult.failure(err)
        let failure2 = StackResult.failure(err)
        XCTAssertEqual(failure1, failure2)


        let failure3 = StackResult.failure(NSError(domain: "err3", code: 1, userInfo: nil))
        XCTAssertNotEqual(failure1, failure3)
    }
}
