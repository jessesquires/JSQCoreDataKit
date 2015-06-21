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


class TestCase: XCTestCase {

    let inMemoryModel = CoreDataModel(name: modelName, storeType: .InMemory, bundle: modelBundle)

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
}
