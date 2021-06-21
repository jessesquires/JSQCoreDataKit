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

import CoreData
import ExampleModel
@testable import JSQCoreDataKit
import XCTest

final class ExampleModelTests: TestCase {

    func test_ThatEmployeeInsertsSuccessfully() {
        let employee = Employee.newEmployee(inMemoryStack.mainContext)
        XCTAssertNotNil(employee)
    }

    func test_ThatCompanyInsertsSuccessfully() {
        let company = Company.newCompany(inMemoryStack.mainContext)
        XCTAssertNotNil(company)
    }
}
