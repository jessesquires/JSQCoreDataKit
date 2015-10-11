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

import JSQCoreDataKit


class PersistentStoreOptionsTests: XCTestCase {
    
    func test_ThatPersistentStoreOptions_AreEqual() {
        // GIVEN: two equal PersistentStoreOptions objects
        let first: PersistentStoreOptions = [
            "key0": "fake value",
            "key1": 234
        ]

        let second: PersistentStoreOptions = [
            "key0": "fake value",
            "key1": 234
        ]

        // WHEN: we compare them
        let result = (first == second)

        // THEN: they are equal
        XCTAssertTrue(result)
    }

    func test_ThatPersistentStoreOptions_AreNotEqual() {
        // GIVEN: two distinct PersistentStoreOptions objects
        let first: PersistentStoreOptions = [
            "key0": "fake value",
            "key1": 234
        ]

        let second: PersistentStoreOptions = [
            "key0": "fake value"
        ]

        // WHEN: we compare them
        let result = (first == second)

        // THEN: they are not equal
        XCTAssertFalse(result)
    }
}
