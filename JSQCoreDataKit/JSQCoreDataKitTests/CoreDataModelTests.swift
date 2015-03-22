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
import ExampleModel


class CoreDataModelTests: XCTestCase {

    override func setUp() {

        let modelProperties = ExampleModelProperties()
        let model = CoreDataModel(name: modelProperties.name, bundle: modelProperties.bundle)
        model.removeExistingModelStore()

        super.setUp()
    }

    func test_ThatCoreDataModel_InitializesSuccessfully() {

        // GIVEN: a model name and bundle
        let modelProperties = ExampleModelProperties()

        // WHEN: we create a model
        let model = CoreDataModel(name: modelProperties.name, bundle: modelProperties.bundle)

        // THEN: the model has the correct name and bundle
        XCTAssertEqual(model.name, modelProperties.name)
        XCTAssertEqual(model.bundle, modelProperties.bundle)

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

    func test_ThatCoreDataModel_RemoveExistingStore_Succeeds() {

        // GIVEN: a core data model and stack
        let modelProperties = ExampleModelProperties()
        let model = CoreDataModel(name: modelProperties.name, bundle: modelProperties.bundle)
        let stack = CoreDataStack(model: model)

        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(model.storeURL.path!), "Model store should exist on disk")

        // WHEN: we remove the existing model store
        let results = model.removeExistingModelStore()

        // THEN: the model store is successfully removed
        XCTAssertTrue(results.success, "Removing store should succeed")
        XCTAssertNil(results.error, "Removing store should not error")
        XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(model.storeURL.path!), "Model store should not exist on disk")
    }

    func test_ThatCoreDataModel_RemoveExistingStore_Fails() {

        // GIVEN: a core data model
        let modelProperties = ExampleModelProperties()
        let model = CoreDataModel(name: modelProperties.name, bundle: modelProperties.bundle)

        // WHEN: we do not create a core data stack

        // THEN: the model store does not exist on disk
        XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(model.storeURL.path!), "Model store should not exist on disk")

        // WHEN: we attempt to remove the existing model store
        let results = model.removeExistingModelStore()

        // THEN: then removal fails
        XCTAssertFalse(results.success, "Removing store should fail")
    }

}
