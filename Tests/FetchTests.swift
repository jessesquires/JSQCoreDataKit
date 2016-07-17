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


final class FetchTests: TestCase {

    func test_ThatFetchRequest_Succeeds_WithManyObjects() {
        // GIVEN: a stack and objects in core data
        let count = 10
        _ = generateEmployeesInContext(inMemoryStack.mainContext, company: nil, count: count)

        // WHEN: we execute a fetch request
        let request = NSFetchRequest<Employee>(entityName: Employee.entityName)
        let results = try! inMemoryStack.mainContext.fetch(request: request)

        // THEN: we receive the expected data
        XCTAssertEqual(results.count, count, "Fetch should return \(count) objects")

        saveContext(inMemoryStack.mainContext) { result in
            XCTAssertTrue(result == .success, "Save should not error")
        }
    }

    func test_ThatFetchRequest_Succeeds_WithSpecificObject() {
        // GIVEN: a stack and objects in core data
        let count = 10
        _ = generateEmployeesInContext(inMemoryStack.mainContext, company: nil, count: count - 1)
        let myEmployee = Employee.newEmployee(inMemoryStack.mainContext)

        // WHEN: we execute a fetch request for the specific object
        let request = NSFetchRequest<Employee>(entityName: Employee.entityName)
        request.predicate = Predicate(format: "name == %@", myEmployee.name)

        let results = try! inMemoryStack.mainContext.fetch(request: request)

        // THEN: we receive the expected data
        XCTAssertEqual(results.count, 1, "Fetch should return specific object \(myEmployee.description)")
        XCTAssertEqual(results.first!, myEmployee, "Fetched object should equal expected model")

        saveContext(inMemoryStack.mainContext) { result in
            XCTAssertTrue(result == .success, "Save should not error")
        }
    }

    func test_ThatFetchRequest_Succeeds_WithoutObjects() {
        // GIVEN: a stack and no objects in core data
        // WHEN: we execute a fetch request
        let request = NSFetchRequest<Employee>(entityName: Employee.entityName)
        let results = try! inMemoryStack.mainContext.fetch(request: request)

        // THEN: we receive the expected data
        XCTAssertEqual(results.count, 0, "Fetch should return 0 objects")
    }
}
