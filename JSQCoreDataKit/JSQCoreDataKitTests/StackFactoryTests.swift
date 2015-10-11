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


class StackFactoryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        
        let sqliteModel = CoreDataModel(name: modelName, bundle: modelBundle)
        let factory = CoreDataStackFactory(model: sqliteModel)

        var stack: CoreDataStack?

        let expect = self.expectationWithDescription("init")

        factory.createStackInBackground { (result: CoreDataStackResult) -> Void in

            switch result {
            case .Success(let s):
                stack = s
            case .Failure(let e):
                print("Error: \(e)")
                XCTFail()
            }

            expect.fulfill()
        }

        waitForExpectationsWithTimeout(10, handler: nil)

        XCTAssertNotNil(stack)

        print(stack)
    }

}
