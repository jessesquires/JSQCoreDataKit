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


class StoreTypeTests: XCTestCase {

    func test_StoreType_SQLite() {
        let url = DefaultDirectoryURL()

        let s = StoreType.SQLite(url)
        XCTAssertEqual(s.type, NSSQLiteStoreType)
        XCTAssertEqual(s.storeDirectory(), url)
    }

    func test_StoreType_Binary() {
        let url = DefaultDirectoryURL()

        let s = StoreType.Binary(url)
        XCTAssertEqual(s.type, NSBinaryStoreType)
        XCTAssertEqual(s.storeDirectory(), url)
    }

    func test_StoreType_InMemory() {
        let s = StoreType.InMemory
        XCTAssertEqual(s.type, NSInMemoryStoreType)
        XCTAssertNil(s.storeDirectory())
    }

    func test_StoreType_Equality() {
        let url = DefaultDirectoryURL()

        let sqlite = StoreType.SQLite(url)
        let binary = StoreType.Binary(url)
        let memory = StoreType.InMemory

        XCTAssertNotEqual(sqlite, binary)
        XCTAssertNotEqual(sqlite, memory)
        XCTAssertNotEqual(binary, memory)
    }

    func test_StoreType_Equality_SQLite() {
        let url = DefaultDirectoryURL()

        let sqlite1 = StoreType.SQLite(url)
        let sqlite2 = StoreType.SQLite(url)
        XCTAssertEqual(sqlite1, sqlite2)

        let sqlite3 = StoreType.SQLite(NSURL(fileURLWithPath: NSTemporaryDirectory()))
        XCTAssertNotEqual(sqlite1, sqlite3)
    }

    func test_StoreType_Equality_Binary() {
        let url = DefaultDirectoryURL()

        let binary1 = StoreType.Binary(url)
        let binary2 = StoreType.Binary(url)
        XCTAssertEqual(binary1, binary2)

        let binary3 = StoreType.Binary(NSURL(fileURLWithPath: NSTemporaryDirectory()))
        XCTAssertNotEqual(binary1, binary3)
    }

    func test_StoreType_Equality_InMemory() {
        let memory1 = StoreType.InMemory
        let memory2 = StoreType.InMemory
        XCTAssertEqual(memory1, memory2)
    }

    func test_StoreType_Description() {
        print("\(__FUNCTION__)")
        let url = DefaultDirectoryURL()

        let sqlite = StoreType.SQLite(url)
        print(sqlite)

        let binary = StoreType.Binary(url)
        print(binary)

        let memory = StoreType.InMemory
        print(memory)
    }
    
}
