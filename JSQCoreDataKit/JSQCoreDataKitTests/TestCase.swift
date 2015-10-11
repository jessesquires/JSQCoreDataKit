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


let modelName = "ExampleModel"
let modelBundle = NSBundle(identifier: "com.hexedbits.ExampleModel")!


class TestCase: XCTestCase {

    let inMemoryModel = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .InMemory)

    let inMemoryStack: CoreDataStack = {
        let inMemoryModel = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .InMemory)
        return CoreDataStack(model: inMemoryModel)
    }()


    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
}
