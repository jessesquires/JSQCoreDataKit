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

    // We'll be using an in-memory store, thus we don't need a real storeURL
    let model = CoreDataModel(name: modelName, bundle: modelBundle, storeDirectory: NSURL())

    override func setUp() {
        do {
            try model.removeExistingModelStore()
        } catch { }

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
}
