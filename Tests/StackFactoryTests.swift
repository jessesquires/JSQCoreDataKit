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


class StackFactoryTests: TestCase {

    override func setUp() {
        cleanUp()
        super.setUp()
    }

    override func tearDown() {
        cleanUp()
        super.tearDown()
    }

    func test_ThatStackFactory_InitializesSuccessFully() {
        let factory = CoreDataStackFactory(model: inMemoryModel)
        XCTAssertEqual(factory.model, inMemoryModel)
        XCTAssertTrue(factory.options! == defaultStoreOptions)
    }

    func test_ThatStackFactory_CreatesStackInBackground_Successfully() {
        // GIVEN: a core data model
        let sqliteModel = CoreDataModel(name: modelName, bundle: modelBundle)

        // GIVEN: a factory
        let factory = CoreDataStackFactory(model: sqliteModel)

        var stack: CoreDataStack?
        let expectation = self.expectation(withDescription: #function)

        // WHEN: we create a stack in the background
        factory.createStack { (result: StackResult) in
            XCTAssertTrue(Thread.isMainThread(), "Factory completion handler should return on main thread")

            switch result {
            case .success(let s):
                stack = s
                XCTAssertNotNil(s)

            case .failure(let e):
                XCTFail("Error: \(e)")
            }

            expectation.fulfill()
        }

        // THEN: creating a stack succeeds
        waitForExpectations(withTimeout: defaultTimeout) { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        }

        XCTAssertNotNil(stack)

        validateStack(stack!, fromFactory: factory)
    }

    func test_ThatStackFactory_CreatesStackSynchronously_Successfully() {
        // GIVEN: a core data model
        let sqliteModel = CoreDataModel(name: modelName, bundle: modelBundle)

        // GIVEN: a factory
        let factory = CoreDataStackFactory(model: sqliteModel)

        // WHEN: we create a stack
        let result = factory.createStack()
        let stack = result.stack()

        XCTAssertNotNil(stack)
        XCTAssertNil(result.error())

        validateStack(stack!, fromFactory: factory)
    }

    func test_StackFactory_Equality() {
        let factory1 = CoreDataStackFactory(model: inMemoryModel)
        let factory2 = CoreDataStackFactory(model: inMemoryModel)
        XCTAssertEqual(factory1, factory2)

        let factory3 = CoreDataStackFactory(model: inMemoryModel, options: nil)
        XCTAssertNotEqual(factory1, factory3)

        let factory4 = CoreDataStackFactory(model: inMemoryModel, options: nil)
        XCTAssertEqual(factory3, factory4)

        let sqliteModel = CoreDataModel(name: modelName, bundle: modelBundle)
        let sqliteFactory = CoreDataStackFactory(model: sqliteModel)
        XCTAssertNotEqual(factory1, sqliteFactory)
    }

    // MARK: Helpers

    func validateStack(_ stack: CoreDataStack, fromFactory factory:CoreDataStackFactory) {
        XCTAssertEqual(stack.model, factory.model)

        XCTAssertNotNil(stack.storeCoordinator)
        XCTAssertEqual(stack.mainContext.persistentStoreCoordinator, stack.backgroundContext.persistentStoreCoordinator)

        XCTAssertEqual(stack.mainContext.name, "JSQCoreDataKit.CoreDataStack.context.main")
        XCTAssertEqual(stack.mainContext.concurrencyType, NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        XCTAssertNil(stack.mainContext.parent)
        XCTAssertNotNil(stack.mainContext.persistentStoreCoordinator)

        XCTAssertEqual(stack.backgroundContext.name, "JSQCoreDataKit.CoreDataStack.context.background")
        XCTAssertEqual(stack.backgroundContext.concurrencyType, NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        XCTAssertNil(stack.backgroundContext.parent)
        XCTAssertNotNil(stack.backgroundContext.persistentStoreCoordinator)
    }
    
}
