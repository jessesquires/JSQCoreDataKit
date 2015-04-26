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
//  Copyright (c) 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import XCTest
import CoreData
import JSQCoreDataKit


class SaveTests: ModelTestCase {

    func test_ThatSaveAndWait_WithoutChanges_IsIgnored() {

        // GIVEN: a stack and context without changes
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        // WHEN: we attempt to save the context
        let result = saveContextAndWait(stack.managedObjectContext)

        // THEN: the save operation is ignored, save reports success and no error
        XCTAssertTrue(result.success)
        XCTAssertNil(result.error)
    }

    func test_ThatSaveAndWait_WithChanges_Succeeds() {

        // GIVEN: a stack and context with changes
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        MyModel(context: stack.managedObjectContext)
        MyModel(context: stack.managedObjectContext)

        var didSave = false
        self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: stack.managedObjectContext) { (notification) -> Bool in
            didSave = true
            return true
        }

        // WHEN: we attempt to save the context
        let saveResult = saveContextAndWait(stack.managedObjectContext)

        // THEN: the save succeeds without an error
        XCTAssertTrue(saveResult.success, "Save should succeed")
        XCTAssertNil(saveResult.error, "Save should not error")

        self.waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        })
    }

    func test_ThatSaveAsync_WithoutChanges_ReturnsImmediately() {

        // GIVEN: a stack and context without changes
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let saveExpectation = self.expectationWithDescription("\(__FUNCTION__)")

        // WHEN: we attempt to save the context asynchronously
        saveContext(stack.managedObjectContext, { (result: ContextSaveResult) -> Void in

            // THEN: the save operation is ignored, save reports success and no error
            XCTAssertTrue(result.success, "Save should succeed")
            XCTAssertNil(result.error, "Save should not error")

            saveExpectation.fulfill()
        })

        self.waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        })
    }

    func test_ThatSaveAsync_WithChanges_Succeeds() {

        // GIVEN: a stack and context with changes
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        MyModel(context: stack.managedObjectContext)
        MyModel(context: stack.managedObjectContext)

        var didSave = false
        self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: stack.managedObjectContext) { (notification) -> Bool in
            didSave = true
            return true
        }

        let saveExpectation = self.expectationWithDescription("\(__FUNCTION__)")

        // WHEN: we attempt to save the context asynchronously
        saveContext(stack.managedObjectContext, { (result: ContextSaveResult) -> Void in

            // THEN: the save succeeds without an error
            XCTAssertTrue(result.success, "Save should succeed")
            XCTAssertNil(result.error, "Save should not error")

            saveExpectation.fulfill()
        })

        self.waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
        })
    }
    
}
