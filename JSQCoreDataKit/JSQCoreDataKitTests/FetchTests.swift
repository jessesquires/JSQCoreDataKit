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
            newFakeBand(stack.managedObjectContext)
        }

        // WHEN: we execute a fetch request
        let request = FetchRequest<Band>(entity: entity(name: Band.entityName, context: stack.managedObjectContext)!)
        let result = fetch(request: request, inContext: stack.managedObjectContext)

        // THEN: we receive the expected data
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.objects.count, count)
        XCTAssertNil(result.error)

        let saveResult = saveContextAndWait(stack.managedObjectContext)
        XCTAssertTrue(saveResult.success)
        XCTAssertNil(saveResult.error)
    }

    func test_ThatFetchRequest_Succeeds_WithoutObjects() {

        // GIVEN: a stack and no objects in core data
        let stack = CoreDataStack(model: model, storeType: NSInMemoryStoreType)

        // WHEN: we execute a fetch request
        let request = FetchRequest<Band>(entity: entity(name: Band.entityName, context: stack.managedObjectContext)!)
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
