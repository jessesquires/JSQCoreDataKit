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


final class CoreDataEntityProtocolTests: TestCase {

    func test_thatManagedObjects_returnCorrect_entityName() {
        // GIVEN: managed objects
        // WHEN: we ask for entity name
        // THEN: we receive expected values

        XCTAssertEqual(Company.entityName, "Company")
        XCTAssertEqual(Employee.entityName, "Employee")
    }

    func test_thatManagedObjects_returnCorrect_entityDescription() {
        // GIVEN: managed objects
        // WHEN: we ask for entity descriptions
        // THEN: we receive expected values

        let companyEntity = Company.entity(context: inMemoryStack.mainContext)
        XCTAssertEqual(companyEntity.name, "Company")
        XCTAssertEqual(companyEntity.managedObjectModel, inMemoryModel.managedObjectModel)

        let employeeEntity = Employee.entity(context: inMemoryStack.mainContext)
        XCTAssertEqual(employeeEntity.name, "Employee")
        XCTAssertEqual(employeeEntity.managedObjectModel, inMemoryModel.managedObjectModel)
    }

    func test_thatManagedObjects_returnCorrect_fetchRequest_andFetchesFromContext() {
        // GIVEN: managed objects
        let context = inMemoryStack.mainContext
        context.performAndWait {
            self.generateDataInContext(context, companiesCount: 2, employeesCount: 4)
        }

        // WHEN: we generate and execute fetch requests
        let companyFetch = Company.fetchRequest
        let companyResults = try? context.fetch(companyFetch)

        let employeeFetch = Employee.fetchRequest
        let employeeResults = try? context.fetch(employeeFetch)

        // THEN: we receive expected values
        XCTAssertNotNil(companyResults)
        XCTAssertEqual(companyResults?.count, 2)

        XCTAssertNotNil(employeeResults)
        XCTAssertEqual(employeeResults?.count, 8)
    }
}
