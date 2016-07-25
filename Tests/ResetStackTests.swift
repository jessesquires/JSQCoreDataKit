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

final class ResetStackTests: TestCase {

    func test_ThatMainContext_WithChanges_DoesNotHaveObjects_AfterReset() {
        // GIVEN: a stack and context with changes
        let context = inMemoryStack.mainContext
        context.performAndWait {
            self.generateCompaniesInContext(context, count: 3)
        }

        let expectation = self.expectation(description: #function)

        // WHEN: we attempt to reset the stack
        inMemoryStack.reset() { (result: StackResult) in
            if case .failure(let e) = result {
                XCTFail("Error while resetting the stack: \(e)")
            }
            expectation.fulfill()
        }

        // THEN: the reset succeeds and the contexts contain no objects
        waitForExpectations(timeout: defaultTimeout) { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        }

        XCTAssertEqual(inMemoryStack.mainContext.registeredObjects.count, 0)
        XCTAssertEqual(inMemoryStack.backgroundContext.registeredObjects.count, 0)
    }

    func test_ThatBackgroundContext_WithChanges_DoesNotHaveObjects_AfterReset() {
        // GIVEN: a stack and context with changes
        let context = inMemoryStack.backgroundContext
        context.performAndWait {
            self.generateCompaniesInContext(context, count: 3)
        }

        let expectation = self.expectation(description: #function)

        // WHEN: we attempt to reset the stack
        inMemoryStack.reset() { (result: StackResult) in
            if case .failure(let e) = result {
                XCTFail("Error while resetting the stack: \(e)")
            }
            expectation.fulfill()
        }

        // THEN: the reset succeeds and the contexts contain no objects
        waitForExpectations(timeout: defaultTimeout) { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        }

        XCTAssertEqual(inMemoryStack.mainContext.registeredObjects.count, 0)
        XCTAssertEqual(inMemoryStack.backgroundContext.registeredObjects.count, 0)
    }

    func test_ThatPersistentStore_WithChanges_DoesNotHaveObjects_AfterReset() {
        // GIVEN: a stack and persistent store with data
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let factory = CoreDataStackFactory(model: model)
        let stack = factory.createStack().stack()!
        let context = stack.mainContext

        context.performAndWait {
            self.generateCompaniesInContext(context, count: 3)
        }
        saveContext(context)

        let request = Company.fetchRequest
        let objectsBefore = try? context.count(for: request)
        XCTAssertEqual(objectsBefore, 3)

        let expectation = self.expectation(description: #function)

        // WHEN: we attempt to reset the stack
        stack.reset() { (result: StackResult) in
            if case .failure(let e) = result {
                XCTFail("Error while resetting the stack: \(e)")
            }
            expectation.fulfill()
        }

        // THEN: the reset succeeds and the stack contains no managed objects
        waitForExpectations(timeout: defaultTimeout) { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        }

        let objectsAfter = try? stack.mainContext.count(for: request)
        XCTAssertEqual(objectsAfter, 0)
    }
}
