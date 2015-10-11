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

@testable
import JSQCoreDataKit


class StackFactoryTests: TestCase {
    
    override func setUp() {
        let model = CoreDataModel(name: modelName, bundle: modelBundle)

        do {
            try model.removeExistingModelStore()
        } catch { }

        super.setUp()
    }

    func test_ThatStackFactory_InitializesSuccessFully() {
        let factory = CoreDataStackFactory(model: inMemoryModel)
        XCTAssertEqual(factory.model, inMemoryModel)
        XCTAssertTrue(factory.options! == DefaultStoreOptions)
    }

    func test_ThatStackFactory_CreatesStackInBackground_Successfully() {
        // GIVEN: a core data model
        let sqliteModel = CoreDataModel(name: modelName, bundle: modelBundle)

        // GIVEN: a factory
        let factory = CoreDataStackFactory(model: sqliteModel)

        var stack: CoreDataStack?
        let expectation = self.expectationWithDescription("\(__FUNCTION__)")

        // WHEN: we attempt to create a stack
        factory.createStackInBackground { (result: CoreDataStackResult) -> Void in
            XCTAssertTrue(NSThread.isMainThread())

            switch result {
            case .Success(let s):
                stack = s

            case .Failure(let e):
                XCTFail("Error: \(e)")
            }

            expectation.fulfill()
        }

        // THEN: creating a stack succeeds
        waitForExpectationsWithTimeout(10) { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        }

        XCTAssertNotNil(stack)
    }

    func test_StackFactory_Equality() {
        let factory1 = CoreDataStackFactory(model: inMemoryModel)
        let factory2 = CoreDataStackFactory(model: inMemoryModel)
        XCTAssertEqual(factory1, factory2)

        let factory3 = CoreDataStackFactory(model: inMemoryModel, options: nil)
        XCTAssertNotEqual(factory1, factory3)

        let sqliteModel = CoreDataModel(name: modelName, bundle: modelBundle)
        let sqliteFactory = CoreDataStackFactory(model: sqliteModel)
        XCTAssertNotEqual(factory1, sqliteFactory)
    }

    func test_StackFactory_Description() {
        print("\(__FUNCTION__)")

        let factory = CoreDataStackFactory(model: inMemoryModel)
        print(factory)
    }

}
