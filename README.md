# JSQCoreDataKit
[![Build Status](https://secure.travis-ci.org/jessesquires/JSQCoreDataKit.svg)](http://travis-ci.org/jessesquires/JSQCoreDataKit) [![Version Status](http://img.shields.io/cocoapods/v/JSQCoreDataKit.png)][docsLink] [![license MIT](http://img.shields.io/badge/license-MIT-orange.png)][mitLink] [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

*A swifter Core Data stack*

## About

This framework aims to do the following:

* Provide better interoperability with Swift
* Harness Swift features and enforce Swift paradigms
* Bring functional paradigms to Core Data
* Simplify the processes of standing up the Core Data stack
* Aid in testing your Core Data models
* Reduce the boilerplate involved with Core Data

> **For more information on Core Data:**
> * [Core Data Programming Guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/cdProgrammingGuide.html)
> * [Core Data Core Competencies Guide](https://developer.apple.com/library/ios/documentation/DataManagement/Devpedia-CoreData/coreDataStack.html#//apple_ref/doc/uid/TP40010398-CH25-SW1)
> * [objc.io issue #4 on Core Data](http://www.objc.io/issue-4/)

## Requirements

* iOS 8
* Swift 1.2

## Installation

#### [CocoaPods](http://cocoapods.org)

````ruby
use_frameworks!

# For latest release in cocoapods
pod 'JSQCoreDataKit'  

# Feeling adventurous? Get the latest on develop
pod 'JSQCoreDataKit', :git => 'https://github.com/jessesquires/JSQCoreDataKit.git', :branch => 'develop'
````

#### [Carthage](https://github.com/Carthage/Carthage)

````bash
github "jessesquires/JSQCoreDataKit"
````

#### Manually

1. Clone this repo and add the `JSQCoreDataKit.xcodeproj` to your project
2. Select your project app target "Build Phases" tab
3. Add the `JSQCoreDataKit.framework` to the "Link Binary With Libraries"  
4. Create a new build phase of type "Copy Files" and set the "Destination" to "Frameworks"
5. Add the `JSQCoreDataKit.framework` and check "Code Sign On Copy"

For an example, see the demo project included in this repo.

For more information, see the [Framework Programming Guide](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPFrameworks/Tasks/IncludingFrameworks.html#//apple_ref/doc/uid/20002257-BAJJBBHJ).

## Documentation

Read the fucking [docs][docsLink]. Generated with [jazzy](https://github.com/realm/jazzy). Hosted by [GitHub Pages](https://pages.github.com).

More information on the [gh-pages](https://github.com/jessesquires/JSQCoreDataKit/tree/gh-pages) branch.

## Getting Started

````swift
import JSQCoreDataKit
````

#### Standing up the stack

````swift
// Initialize the Core Data model, this class encapsulates the notion of a .xcdatamodeld file
// The name passed here should be the name of an .xcdatamodeld file
let model = CoreDataModel(name: "MyModel", bundle: NSBundle(identifier: "com.MyApp.MyModelFramework")!)

// Initialize a default stack
let stack = CoreDataStack(model: model)

// Initialize a private queue, in-memory stack
let privateStack = CoreDataStack(model: model, storeType: NSInMemoryStoreType, options: nil, concurrencyType: .PrivateQueueConcurrencyType)
````

#### Saving a managed object context

````swift
// Saving returns a tuple (Bool, NSError?)
let result: ContextSaveResult = saveContextAndWait(stack.managedObjectContext)
if !result.success {
    // save failed
    println("Save error: \(result.error)")
}
````

#### Deleting the store

````swift
let model = CoreDataModel(name: "MyModel", bundle: NSBundle(identifier: "com.MyApp.MyModelFramework")!)
model.removeExistingModelStore()
````

#### Checking migrations

````swift
let model = CoreDataModel(name: "MyModel", bundle: NSBundle(identifier: "com.MyApp.MyModelFramework")!)
let needsMigration: Bool = model.modelStoreNeedsMigration
````

#### Using child contexts

````swift
let model = CoreDataModel(name: "MyModel", bundle: NSBundle(identifier: "com.MyApp.MyModelFramework")!)
let stack = CoreDataStack(model: model)

// Create a default child context on main queue
let childContext = stack.childManagedObjectContext()

// Create a private queue child context with custom merge policy
let privateChildContext = stack.childManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType, mergePolicyType: .ErrorMergePolicyType)
````

#### Fetching

````swift
// Create a FetchRequest<T>, where T is a phantom type
let entity = entity(name: "MyModel", context: context)!
let request = FetchRequest<MyModel>(entity: entity)

// Fetching returns a FetchResult<T>
let result = fetch(request: request, inContext: context)

if !result.success {
    println("Error = \(result.error)")
}

// use objects, [MyModel]
result.objects
````

#### Deleting

````swift
let objects: [MyModel] = /* array of MyModel objects */

deleteObjects(objects, inContext: context)

// Commit changes, remove objects from store
saveContextAndWait(context)
````

## Unit tests

There's a suite of unit tests for `JSQCoreDataKit.framework`. To run them, open `JSQCoreDataKit.xcworkspace`, select the `JSQCoreDataKit` scheme, then &#x2318;-u. Additional tests are under the `Example` scheme.

These tests are well commented and serve as further documentation for how to use this library.

## Contribute

Please follow these sweet [contribution guidelines](https://github.com/jessesquires/HowToContribute).

## Credits

Created and maintained by [**@jesse_squires**](https://twitter.com/jesse_squires)

This project borrows some ideas and concepts from my work on [RSTCoreDataKit](https://github.com/rosettastone/RSTCoreDataKit).

## License

`JSQCoreDataKit` is released under an [MIT License][mitLink]. See `LICENSE` for details.

>**Copyright &copy; 2015 Jesse Squires.**

*Please provide attribution, it is greatly appreciated.*

[mitLink]:http://opensource.org/licenses/MIT
[docsLink]:http://www.jessesquires.com/JSQCoreDataKit
