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

import ExampleModel

@testable
import JSQCoreDataKit


class ModelTests: XCTestCase {

    override func setUp() {
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        _ = try? model.removeExistingStore()
        super.setUp()
    }

    func test_ThatSQLiteModel_InitializesSuccessfully() {
        // GIVEN: a model name and bundle

        // WHEN: we create a model
        let model = CoreDataModel(name: modelName, bundle: modelBundle)

        // THEN: the model has the correct name, bundle, and type
        XCTAssertEqual(model.name, modelName)
        XCTAssertEqual(model.bundle, modelBundle)
        XCTAssertEqual(model.storeType, StoreType.sqlite(defaultDirectoryURL()))

        // THEN: the model returns the correct database filename
        XCTAssertEqual(model.databaseFileName, model.name + "." + ModelFileExtension.sqlite.rawValue)

        // THEN: the store file is in the documents directory
        let storeURLComponents = model.storeURL!.pathComponents!
        XCTAssertEqual(String(storeURLComponents.last!), model.databaseFileName)
        XCTAssertEqual(String(storeURLComponents[storeURLComponents.count - 2]), "Documents")
        XCTAssertTrue(model.storeURL!.isFileURL)

        // THEN: the model is in its specified bundle
        let modelURLComponents = model.modelURL.pathComponents!
        XCTAssertEqual(String(modelURLComponents.last!), model.name + ".momd")

        #if os(iOS)
            let count = modelURLComponents.count - 2
        #elseif os(OSX)
            let count = modelURLComponents.count - 3
        #endif

        XCTAssertEqual(String(modelURLComponents[count]), NSString(string: model.bundle.bundlePath).lastPathComponent)

        // THEN: the managed object model does not assert
        XCTAssertNotNil(model.managedObjectModel)

        // THEN: the store doesn't need migration
        XCTAssertFalse(model.needsMigration)
    }

    func test_ThatBinaryModel_InitializesSuccessfully() {
        // GIVEN: a model name and bundle

        // WHEN: we create a model
        let model = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .binary(URL(fileURLWithPath: NSTemporaryDirectory())))

        // THEN: the model has the correct name, bundle, and type
        XCTAssertEqual(model.name, modelName)
        XCTAssertEqual(model.bundle, modelBundle)
        XCTAssertEqual(model.storeType, StoreType.binary(URL(fileURLWithPath: NSTemporaryDirectory())))

        // THEN: the model returns the correct database filename
        XCTAssertEqual(model.databaseFileName, model.name)

        // THEN: the store file is in the tmp directory
        let storeURLComponents = model.storeURL!.pathComponents!
        XCTAssertEqual(String(storeURLComponents.last!), model.databaseFileName)

        #if os(iOS)
            let temp = "tmp"
        #elseif os(OSX)
            let temp = "T"
        #endif

        XCTAssertEqual(String(storeURLComponents[storeURLComponents.count - 2]), temp)
        XCTAssertTrue(model.storeURL!.isFileURL)

        // THEN: the model is in its specified bundle
        let modelURLComponents = model.modelURL.pathComponents!
        XCTAssertEqual(String(modelURLComponents.last!), model.name + ".momd")

        #if os(iOS)
            let count = modelURLComponents.count - 2
        #elseif os(OSX)
            let count = modelURLComponents.count - 3
        #endif

        XCTAssertEqual(String(modelURLComponents[count]), NSString(string: model.bundle.bundlePath).lastPathComponent)

        // THEN: the managed object model does not assert
        XCTAssertNotNil(model.managedObjectModel)

        // THEN: the store doesn't need migration
        XCTAssertFalse(model.needsMigration)
    }

    func test_ThatInMemoryModel_InitializesSuccessfully() {
        // GIVEN: a model name and bundle

        // WHEN: we create a model
        let model = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .inMemory)

        // THEN: the model has the correct name, bundle, and type
        XCTAssertEqual(model.name, modelName)
        XCTAssertEqual(model.bundle, modelBundle)
        XCTAssertEqual(model.storeType, StoreType.inMemory)

        // THEN: the model returns the correct database filename
        XCTAssertEqual(model.databaseFileName, model.name)

        // THEN: the store URL is nil
        XCTAssertNil(model.storeURL)

        // THEN: the model is in its specified bundle
        let modelURLComponents = model.modelURL.pathComponents!
        XCTAssertEqual(String(modelURLComponents.last!), model.name + ".momd")

        #if os(iOS)
            let count = modelURLComponents.count - 2
        #elseif os(OSX)
            let count = modelURLComponents.count - 3
        #endif

        XCTAssertEqual(String(modelURLComponents[count]), NSString(string: model.bundle.bundlePath).lastPathComponent)

        // THEN: the managed object model does not assert
        XCTAssertNotNil(model.managedObjectModel)

        // THEN: the store doesn't need migration
        XCTAssertFalse(model.needsMigration)
    }

    func test_ThatSQLiteModel_RemoveExistingStore_Succeeds() {
        // GIVEN: a core data model and stack
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        let factory = CoreDataStackFactory(model: model)
        let result = factory.createStack()
        let stack = result.stack()!
        saveContext(stack.mainContext) { error in
        }

        let fileManager = FileManager.default()

        XCTAssertTrue(fileManager.fileExists(atPath: model.storeURL!.path!), "Model store should exist on disk")
        XCTAssertTrue(fileManager.fileExists(atPath: model.storeURL!.path! + "-wal"), "Model write ahead log should exist on disk")
        XCTAssertTrue(fileManager.fileExists(atPath: model.storeURL!.path! + "-shm"), "Model shared memory file should exist on disk")

        // WHEN: we remove the existing model store
        do {
            try model.removeExistingStore()
        }
        catch {
            XCTFail("Removing existing model store should not error.")
        }

        // THEN: the model store is successfully removed
        XCTAssertFalse(fileManager.fileExists(atPath: model.storeURL!.path!), "Model store should NOT exist on disk")
        XCTAssertFalse(fileManager.fileExists(atPath: model.storeURL!.path! + "-wal"), "Model write ahead log should NOT exist on disk")
        XCTAssertFalse(fileManager.fileExists(atPath: model.storeURL!.path! + "-shm"), "Model shared memory file should NOT exist on disk")
    }

    func test_ThatSQLiteModel_RemoveExistingStore_Fails() {
        // GIVEN: a core data model
        let model = CoreDataModel(name: modelName, bundle: modelBundle)

        // WHEN: we do not create a core data stack

        // THEN: the model store does not exist on disk
        XCTAssertFalse(FileManager.default().fileExists(atPath: model.storeURL!.path!), "Model store should not exist on disk")

        // WHEN: we attempt to remove the existing model store
        var success = true
        do {
            try model.removeExistingStore()
        }
        catch {
            success = false
        }

        // THEN: then removal is ignored
        XCTAssertTrue(success, "Removing store should be ignored")
    }

    func test_ThatInMemoryModel_RemoveExistingStore_Fails() {
        // GIVEN: a core data model in-memory
        let model = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .inMemory)

        // THEN: the store URL is nil
        XCTAssertNil(model.storeURL)

        // WHEN: we attempt to remove the existing model store
        var success = true
        do {
            try model.removeExistingStore()
        }
        catch {
            success = false
        }

        // THEN: then removal is ignored
        XCTAssertTrue(success, "Removing store should be ignored")
    }
    
    func test_Model_Description() {
        print(#function)
        
        let model = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .inMemory)
        print(model)
    }
    
}
