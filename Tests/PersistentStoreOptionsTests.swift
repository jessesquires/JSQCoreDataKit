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

final class PersistentStoreOptionsTests: XCTestCase {

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

    func test_ThatPersistentStoreOptions_AreNotEqual_MissingKeys() {
        // GIVEN: two distinct PersistentStoreOptions objects
        let first: PersistentStoreOptions = [
            "key0": "fake value",
            "key1": 234,
            "key2": NSDate()
        ]

        let second: PersistentStoreOptions = [
            "key0": "fake value"
        ]

        // WHEN: we compare them
        let result = (first == second)

        // THEN: they are not equal
        XCTAssertFalse(result)
    }

    func test_ThatPersistentStoreOptions_AreNotEqual_DifferentValues() {
        // GIVEN: two distinct PersistentStoreOptions objects
        let first: PersistentStoreOptions = [
            "key0": "fake value",
            "key1": 234,
            "key2": NSDate()
        ]

        let second: PersistentStoreOptions = [
            "key0": "different",
            "key1": 4567,
            "key2": NSDate()
        ]

        // WHEN: we compare them
        let result = (first == second)

        // THEN: they are not equal
        XCTAssertFalse(result)
    }

    func test_ThatPersistentStoreOptions_AreNotEqual_DifferentKeys() {
        // GIVEN: two distinct PersistentStoreOptions objects
        let first: PersistentStoreOptions = [
            "key0": "fake value",
            "key1": 234,
            "key2": NSDate()
        ]

        let second: PersistentStoreOptions = [
            "key7": "different",
            "key8": 4567,
            "key9": NSDate()
        ]

        // WHEN: we compare them
        let result = (first == second)
        
        // THEN: they are not equal
        XCTAssertFalse(result)
    }
}
