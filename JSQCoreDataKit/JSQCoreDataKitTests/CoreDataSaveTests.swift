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

import JSQCoreDataKit
import ExampleModel

let modelId = ModelId()


class CoreDataSaveTests: XCTestCase {

    let model = CoreDataModel(name: modelId.name, bundle: modelId.bundle)

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_ThatSaveAndWait_WithoutChanges_IsIgnored() {

        // GIVEN: a stack and context
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        // WHEN: we attempt to save the context
        let results = saveContextAndWait(stack.managedObjectContext)

        // THEN: the save operation is ignored, save reports success and no error
        let result = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(result.success)
        XCTAssertNil(result.error)
    }
    
}
