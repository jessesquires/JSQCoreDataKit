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


class ViewController: UIViewController {

    var stack: CoreDataStack?

    override func viewDidLoad() {
        super.viewDidLoad()

        let properties = ExampleModelProperties()

        // Create model
        let model = CoreDataModel(name: properties.name, bundle: properties.bundle)

        // Create stack
        self.stack = CoreDataStack(model: model)

    }

}

