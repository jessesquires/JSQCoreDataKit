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

import UIKit

import ExampleModel

import JSQCoreDataKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let model = CoreDataModel(name: "ExampleModel", bundle: NSBundle(identifier: "com.hexedbits.ExampleModel")!)
        let stack = CoreDataStack(model: model)

        let band = Band(context: stack.managedObjectContext)
        band.name = "Gore Gore"
        band.genre = 0
        band.city = "SF"
        band.dateFounded = NSDate()

        println("MODEL == \(model)")

        println("BAND == \(band)")

        return true
    }

}
