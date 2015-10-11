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


class TestCase: XCTestCase {

    let inMemoryModel = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .InMemory)

    var inMemoryStack: CoreDataStack!

    override func setUp() {
        super.setUp()

        let factory = CoreDataStackFactory(model: inMemoryModel)
        let result = factory.createStack()
        inMemoryStack = result.stack()
    }

    override func tearDown() {
        super.tearDown()
    }
    
}
