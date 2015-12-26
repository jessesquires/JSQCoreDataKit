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


class FetchTests: TestCase {

    func test_ThatFetchRequest_Succeeds_WithManyObjects() {
        // GIVEN: a stack and objects in core data
        let stack = self.inMemoryStack

        let count = 10
        generateEmployeesInContext(stack.mainContext, company: nil, count: count)

        // WHEN: we execute a fetch request
        let request = FetchRequest<Employee>(entity: entity(name: Employee.entityName, context: stack.mainContext))
        let results = try! fetch(request: request, inContext: stack.mainContext)

        // THEN: we receive the expected data
        XCTAssertEqual(results.count, count, "Fetch should return \(count) objects")

        saveContext(stack.mainContext) { result in
            XCTAssertTrue(result == .Success, "Save should not error")
        }
    }

    func test_ThatFetchRequest_Succeeds_WithSpecificObject() {
        // GIVEN: a stack and objects in core data
        let stack = self.inMemoryStack

        let count = 10
        generateEmployeesInContext(stack.mainContext, company: nil, count: count - 1)
        let myEmployee = Employee.newEmployee(stack.mainContext)
        
        // WHEN: we execute a fetch request for the specific object
        let request = FetchRequest<Employee>(entity: entity(name: Employee.entityName, context: stack.mainContext))
        request.predicate = NSPredicate(format: "name == %@", myEmployee.name)

        let results = try! fetch(request: request, inContext: stack.mainContext)

        // THEN: we receive the expected data
        XCTAssertEqual(results.count, 1, "Fetch should return specific object \(myEmployee.description)")
        XCTAssertEqual(results.first!, myEmployee, "Fetched object should equal expected model")

        saveContext(stack.mainContext) { result in
            XCTAssertTrue(result == .Success, "Save should not error")
        }
    }

    func test_ThatFetchRequest_Succeeds_WithoutObjects() {
        // GIVEN: a stack and no objects in core data
        let stack = self.inMemoryStack

        // WHEN: we execute a fetch request
        let request = FetchRequest<Employee>(entity: entity(name: Employee.entityName, context: stack.mainContext))
        let results = try! fetch(request: request, inContext: stack.mainContext)

        // THEN: we receive the expected data
        XCTAssertEqual(results.count, 0, "Fetch should return 0 objects")
    }
    
}
