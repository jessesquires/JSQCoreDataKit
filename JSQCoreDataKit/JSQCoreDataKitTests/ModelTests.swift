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


class ModelTests: XCTestCase {

    override func setUp() {
        let model = CoreDataModel(name: modelName, bundle: modelBundle)

        do {
            try model.removeExistingModelStore()
        } catch { }

        super.setUp()
    }

    func test_ThatSQLiteModel_InitializesSuccessfully() {

        // GIVEN: a model name and bundle

        // WHEN: we create a model
        let model = CoreDataModel(name: modelName, bundle: modelBundle)

        // THEN: the model has the correct name, bundle, and type
        XCTAssertEqual(model.name, modelName)
        XCTAssertEqual(model.bundle, modelBundle)

        let docsDir = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory,
            inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        XCTAssertEqual(model.storeType, .SQLite(docsDir))

        // THEN: the model returns the correct database filename
        XCTAssertEqual(model.databaseFileName, model.name + ".sqlite")

        // THEN: the store file is in the documents directory
        let storeURLComponents = model.storeURL!.pathComponents!
        XCTAssertEqual(String(storeURLComponents.last!), model.databaseFileName)
        XCTAssertEqual(String(storeURLComponents[storeURLComponents.count - 2]), "Documents")
        XCTAssertTrue(model.storeURL!.fileURL)

        // THEN: the model is in its specified bundle
        let modelURLComponents = model.modelURL.pathComponents!
        XCTAssertEqual(String(modelURLComponents.last!), model.name + ".momd")
        XCTAssertEqual(String(modelURLComponents[modelURLComponents.count - 2]), model.bundle.bundlePath.lastPathComponent)

        // THEN: the managed object model does not assert
        XCTAssertNotNil(model.managedObjectModel)

        // THEN: the store doesn't need migration
        XCTAssertFalse(model.needsMigration)
    }

    func test_ThatBinaryModel_InitializesSuccessfully() {

        // GIVEN: a model name and bundle

        // WHEN: we create a model
        let model = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .Binary(NSURL(fileURLWithPath: NSTemporaryDirectory())))

        // THEN: the model has the correct name, bundle, and type
        XCTAssertEqual(model.name, modelName)
        XCTAssertEqual(model.bundle, modelBundle)
        XCTAssertEqual(model.storeType, .Binary(NSURL(fileURLWithPath: NSTemporaryDirectory())))

        // THEN: the model returns the correct database filename
        XCTAssertEqual(model.databaseFileName, model.name)

        // THEN: the store file is in the tmp directory
        let storeURLComponents = model.storeURL!.pathComponents!
        XCTAssertEqual(String(storeURLComponents.last!), model.databaseFileName)
        XCTAssertEqual(String(storeURLComponents[storeURLComponents.count - 2]), "tmp")
        XCTAssertTrue(model.storeURL!.fileURL)

        // THEN: the model is in its specified bundle
        let modelURLComponents = model.modelURL.pathComponents!
        XCTAssertEqual(String(modelURLComponents.last!), model.name + ".momd")
        XCTAssertEqual(String(modelURLComponents[modelURLComponents.count - 2]), model.bundle.bundlePath.lastPathComponent)

        // THEN: the managed object model does not assert
        XCTAssertNotNil(model.managedObjectModel)

        // THEN: the store doesn't need migration
        XCTAssertFalse(model.needsMigration)
    }

    func test_ThatInMemoryModel_InitializesSuccessfully() {

        // GIVEN: a model name and bundle

        // WHEN: we create a model
        let model = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .InMemory)

        // THEN: the model has the correct name, bundle, and type
        XCTAssertEqual(model.name, modelName)
        XCTAssertEqual(model.bundle, modelBundle)
        XCTAssertEqual(model.storeType, .InMemory)

        // THEN: the model returns the correct database filename
        XCTAssertEqual(model.databaseFileName, model.name)

        // THEN: the store URL is nil
        XCTAssertNil(model.storeURL)

        // THEN: the model is in its specified bundle
        let modelURLComponents = model.modelURL.pathComponents!
        XCTAssertEqual(String(modelURLComponents.last!), model.name + ".momd")
        XCTAssertEqual(String(modelURLComponents[modelURLComponents.count - 2]), model.bundle.bundlePath.lastPathComponent)

        // THEN: the managed object model does not assert
        XCTAssertNotNil(model.managedObjectModel)

        // THEN: the store doesn't need migration
        XCTAssertFalse(model.needsMigration)
    }

    func test_ThatSQLiteModel_RemoveExistingStore_Succeeds() {

        // GIVEN: a core data model and stack
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let stack = CoreDataStack(model: model)
        saveContext(stack.context) { error in
        }

        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(model.storeURL!.path!), "Model store should exist on disk")

        // WHEN: we remove the existing model store
        do {
            try model.removeExistingModelStore()
        }
        catch {
            XCTFail("Removing existing model store should not error.")
        }

        // THEN: the model store is successfully removed
        XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(model.storeURL!.path!), "Model store should not exist on disk")
    }

    func test_ThatSQLiteModel_RemoveExistingStore_Fails() {

        // GIVEN: a core data model
        let model = CoreDataModel(name: modelName, bundle: modelBundle)

        // WHEN: we do not create a core data stack

        // THEN: the model store does not exist on disk
        XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(model.storeURL!.path!), "Model store should not exist on disk")

        // WHEN: we attempt to remove the existing model store
        var success = true
        do {
            try model.removeExistingModelStore()
        }
        catch {
            success = false
        }
        
        // THEN: then removal is ignored
        XCTAssertTrue(success, "Removing store should be ignored")
    }

    func test_ThatInMemoryModel_RemoveExistingStore_Fails() {

        // GIVEN: a core data model in-memory
        let model = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .InMemory)

        // THEN: the store URL is nil
        XCTAssertNil(model.storeURL)

        // WHEN: we attempt to remove the existing model store
        var success = true
        do {
            try model.removeExistingModelStore()
        }
        catch {
            success = false
        }

        // THEN: then removal is ignored
        XCTAssertTrue(success, "Removing store should be ignored")
    }

    func test_ThatModel_HasDescription() {
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        XCTAssertNotNil(model.description)
        print("Description = \(model.description)")
    }
    
}
