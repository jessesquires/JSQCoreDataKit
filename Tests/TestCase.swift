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


let DefaultTimeout = NSTimeInterval(20)


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

    func generateDataInContext(context: NSManagedObjectContext,
        companiesCount: Int = Int(arc4random_uniform(10)),
        employeesCount: Int = Int(arc4random_uniform(1_000))) -> [Company] {
            let companies = generateCompaniesInContext(context, count: companiesCount)

            companies.forEach { c in
                generateEmployeesInContext(context, company: c, count: employeesCount)
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
