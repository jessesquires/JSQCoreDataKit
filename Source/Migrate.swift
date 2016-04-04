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

     - parameter model: The model that failed to be migrated.
     */
    case sourceModelNotFound(model: CoreDataModel)

    /**
     Specifies that an `NSMappingModel` was not found in the model's bundle in the progressive migration 'path'.

     - parameter sourceModel: The destination managed object model for which a mapping model was not found.
     */
    case mappingModelNotFound(destinationModel: NSManagedObjectModel)
}


/**
 Progressively migrates the persistent store of the specified `CoreDataModel` based on mapping models found in the model's bundle.
 If model returns false from `.needsMigration`, this function does nothing.

 - parameter model: The `CoreDataModel` instance on which to perform a migration.

 - throws: If an error occurs, either an `NSError` or a `MigrationError` is thrown. If an `NSError` is thrown, it could 
 specify any of the following: an error checking persistent store metadata, an error from `NSMigrationManager`, or
 an error from `NSFileManager`.

 - warning: Migration is only supported for on-disk persistent stores.
 A complete 'path' of mapping models must exist between the peristent store's version and the model's version.
 */
public func migrate(model: CoreDataModel) throws {
    guard model.needsMigration else { return }

    guard let storeURL = model.storeURL, let storeDirectory = model.storeType.storeDirectory() else {
        preconditionFailure("*** Error: migration is only available for on-disk persistent stores. Received invalid model: \(model)")
    }

    let bundle = model.bundle
    let storeType = model.storeType.type

    // could also throw NSError from NSPersistentStoreCoordinator
    guard let sourceModel = try findCompatibleModel(withBundle: bundle, storeType: storeType, storeURL: storeURL) else {
        throw MigrationError.sourceModelNotFound(model: model)
    }

    let migrationSteps = try buildMigrationMappingSteps(bundle: bundle,
                                                        sourceModel: sourceModel,
                                                        destinationModel: model.managedObjectModel)

    for step in migrationSteps {
        let tempURL = storeDirectory.URLByAppendingPathComponent("migration." + ModelFileExtension.sqlite.rawValue)

        // could throw error from `migrateStoreFromURL`
        let manager = NSMigrationManager(sourceModel: step.source, destinationModel: step.destination)
        try manager.migrateStoreFromURL(storeURL,
                                        type: storeType,
                                        options: nil,
                                        withMappingModel: step.mapping,
                                        toDestinationURL: tempURL,
                                        destinationType: storeType,
                                        destinationOptions: nil)

        // could throw file system errors
        try model.removeExistingStore()
        try NSFileManager.defaultManager().moveItemAtURL(tempURL, toURL: storeURL)
    }

}


// MARK: Internal

internal struct MigrationMappingStep: CustomStringConvertible {
    let source: NSManagedObjectModel
    let mapping: NSMappingModel
    let destination: NSManagedObjectModel

    var description: String {
        get {
            return "\(MigrationMappingStep.self): source=\(source); mapping=\(mapping); destination=\(destination);"
        }
    }
}


internal func findCompatibleModel(withBundle bundle: NSBundle, storeType: String, storeURL: NSURL) throws -> NSManagedObjectModel? {
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


internal func buildMigrationMappingSteps(bundle bundle: NSBundle,
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

    } while nextModel != destinationModel

    return migrationSteps
}


internal func nextMigrationMappingStep(fromSourceModel sourceModel: NSManagedObjectModel, bundle: NSBundle) -> MigrationMappingStep? {
    let modelsInBundle = findModelsInBundle(bundle)

    for nextDestinationModel in modelsInBundle where nextDestinationModel != sourceModel {
        if let mappingModel = NSMappingModel(fromBundles: [bundle],
                                             forSourceModel: sourceModel,
                                             destinationModel: nextDestinationModel) {
            return MigrationMappingStep(source: sourceModel, mapping: mappingModel, destination: nextDestinationModel)
        }
    }
    return nil
}
