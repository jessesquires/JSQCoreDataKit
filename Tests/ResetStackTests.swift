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


class ResetStackTests: TestCase {

    func test_ThatMainContext_WithChanges_DoesNotHaveObjects_AfterReset() {
        // GIVEN: a stack and context with changes
        let stack = self.inMemoryStack
        generateCompaniesInContext(stack.mainContext, count: 3)

        let expectation = expectationWithDescription("\(#function)")

        // WHEN: we attempt to reset the stack
        stack.reset() { (result: StackResult) in
            if case .failure(let e) = result {
                XCTFail("Error while resetting the stack: \(e)")
            }
            expectation.fulfill()
        }

        // THEN: the reset succeeds and the contexts contain no objects
        waitForExpectationsWithTimeout(DefaultTimeout) { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        }

        XCTAssertEqual(stack.mainContext.registeredObjects.count, 0)
        XCTAssertEqual(stack.backgroundContext.registeredObjects.count, 0)
    }

    func test_ThatBackgroundContext_WithChanges_DoesNotHaveObjects_AfterReset() {
        // GIVEN: a stack and context with changes
        let stack = self.inMemoryStack
        generateCompaniesInContext(stack.backgroundContext, count: 3)

        let expectation = expectationWithDescription("\(#function)")

        // WHEN: we attempt to reset the stack
        stack.reset() { (result: StackResult) in
            if case .failure(let e) = result {
                XCTFail("Error while resetting the stack: \(e)")
            }
            expectation.fulfill()
        }

        // THEN: the reset succeeds and the contexts contain no objects
        waitForExpectationsWithTimeout(DefaultTimeout) { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        }

        XCTAssertEqual(stack.mainContext.registeredObjects.count, 0)
        XCTAssertEqual(stack.backgroundContext.registeredObjects.count, 0)
    }

    func test_ThatPersistentStore_WithChanges_DoesNotHaveObjects_AfterReset() {
        // GIVEN: a stack and persistent store with data
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let factory = CoreDataStackFactory(model: model)
        let stack = factory.createStack().stack()!

        generateCompaniesInContext(stack.mainContext, count: 3)
        saveContext(stack.mainContext)

        let request = FetchRequest<Company>(entity: entity(name: Company.entityName, context: stack.mainContext))

        let objectsBefore = try? stack.mainContext.countForFetchRequest(request)
        XCTAssertEqual(objectsBefore, 3)

        let expectation = expectationWithDescription("\(#function)")

        // WHEN: we attempt to reset the stack
        stack.reset() { (result: StackResult) in
            if case .failure(let e) = result {
                XCTFail("Error while resetting the stack: \(e)")
            }
            expectation.fulfill()
        }

        // THEN: the reset succeeds and the stack contains no managed objects
        waitForExpectationsWithTimeout(DefaultTimeout) { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        }

        let objectsAfter = try? stack.mainContext.countForFetchRequest(request)
        XCTAssertEqual(objectsAfter, 0)
    }
    
}
