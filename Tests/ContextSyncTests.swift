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


final class ContextSyncTests: TestCase {

    func test_ThatUnsavedChangesFromChildContext_DoNotPropogate() {
        // GIVEN: objects in a child context
        let childContext = inMemoryStack.childContext()
        childContext.performAndWait {
            self.generateDataInContext(childContext, companiesCount: 3, employeesCount: 3)
        }

        // WHEN: we do not save the child context

        // WHEN: we fetch the objects from the main context
        let request = Company.fetchRequest
        let results = try? inMemoryStack.mainContext.fetch(request)

        // THEN: the main context does not return any objects
        XCTAssertEqual(results?.count, 0, "Main context should return nothing")
    }

    func test_ThatChangesPropagate_FromMainContext_ToBackgroundContext() {
        // GIVEN: objects in the main context
        let context = inMemoryStack.mainContext
        var companies = [Company]()
        context.performAndWait {
            companies = self.generateDataInContext(context, companiesCount:3, employeesCount:3)
        }
        let companyNames = companies.map { $0.name }

        // WHEN: we save the main context
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: inMemoryStack.mainContext, handler: nil)

        saveContext(inMemoryStack.mainContext) { result in
            XCTAssertTrue(result == .success)
        }

        waitForExpectations(timeout: defaultTimeout) { (error) in
            XCTAssertNil(error, "Expectation should not error")
        }

        // WHEN: we fetch the objects in the background context
        let request = Company.fetchRequest
        let bgContext = inMemoryStack.backgroundContext
        var results = [Company]()
        bgContext.performAndWait {
            results = try! bgContext.fetch(request)
        }

        // THEN: the background context returns the objects
        XCTAssertEqual(results.count, companies.count, "Background context should return same objects")
        results.forEach { (company: Company) in
            XCTAssertTrue(companyNames.contains(company.name), "Background context should return same objects")
        }
    }

    func test_ThatChangesPropagate_FromBackgroundContext_ToMainContext() {
        // GIVEN: objects in the background context
        let context = inMemoryStack.backgroundContext
        var companies = [Company]()
        context.performAndWait {
            companies = self.generateDataInContext(context, companiesCount: 3, employeesCount: 3)
        }
        let companyNames = companies.map { $0.name }

        // WHEN: we save the background context
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: inMemoryStack.backgroundContext, handler: nil)

        saveContext(inMemoryStack.backgroundContext) { result in
            XCTAssertTrue(result == .success)
        }

        waitForExpectations(timeout: defaultTimeout) { (error) in
            XCTAssertNil(error, "Expectation should not error")
        }

        // WHEN: we fetch the objects from the main context
        let request = NSFetchRequest<Company>(entityName: Company.entityName)
        let results = try! inMemoryStack.mainContext.fetch(request)

        // THEN: the main context returns the objects
        XCTAssertEqual(results.count, companies.count, "Main context should return the same objects")
        results.forEach { (company: Company) in
            XCTAssertTrue(companyNames.contains(company.name), "Main context should return same objects")
        }
    }

    func test_ThatChangesPropagate_FromChildContext_ToMainContext() {
        // GIVEN: objects in a child context
        let childContext = inMemoryStack.childContext(concurrencyType: .mainQueueConcurrencyType)
        var companies = [Company]()
        childContext.performAndWait {
            companies = self.generateDataInContext(childContext, companiesCount: 3, employeesCount: 3)
        }
        let companyNames = companies.map { $0.name }

        // WHEN: we save the child context
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: childContext, handler: nil)
        saveContext(childContext) { (result) -> Void in
            XCTAssertTrue(result == .success)
        }

        waitForExpectations(timeout: defaultTimeout) { (error) in
            XCTAssertNil(error, "Expectation should not error")
        }

        // WHEN: we fetch the objects from the main context
        let request = Company.fetchRequest
        let context = inMemoryStack.mainContext
        var results = [Company]()
        context.performAndWait {
            results = try! context.fetch(request)
        }

        // THEN: the main context returns the objects
        XCTAssertEqual(results.count, companies.count, "Main context should return the same objects")
        results.forEach { (company: Company) in
            XCTAssertTrue(companyNames.contains(company.name), "Main context should return same objects")
        }
    }

    func test_ThatChangesPropagate_FromChildContext_ToBackgroundContext() {
        // GIVEN: objects in a child context
        let childContext = inMemoryStack.childContext(concurrencyType: .privateQueueConcurrencyType)
        var companies = [Company]()
        childContext.performAndWait {
            companies = self.generateDataInContext(childContext, companiesCount: 3, employeesCount: 3)
        }
        let companyNames = companies.map { $0.name }

        // WHEN: we save the child context
        expectation(forNotification: Notification.Name.NSManagedObjectContextDidSave.rawValue, object: childContext, handler: nil)
        saveContext(childContext) { (result) -> Void in
            XCTAssertTrue(result == .success)
        }

        waitForExpectations(timeout: defaultTimeout) { (error) in
            XCTAssertNil(error, "Expectation should not error")
        }

        // WHEN: we fetch the objects from the background context
        let request = Company.fetchRequest
        let context = inMemoryStack.backgroundContext
        var results = [Company]()
        context.performAndWait {
            results = try! context.fetch(request)
        }

        // THEN: the background context returns the objects
        XCTAssertEqual(results.count, companies.count, "Background context should return the same objects")
        results.forEach { (company: Company) in
            XCTAssertTrue(companyNames.contains(company.name), "Background context should return same objects")
        }
    }
}
