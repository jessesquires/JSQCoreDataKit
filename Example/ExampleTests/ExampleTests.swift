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

        newFakeBand(stack.context)

        saveContext(stack.context) { error in
            XCTAssertNil(error, "Save should not error")
        }
    }

    func test_ThatFakeAlbumInserts_Successfully() {
        
        let model = CoreDataModel(name: ModelName, bundle: ModelBundle)

        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let band = newFakeBand(stack.context)
        newFakeAlbum(stack.context, band: band)

        saveContext(stack.context) { error in
            XCTAssertNil(error, "Save should not error")
        }
    }

}
