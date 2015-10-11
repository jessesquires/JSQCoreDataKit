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

import JSQCoreDataKit


class StackTests: XCTestCase {

    func test_ThatSQLiteStack_InitializesSuccessfully() {

        // GIVEN: a SQLite model
        let sqliteModel = CoreDataModel(name: modelName, bundle: modelBundle)

        // WHEN: we create a stack

        let stack = CoreDataStack(model: sqliteModel)

        // THEN: it is setup as expected
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(sqliteModel.storeURL!.path!), "Model store should exist on disk")
        XCTAssertEqual(stack.mainContext.concurrencyType, NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    }

    func test_ThatBinaryStack_InitializesSuccessfully() {

        // GIVEN: a binary model
        let binaryModel = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .Binary(NSURL(fileURLWithPath: NSTemporaryDirectory())))

        // WHEN: we create a stack
        let stack = CoreDataStack(model: binaryModel)

        // THEN: it is setup as expected
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(binaryModel.storeURL!.path!), "Model store should exist on disk")
        XCTAssertEqual(stack.mainContext.concurrencyType, NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    }

    func test_ThatInMemoryStack_InitializesSuccessfully() {

        // GIVEN: a in-memory model
        let inMemoryModel = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .InMemory)

        // WHEN: we create a stack
        let stack = CoreDataStack(model: inMemoryModel, options: nil)

        // THEN: it is setup as expected
        XCTAssertNil(inMemoryModel.storeURL, "Model store should not exist on disk")
        XCTAssertEqual(stack.mainContext.concurrencyType, NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    }

    func test_ThatMainChildContext_IsCreatedSuccessfully() {

        // GIVEN: a model and stack
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let stack = CoreDataStack(model: model)

        // WHEN: we create a child context from main
        let childContext = stack.childContextFromMain(concurrencyType: .PrivateQueueConcurrencyType, mergePolicyType: .ErrorMergePolicyType)

        // THEN: it is initialized as expected
        XCTAssertEqual(childContext.parentContext!, stack.mainContext)
        XCTAssertEqual(childContext.concurrencyType, NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        XCTAssertEqual(childContext.mergePolicy.mergeType, NSMergePolicyType.ErrorMergePolicyType)
    }

    func test_ThatBackgroundChildContext_IsCreatedSuccessfully() {

        // GIVEN: a model and stack
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let stack = CoreDataStack(model: model)

        // WHEN: we create a child context from background
        let childContext = stack.childContextFromBackground(concurrencyType: .PrivateQueueConcurrencyType, mergePolicyType: .ErrorMergePolicyType)

        // THEN: it is initialized as expected
        XCTAssertEqual(childContext.parentContext!, stack.backgroundContext)
        XCTAssertEqual(childContext.concurrencyType, NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        XCTAssertEqual(childContext.mergePolicy.mergeType, NSMergePolicyType.ErrorMergePolicyType)
    }

    func test_Stack_Description() {
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let stack = CoreDataStack(model: model)
        print(stack)
    }
    
}
