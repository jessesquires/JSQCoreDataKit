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
//  Copyright © 2015 Jesse Squires
//  Released under an MIT license: https://opensource.org/licenses/MIT
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
            "key0" as NSObject: "fake value" as AnyObject,
            "key1" as NSObject: 234 as AnyObject
        ]

        let second: PersistentStoreOptions = [
            "key0" as NSObject: "fake value" as AnyObject,
            "key1" as NSObject: 234 as AnyObject
        ]

        // WHEN: we compare them
        let result = (first == second)

        // THEN: they are equal
        XCTAssertTrue(result)
    }

    func test_ThatPersistentStoreOptions_AreNotEqual_MissingKeys() {
        // GIVEN: two distinct PersistentStoreOptions objects
        let first: PersistentStoreOptions = [
            "key0" as NSObject: "fake value" as AnyObject,
            "key1" as NSObject: 234 as AnyObject,
            "key2" as NSObject: NSDate() as AnyObject
        ]

        let second: PersistentStoreOptions = [
            "key0" as NSObject: "fake value" as AnyObject
        ]

        // WHEN: we compare them
        let result = (first == second)

        // THEN: they are not equal
        XCTAssertFalse(result)
    }

    func test_ThatPersistentStoreOptions_AreNotEqual_DifferentValues() {
        // GIVEN: two distinct PersistentStoreOptions objects
        let first: PersistentStoreOptions = [
            "key0" as NSObject: "fake value" as AnyObject,
            "key1" as NSObject: 234 as AnyObject,
            "key2" as NSObject: NSDate() as AnyObject
        ]

        let second: PersistentStoreOptions = [
            "key0" as NSObject: "different" as AnyObject,
            "key1" as NSObject: 4567 as AnyObject,
            "key2" as NSObject: NSDate() as AnyObject
        ]

        // WHEN: we compare them
        let result = (first == second)

        // THEN: they are not equal
        XCTAssertFalse(result)
    }

    func test_ThatPersistentStoreOptions_AreNotEqual_DifferentKeys() {
        // GIVEN: two distinct PersistentStoreOptions objects
        let first: PersistentStoreOptions = [
            "key0" as NSObject: "fake value" as AnyObject,
            "key1" as NSObject: 234 as AnyObject,
            "key2" as NSObject: NSDate() as AnyObject
        ]

        let second: PersistentStoreOptions = [
            "key7" as NSObject: "different" as AnyObject,
            "key8" as NSObject: 4567 as AnyObject,
            "key9" as NSObject: NSDate() as AnyObject
        ]

        // WHEN: we compare them
        let result = (first == second)
        
        // THEN: they are not equal
        XCTAssertFalse(result)
    }
}
