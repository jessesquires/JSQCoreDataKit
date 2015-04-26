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

    func test_ThatFetchRequest_Succeeds_WithObjects() {

        // GIVEN: a stack and objects in core data
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let count = 10
        for i in 1...count {
            MyModel(context: stack.managedObjectContext)
        }

        // WHEN: we execute a fetch request
        let request = FetchRequest<MyModel>(entity: entity(name: MyModelEntityName, context: stack.managedObjectContext))
        let result = fetch(request: request, inContext: stack.managedObjectContext)

        // THEN: we receive the expected data
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.objects.count, count)
        XCTAssertNil(result.error)

        let saveResult = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(saveResult.success)
        XCTAssertNil(saveResult.error)
    }

    func test_ThatFetchRequest_Succeeds_WithSpecificObject() {

        // GIVEN: a stack and objects in core data
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let count = 10
        for i in 1...count {
            MyModel(context: stack.managedObjectContext)
        }

        let myModel = MyModel(context: stack.managedObjectContext)

        println("MODEL = \(myModel)")

        // WHEN: we execute a fetch request for the specific object
        let request = FetchRequest<MyModel>(entity: entity(name: MyModelEntityName, context: stack.managedObjectContext))
        request.predicate = NSPredicate(format: "myString == %@", myModel.myString)

        let result = fetch(request: request, inContext: stack.managedObjectContext)
        let firstObject = result.objects.first
        
        // THEN: we receive the expected data
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.objects.count, 1)
        XCTAssertEqual(result.objects.first!, myModel)
        XCTAssertNil(result.error)

        let saveResult = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(saveResult.success)
        XCTAssertNil(saveResult.error)
    }

    func test_ThatFetchRequest_Succeeds_WithoutObjects() {

        // GIVEN: a stack and no objects in core data
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        // WHEN: we execute a fetch request
        let request = FetchRequest<MyModel>(entity: entity(name: MyModelEntityName, context: stack.managedObjectContext))
        let result = fetch(request: request, inContext: stack.managedObjectContext)

        // THEN: we receive the expected data
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.objects.count, 0)
        XCTAssertNil(result.error)

        let saveResult = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(saveResult.success)
        XCTAssertNil(saveResult.error)
    }

}
