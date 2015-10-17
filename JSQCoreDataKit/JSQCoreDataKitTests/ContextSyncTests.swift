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


class ContextSyncTests: TestCase {

    func test_ThatUnsavedChangesFromChildContext_DoNotPropogate() {
        // GIVEN: objects in a child context
        let childContext = inMemoryStack.childContext()
        generateDataInContext(childContext, companiesCount: 3, employeesCount: 3)

        // WHEN: we do not save the child context

        // WHEN: we fetch the objects from the main context
        let request = FetchRequest<Company>(entity: entity(name: Company.entityName, context: inMemoryStack.mainContext))
        let results = [Company]()
        try! fetch(request: request, inContext: inMemoryStack.mainContext)

        // THEN: the main context does not return any objects
        XCTAssertEqual(results.count, 0, "Main context should return nothing")
    }

    func test_ThatChangesPropagate_FromMainContext_ToBackgroundContext() {
        // GIVEN: objects in the main context
        let companies = generateDataInContext(inMemoryStack.mainContext, companiesCount:3, employeesCount:3)
        let companyNames = companies.map { $0.name }

        // WHEN: we save the main context
        expectationForNotification(NSManagedObjectContextDidSaveNotification, object: inMemoryStack.mainContext, handler: nil)
        expectationForNotification(NSManagedObjectContextDidSaveNotification, object: inMemoryStack.backgroundContext, handler: nil)

        saveContext(inMemoryStack.mainContext) { result in
            XCTAssertTrue(result == .Success)
        }

        waitForExpectationsWithTimeout(DefaultTimeout) { (error) in
            XCTAssertNil(error, "Expectation should not error")
        }

        // WHEN: we fetch the objects in the background context
        let request = FetchRequest<Company>(entity: entity(name: Company.entityName, context: inMemoryStack.backgroundContext))
        let results = try! fetch(request: request, inContext: inMemoryStack.backgroundContext)

        // THEN: the background context returns the objects
        XCTAssertEqual(results.count, companies.count, "Background context should return same objects")
        results.forEach { (company: Company) in
            XCTAssertTrue(companyNames.contains(company.name), "Background context should return same objects")
        }
    }

    func test_ThatChangesPropagate_FromBackgroundContext_ToMainContext() {
        // GIVEN: objects in the background context
        let companies = generateDataInContext(inMemoryStack.backgroundContext, companiesCount: 3, employeesCount: 3)
        let companyNames = companies.map { $0.name }

        // WHEN: we fetch the objects from the main context
        let request = FetchRequest<Company>(entity: entity(name: Company.entityName, context: inMemoryStack.mainContext))
        let results = try! fetch(request: request, inContext: inMemoryStack.mainContext)

        // THEN: the main context returns the objects
        XCTAssertEqual(results.count, companies.count, "Main context should return the same objects")
        results.forEach { (company: Company) in
            XCTAssertTrue(companyNames.contains(company.name), "Main context should return same objects")
        }
    }

    func test_ThatChangesPropagate_FromChildContext_ToMainContext() {
        // GIVEN: objects in a child context
        let childContext = inMemoryStack.childContext()
        let companies = generateDataInContext(childContext, companiesCount: 3, employeesCount: 3)
        let companyNames = companies.map { $0.name }

        // WHEN: we save the child context
        expectationForNotification(NSManagedObjectContextDidSaveNotification, object: childContext, handler: nil)
        saveContext(childContext) { (result) -> Void in
            XCTAssertTrue(result == .Success)
        }

        waitForExpectationsWithTimeout(DefaultTimeout) { (error) in
            XCTAssertNil(error, "Expectation should not error")
        }

        // WHEN: we fetch the objects from the main context
        let request = FetchRequest<Company>(entity: entity(name: Company.entityName, context: inMemoryStack.mainContext))
        let results = try! fetch(request: request, inContext: inMemoryStack.mainContext)

        // THEN: the main context returns the objects
        XCTAssertEqual(results.count, companies.count, "Main context should return the same objects")
        results.forEach { (company: Company) in
            XCTAssertTrue(companyNames.contains(company.name), "Main context should return same objects")
        }
    }
    
}
