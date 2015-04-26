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
import UIKit
import CoreData
import ExampleModel

import JSQCoreDataKit

/*

Here's a terrible, Obj-C-ish way to do things.

extension NSManagedObject {

    class func entityName() -> String {
        let fullClassName = NSStringFromClass(object_getClass(self))
        let classNameComponents: [String] = split(fullClassName) { $0 == "." }
        return last(classNameComponents)!
    }

    convenience init(context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entityForName(self.dynamicType.entityName(), inManagedObjectContext: context)!
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
}

*/

class ViewController: UIViewController {

    var stack: CoreDataStack?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create model
        let model = CoreDataModel(name: ModelName, bundle: ModelBundle)

        // Create stack
        self.stack = CoreDataStack(model: model)

    }

}

