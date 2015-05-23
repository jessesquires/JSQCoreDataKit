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
        for i in 1...count {
            MyModel(context: stack.context)
        }

        // WHEN: we execute a fetch request
        let request = FetchRequest<MyModel>(entity: entity(name: MyModelEntityName, context: stack.context))
        let result = fetch(request: request, inContext: stack.context)

        // THEN: we receive the expected data
        XCTAssertTrue(result.success, "Fetch should succeed")
        XCTAssertEqual(result.objects.count, count, "Fetch should return \(count) objects")
        XCTAssertNil(result.error, "Fetch should not error")

        let saveResult = saveContextAndWait(stack.context)
        XCTAssertTrue(saveResult.success, "Save should succeed")
        XCTAssertNil(saveResult.error, "Save should not error")
    }

    func test_ThatFetchRequest_Succeeds_WithSpecificObject() {

        // GIVEN: a stack and objects in core data
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let count = 10
        for i in 1...count {
            MyModel(context: stack.context)
        }

        let myModel = MyModel(context: stack.context)
        
        // WHEN: we execute a fetch request for the specific object
        let request = FetchRequest<MyModel>(entity: entity(name: MyModelEntityName, context: stack.context))
        request.predicate = NSPredicate(format: "myString == %@", myModel.myString)

        let result = fetch(request: request, inContext: stack.context)
        let firstObject = result.objects.first
        
        // THEN: we receive the expected data
        XCTAssertTrue(result.success, "Fetch should succeed")
        XCTAssertEqual(result.objects.count, 1, "Fetch should return specific object \(myModel.description)")
        XCTAssertEqual(result.objects.first!, myModel, "Fetched object should equal expected model")
        XCTAssertNil(result.error, "Fetch should not error")

        let saveResult = saveContextAndWait(stack.context)
        XCTAssertTrue(saveResult.success, "Save should succeed")
        XCTAssertNil(saveResult.error, "Save should not error")
    }

    func test_ThatFetchRequest_Succeeds_WithoutObjects() {

        // GIVEN: a stack and no objects in core data
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        // WHEN: we execute a fetch request
        let request = FetchRequest<MyModel>(entity: entity(name: MyModelEntityName, context: stack.context))
        let result = fetch(request: request, inContext: stack.context)

        // THEN: we receive the expected data
        XCTAssertTrue(result.success, "Fetch should succeed")
        XCTAssertEqual(result.objects.count, 0, "Fetch should return 0 objects")
        XCTAssertNil(result.error, "Fetch should not error")

        let saveResult = saveContextAndWait(stack.context)
        XCTAssertTrue(saveResult.success, "Save should succeed")
        XCTAssertNil(saveResult.error, "Save should not error")
    }

}
