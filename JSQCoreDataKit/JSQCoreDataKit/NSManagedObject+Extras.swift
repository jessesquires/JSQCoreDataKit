//
//  NSManagedObject+Extras.swift
//  JSQCoreDataKit
//
//  Created by Doug Mason on 9/6/15.
//  Copyright © 2015 Hexed Bits. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    /**
    Convenience static function to grab name of an entity to make life easier when creating an NSEntityDescription instance especially on
    NSManagedObject subclass's during initialization.
    */
    public static func entityName() -> String {
        let fullClassName = NSStringFromClass(object_getClass(self))
        let nameComponents = fullClassName.characters.split { $0 == "." }
                                                     .map { String($0) }
        
        return nameComponents.last!
    }
}
