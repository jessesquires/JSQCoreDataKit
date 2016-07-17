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
        let count = 10
        let objects = generateEmployeesInContext(inMemoryStack.mainContext, company: nil, count: count)

        let request = NSFetchRequest<Employee>(entityName: Employee.entityName)
        let results = try? inMemoryStack.mainContext.fetch(request: request)
        XCTAssertEqual(results?.count, count)

        // WHEN: we delete the objects
        inMemoryStack.mainContext.delete(objects: objects)

        // THEN: the objects are removed from the context
        let resultAfterDelete = try? inMemoryStack.mainContext.fetch(request: request)
        XCTAssertEqual(resultAfterDelete?.count, 0, "Fetch should return 0 objects")

        XCTAssertTrue(inMemoryStack.mainContext.hasChanges)

        saveContext(inMemoryStack.mainContext) { result in
            XCTAssertTrue(result == .success, "Save should not error")
        }
    }

    func test_ThatDelete_Succeeds_WithSpecificObject() {
        // GIVEN: a stack and objects in core data
        let count = 10
        _ = generateEmployeesInContext(inMemoryStack.mainContext, company: nil, count: count - 1)
        let myEmployee = Employee.newEmployee(inMemoryStack.mainContext)

        let request = NSFetchRequest<Employee>(entityName: Employee.entityName)
        let results = try? inMemoryStack.mainContext.fetch(request: request)
        XCTAssertEqual(results?.count, count, "Fetch should return all \(count) objects")

        let requestForObject = NSFetchRequest<Employee>(entityName: Employee.entityName)
        requestForObject.predicate = Predicate(format: "name == %@", myEmployee.name)

        let resultForObject = try? inMemoryStack.mainContext.fetch(request: requestForObject)
        XCTAssertEqual(resultForObject?.count, 1, "Fetch should return specific object \(myEmployee.description)")
        XCTAssertEqual(resultForObject?.first!, myEmployee, "Fetched object should equal expected model")

        // WHEN: we delete a specific object
        inMemoryStack.mainContext.delete(objects: [myEmployee])

        // THEN: the specific object is removed from the context
        let resultAfterDelete = try? inMemoryStack.mainContext.fetch(request: request)
        XCTAssertEqual(resultAfterDelete?.count, count - 1, "Fetch should return remaining objects")

        let resultForObjectAfterDelete = try? inMemoryStack.mainContext.fetch(request: requestForObject)
        XCTAssertEqual(resultForObjectAfterDelete?.count, 0, "Fetch for specific object should return no objects")

        XCTAssertTrue(inMemoryStack.mainContext.hasChanges)

        saveContext(inMemoryStack.mainContext) { result in
            XCTAssertTrue(result == .success, "Save should not error")
        }
    }

    func test_ThatDelete_Succeeds_WithEmptyArray() {
        // GIVEN: a stack
        // WHEN: we delete an empty array of objects
        inMemoryStack.mainContext.delete(objects: [])
        
        // THEN: the operation is ignored
        XCTAssertFalse(inMemoryStack.mainContext.hasChanges)
    }
    
}
