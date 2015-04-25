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

    func test_ThatDelete_Succeeds_WithObjects() {

        // GIVEN: a stack and objects in core data
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        let count = 10
        var objects = [Band]()
        for i in 1...count {
            objects.append(newFakeBand(stack.managedObjectContext))
        }

        let request = FetchRequest<Band>(entity: entity(name: Band.entityName, context: stack.managedObjectContext))
        let result = fetch(request: request, inContext: stack.managedObjectContext)
        XCTAssertEqual(result.objects.count, count)

        // WHEN: we delete the objects
        deleteObjects(objects, inContext: stack.managedObjectContext)

        // THEN: the objects are removed from the context
        let resultAfterDelete = fetch(request: request, inContext: stack.managedObjectContext)
        XCTAssertEqual(resultAfterDelete.objects.count, 0)

        let saveResult = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(saveResult.success)
        XCTAssertNil(saveResult.error)
    }

    func test_ThatDelete_Succeeds_WithEmptyArray() {

        // GIVEN: a stack 
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        // WHEN: we delete an empty array of objects
        deleteObjects([], inContext: stack.managedObjectContext)

        // THEN: the operation is ignored

        
        let saveResult = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(saveResult.success)
        XCTAssertNil(saveResult.error)
    }

}
