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
//  Copyright (c) 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import Foundation
import CoreData


public let ModelName = "ExampleModel"

public let ModelBundle = NSBundle(identifier: "com.hexedbits.ExampleModel")!


public struct ExampleModelEntity {
    public static let Band = "Band"
    public static let Album = "Album"
}


public func newFakeBand(context: NSManagedObjectContext,
    name: String = "Name " + NSUUID().UUIDString,
    dateFounded: NSDate = NSDate(),
    city: String = "City",
    genre: String = "Genre") -> Band {

        return Band(context: context, name: name, dateFounded: dateFounded, city: city, genre: genre)
}


public func newFakeAlbum(context: NSManagedObjectContext,
    band: Band,
    title: String = "Title " + NSUUID().UUIDString,
    dateReleased: NSDate = NSDate(),
    price: NSDecimalNumber = 10.0) -> Album {

        return Album(context: context, title: title, dateReleased: dateReleased, price: price, band: band)
}
