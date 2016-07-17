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


class MigrationTests: TestCase {

    let model: CoreDataModel = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .sqlite(defaultDirectoryURL()))

    override func setUp() {
        super.setUp()
        _ = try? model.removeExistingStore()
    }

    override func tearDown() {
        _ = try? model.removeExistingStore()
        super.tearDown()
    }

    func test_ThatCoreDataModel_NeedsMigration_WhenUsingOldModel() {
        // GIVEN: an existing SQLite file with metadata pointing to an old version of the model
        _ = createSQLitePersistentStore(managedObjectModel(versionName: "Version 1"))

        // WHEN: we ask if it needs migration
        // THEN: model needs migration
        XCTAssertTrue(model.needsMigration)
    }

    func test_ThatCoreDataModel_DoesNotNeedMigration_WhenUsingMostRecentModel() {
        // GIVEN: an existing SQLite file with metadata pointing to the latest version of the model
        XCTAssertFalse(model.needsMigration)
        _ = createSQLitePersistentStore(managedObjectModel(versionName: "Version 3"))

        // WHEN: we ask if it needs migration
        // THEN: model does not need migration
        XCTAssertFalse(model.needsMigration)

        // THEN: calling migrate does nothing
        try! model.migrate()
    }

    func test_ThatModelMigrates_Successfully() {
        // GIVEN: an existing SQLite file with metadata pointing to an old version of the model
        _ = createSQLitePersistentStore(managedObjectModel(versionName: "Version 1"))
        XCTAssertTrue(model.needsMigration)

        // WHEN: CoreDataModel is migrated
        do {
            try model.migrate()
        } catch {
            XCTFail("Failed to migrate model: \(error)")
        }

        // THEN: model does not need migration
        XCTAssertFalse(model.needsMigration)
    }


    // MARK: buildMigrationMappingSteps

    func test_ThatBuildingMigrationMappingSteps_WithValidModels_ReturnsCorrectSteps() {
        // GIVEN: the source and destination models
        let sourceModel = managedObjectModel(versionName: "Version 1")
        let destinationModel = managedObjectModel(versionName: "Version 3")

        // WHEN: building the mapping steps
        let mappingSteps = try! buildMigrationMappingSteps(bundle: model.bundle, sourceModel: sourceModel, destinationModel: destinationModel)

        // THEN: the mapping steps are correct
        let version2Model = managedObjectModel(versionName: "Version 2")
        let version1ToVersion2Mapping = mappingModel(name: "Version1_to_Version2")
        let version2ToVersion3Mapping = mappingModel(name: "Version2_to_Version3")

        XCTAssertEqual(mappingSteps[0].source, sourceModel)
        XCTAssertEqual(mappingSteps[0].mapping, version1ToVersion2Mapping)
        XCTAssertEqual(mappingSteps[0].destination, version2Model)

        XCTAssertEqual(mappingSteps[1].source, version2Model)
        XCTAssertEqual(mappingSteps[1].mapping, version2ToVersion3Mapping)
        XCTAssertEqual(mappingSteps[1].destination, destinationModel)
    }

    func test_ThatBuildingMigrationMappingSteps_WithInvalidModels_ThrowsError() {
        // GIVEN: invalid source and destination models
        let sourceModel = managedObjectModel(versionName: "Version 1")
        let destinationModel = sourceModel

        // WHEN: building the mapping steps
        var mappingSteps: [MigrationMappingStep]?
        do {
            mappingSteps = try buildMigrationMappingSteps(bundle: model.bundle, sourceModel: sourceModel, destinationModel: destinationModel)
        } catch MigrationError.mappingModelNotFound(let destinationModel) {
            // THEN: the expected error is thrown
            XCTAssertNil(mappingSteps)
            XCTAssertEqual(destinationModel, managedObjectModel(versionName: "Version 3"))
        } catch {
            XCTFail("Unexpected error was thrown: \(error)")
        }
    }


    // MARK: findCompatibleModel

    func test_thatWhenFindingACompatibleModel_ForAValidStore_ThenTheCorrectModelIsFound() {
        // GIVEN: a SQLite store with metadata pointing to a specific version of the model
        let version1Model = managedObjectModel(versionName: "Version 1")
        let persistentStore = createSQLitePersistentStore(version1Model)

        // WHEN: we search for a compatible model in the bundle
        let foundModel = try! findCompatibleModel(withBundle: model.bundle, storeType: persistentStore.type, storeURL: persistentStore.url!)

        // THEN: the found model is the same as the one used to create the store
        XCTAssertEqual(foundModel, version1Model)
    }

    func test_thatWhenFindingACompatibleModel_ForAnInvalidStore_ThenNoModelIsFound_AndAnErrorIsThrown() {
        // GIVEN: an invalid store bundle
        let bundle = Bundle(for: MigrationTests.self)

        // WHEN: we search for a compatible model in the bundle
        var foundModel: NSManagedObjectModel?
        do {
            foundModel = try findCompatibleModel(withBundle: bundle, storeType: model.storeType.type, storeURL: model.storeURL!)
        } catch {
            XCTAssertNotNil(error)
        }

        // THEN: no model is found
        XCTAssertNil(foundModel)
    }


    // MARK: findModelsInBundle

    func test_ThatFindModelsInBundle_ReturnsExpectedModels() {
        // GIVEN: a model in a bundle
        let bundle = model.bundle

        // WHEN: fetching all model versions from the bundle
        let modelsInBundle = findModelsInBundle(bundle)

        // THEN: all model versions are found
        let version1 = managedObjectModel(versionName: "Version 1")
        let version2 = managedObjectModel(versionName: "Version 2")
        let version3 = managedObjectModel(versionName: "Version 3")
        XCTAssertEqual(modelsInBundle, [version1, version2, version3])
    }

    func test_ThatFindModelsInBundle_ReturnsEmptyArrayForInvalidBundle() {
        // GIVEN: no models in a bundle
        let bundle = Bundle(for: MigrationTests.self)

        // WHEN: fetching all model versions from the bundle
        let modelsInBundle = findModelsInBundle(bundle)

        // THEN: all model versions are found
        XCTAssertEqual(modelsInBundle.count, 0)
    }


    // MARK: nextMigrationMappingStep

    func test_thatWhenFetchingTheNextMigrationMappingStep_ThenTheCorrectMappingIsFound_Version1to2() {
        // GIVEN: a model that has a corresponding mapping model
        let version1Model = managedObjectModel(versionName: "Version 1")

        // WHEN: finding the next model and mapping
        let mappingStep = nextMigrationMappingStep(fromSourceModel: version1Model, bundle: model.bundle)!

        // THEN: the correct mapping and target model are found
        XCTAssertEqual(mappingStep.source, version1Model)
        XCTAssertEqual(mappingStep.mapping, mappingModel(name: "Version1_to_Version2"))
        XCTAssertEqual(mappingStep.destination, managedObjectModel(versionName: "Version 2"))
    }

    func test_thatWhenFetchingTheNextMigrationMappingStep_ThenTheCorrectMappingIsFound_Version2to3() {
        // GIVEN: a model that has a corresponding mapping model
        let version1Model = managedObjectModel(versionName: "Version 2")

        // WHEN: finding the next model and mapping
        let mappingStep = nextMigrationMappingStep(fromSourceModel: version1Model, bundle: model.bundle)!

        // THEN: the correct mapping and target model are found
        XCTAssertEqual(mappingStep.source, version1Model)
        XCTAssertEqual(mappingStep.mapping, mappingModel(name: "Version2_to_Version3"))
        XCTAssertEqual(mappingStep.destination, managedObjectModel(versionName: "Version 3"))
    }

    func test_thatWhenFetchingTheNextMigrationMappingStep_ThenNilIsReturned_WhenNoStepsLeft() {
        // GIVEN: a model that does not have a corresponding mapping model
        let version3Model = managedObjectModel(versionName: "Version 3")

        // WHEN: finding the next model and mapping
        let result = nextMigrationMappingStep(fromSourceModel: version3Model, bundle: model.bundle)

        // THEN: no more mapping steps are found
        XCTAssertNil(result)
    }


    // MARK: Helpers

    func createSQLitePersistentStore(_ managedObjectModel: NSManagedObjectModel) -> NSPersistentStore {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let storeURL = try! defaultDirectoryURL().appendingPathComponent("\(modelName)." + ModelFileExtension.sqlite.rawValue)

        return try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
    }

    func managedObjectModel(versionName: String) -> NSManagedObjectModel {
        let modelURL = try! model.modelURL.appendingPathComponent("\(versionName).\(ModelFileExtension.versionedFile.rawValue)")

        guard let result = NSManagedObjectModel(contentsOf: modelURL) else {
            preconditionFailure("Model with given name not found in bundle or is invalid.")
        }
        return result
    }

    func mappingModel(name: String) -> NSMappingModel {
        guard let mappingModelURL = model.bundle.urlForResource(name, withExtension: ModelFileExtension.mapping.rawValue) else {
            preconditionFailure("Mapping model named \(name) not found in bundle.")
        }
        
        guard let result = NSMappingModel(contentsOf: mappingModelURL) else {
            preconditionFailure("Mapping model named \(name) is invalid.")
        }
        return result
    }
    
}
