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


public struct ExampleModelProperties {
    public let name = "ExampleModel"
    public let bundle = NSBundle(identifier: "com.hexedbits.ExampleModel")!
    public init() { }
}


public func newFakeBand(context: NSManagedObjectContext) -> Band {

    return Band(context: context,
        name: "Name " + NSUUID().UUIDString,
        dateFounded: NSDate(),
        city: "City",
        genre: "Genre")
}


public func newFakeAlbum(context: NSManagedObjectContext, band: Band) -> Album {

    return Album(context: context,
        title: "Title " + NSUUID().UUIDString,
        dateReleased: NSDate(),
        price: 10.0,
        band: band)
}
