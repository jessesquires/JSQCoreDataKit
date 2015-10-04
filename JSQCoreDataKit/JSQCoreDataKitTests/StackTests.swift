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


class StackTests: XCTestCase {

    func test_ThatSQLiteStack_InitializesSuccessfully() {

        // GIVEN: a SQLite model
        let sqliteModel = CoreDataModel(name: modelName, bundle: modelBundle)

        // WHEN: we create a stack
        let stack = CoreDataStack(model: sqliteModel)

        // THEN: it is setup as expected
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(sqliteModel.storeURL!.path!), "Model store should exist on disk")
        XCTAssertEqual(stack.context.concurrencyType, NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    }

    func test_ThatBinaryStack_InitializesSuccessfully() {

        // GIVEN: a binary model
        let binaryModel = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .Binary(NSURL(fileURLWithPath: NSTemporaryDirectory())))

        // WHEN: we create a stack
        let stack = CoreDataStack(model: binaryModel)

        // THEN: it is setup as expected
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(binaryModel.storeURL!.path!), "Model store should exist on disk")
        XCTAssertEqual(stack.context.concurrencyType, NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    }

    func test_ThatInMemoryStack_InitializesSuccessfully() {

        // GIVEN: a in-memory model
        let inMemoryModel = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .InMemory)

        // WHEN: we create a stack
        let stack = CoreDataStack(model: inMemoryModel, options: nil, concurrencyType: .PrivateQueueConcurrencyType)

        // THEN: it is setup as expected
        XCTAssertNil(inMemoryModel.storeURL, "Model store should not exist on disk")
        XCTAssertEqual(stack.context.concurrencyType, NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
    }

    func test_ThatChildContext_IsCreatedSuccessfully() {

        // GIVEN: a model and stack
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let stack = CoreDataStack(model: model)

        // WHEN: we create a child context
        let childContext = stack.childManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType, mergePolicyType: .ErrorMergePolicyType)

        // THEN: it is initialized as expected
        XCTAssertEqual(childContext.parentContext!, stack.context)
        XCTAssertEqual(childContext.concurrencyType, NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        XCTAssertEqual(childContext.mergePolicy.mergeType, NSMergePolicyType.ErrorMergePolicyType)
    }

    func test_ThatStack_HasDescription() {
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let stack = CoreDataStack(model: model)
        XCTAssertNotNil(stack.description)
        print("Description = \(stack.description)")
    }
    
}
