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
import ExampleModel
@testable import JSQCoreDataKit
import XCTest

// swiftlint:disable force_try

final class MigrationTests: TestCase {

    let model = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .sqlite(CoreDataModel.defaultDirectoryURL()))

    override func setUp() {
        super.setUp()
        _ = try? self.model.removeExistingStore()
    }

    override func tearDown() {
        _ = try? self.model.removeExistingStore()
        super.tearDown()
    }

    func test_ThatCoreDataModel_NeedsMigration_WhenUsingOldModel() {
        // GIVEN: an existing SQLite file with metadata pointing to an old version of the model
        _ = self.createSQLitePersistentStore(self.managedObjectModel(versionName: "Version 1"))

        // WHEN: we ask if it needs migration
        // THEN: model needs migration
        XCTAssertTrue(self.model.needsMigration)
    }

    func test_ThatCoreDataModel_DoesNotNeedMigration_WhenUsingMostRecentModel() {
        // GIVEN: an existing SQLite file with metadata pointing to the latest version of the model
        XCTAssertFalse(self.model.needsMigration)
        _ = self.createSQLitePersistentStore(self.managedObjectModel(versionName: "Version 3"))

        // WHEN: we ask if it needs migration
        // THEN: model does not need migration
        XCTAssertFalse(self.model.needsMigration)

        // THEN: calling migrate does nothing
        try! self.model.migrate()
    }

    func test_ThatModelMigrates_Successfully() {
        // GIVEN: an existing SQLite file with metadata pointing to an old version of the model
        _ = self.createSQLitePersistentStore(self.managedObjectModel(versionName: "Version 1"))
        XCTAssertTrue(self.model.needsMigration)

        // WHEN: CoreDataModel is migrated
        do {
            try self.model.migrate()
        } catch {
            XCTFail("Failed to migrate model: \(error)")
        }

        // THEN: model does not need migration
        XCTAssertFalse(self.model.needsMigration)
    }

    // MARK: buildMigrationMappingSteps

    func test_ThatBuildingMigrationMappingSteps_WithValidModels_ReturnsCorrectSteps() {
        // GIVEN: the source and destination models
        let sourceModel = self.managedObjectModel(versionName: "Version 1")
        let destinationModel = self.managedObjectModel(versionName: "Version 3")

        // WHEN: building the mapping steps
        let mappingSteps = try! buildMigrationMappingSteps(bundle: self.model.bundle, sourceModel: sourceModel, destinationModel: destinationModel)

        // THEN: the mapping steps are correct
        let version2Model = self.managedObjectModel(versionName: "Version 2")
        let version1ToVersion2Mapping = self.mappingModel(name: "Version1_to_Version2")
        let version2ToVersion3Mapping = self.mappingModel(name: "Version2_to_Version3")

        XCTAssertEqual(mappingSteps[0].source, sourceModel)
        XCTAssertEqual(mappingSteps[0].mapping, version1ToVersion2Mapping)
        XCTAssertEqual(mappingSteps[0].destination, version2Model)

        XCTAssertEqual(mappingSteps[1].source, version2Model)
        XCTAssertEqual(mappingSteps[1].mapping, version2ToVersion3Mapping)
        XCTAssertEqual(mappingSteps[1].destination, destinationModel)
    }

    func test_ThatBuildingMigrationMappingSteps_WithInvalidModels_ThrowsError() {
        // GIVEN: invalid source and destination models
        let sourceModel = self.managedObjectModel(versionName: "Version 1")
        let destinationModel = sourceModel

        // WHEN: building the mapping steps
        var mappingSteps = [MigrationMappingStep]()
        do {
            mappingSteps = try buildMigrationMappingSteps(bundle: self.model.bundle, sourceModel: sourceModel, destinationModel: destinationModel)
        } catch MigrationError.mappingModelNotFound(let destinationModel) {
            // THEN: the expected error is thrown
            XCTAssertTrue(mappingSteps.isEmpty)
            XCTAssertEqual(destinationModel, self.managedObjectModel(versionName: "Version 3"))
        } catch {
            XCTFail("Unexpected error was thrown: \(error)")
        }
    }

    // MARK: findCompatibleModel

    func test_thatWhenFindingACompatibleModel_ForAValidStore_ThenTheCorrectModelIsFound() {
        // GIVEN: a SQLite store with metadata pointing to a specific version of the model
        let version1Model = self.managedObjectModel(versionName: "Version 1")
        let persistentStore = self.createSQLitePersistentStore(version1Model)

        // WHEN: we search for a compatible model in the bundle
        let foundModel = try! findCompatibleModel(withBundle: self.model.bundle, storeType: persistentStore.type, storeURL: persistentStore.url!)

        // THEN: the found model is the same as the one used to create the store
        XCTAssertEqual(foundModel, version1Model)
    }

    func test_thatWhenFindingACompatibleModel_ForAnInvalidStore_ThenNoModelIsFound_AndAnErrorIsThrown() {
        // GIVEN: an invalid store bundle
        let bundle = Bundle(for: Self.self)

        // WHEN: we search for a compatible model in the bundle
        var foundModel: NSManagedObjectModel?
        do {
            foundModel = try findCompatibleModel(withBundle: bundle, storeType: self.model.storeType.type, storeURL: self.model.storeURL!)
        } catch {
            XCTAssertNotNil(error)
        }

        // THEN: no model is found
        XCTAssertNil(foundModel)
    }

    // MARK: findModelsInBundle

    func test_ThatFindModelsInBundle_ReturnsExpectedModels() {
        // GIVEN: a model in a bundle
        let bundle = self.model.bundle

        // WHEN: fetching all model versions from the bundle
        let modelsInBundle = findModelsInBundle(bundle)

        // THEN: all model versions are found
        let version1 = self.managedObjectModel(versionName: "Version 1")
        let version2 = self.managedObjectModel(versionName: "Version 2")
        let version3 = self.managedObjectModel(versionName: "Version 3")
        XCTAssertEqual(modelsInBundle, [version1, version2, version3])
    }

    func test_ThatFindModelsInBundle_ReturnsEmptyArrayForInvalidBundle() {
        // GIVEN: no models in a bundle
        let bundle = Bundle(for: Self.self)

        // WHEN: fetching all model versions from the bundle
        let modelsInBundle = findModelsInBundle(bundle)

        // THEN: all model versions are found
        XCTAssertEqual(modelsInBundle.count, 0)
    }

    // MARK: nextMigrationMappingStep

    func test_thatWhenFetchingTheNextMigrationMappingStep_ThenTheCorrectMappingIsFound_Version1to2() {
        // GIVEN: a model that has a corresponding mapping model
        let version1Model = self.managedObjectModel(versionName: "Version 1")

        // WHEN: finding the next model and mapping
        let mappingStep = nextMigrationMappingStep(fromSourceModel: version1Model, bundle: self.model.bundle)!

        // THEN: the correct mapping and target model are found
        XCTAssertEqual(mappingStep.source, version1Model)
        XCTAssertEqual(mappingStep.mapping, self.mappingModel(name: "Version1_to_Version2"))
        XCTAssertEqual(mappingStep.destination, self.managedObjectModel(versionName: "Version 2"))
    }

    func test_thatWhenFetchingTheNextMigrationMappingStep_ThenTheCorrectMappingIsFound_Version2to3() {
        // GIVEN: a model that has a corresponding mapping model
        let version1Model = self.managedObjectModel(versionName: "Version 2")

        // WHEN: finding the next model and mapping
        let mappingStep = nextMigrationMappingStep(fromSourceModel: version1Model, bundle: self.model.bundle)!

        // THEN: the correct mapping and target model are found
        XCTAssertEqual(mappingStep.source, version1Model)
        XCTAssertEqual(mappingStep.mapping, self.mappingModel(name: "Version2_to_Version3"))
        XCTAssertEqual(mappingStep.destination, self.managedObjectModel(versionName: "Version 3"))
    }

    func test_thatWhenFetchingTheNextMigrationMappingStep_ThenNilIsReturned_WhenNoStepsLeft() {
        // GIVEN: a model that does not have a corresponding mapping model
        let version3Model = self.managedObjectModel(versionName: "Version 3")

        // WHEN: finding the next model and mapping
        let result = nextMigrationMappingStep(fromSourceModel: version3Model, bundle: self.model.bundle)

        // THEN: no more mapping steps are found
        XCTAssertNil(result)
    }

    // MARK: Helpers

    func createSQLitePersistentStore(_ managedObjectModel: NSManagedObjectModel) -> NSPersistentStore {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let storeURL = CoreDataModel.defaultDirectoryURL().appendingPathComponent("\(modelName)." + ModelFileExtension.sqlite.rawValue)
        return try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
    }

    func managedObjectModel(versionName: String) -> NSManagedObjectModel {
        let modelURL = self.model.modelURL.appendingPathComponent("\(versionName).\(ModelFileExtension.versionedFile.rawValue)")
        guard let result = NSManagedObjectModel(contentsOf: modelURL) else {
            preconditionFailure("Model with given name not found in bundle or is invalid.")
        }
        return result
    }

    func mappingModel(name: String) -> NSMappingModel {
        guard let mappingModelURL = self.model.bundle.url(forResource: name, withExtension: ModelFileExtension.mapping.rawValue) else {
            preconditionFailure("Mapping model named \(name) not found in bundle.")
        }
        guard let result = NSMappingModel(contentsOf: mappingModelURL) else {
            preconditionFailure("Mapping model named \(name) is invalid.")
        }
        return result
    }
}

// swiftlint:enable force_try
