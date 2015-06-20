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


class FetchTests: ModelTestCase {

    func test_ThatFetchRequest_Succeeds_WithManyObjects() {

        // GIVEN: a stack and objects in core data
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let count = 10
        for _ in 1...count {
            MyModel(context: stack.managedObjectContext)
        }

        // WHEN: we execute a fetch request
        let request = FetchRequest<MyModel>(entity: entity(name: MyModelEntityName, context: stack.managedObjectContext))
        let results = try! fetch(request: request, inContext: stack.managedObjectContext)

        // THEN: we receive the expected data
        XCTAssertEqual(results.count, count, "Fetch should return \(count) objects")

        saveContext(stack.managedObjectContext) { error in
            XCTAssertNil(error, "Save should not error")
        }
    }

    func test_ThatFetchRequest_Succeeds_WithSpecificObject() {

        // GIVEN: a stack and objects in core data
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let count = 10
        for _ in 1...count {
            MyModel(context: stack.managedObjectContext)
        }

        let myModel = MyModel(context: stack.managedObjectContext)

        // WHEN: we execute a fetch request for the specific object
        let request = FetchRequest<MyModel>(entity: entity(name: MyModelEntityName, context: stack.managedObjectContext))
        request.predicate = NSPredicate(format: "myString == %@", myModel.myString)

        let results = try! fetch(request: request, inContext: stack.managedObjectContext)

        // THEN: we receive the expected data
        XCTAssertEqual(results.count, 1, "Fetch should return specific object \(myModel.description)")
        XCTAssertEqual(results.first!, myModel, "Fetched object should equal expected model")

        saveContext(stack.managedObjectContext) { error in
            XCTAssertNil(error, "Save should not error")
        }
    }

    func test_ThatFetchRequest_Succeeds_WithoutObjects() {

        // GIVEN: a stack and no objects in core data
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        // WHEN: we execute a fetch request
        let request = FetchRequest<MyModel>(entity: entity(name: MyModelEntityName, context: stack.managedObjectContext))
        let results = try! fetch(request: request, inContext: stack.managedObjectContext)

        // THEN: we receive the expected data
        XCTAssertEqual(results.count, 0, "Fetch should return 0 objects")

        saveContext(stack.managedObjectContext) { error in
            XCTAssertNil(error, "Save should not error")
        }
    }
    
}
