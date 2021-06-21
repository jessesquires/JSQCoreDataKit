//
//  Created by Jesse Squires
//  https://www.jessesquires.com
//
//
//  Documentation
//  https://jessesquires.github.io/JSQCoreDataKit
//
//
//  GitHub
//  https://github.com/jessesquires/JSQCoreDataKit
//
//
//  License
//  Copyright © 2015-present Jesse Squires
//  Released under an MIT license: https://opensource.org/licenses/MIT
//

// swiftlint:disable force_try

import CoreData
import ExampleModel
@testable import JSQCoreDataKit
import XCTest

let defaultTimeout = TimeInterval(20)

extension CoreDataStackProvider {

    func createStack() -> CoreDataStack.StackResult {
        var result: CoreDataStack.StackResult!
        createStack(onQueue: nil) { result = $0 }
        return result
    }
}

extension XCTestCase {
    func cleanUp() {
        let model = CoreDataModel(name: modelName, bundle: modelBundle)
        _ = try? model.removeExistingStore()
    }
}

class TestCase: XCTestCase {

    let inMemoryModel = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .inMemory)

    var inMemoryStack: CoreDataStack!

    override func setUp() {
        super.setUp()

        let factory = CoreDataStackProvider(model: inMemoryModel)
        let result = factory.createStack()
        inMemoryStack = try! result.get()
    }

    override func tearDown() {
        inMemoryStack = nil
        super.tearDown()
    }

    // MARK: Helpers

    @discardableResult
    func generateDataInContext(_ context: NSManagedObjectContext,
                               companiesCount: Int = Int.random(in: 0...10),
                               employeesCount: Int = Int.random(in: 0...1_000)) -> [Company] {
        let companies = generateCompaniesInContext(context, count: companiesCount)

        companies.forEach { company in
            generateEmployeesInContext(context, count: employeesCount, company: company)
        }

        return companies
    }

    @discardableResult
    func generateCompaniesInContext(_ context: NSManagedObjectContext, count: Int) -> [Company] {
        var companies = [Company]()

        for _ in 0..<count {
            let company = Company.newCompany(context)
            companies.append(company)
        }

        return companies
    }

    @discardableResult
    func generateEmployeesInContext(_ context: NSManagedObjectContext, count: Int, company: Company? = nil) -> [Employee] {
        var employees = [Employee]()

        for _ in 0..<count {
            let company = Employee.newEmployee(context, company: company)
            employees.append(company)
        }

        return employees
    }
}

// swiftlint:enable force_try
