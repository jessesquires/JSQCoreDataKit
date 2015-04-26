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

let MyModelEntityName = "MyModel"

class MyModel: NSManagedObject {

    @NSManaged var myString: String
    @NSManaged var myInt: Int32
    @NSManaged var myDate: NSDate
    @NSManaged var myFloat: Float
    @NSManaged var myBool: Bool

    init(context: NSManagedObjectContext,
        myString: String = NSUUID().UUIDString,
        myInt: Int32 = Int32(arc4random_uniform(10_000)),
        myDate: NSDate = NSDate(),
        myFloat: Float = Float(arc4random_uniform(100)),
        myBool: Bool = true) {
            
            let entity = NSEntityDescription.entityForName(MyModelEntityName, inManagedObjectContext: context)!
            super.init(entity: entity, insertIntoManagedObjectContext: context)

            self.myString = myString
            self.myInt = myInt
            self.myDate = myDate
            self.myFloat = myFloat
            self.myBool = myBool
    }
    
}
