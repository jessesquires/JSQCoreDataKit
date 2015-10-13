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


let DefaultTimeout = NSTimeInterval(15)


class TestCase: XCTestCase {

    let inMemoryModel = CoreDataModel(name: modelName, bundle: modelBundle, storeType: .InMemory)

    var inMemoryStack: CoreDataStack!

    override func setUp() {
        super.setUp()

        let factory = CoreDataStackFactory(model: inMemoryModel)
        let result = factory.createStack()
        inMemoryStack = result.stack()
    }

    override func tearDown() {
        inMemoryStack = nil
        super.tearDown()
    }


    // MARK: Helpers

    func generateFakeDataInContext(context: NSManagedObjectContext) -> [Company] {
        let numCompanies = Int(arc4random_uniform(10))

        let companies = generateCompaniesInContext(context, count: numCompanies)

        for c in companies {
            let numEmployees = Int(arc4random_uniform(1_000))
            generateEmployeesInContext(context, company: c, count: numEmployees)
        }

        return companies
    }

    func generateCompaniesInContext(context: NSManagedObjectContext, count: Int) -> [Company] {
        var companies = [Company]()

        for _ in 0..<count {
            let c = Company.newCompany(context)
            companies.append(c)
        }

        return companies
    }

    func generateEmployeesInContext(context: NSManagedObjectContext, company: Company? = nil, count: Int) -> [Employee] {
        var employees = [Employee]()

        for _ in 0..<count {
            let c = Employee.newEmployee(context, company: company)
            employees.append(c)
        }
        
        return employees
    }
    
}
