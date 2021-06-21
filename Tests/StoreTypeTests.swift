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
@testable import JSQCoreDataKit
import XCTest

final class StoreTypeTests: XCTestCase {

    let url = CoreDataModel.defaultDirectoryURL()

    func test_StoreType_SQLite() {
        let store = StoreType.sqlite(self.url)
        XCTAssertEqual(store.type, NSSQLiteStoreType)
        XCTAssertEqual(store.storeDirectory(), self.url)
    }

    func test_StoreType_Binary() {
        let store = StoreType.binary(self.url)
        XCTAssertEqual(store.type, NSBinaryStoreType)
        XCTAssertEqual(store.storeDirectory(), self.url)
    }

    func test_StoreType_InMemory() {
        let store = StoreType.inMemory
        XCTAssertEqual(store.type, NSInMemoryStoreType)
        XCTAssertNil(store.storeDirectory())
    }

    func test_StoreType_Equality() {
        let sqlite = StoreType.sqlite(self.url)
        let binary = StoreType.binary(self.url)
        let memory = StoreType.inMemory

        XCTAssertNotEqual(sqlite, binary)
        XCTAssertNotEqual(sqlite, memory)
        XCTAssertNotEqual(binary, memory)
    }

    func test_StoreType_Equality_SQLite() {
        let sqlite1 = StoreType.sqlite(self.url)
        let sqlite2 = StoreType.sqlite(self.url)
        XCTAssertEqual(sqlite1, sqlite2)

        let sqlite3 = StoreType.sqlite(URL(fileURLWithPath: NSTemporaryDirectory()))
        XCTAssertNotEqual(sqlite1, sqlite3)
    }

    func test_StoreType_Equality_Binary() {
        let binary1 = StoreType.binary(self.url)
        let binary2 = StoreType.binary(self.url)
        XCTAssertEqual(binary1, binary2)

        let binary3 = StoreType.binary(URL(fileURLWithPath: NSTemporaryDirectory()))
        XCTAssertNotEqual(binary1, binary3)
    }

    func test_StoreType_Equality_InMemory() {
        let memory1 = StoreType.inMemory
        let memory2 = StoreType.inMemory
        XCTAssertEqual(memory1, memory2)
    }
}
