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

let modelName = "TestModel"
let modelBundle = NSBundle(forClass: ModelTests.self)


class ModelTestCase: XCTestCase {

    let model = CoreDataModel(name: modelName, bundle: modelBundle, storeDirectoryURL: NSURL())

    override func setUp() {
        model.removeExistingModelStore()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

}
