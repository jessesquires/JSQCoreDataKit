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
@testable import JSQCoreDataKit
import XCTest

final class SaveTests: TestCase {

    func test_ThatSaveAndWait_WithoutChanges_CompletionHandlerIsNotCalled() {
        // GIVEN: a stack and context without changes
        var didCallCompletion = false

        // WHEN: we attempt to save the context

        // THEN: the save operation is ignored
        self.inMemoryStack.mainContext.saveSync { _ in
            didCallCompletion = true
        }

        XCTAssertFalse(didCallCompletion, "Save should be ignored")
    }

    func test_ThatSaveAndWait_WithChangesSucceeds_CompletionHandlerIsCalled() {
        // GIVEN: a stack and context with changes
        let context = self.inMemoryStack.mainContext
        context.performAndWait {
            self.generateCompaniesInContext(context, count: 3)
        }

        var didSaveMain = false
        self.expectation(forNotification: .NSManagedObjectContextDidSave,
                         object: self.inMemoryStack.mainContext) { _ -> Bool in
            didSaveMain = true
            return true
        }

        var didUpdateBackground = false
        self.expectation(forNotification: .NSManagedObjectContextObjectsDidChange,
                         object: self.inMemoryStack.backgroundContext) { _ -> Bool in
            didUpdateBackground = true
            return true
        }

        let saveExpectation = self.expectation(description: #function)

        // WHEN: we attempt to save the context
        self.inMemoryStack.mainContext.saveSync { result in

            // THEN: the save succeeds without an error
            XCTAssertNotNil(try? result.get(), "Save should not error")
            saveExpectation.fulfill()
        }

        // THEN: then the main and background contexts are saved and the completion handler is called
        self.waitForExpectations(timeout: defaultTimeout) { error -> Void in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didSaveMain, "Main context should be saved")
            XCTAssertTrue(didUpdateBackground, "Background context should be updated")
        }
    }

    func test_ThatSaveAndWait_WithChanges_WithoutCompletionClosure_Succeeds() {
        // GIVEN: a stack and context with changes
        let context = self.inMemoryStack.mainContext
        context.performAndWait {
            self.generateCompaniesInContext(context, count: 3)
        }

        var didSaveMain = false
        self.expectation(forNotification: .NSManagedObjectContextDidSave,
                         object: self.inMemoryStack.mainContext) { _ -> Bool in
            didSaveMain = true
            return true
        }

        var didUpdateBackground = false
        self.expectation(forNotification: .NSManagedObjectContextObjectsDidChange,
                         object: self.inMemoryStack.backgroundContext) { _ -> Bool in
            didUpdateBackground = true
            return true
        }

        // WHEN: we attempt to save the context

        // THEN: the save succeeds without an error
        self.inMemoryStack.mainContext.saveSync()

        // THEN: then the main and background contexts are saved
        self.waitForExpectations(timeout: defaultTimeout) { error -> Void in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didSaveMain, "Main context should be saved")
            XCTAssertTrue(didUpdateBackground, "Background context should be updated")
        }
    }

    func test_ThatSaveAsync_WithoutChanges_ReturnsImmediately() {
        // GIVEN: a stack and context without changes
        var didCallCompletion = false

        // WHEN: we attempt to save the context asynchronously
        self.inMemoryStack.mainContext.saveAsync { _ in
            didCallCompletion = true
        }

        // THEN: the save operation is ignored
        XCTAssertFalse(didCallCompletion, "Save should be ignored")
    }

    func test_ThatSaveAsync_WithChanges_Succeeds() {
        // GIVEN: a stack and context with changes
        let context = self.inMemoryStack.mainContext
        context.performAndWait {
            self.generateCompaniesInContext(context, count: 3)
        }

        var didSaveMain = false
        self.expectation(forNotification: .NSManagedObjectContextDidSave,
                         object: self.inMemoryStack.mainContext) { _ -> Bool in
            didSaveMain = true
            return true
        }

        var didUpdateBackground = false
        self.expectation(forNotification: .NSManagedObjectContextObjectsDidChange,
                         object: self.inMemoryStack.backgroundContext) { _ -> Bool in
            didUpdateBackground = true
            return true
        }

        let saveExpectation = self.expectation(description: #function)

        // WHEN: we attempt to save the context asynchronously
        self.inMemoryStack.mainContext.saveAsync { result in

            // THEN: the save succeeds without an error
            XCTAssertNotNil(try? result.get(), "Save should not error")
            saveExpectation.fulfill()
        }

        // THEN: then the main and background contexts are saved and the completion handler is called
        self.waitForExpectations(timeout: defaultTimeout) { error -> Void in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didSaveMain, "Main context should be saved")
            XCTAssertTrue(didUpdateBackground, "Background context should be updated")
        }
    }

    func test_ThatSavingChildContext_SucceedsAndSavesParentMainContext() {
        // GIVEN: a stack and child context with changes
        let childContext = self.inMemoryStack.childContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.performAndWait {
            self.generateCompaniesInContext(childContext, count: 3)
        }

        var didSaveChild = false
        self.expectation(forNotification: .NSManagedObjectContextDidSave,
                         object: childContext) { _ -> Bool in
            didSaveChild = true
            return true
        }

        var didSaveMain = false
        self.expectation(forNotification: .NSManagedObjectContextDidSave,
                         object: self.inMemoryStack.mainContext) { _ -> Bool in
            didSaveMain = true
            return true
        }

        var didUpdateBackground = false
        self.expectation(forNotification: .NSManagedObjectContextObjectsDidChange,
                         object: self.inMemoryStack.backgroundContext) { _ -> Bool in
            didUpdateBackground = true
            return true
        }

        let saveExpectation = self.expectation(description: #function)

        // WHEN: we attempt to save the context
        childContext.saveSync { result in

            // THEN: the save succeeds without an error
            XCTAssertNotNil(try? result.get(), "Save should not error")
            saveExpectation.fulfill()
        }

        // THEN: then all contexts are saved, synchronized and the completion handler is called
        self.waitForExpectations(timeout: defaultTimeout) { error -> Void in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didSaveChild, "Child context should be saved")
            XCTAssertTrue(didSaveMain, "Main context should be saved")
            XCTAssertTrue(didUpdateBackground, "Background context should be updated")
        }
    }

    func test_ThatSavingChildContext_SucceedsAndSavesParentBackgroundContext() {
        // GIVEN: a stack and child context with changes
        let childContext = self.inMemoryStack.childContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.performAndWait {
            self.generateCompaniesInContext(childContext, count: 3)
        }

        var didSaveChild = false
        self.expectation(forNotification: .NSManagedObjectContextDidSave,
                         object: childContext) { _ -> Bool in
            didSaveChild = true
            return true
        }

        var didSaveBackground = false
        self.expectation(forNotification: .NSManagedObjectContextDidSave,
                         object: self.inMemoryStack.backgroundContext) { _ -> Bool in
            didSaveBackground = true
            return true
        }

        var didUpdateMain = false
        self.expectation(forNotification: .NSManagedObjectContextObjectsDidChange,
                         object: self.inMemoryStack.mainContext) { _ -> Bool in
            didUpdateMain = true
            return true
        }

        let saveExpectation = self.expectation(description: #function)

        // WHEN: we attempt to save the context
        childContext.saveSync { result in

            // THEN: the save succeeds without an error
            XCTAssertNotNil(try? result.get(), "Save should not error")
            saveExpectation.fulfill()
        }

        // THEN: then all contexts are saved, synchronized and the completion handler is called
        self.waitForExpectations(timeout: defaultTimeout) { error -> Void in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didSaveChild, "Child context should be saved")
            XCTAssertTrue(didSaveBackground, "Background context should be saved")
            XCTAssertTrue(didUpdateMain, "Main context should be updated")
        }
    }

    func test_ThatSavingBackgroundContext_SucceedsAndUpdateMainContext() {
        // GIVEN: a stack and context with changes
        let context = self.inMemoryStack.backgroundContext
        context.performAndWait {
            self.generateCompaniesInContext(context, count: 3)
        }

        var didSaveBackground = false
        self.expectation(forNotification: .NSManagedObjectContextDidSave,
                         object: self.inMemoryStack.backgroundContext) { _ -> Bool in
            didSaveBackground = true
            return true
        }

        var didUpdateMain = false
        self.expectation(forNotification: .NSManagedObjectContextObjectsDidChange,
                         object: self.inMemoryStack.mainContext) { _ -> Bool in
            didUpdateMain = true
            return true
        }

        let saveExpectation = self.expectation(description: #function)

        // WHEN: we attempt to save the context asynchronously
        self.inMemoryStack.backgroundContext.saveAsync { result in

            // THEN: the save succeeds without an error
            XCTAssertNotNil(try? result.get(), "Save should not error")
            saveExpectation.fulfill()
        }

        // THEN: then the main and background contexts are saved and the completion handler is called
        self.waitForExpectations(timeout: defaultTimeout) { error -> Void in
            XCTAssertNil(error, "Expectation should not error")
            XCTAssertTrue(didSaveBackground, "Background context should be saved")
            XCTAssertTrue(didUpdateMain, "Main context should be updated")
        }
    }
}
