//
//  Created by Marius Serban
//  http://www.serbanmarius.com
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
//  Copyright © 2015 Marius Serban
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

        // WHEN: we attempt to reset the stack
        do {
            try resetStack(stack)
        } catch {
            XCTFail("Exception while resetting the stack: \(error)")
        }

        // THEN: the context contains no managed objects
        let numberOfObjects = stack.mainContext.registeredObjects.count
        XCTAssertEqual(numberOfObjects, 0)
    }

    func test_ThatBackgroundContext_WithChanges_DoesNotHaveObjects_AfterReset() {

        // GIVEN: a stack and context with changes
        let stack = self.inMemoryStack
        generateCompaniesInContext(stack.backgroundContext, count: 3)

        // WHEN: we attempt to reset the stack
        do {
            try resetStack(stack)
        } catch {
            XCTFail("Exception while resetting the stack: \(error)")
        }

        // THEN: the context contains no managed objects
        let numberOfObjects = stack.backgroundContext.registeredObjects.count
        XCTAssertEqual(numberOfObjects, 0)
    }

    func test_ThatPersistentStore_WithChanges_DoesNotHaveObjects_AfterReset() {

        // GIVEN: a stack and persistent store with changes
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let factory = CoreDataStackFactory(model: model)
        let stack: CoreDataStack! = factory.createStack().stack()

        generateCompaniesInContext(stack.backgroundContext, count: 3)
        saveContext(stack.backgroundContext)

        // WHEN: we attempt to reset the stack
        do {
            try resetStack(stack)
        } catch {
            XCTFail("Exception while resetting the stack: \(error)")
        }

        // THEN: the stack contains no managed objects
        var error: NSError?
        let request = FetchRequest<Company>(entity: entity(name: Company.entityName, context: stack.mainContext))
        let numberOfObjects = stack.backgroundContext.countForFetchRequest(request, error: &error)
        XCTAssertNil(error)
        XCTAssertEqual(numberOfObjects, 0)
    }


}
