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

import XCTest
import CoreData

import ExampleModel

@testable
import JSQCoreDataKit


class ContextSyncTests: TestCase {

    var model: CoreDataModel!
    var stack: CoreDataStack!

    override func setUp() {
        super.setUp()
        setUpStack()
    }

    override func tearDown() {
        tearDownStack()
        super.tearDown()
    }

    func test_ThatChangesPropagate_FromMainContext_ToBackgroundContext_ToStore() {
        // TODO:
    }

    func test_ThatChangesPropagate_FromBackgroundContext_ToMainContext() {
        // TODO:
    }

    func test_ThatChangesPropagate_FromChildContext_ToMainContext() {
        // TODO:
    }

    func test_ThatUnsavedChangesFromChildContext_DoNotPropogate() {
        // TODO:
    }


    // MARK: Helpers

    func setUpStack() {
        let tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory())
        model = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .SQLite(tempDir))

        let factory = CoreDataStackFactory(model: model)
        let result = factory.createStack()
        stack = result.stack()
    }

    func tearDownStack() {
        try! model.removeExistingModelStore()
        model = nil
        stack = nil
    }

}
