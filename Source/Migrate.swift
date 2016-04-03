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

import CoreData
import Foundation



public enum MigrationError: ErrorType {
    case SourceModelNotFound(model: CoreDataModel)
    case MappingModelNotFound(sourceManagedObjectModel: NSManagedObjectModel)
}

/**
 Progressively migrates the persistent store of a `CoreDataModel` based on mapping models found in the model's bundle.

 - note: Migration is only supported for on-disk persistent stores.
 A complete 'path' of mapping models must exist between the peristent store's version and the model's version.

 - parameter model:      The `CoreDataModel` to perform migration upon.

 - throws: If the `NSManagedObjectModel` corresponding to the existing persistent store is not found in the model bundle
 then this function throws `.SourceManagedObjectModelNotFound`. If an `NSMappingModel` part of the progressive
 migration 'path' is not found in the model bundle then a `.MappingModelNotFound` is thrown.
 The function rethrows exceptions that may result from reading the persistent store metadata,
 file system operations or migration with `NSMigrationManager`.
 */
public func migrate(model: CoreDataModel) throws {

    guard model.needsMigration else { return }

    guard let storeURL = model.storeURL else {
        preconditionFailure("Migration is only available for on-disk persistent stores")
    }

    let storeType = model.storeType.type

    guard let sourceModel = try findModelCompatibleWithStore(model.bundle, storeType: storeType, storeURL: storeURL) else {
        throw MigrationError.SourceModelNotFound(model: model)
    }

    let migrationSteps = try buildMappingModelPath(model.bundle, sourceModel: sourceModel, destinationModel: model.managedObjectModel)

    for step in migrationSteps {
        let tempURL = defaultDirectoryURL().URLByAppendingPathComponent("migration.sqlite")

        let manager = NSMigrationManager(sourceModel: step.source, destinationModel: step.destination)
        try manager.migrateStoreFromURL(storeURL, type: storeType, options: nil, withMappingModel: step.mapping, toDestinationURL: tempURL, destinationType: storeType, destinationOptions: nil)

        try model.removeExistingStore()
        try NSFileManager.defaultManager().moveItemAtURL(tempURL, toURL: storeURL)
    }

}


// MARK: Internal

internal func findModelCompatibleWithStore(bundle: NSBundle, storeType: String, storeURL: NSURL) throws -> NSManagedObjectModel? {
    let storeMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(storeType, URL: storeURL, options: nil)

    for model in findModelsInBundle(bundle) where model.isConfiguration(nil, compatibleWithStoreMetadata: storeMetadata) {
        return model
    }

    return nil
}

internal func findModelsInBundle(bundle: NSBundle) -> [NSManagedObjectModel] {
    guard let modelDirectoryURLs = bundle.URLsForResourcesWithExtension("momd", subdirectory: nil) else {
        return []
    }

    let modelDirectoryNames = modelDirectoryURLs.flatMap { $0.lastPathComponent }

    let modelURLs = Array(modelDirectoryNames.flatMap { bundle.URLsForResourcesWithExtension("mom", subdirectory: $0) }.flatten())

    return modelURLs.flatMap { NSManagedObjectModel(contentsOfURL: $0) }
}

internal func buildMappingModelPath(bundle: NSBundle,
                                    sourceModel: NSManagedObjectModel,
                                    destinationModel: NSManagedObjectModel) throws -> [(source: NSManagedObjectModel, mapping: NSMappingModel, destination: NSManagedObjectModel)] {
    var migrationSteps: [(source: NSManagedObjectModel, mapping: NSMappingModel, destination: NSManagedObjectModel)] = []
    var stepModel: NSManagedObjectModel = sourceModel
    repeat {
        guard let nextModelAndMapping = nextIncrementalModelAndMapping(sourceModel: stepModel, bundle: bundle) else {
            throw MigrationError.MappingModelNotFound(sourceManagedObjectModel: stepModel)
        }

        migrationSteps.append((source: stepModel, mapping: nextModelAndMapping.mapping, destination: nextModelAndMapping.destination))
        stepModel = nextModelAndMapping.destination

    } while stepModel != destinationModel

    return migrationSteps
}

internal func nextIncrementalModelAndMapping(sourceModel sourceModel: NSManagedObjectModel, bundle: NSBundle) -> (destination: NSManagedObjectModel, mapping: NSMappingModel)? {
    for nextDestinationModel in findModelsInBundle(bundle) where nextDestinationModel != sourceModel {
        if let mappingModel = NSMappingModel(fromBundles: [bundle], forSourceModel: sourceModel, destinationModel: nextDestinationModel) {
            return (nextDestinationModel, mappingModel)
        }
    }
    
    return nil
}
