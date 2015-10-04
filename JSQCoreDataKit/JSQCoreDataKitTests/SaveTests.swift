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


class SaveTests: TestCase {

    func test_ThatSaveAndWait_WithoutChanges_IsIgnored() {

        // GIVEN: a stack and context without changes
        let stack = CoreDataStack(model: inMemoryModel)
        var didSave = false

        // WHEN: we attempt to save the context

        // THEN: the save operation is ignored
        saveContext(stack.context) { error in
            didSave = true
        }

        XCTAssertFalse(didSave, "Save should be ignored")
    }

    func test_ThatSaveAndWait_WithChanges_Succeeds() {

        // GIVEN: a stack and context with changes
        let stack = CoreDataStack(model: inMemoryModel)

        let _ = MyModel(context: stack.context)
        let _ = MyModel(context: stack.context)

        var didSave = false
        self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: stack.context) { (notification) -> Bool in
            didSave = true
            return true
        }

        // WHEN: we attempt to save the context

        // THEN: the save succeeds without an error
        saveContext(stack.context) { error in
            XCTAssertNil(error, "Save should not error")
        }

        self.waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")

            XCTAssertTrue(didSave, "Context should be saved")
        })
    }

    func test_ThatSaveAndWait_WithChanges_WithoutCompletionClosure_Succeeds() {

        // GIVEN: a stack and context with changes
        let stack = CoreDataStack(model: inMemoryModel)

        let _ = MyModel(context: stack.context)
        let _ = MyModel(context: stack.context)

        var didSave = false
        self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: stack.context) { (notification) -> Bool in
            didSave = true
            return true
        }

        // WHEN: we attempt to save the context

        // THEN: the save succeeds without an error
        saveContext(stack.context)
        
        self.waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")

            XCTAssertTrue(didSave, "Context should be saved")
        })
    }

    func test_ThatSaveAsync_WithoutChanges_ReturnsImmediately() {

        // GIVEN: a stack and context without changes
        let stack = CoreDataStack(model: inMemoryModel)
        var didSave = false

        // WHEN: we attempt to save the context asynchronously
        saveContext(stack.context, wait: false) { error in
            didSave = true
        }

        // THEN: the save operation is ignored
        XCTAssertFalse(didSave, "Save should be ignored")
    }

    func test_ThatSaveAsync_WithChanges_Succeeds() {

        // GIVEN: a stack and context with changes
        let stack = CoreDataStack(model: inMemoryModel)

        let _ = MyModel(context: stack.context)
        let _ = MyModel(context: stack.context)

        var didSave = false
        self.expectationForNotification(NSManagedObjectContextDidSaveNotification, object: stack.context) { (notification) -> Bool in
            didSave = true
            return true
        }

        let saveExpectation = self.expectationWithDescription("\(__FUNCTION__)")

        // WHEN: we attempt to save the context asynchronously
        saveContext(stack.context, wait: false) { error in

            // THEN: the save succeeds without an error
            XCTAssertNil(error, "Save should not error")

            saveExpectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didSave, "Context should be saved")
        })
    }
    
}
