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

// swiftlint:disable force_try

final class ResetStackTests: TestCase {

    func test_ThatMainContext_WithChanges_DoesNotHaveObjects_AfterReset() {
        // GIVEN: a stack and context with changes
        let context = self.inMemoryStack.mainContext
        context.performAndWait {
            self.generateCompaniesInContext(context, count: 3)
        }

        let expectation = self.expectation(description: #function)

        // WHEN: we attempt to reset the stack
        self.inMemoryStack.reset { result in
            if case .failure(let error) = result {
                XCTFail("Error while resetting the stack: \(error)")
            }
            expectation.fulfill()
        }

        // THEN: the reset succeeds and the contexts contain no objects
        self.waitForExpectations(timeout: defaultTimeout) { error -> Void in
            XCTAssertNil(error, "Expectation should not error")
        }

        XCTAssertEqual(self.inMemoryStack.mainContext.registeredObjects.count, 0)
        XCTAssertEqual(self.inMemoryStack.backgroundContext.registeredObjects.count, 0)
    }

    func test_ThatBackgroundContext_WithChanges_DoesNotHaveObjects_AfterReset() {
        // GIVEN: a stack and context with changes
        let context = self.inMemoryStack.backgroundContext
        context.performAndWait {
            self.generateCompaniesInContext(context, count: 3)
        }

        let expectation = self.expectation(description: #function)

        // WHEN: we attempt to reset the stack
        self.inMemoryStack.reset { result in
            if case .failure(let error) = result {
                XCTFail("Error while resetting the stack: \(error)")
            }
            expectation.fulfill()
        }

        // THEN: the reset succeeds and the contexts contain no objects
        self.waitForExpectations(timeout: defaultTimeout) { error -> Void in
            XCTAssertNil(error, "Expectation should not error")
        }

        XCTAssertEqual(self.inMemoryStack.mainContext.registeredObjects.count, 0)
        XCTAssertEqual(self.inMemoryStack.backgroundContext.registeredObjects.count, 0)
    }

    func test_ThatPersistentStore_WithChanges_DoesNotHaveObjects_AfterReset() {
        // GIVEN: a stack and persistent store with data
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let factory = CoreDataStackProvider(model: model)
        let stack = try! factory.createStack().get()
        let context = stack.mainContext

        context.performAndWait {
            self.generateCompaniesInContext(context, count: 3)
        }
        context.saveSync()

        let request = Company.fetchRequest
        let objectsBefore = try? context.count(for: request)
        XCTAssertEqual(objectsBefore, 3)

        let expectation = self.expectation(description: #function)

        // WHEN: we attempt to reset the stack
        stack.reset { result in
            if case .failure(let error) = result {
                XCTFail("Error while resetting the stack: \(error)")
            }
            expectation.fulfill()
        }

        // THEN: the reset succeeds and the stack contains no managed objects
        self.waitForExpectations(timeout: defaultTimeout) { error -> Void in
            XCTAssertNil(error, "Expectation should not error")
        }

        let objectsAfter = try? stack.mainContext.count(for: request)
        XCTAssertEqual(objectsAfter, 0)
    }
}

// swiftlint:enable force_try
