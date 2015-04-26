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
import ExampleModel

import JSQCoreDataKit


///  --------------------------------------------
///  NOTE:
///  Testing the following APIs requires that JSQCoreDataKit be embedded in an actual application
///
///  This is a workaround for issues with xcodebuild, xctool, and travis-ci
///
///  Failed to query the list of test cases in the test bundle: 
///  /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin/sim:
///  No simulator devices appear to be running.  Setting data directories to /var/empty.
///  
///  DYLD_INSERT_LIBRARIES contains possible bad values. Caller beware: /usr/local/Cellar/xctool/0.2.3/libexec/lib/otest-query-lib-ios.dylib
///  
///  assertion failed: *** Error finding documents directory: Optional(Error Domain=NSCocoaErrorDomain Code=513 "The operation couldn’t be completed. (Cocoa error 513.)"
///  UserInfo=0x7bb40ae0 {NSFilePath=/var/empty/Documents, NSUnderlyingError=0x7bb40a10 "The operation couldn’t be completed. Permission denied"}): 
///  file /Users/jesse/GitHub/JSQCoreDataKit/JSQCoreDataKit/JSQCoreDataKit/CoreDataModel.swift, line 136
///
///  --------------------------------------------


class JSQCoreDataKitTests: XCTestCase {

    let model = CoreDataModel(name: ModelName, bundle: ModelBundle)

    override func setUp() {
        model.removeExistingModelStore()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_ThatCoreDataModel_DoesNotNeedMigration() {

        // GIVEN: a model with 1 version

        // WHEN: we check if it needs migration

        // THEN: the store doesn't need migration
        XCTAssertFalse(model.modelStoreNeedsMigration)
    }

    func test_ThatCoreDataModel_InitializesSuccessfully() {

        // GIVEN: a model name and bundle

        // WHEN: we create a model
        let model = CoreDataModel(name: ModelName, bundle: ModelBundle)

        // THEN: the model has the correct name and bundle
        XCTAssertEqual(model.name, ModelName)
        XCTAssertEqual(model.bundle, ModelBundle)

        // THEN: the model returns the correct database filename
        XCTAssertEqual(model.databaseFileName, model.name + ".sqlite")

        // THEN: the store file is in the documents directory
        let storeURLComponents = model.storeURL.pathComponents!
        XCTAssertEqual(toString(storeURLComponents.last!), model.databaseFileName)
        XCTAssertEqual(toString(storeURLComponents[storeURLComponents.count - 2]), "Documents")
        XCTAssertTrue(model.storeURL.fileURL)

        // THEN: the model is in its specified bundle
        let modelURLComponents = model.modelURL.pathComponents!
        XCTAssertEqual(toString(modelURLComponents.last!), model.name + ".momd")
        XCTAssertEqual(toString(modelURLComponents[modelURLComponents.count - 2]), model.bundle.bundlePath.lastPathComponent)

        // THEN: the managed object model does not assert
        XCTAssertNotNil(model.managedObjectModel)

        // THEN: the store doesn't need migration
        XCTAssertFalse(model.modelStoreNeedsMigration)
    }

    func test_ThatCoreDataStack_InitializesSuccessfully() {

        // GIVEN: a model

        // WHEN: we create a stack
        let stack = CoreDataStack(model: model)

        // THEN: it is setup as expected
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(model.storeURL.path!), "Model store should exist on disk")
        XCTAssertEqual(stack.managedObjectContext.concurrencyType, .MainQueueConcurrencyType)
    }

    func test_ThatChildContext_IsCreatedSuccessfully() {

        // GIVEN: a model and stack
        let stack = CoreDataStack(model: model)

        // WHEN: we create a child context
        let childContext = stack.childManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType, mergePolicyType: .ErrorMergePolicyType)

        // THEN: it is initialized as expected
        XCTAssertEqual(childContext.parentContext!, stack.managedObjectContext)
        XCTAssertEqual(childContext.concurrencyType, .PrivateQueueConcurrencyType)
        XCTAssertEqual(childContext.mergePolicy.mergeType, .ErrorMergePolicyType)
    }
    
}
