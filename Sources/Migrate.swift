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
import Foundation

/**
 An error type that specifies possible errors that are thrown by calling `CoreDataModel.migrate() throws`.
 */
public enum MigrationError: Error {

    /**
     Specifies that the `NSManagedObjectModel` corresponding to the existing persistent store was not found in the model's bundle.

     - parameter model: The model that failed to be migrated.
     */
    case sourceModelNotFound(model: CoreDataModel)

    /**
     Specifies that an `NSMappingModel` was not found in the model's bundle in the progressive migration 'path'.

     - parameter sourceModel: The destination managed object model for which a mapping model was not found.
     */
    case mappingModelNotFound(destinationModel: NSManagedObjectModel)
}

extension CoreDataModel {

    /**
     Progressively migrates the persistent store of the `CoreDataModel` based on mapping models found in the model's bundle.
     If the model returns false from `needsMigration`, then this function does nothing.

     - throws: If an error occurs, either an `NSError` or a `MigrationError` is thrown. If an `NSError` is thrown, it could
     specify any of the following: an error checking persistent store metadata, an error from `NSMigrationManager`, or
     an error from `NSFileManager`.

     - warning: Migration is only supported for on-disk persistent stores.
     A complete 'path' of mapping models must exist between the peristent store's version and the model's version.
     */
    public func migrate() throws {
        guard self.needsMigration else { return }

        guard let storeURL = self.storeURL, let storeDirectory = self.storeType.storeDirectory() else {
            preconditionFailure("*** Error: migration is only available for on-disk persistent stores. Invalid model: \(self)")
        }

        // could also throw NSError from NSPersistentStoreCoordinator
        guard let sourceModel = try findCompatibleModel(withBundle: self.bundle, storeType: self.storeType.type, storeURL: storeURL) else {
            throw MigrationError.sourceModelNotFound(model: self)
        }

        let migrationSteps = try buildMigrationMappingSteps(bundle: self.bundle,
                                                            sourceModel: sourceModel,
                                                            destinationModel: self.managedObjectModel)

        for step in migrationSteps {
            let tempURL = storeDirectory.appendingPathComponent("migration." + ModelFileExtension.sqlite.rawValue)

            // could throw error from `migrateStoreFromURL`
            let manager = NSMigrationManager(sourceModel: step.source, destinationModel: step.destination)
            try manager.migrateStore(from: storeURL,
                                     sourceType: self.storeType.type,
                                     options: nil,
                                     with: step.mapping,
                                     toDestinationURL: tempURL,
                                     destinationType: self.storeType.type,
                                     destinationOptions: nil)

            // could throw file system errors
            try self.removeExistingStore()
            try FileManager.default.moveItem(at: tempURL, to: storeURL)
        }
    }
}

// MARK: Internal

struct MigrationMappingStep {
    let source: NSManagedObjectModel
    let mapping: NSMappingModel
    let destination: NSManagedObjectModel
}

func findCompatibleModel(withBundle bundle: Bundle,
                         storeType: String,
                         storeURL: URL) throws -> NSManagedObjectModel? {
    let storeMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: storeType, at: storeURL, options: nil)
    let modelsInBundle = findModelsInBundle(bundle)
    for model in modelsInBundle where model.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata) {
        return model
    }
    return nil
}

func findModelsInBundle(_ bundle: Bundle) -> [NSManagedObjectModel] {
    guard let modelBundleDirectoryURLs = bundle.urls(forResourcesWithExtension: ModelFileExtension.bundle.rawValue, subdirectory: nil) else {
        return []
    }

    let modelBundleDirectoryNames = modelBundleDirectoryURLs.compactMap { url -> String? in
        url.lastPathComponent
    }

    let modelVersionFileURLs = modelBundleDirectoryNames.compactMap { name -> [URL]? in
        bundle.urls(forResourcesWithExtension: ModelFileExtension.versionedFile.rawValue, subdirectory: name)
    }
    .joined()
    .sorted { $0.absoluteString < $1.absoluteString }

    return modelVersionFileURLs.compactMap { url -> NSManagedObjectModel? in
        NSManagedObjectModel(contentsOf: url)
    }
}

func buildMigrationMappingSteps(bundle: Bundle,
                                sourceModel: NSManagedObjectModel,
                                destinationModel: NSManagedObjectModel) throws -> [MigrationMappingStep] {
    var migrationSteps = [MigrationMappingStep]()
    var nextModel = sourceModel
    repeat {
        guard let nextStep = nextMigrationMappingStep(fromSourceModel: nextModel, bundle: bundle) else {
            throw MigrationError.mappingModelNotFound(destinationModel: nextModel)
        }
        migrationSteps.append(nextStep)
        nextModel = nextStep.destination

    } while nextModel.entityVersionHashesByName != destinationModel.entityVersionHashesByName

    return migrationSteps
}

func nextMigrationMappingStep(fromSourceModel sourceModel: NSManagedObjectModel,
                              bundle: Bundle) -> MigrationMappingStep? {
    let modelsInBundle = findModelsInBundle(bundle)

    for nextDestinationModel in modelsInBundle where nextDestinationModel.entityVersionHashesByName != sourceModel.entityVersionHashesByName {
        if let mappingModel = NSMappingModel(from: [bundle],
                                             forSourceModel: sourceModel,
                                             destinationModel: nextDestinationModel) {
            return MigrationMappingStep(source: sourceModel, mapping: mappingModel, destination: nextDestinationModel)
        }
    }
    return nil
}
