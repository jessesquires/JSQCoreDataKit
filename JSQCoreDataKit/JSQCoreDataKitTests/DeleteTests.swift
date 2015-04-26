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


class DeleteTests: ModelTestCase {

    func test_ThatDelete_Succeeds_WithManyObjects() {

        // GIVEN: a stack and objects in core data
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let count = 10
        var objects = [MyModel]()
        for i in 1...count {
            objects.append(MyModel(context: stack.managedObjectContext))
        }

        let request = FetchRequest<MyModel>(entity: entity(name: MyModelEntityName, context: stack.managedObjectContext))
        let result = fetch(request: request, inContext: stack.managedObjectContext)
        XCTAssertEqual(result.objects.count, count)

        // WHEN: we delete the objects
        deleteObjects(objects, inContext: stack.managedObjectContext)

        // THEN: the objects are removed from the context
        let resultAfterDelete = fetch(request: request, inContext: stack.managedObjectContext)
        XCTAssertEqual(resultAfterDelete.objects.count, 0, "Fetch should return 0 objects")

        let saveResult = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(saveResult.success, "Save should succeed")
        XCTAssertNil(saveResult.error, "Save should not error")
    }

    func test_ThatDelete_Succeeds_WithSpecificObject() {
        
        // GIVEN: a stack and objects in core data
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let count = 10
        var objects = [MyModel]()
        for i in 1..<count {
            objects.append(MyModel(context: stack.managedObjectContext))
        }

        let myModel = MyModel(context: stack.managedObjectContext)

        let request = FetchRequest<MyModel>(entity: entity(name: MyModelEntityName, context: stack.managedObjectContext))
        let result = fetch(request: request, inContext: stack.managedObjectContext)
        XCTAssertEqual(result.objects.count, count, "Fetch should return all \(count) objects")

        let requestForObject = FetchRequest<MyModel>(entity: entity(name: MyModelEntityName, context: stack.managedObjectContext))
        requestForObject.predicate = NSPredicate(format: "myString == %@", myModel.myString)

        let resultForObject = fetch(request: requestForObject, inContext: stack.managedObjectContext)
        XCTAssertEqual(resultForObject.objects.count, 1, "Fetch should return specific object \(myModel.description)")
        XCTAssertEqual(resultForObject.objects.first!, myModel, "Fetched object should equal expected model")

        // WHEN: we delete a specific object
        deleteObjects([myModel], inContext: stack.managedObjectContext)

        // THEN: the specific object is removed from the context
        let resultAfterDelete = fetch(request: request, inContext: stack.managedObjectContext)
        XCTAssertEqual(resultAfterDelete.objects.count, count - 1, "Fetch should return remaining objects")

        let resultForObjectAfterDelete = fetch(request: requestForObject, inContext: stack.managedObjectContext)
        XCTAssertEqual(resultForObjectAfterDelete.objects.count, 0, "Fetch for specific object should return no objects")

        let saveResult = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(saveResult.success, "Save should succeed")
        XCTAssertNil(saveResult.error, "Save should not error")
    }

    func test_ThatDelete_Succeeds_WithEmptyArray() {

        // GIVEN: a stack 
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        // WHEN: we delete an empty array of objects
        deleteObjects([], inContext: stack.managedObjectContext)

        // THEN: the operation is ignored

        let saveResult = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(saveResult.success, "Save should succeed")
        XCTAssertNil(saveResult.error, "Save should not error")
    }

}
