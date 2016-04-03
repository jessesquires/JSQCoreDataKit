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

    func test_GivenExistingStore_WhenFindingItsModel_ThenTheCorrectModelIsFound() {
        // GIVEN: a SQLite store with metadata pointing to a specific version of the model
        let version1Model = managedObjectModelVersion("Version 1")
        let persistentStore = createSQLitePersistentStore(version1Model)

        // WHEN: the compatible model is found in the test bundle
        let foundModel = try! findModelCompatibleWithStore(model.bundle, storeType: persistentStore.type, storeURL: persistentStore.URL!)

        // THEN: the found model is the same as the one used to create the store
        XCTAssertEqual(foundModel, version1Model)
    }

    func test_WhenFetchinglAllModelVersions_AllVersionsAreFound() {
        // WHEN: fetching all model versions from the test bundle
        let modelsInBundle = findModelsInBundle(model.bundle)

        // THEN: all model versions are found
        let version1 = managedObjectModelVersion("Version 1")
        let version2 = managedObjectModelVersion("Version 2")
        let version3 = managedObjectModelVersion("Version 3")
        XCTAssertEqual(Set(modelsInBundle), Set([version1, version2, version3]))
    }

    func test_GivenSourceAndDestinationModels_WhenBuildingTheMappingPathsBetweenThem_ThenTheMappingStepsAreCorrect() {
        // GIVEN: the source and destination models
        let sourceModel = managedObjectModelVersion("Version 1")
        let destinationModel = managedObjectModelVersion("Version 3")

        // WHEN: building the mapping path
        let mappingPath = try! buildMappingModelPath(model.bundle, sourceModel: sourceModel, destinationModel: destinationModel)

        // THEN: the mapping steps are correct
        let version2Model = managedObjectModelVersion("Version 2")
        let version1ToVersion2Mapping = mappingModel("Version1_to_Version2")
        let version2ToVersion3Mapping = mappingModel("Version2_to_Version3")

        XCTAssertEqual(mappingPath[0].source, sourceModel)
        XCTAssertEqual(mappingPath[0].mapping, version1ToVersion2Mapping)
        XCTAssertEqual(mappingPath[0].destination, version2Model)

        XCTAssertEqual(mappingPath[1].source, version2Model)
        XCTAssertEqual(mappingPath[1].mapping, version2ToVersion3Mapping)
        XCTAssertEqual(mappingPath[1].destination, destinationModel)
    }

    func test_GivenTwoModelsWithNoMappingPath_WhenBuildingTheMappingPathsBetweenThem_ThenExceptionIsThrown() {
        // GIVEN: the source and destination models
        let sourceModel = managedObjectModelVersion("Version 1")
        let destinationModel = sourceModel

        // WHEN: building the mapping path
        do {
            try buildMappingModelPath(model.bundle, sourceModel: sourceModel, destinationModel: destinationModel)

            // THEN: a `MigrationError.MappingModelNotFound` exception is thrown
        } catch MigrationError.MappingModelNotFound(let errorModel) {
            XCTAssertEqual(errorModel, managedObjectModelVersion("Version 3"))
            return

        } catch { }

        XCTFail("Expected exception not thrown")
    }

    func test_GivenModelWithForwardMapping_WhenFetchingTheNextMappingAndModel_ThenTheCorrectPairIsFound() {
        // GIVEN: a model that has a corresponding mapping model
        let version1Model = managedObjectModelVersion("Version 1")

        // WHEN: finding the next model and mapping
        let (targetModel, mapping) = nextIncrementalModelAndMapping(sourceModel: version1Model, bundle: model.bundle)!

        // THEN: the correct mapping and target model are found
        XCTAssertEqual(mapping, mappingModel("Version1_to_Version2"))
        XCTAssertEqual(targetModel, managedObjectModelVersion("Version 2"))
    }

    func test_GivenModelWithNoForwardMapping_WhenFindingTheNextMappingAndModel_ThenNilIsReturned() {
        // GIVEN: a model that has a corresponding mapping model
        let version3Model = managedObjectModelVersion("Version 3")

        // WHEN: finding the next model and mapping
        let result = nextIncrementalModelAndMapping(sourceModel: version3Model, bundle: model.bundle)

        // THEN: the return value is nil
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
