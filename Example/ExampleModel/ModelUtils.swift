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
    let id = NSUUID().UUIDString

    let b = Band(context: context)
    b.name = "Name " + id
    b.dateFounded = NSDate()
    b.city = "City " + id
    b.genre = "Genre " + id
    
    return b
}


public func newFakeAlbum(context: NSManagedObjectContext, band: Band) -> Album {
    let id = NSUUID().UUIDString

    let a = Album(context: context)
    a.title = "Title " + id
    a.dateReleased = NSDate()
    a.price = 10.0

    a.band = newFakeBand(context)
    
    return a
}
