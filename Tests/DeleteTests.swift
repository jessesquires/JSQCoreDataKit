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


class DeleteTests: TestCase {

    func test_ThatDelete_Succeeds_WithManyObjects() {
        // GIVEN: a stack and objects in core data
        let stack = self.inMemoryStack

        let count = 10
        let objects = generateEmployeesInContext(stack.mainContext, company: nil, count: count)

        let request = FetchRequest<Employee>(context: stack.mainContext)
        let results = try! stack.mainContext.fetch(request: request)
        XCTAssertEqual(results.count, count)

        // WHEN: we delete the objects
        stack.mainContext.delete(objects: objects)

        // THEN: the objects are removed from the context
        let resultAfterDelete = try! stack.mainContext.fetch(request: request)
        XCTAssertEqual(resultAfterDelete.count, 0, "Fetch should return 0 objects")

        XCTAssertTrue(stack.mainContext.hasChanges)

        saveContext(stack.mainContext) { result in
            XCTAssertTrue(result == .success, "Save should not error")
        }
    }

    func test_ThatDelete_Succeeds_WithSpecificObject() {
        // GIVEN: a stack and objects in core data
        let stack = self.inMemoryStack

        let count = 10
        generateEmployeesInContext(stack.mainContext, company: nil, count: count - 1)
        let myEmployee = Employee.newEmployee(stack.mainContext)

        let request = FetchRequest<Employee>(context: stack.mainContext)
        let results = try! stack.mainContext.fetch(request: request)
        XCTAssertEqual(results.count, count, "Fetch should return all \(count) objects")

        let requestForObject = FetchRequest<Employee>(context: stack.mainContext)
        requestForObject.predicate = NSPredicate(format: "name == %@", myEmployee.name)

        let resultForObject = try! stack.mainContext.fetch(request: requestForObject)
        XCTAssertEqual(resultForObject.count, 1, "Fetch should return specific object \(myEmployee.description)")
        XCTAssertEqual(resultForObject.first!, myEmployee, "Fetched object should equal expected model")

        // WHEN: we delete a specific object
        stack.mainContext.delete(objects: [myEmployee])

        // THEN: the specific object is removed from the context
        let resultAfterDelete = try! stack.mainContext.fetch(request: request)
        XCTAssertEqual(resultAfterDelete.count, count - 1, "Fetch should return remaining objects")

        let resultForObjectAfterDelete = try! stack.mainContext.fetch(request: requestForObject)
        XCTAssertEqual(resultForObjectAfterDelete.count, 0, "Fetch for specific object should return no objects")

        XCTAssertTrue(stack.mainContext.hasChanges)

        saveContext(stack.mainContext) { result in
            XCTAssertTrue(result == .success, "Save should not error")
        }
    }

    func test_ThatDelete_Succeeds_WithEmptyArray() {
        // GIVEN: a stack
        let stack = self.inMemoryStack

        // WHEN: we delete an empty array of objects
        stack.mainContext.delete(objects: [])
        
        // THEN: the operation is ignored
        XCTAssertFalse(stack.mainContext.hasChanges)
    }
    
}
