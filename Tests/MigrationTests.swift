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

    let model: CoreDataModel = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .SQLite(defaultDirectoryURL()))

    override func setUp() {
        super.setUp()
        _ = try? model.removeExistingStore()
    }

    func test_GivenExistingPersistentStoreIsStale_ThenCoreDataModel_needsMigration() {
        // GIVEN: an existing SQLite file with metadata pointing to an old version of the model
        createSQLitePersistentStore(managedObjectModelVersion("Version 1"))

        // THEN: model needs migration
        XCTAssertTrue(model.needsMigration)
    }

    func test_GivenExistingPersistentStoreIsFresh_ThenCoreDataModel_doesNotNeedMigration() {
        // GIVEN: an existing SQLite file with metadata pointing to the latest version of the model
        createSQLitePersistentStore(managedObjectModelVersion("Version 3"))

        // THEN: model does not need migration
        XCTAssertFalse(model.needsMigration)
    }


    func test_GivenStalePersistentStore_WhenModelIsMigrated_ThenModelDoesNotNeedMigration() {
        // GIVEN: an existing SQLite file with metadata pointing to an old version of the model
        createSQLitePersistentStore(managedObjectModelVersion("Version 1"))

        // WHEN: CoreDataModel is migrated
        try! migrate(model)

        // THEN: model does not need migration
        XCTAssertFalse(model.needsMigration)
    }


    // MARK: buildMigrationMappingSteps

    func test_ThatBuildingMigrationMappingSteps_WithValidModels_ReturnsCorrectSteps() {
        // GIVEN: the source and destination models
        let sourceModel = managedObjectModelVersion("Version 1")
        let destinationModel = managedObjectModelVersion("Version 3")

        // WHEN: building the mapping steps
        let mappingSteps = try! buildMigrationMappingSteps(bundle: model.bundle, sourceModel: sourceModel, destinationModel: destinationModel)

        // THEN: the mapping steps are correct
        let version2Model = managedObjectModelVersion("Version 2")
        let version1ToVersion2Mapping = mappingModel("Version1_to_Version2")
        let version2ToVersion3Mapping = mappingModel("Version2_to_Version3")

        XCTAssertEqual(mappingSteps[0].source, sourceModel)
        XCTAssertEqual(mappingSteps[0].mapping, version1ToVersion2Mapping)
        XCTAssertEqual(mappingSteps[0].destination, version2Model)

        XCTAssertEqual(mappingSteps[1].source, version2Model)
        XCTAssertEqual(mappingSteps[1].mapping, version2ToVersion3Mapping)
        XCTAssertEqual(mappingSteps[1].destination, destinationModel)
    }

    func test_ThatBuildingMigrationMappingSteps_WithInvalidModels_ThrowsError() {
        // GIVEN: invalid source and destination models
        let sourceModel = managedObjectModelVersion("Version 1")
        let destinationModel = sourceModel

        // WHEN: building the mapping steps
        var mappingSteps: [MigrationMappingStep]?
        do {
            mappingSteps = try buildMigrationMappingSteps(bundle: model.bundle, sourceModel: sourceModel, destinationModel: destinationModel)
        } catch MigrationError.MappingModelNotFound(let destinationModel) {
            // THEN: the expected error is thrown
            XCTAssertNil(mappingSteps)
            XCTAssertEqual(destinationModel, managedObjectModelVersion("Version 3"))
        } catch {
            XCTFail("Unexpected error was thrown: \(error)")
        }
    }


    // MARK: findCompatibleModel

    func test_thatWhenFindingACompatibleModel_ForAValidStore_ThenTheCorrectModelIsFound() {
        // GIVEN: a SQLite store with metadata pointing to a specific version of the model
        let version1Model = managedObjectModelVersion("Version 1")
        let persistentStore = createSQLitePersistentStore(version1Model)

        // WHEN: we search for a compatible model in the bundle
        let foundModel = try! findCompatibleModel(withBundle: model.bundle, storeType: persistentStore.type, storeURL: persistentStore.URL!)

        // THEN: the found model is the same as the one used to create the store
        XCTAssertEqual(foundModel, version1Model)
    }

    func test_thatWhenFindingACompatibleModel_ForAnInvalidStore_ThenNoModelIsFound_AndAnErrorIsThrown() {
        // GIVEN: an invalid store bundle
        let bundle = NSBundle(forClass: MigrationTests.self)

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
        let version1 = managedObjectModelVersion("Version 1")
        let version2 = managedObjectModelVersion("Version 2")
        let version3 = managedObjectModelVersion("Version 3")
        XCTAssertEqual(modelsInBundle, [version1, version2, version3])
    }

    func test_ThatFindModelsInBundle_ReturnsEmptyArrayForInvalidBundle() {
        // GIVEN: no models in a bundle
        let bundle = NSBundle(forClass: MigrationTests.self)

        // WHEN: fetching all model versions from the bundle
        let modelsInBundle = findModelsInBundle(bundle)

        // THEN: all model versions are found
        XCTAssertEqual(modelsInBundle.count, 0)
    }


    // MARK: nextMigrationMappingStep

    func test_thatWhenFetchingTheNextMigrationMappingStep_ThenTheCorrectMappingIsFound_Version1to2() {
        // GIVEN: a model that has a corresponding mapping model
        let version1Model = managedObjectModelVersion("Version 1")

        // WHEN: finding the next model and mapping
        let mappingStep = nextMigrationMappingStep(fromSourceModel: version1Model, bundle: model.bundle)!

        // THEN: the correct mapping and target model are found
        XCTAssertEqual(mappingStep.source, version1Model)
        XCTAssertEqual(mappingStep.mapping, mappingModel("Version1_to_Version2"))
        XCTAssertEqual(mappingStep.destination, managedObjectModelVersion("Version 2"))
    }

    func test_thatWhenFetchingTheNextMigrationMappingStep_ThenTheCorrectMappingIsFound_Version2to3() {
        // GIVEN: a model that has a corresponding mapping model
        let version1Model = managedObjectModelVersion("Version 2")

        // WHEN: finding the next model and mapping
        let mappingStep = nextMigrationMappingStep(fromSourceModel: version1Model, bundle: model.bundle)!

        // THEN: the correct mapping and target model are found
        XCTAssertEqual(mappingStep.source, version1Model)
        XCTAssertEqual(mappingStep.mapping, mappingModel("Version2_to_Version3"))
        XCTAssertEqual(mappingStep.destination, managedObjectModelVersion("Version 3"))
    }

    func test_thatWhenFetchingTheNextMigrationMappingStep_ThenNilIsReturned_WhenNoStepsLeft() {
        // GIVEN: a model that does not have a corresponding mapping model
        let version3Model = managedObjectModelVersion("Version 3")

        // WHEN: finding the next model and mapping
        let result = nextMigrationMappingStep(fromSourceModel: version3Model, bundle: model.bundle)

        // THEN: no more mapping steps are found
        XCTAssertNil(result)
    }


    // MARK: Helpers

    func createSQLitePersistentStore(managedObjectModel: NSManagedObjectModel) -> NSPersistentStore {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let storeURL = defaultDirectoryURL().URLByAppendingPathComponent("\(modelName).sqlite")
        return try! coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
    }

    func managedObjectModelVersion(name: String) -> NSManagedObjectModel {
        let modelURL = model.modelURL.URLByAppendingPathComponent("\(name).mom")

        guard let result = NSManagedObjectModel(contentsOfURL: modelURL) else {
            preconditionFailure("Model with given name not found in bundle or is invalid.")
        }
        return result
    }

    func mappingModel(name: String) -> NSMappingModel {
        guard let mappingModelURL = model.bundle.URLForResource(name, withExtension: "cdm") else {
            preconditionFailure("Mapping model named \(name) not found in bundle.")
        }
        
        guard let result = NSMappingModel(contentsOfURL: mappingModelURL) else {
            preconditionFailure("Mapping model named \(name) is invalid.")
        }
        return result
    }
    
}
