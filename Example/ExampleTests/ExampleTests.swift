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


let model = CoreDataModel(name: ModelName, bundle: ModelBundle, storeType: .InMemory)

let stack = CoreDataStack(model: model)


class ExampleTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_ThatFakeBandInserts_Successfully() {

        newFakeBand(stack.mainQueueContext)

        saveContext(stack.mainQueueContext) { error in
            XCTAssertNil(error, "Save should not error")
        }
    }

    func test_ThatFakeAlbumInserts_Successfully() {

        let band = newFakeBand(stack.mainQueueContext)
        newFakeAlbum(stack.mainQueueContext, band: band)

        saveContext(stack.mainQueueContext) { error in
            XCTAssertNil(error, "Save should not error")
        }
    }

}
