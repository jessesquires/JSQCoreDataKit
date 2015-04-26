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

import ExampleModel

import JSQCoreDataKit


let modelProperties = ExampleModelProperties()


class ExampleTests: XCTestCase {

    let model = CoreDataModel(name: modelProperties.name, bundle: modelProperties.bundle)

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_ThatCoreDataModel_DoesNotNeedMigration() {

        // GIVEN: a model with 1 version

        // WHEN: we check if it needs migration

        // THEN: the store doesn't need migration
        XCTAssertFalse(model.modelStoreNeedsMigration)
    }

    func test_ThatFakeBandInserts_Successfully() {

        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let band = newFakeBand(stack.managedObjectContext)

        let result = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(result.success)
        XCTAssertNil(result.error)
    }

    func test_ThatFakeAlbumInserts_Successfully() {

        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let band = newFakeBand(stack.managedObjectContext)
        let album = newFakeAlbum(stack.managedObjectContext, band)

        let result = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(result.success)
        XCTAssertNil(result.error)
    }
    
}
