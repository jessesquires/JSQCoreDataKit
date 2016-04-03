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

/**
 An error type that specifies possible errors that are thrown by calling `func migrate(model: CoreDataModel) throws`
 */
public enum MigrationError: ErrorType {

    /**
     Specifies that the `NSManagedObjectModel` corresponding to the existing persistent store was not found in the model's bundle.

     - parameter model: The model attempting to be migrated.
     */
    case SourceModelNotFound(model: CoreDataModel)

    /**
     Specifies that an `NSMappingModel` was not found in the model's bundle in the progressive migration 'path'.

     - parameter sourceManagedObjectModel: The managed object model
     */
    case MappingModelNotFound(sourceManagedObjectModel: NSManagedObjectModel)
}


/**
 Progressively migrates the persistent store of the specified `CoreDataModel` based on mapping models found in the model's bundle.
 If model returns false from `.needsMigration`, this function does nothing.

 - parameter model: The `CoreDataModel` instance on which to perform a migration.

 - throws: If an error occurs, a `MigrationError` is thrown.
 - seealso: `MigrationError`

 - warning: Migration is only supported for on-disk persistent stores.
 A complete 'path' of mapping models must exist between the peristent store's version and the model's version.
 */
public func migrate(model: CoreDataModel) throws {
    guard model.needsMigration else { return }

    guard let storeURL = model.storeURL else {
        preconditionFailure("*** Error: migration is only available for on-disk persistent stores. Model storeURL is nil.")
    }

    let bundle = model.bundle
    let storeType = model.storeType.type

    guard let sourceModel = try findModelCompatibleWithStore(bundle, storeType: storeType, storeURL: storeURL) else {
        throw MigrationError.SourceModelNotFound(model: model)
    }

    let migrationSteps = try buildMappingModelPath(bundle, sourceModel: sourceModel, destinationModel: model.managedObjectModel)

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

    let modelsInBundle = findModelsInBundle(bundle)
    for model in modelsInBundle where model.isConfiguration(nil, compatibleWithStoreMetadata: storeMetadata) {
        return model
    }

    return nil
}


internal func findModelsInBundle(bundle: NSBundle) -> [NSManagedObjectModel] {
    guard let modelBundleDirectoryURLs = bundle.URLsForResourcesWithExtension(ModelFileExtension.bundle.rawValue, subdirectory: nil) else {
        return []
    }

    let modelBundleDirectoryNames = modelBundleDirectoryURLs.flatMap { url -> String? in
        url.lastPathComponent
    }

    let modelVersionFileURLs = modelBundleDirectoryNames.flatMap { name -> [NSURL]? in
        bundle.URLsForResourcesWithExtension(ModelFileExtension.versionedFile.rawValue, subdirectory: name)
    }

    let managedObjectModels = Array(modelVersionFileURLs.flatten()).flatMap { url -> NSManagedObjectModel? in
        NSManagedObjectModel(contentsOfURL: url)
    }

    return managedObjectModels
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
    let modelsInBundle = findModelsInBundle(bundle)
    for nextDestinationModel in modelsInBundle where nextDestinationModel != sourceModel {
        if let mappingModel = NSMappingModel(fromBundles: [bundle], forSourceModel: sourceModel, destinationModel: nextDestinationModel) {
            return (nextDestinationModel, mappingModel)
        }
    }
    
    return nil
}
