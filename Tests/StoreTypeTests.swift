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
        let url = defaultDirectoryURL()

        let s = StoreType.sqlite(url)
        XCTAssertEqual(s.type, NSSQLiteStoreType)
        XCTAssertEqual(s.storeDirectory(), url)
    }

    func test_StoreType_Binary() {
        let url = defaultDirectoryURL()

        let s = StoreType.binary(url)
        XCTAssertEqual(s.type, NSBinaryStoreType)
        XCTAssertEqual(s.storeDirectory(), url)
    }

    func test_StoreType_InMemory() {
        let s = StoreType.inMemory
        XCTAssertEqual(s.type, NSInMemoryStoreType)
        XCTAssertNil(s.storeDirectory())
    }

    func test_StoreType_Equality() {
        let url = defaultDirectoryURL()

        let sqlite = StoreType.sqlite(url)
        let binary = StoreType.binary(url)
        let memory = StoreType.inMemory

        XCTAssertNotEqual(sqlite, binary)
        XCTAssertNotEqual(sqlite, memory)
        XCTAssertNotEqual(binary, memory)
    }

    func test_StoreType_Equality_SQLite() {
        let url = defaultDirectoryURL()

        let sqlite1 = StoreType.sqlite(url)
        let sqlite2 = StoreType.sqlite(url)
        XCTAssertEqual(sqlite1, sqlite2)

        let sqlite3 = StoreType.sqlite(URL(fileURLWithPath: NSTemporaryDirectory()))
        XCTAssertNotEqual(sqlite1, sqlite3)
    }

    func test_StoreType_Equality_Binary() {
        let url = defaultDirectoryURL()

        let binary1 = StoreType.binary(url)
        let binary2 = StoreType.binary(url)
        XCTAssertEqual(binary1, binary2)

        let binary3 = StoreType.binary(URL(fileURLWithPath: NSTemporaryDirectory()))
        XCTAssertNotEqual(binary1, binary3)
    }

    func test_StoreType_Equality_InMemory() {
        let memory1 = StoreType.inMemory
        let memory2 = StoreType.inMemory
        XCTAssertEqual(memory1, memory2)
    }

    func test_StoreType_Description() {
        print(#function)
        let url = defaultDirectoryURL()

        let sqlite = StoreType.sqlite(url)
        print(sqlite)

        let binary = StoreType.binary(url)
        print(binary)
        
        let memory = StoreType.inMemory
        print(memory)
    }
    
}
