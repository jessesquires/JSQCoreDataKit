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
//  Copyright © 2015-present Jesse Squires
//  Released under an MIT license: https://opensource.org/licenses/MIT
//

import CoreData
import ExampleModel
@testable import JSQCoreDataKit
import XCTest

final class StackFactoryTests: TestCase {

    override func setUp() {
        self.cleanUp()
        super.setUp()
    }

    override func tearDown() {
        self.cleanUp()
        super.tearDown()
    }

    func test_ThatStackFactory_InitializesSuccessFully() {
        let factory = CoreDataStackProvider(model: self.inMemoryModel)
        XCTAssertEqual(factory.model, self.inMemoryModel)
        XCTAssertTrue(factory.options?[NSMigratePersistentStoresAutomaticallyOption] as! Bool)
        XCTAssertTrue(factory.options?[NSInferMappingModelAutomaticallyOption] as! Bool)
    }

    func test_ThatStackFactory_CreatesStackInBackground_Successfully() {
        // GIVEN: a core data model
        let sqliteModel = CoreDataModel(name: modelName, bundle: modelBundle)

        // GIVEN: a factory
        let factory = CoreDataStackProvider(model: sqliteModel)

        var stack: CoreDataStack?
        let expectation = self.expectation(description: #function)

        // WHEN: we create a stack in the background
        factory.createStack { result in
            XCTAssertTrue(Thread.isMainThread, "Factory completion handler should return on main thread")

            switch result {
            case .success(let success):
                stack = success
                XCTAssertNotNil(stack)

            case .failure(let error):
                XCTFail("Error: \(error)")
            }

            expectation.fulfill()
        }

        // THEN: creating a stack succeeds
        self.waitForExpectations(timeout: defaultTimeout) { error -> Void in
            XCTAssertNil(error, "Expectation should not error")
        }

        XCTAssertNotNil(stack)

        self.validateStack(stack!, fromFactory: factory)
    }

    func test_ThatStackFactory_CreatesStackSynchronously_Successfully() {
        // GIVEN: a core data model
        let sqliteModel = CoreDataModel(name: modelName, bundle: modelBundle)

        // GIVEN: a factory
        let factory = CoreDataStackProvider(model: sqliteModel)

        // WHEN: we create a stack
        let result = factory.createStack()
        let stack = try? result.get()

        XCTAssertNotNil(stack)

        self.validateStack(stack!, fromFactory: factory)
    }

    func test_StackFactory_Equality() {
        let factory1 = CoreDataStackProvider(model: self.inMemoryModel)
        let factory2 = CoreDataStackProvider(model: self.inMemoryModel)
        XCTAssertEqual(factory1, factory2)

        let factory3 = CoreDataStackProvider(model: self.inMemoryModel, options: nil)
        XCTAssertEqual(factory1, factory3)

        let factory4 = CoreDataStackProvider(model: self.inMemoryModel, options: nil)
        XCTAssertEqual(factory3, factory4)

        let sqliteModel = CoreDataModel(name: modelName, bundle: modelBundle)
        let sqliteFactory = CoreDataStackProvider(model: sqliteModel)
        XCTAssertNotEqual(factory1, sqliteFactory)
    }

    // MARK: Helpers

    func validateStack(_ stack: CoreDataStack, fromFactory factory: CoreDataStackProvider) {
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
