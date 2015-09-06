//
//  MangedObjectTests.swift
//  JSQCoreDataKit
//
//  Created by Doug Mason on 9/6/15.
//  Copyright © 2015 Hexed Bits. All rights reserved.
//

import XCTest
import CoreData

import JSQCoreDataKit

class ManagedObjectTests: XCTestCase {
    
    func test_ThatEntityName_ReturnsExpectedNonFullyQualifiedName() {
        let entityName = MyModel.entityName()
        XCTAssertEqual(MyModelEntityName, entityName)
    }
}
