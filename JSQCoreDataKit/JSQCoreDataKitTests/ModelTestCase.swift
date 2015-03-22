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


class ModelTestCase: XCTestCase {

    let model = CoreDataModel(name: ExampleModelProperties().name,
                              bundle: ExampleModelProperties().bundle)

    override func setUp() {

        model.removeExistingModelStore()

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

}
