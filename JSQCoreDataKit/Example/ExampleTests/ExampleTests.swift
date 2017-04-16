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


class ExampleTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_ThatFakeBandInserts_Successfully() {

        let model = CoreDataModel(name: ModelName, bundle: ModelBundle)

        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let band = newFakeBand(stack.managedObjectContext)

        let result = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(result.success)
        XCTAssertNil(result.error)
    }

    func test_ThatFakeAlbumInserts_Successfully() {
        
        let model = CoreDataModel(name: ModelName, bundle: ModelBundle)

        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let band = newFakeBand(stack.managedObjectContext)
        let album = newFakeAlbum(stack.managedObjectContext, band)

        let result = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(result.success)
        XCTAssertNil(result.error)
    }
    
}
