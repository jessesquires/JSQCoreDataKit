# JSQCoreDataKit
[![Build Status](https://secure.travis-ci.org/jessesquires/JSQCoreDataKit.svg)](http://travis-ci.org/jessesquires/JSQCoreDataKit) [![Version Status](https://img.shields.io/cocoapods/v/JSQCoreDataKit.svg)][podLink] [![license MIT](https://img.shields.io/cocoapods/l/JSQCoreDataKit.svg)][mitLink] [![codecov.io](https://img.shields.io/codecov/c/github/jessesquires/JSQCoreDataKit.svg)](http://codecov.io/github/jessesquires/JSQCoreDataKit) [![Platform](https://img.shields.io/cocoapods/p/JSQCoreDataKit.svg)][docsLink] [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

*A swifter Core Data stack*

## About

This library aims to do the following:

* Provide better interoperability with Swift
* Harness Swift features and enforce Swift paradigms
* Bring functional paradigms to Core Data
* Simplify the processes of standing up the Core Data stack
* Aid in testing your Core Data models
* Reduce the boilerplate involved with Core Data

> **Further reading on Core Data:**
>
> * [Core Data Programming Guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/cdProgrammingGuide.html)
> * [Core Data Core Competencies Guide](https://developer.apple.com/library/ios/documentation/DataManagement/Devpedia-CoreData/coreDataStack.html#//apple_ref/doc/uid/TP40010398-CH25-SW1)
> * [objc.io issue #4 on Core Data](http://www.objc.io/issue-4/)
> * [Concurrent Core Data Stacks – Performance Shootout](http://floriankugler.com/2013/04/29/concurrent-core-data-stack-performance-shootout/)
> * [Backstage with Nested Managed Object Contexts](http://floriankugler.com/2013/05/13/backstage-with-nested-managed-object-contexts/)
> * [BNR core data stack](https://www.bignerdranch.com/blog/introducing-the-big-nerd-ranch-core-data-stack/)

## Requirements

* Xcode 7.2+
* iOS 8.0+
* OSX 10.10+
* tvOS 9.1+
* watchOS 2.0+
* Swift 2.0+

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

More information on the [`gh-pages`](https://github.com/jessesquires/JSQCoreDataKit/tree/gh-pages) branch.

## Getting Started

````swift
import JSQCoreDataKit
````

#### Standing up the stack

````swift
// Initialize the Core Data model, this class encapsulates the notion of a .xcdatamodeld file
// The name passed here should be the name of an .xcdatamodeld file
let bundle = NSBundle(identifier: "com.MyApp.MyModelFramework")!
let model = CoreDataModel(name: "MyModel", bundle: bundle)

// Initialize a stack with a factory
let factory = CoreDataStackFactory(model: model)

let stack: CoreDataStack?
factory.createStackInBackground { (result: CoreDataStackResult) in
    switch result {
        case .Success(let s):
            stack = s

        case .Failure(let e):
            print("Error: \(e)")
    }
}
````

#### In-memory stacks for testing

````swift
let inMemoryModel = CoreDataModel(name: myName, bundle: myBundle, storeType: .InMemory)
let factory = CoreDataStackFactory(model: inMemoryModel)
let stack = factory.createStack()
````

#### Saving a managed object context

````swift
saveContext(stack.mainContext) { result in
    switch result {
        case .Success:
            print("save succeeded")

        case .Failure(let error):
            print("save failed: \(error)")
    }
}
````

#### Deleting the store

````swift
let bundle = NSBundle(identifier: "com.MyApp.MyModelFramework")!
let model = CoreDataModel(name: "MyModel", bundle: bundle)
do {
    try model.removeExistingModelStore()
} catch {
    print("Error: \(error)")
}
````

#### Checking migrations

````swift
let bundle = NSBundle(identifier: "com.MyApp.MyModelFramework")!
let model = CoreDataModel(name: "MyModel", bundle: bundle)
if model.needsMigration {
    // do migration
}
````

#### Using child contexts

````swift
// Create a background queue child context from the main queue context
let childContext = stack.childContext()
````

#### Fetching

````swift
// Create a FetchRequest<T>, where T is a phantom type
let entity = entity(name: "MyModel", context: context)!
let request = FetchRequest<MyModel>(entity: entity)

var results = [MyModel]()
do {
    results = try fetch(request: request, inContext: context)
}
catch {
    print("Fetch error: \(error)")
}

print("Results = \(results)")
````

#### Deleting

````swift
let objects: [MyModel] = /* array of MyModel objects */

deleteObjects(objects, inContext: context)

// Commit changes to remove objects from store
saveContext(context)
````

## Example app

There's an example app in the `ExampleApp/` directory. Open the `ExampleApp.xcodeproj` to run it. The project exercises all basic functionality of the library.

## Unit tests

There's a suite of unit tests for `JSQCoreDataKit.framework`. To run them, open `JSQCoreDataKit.xcworkspace`, select the `JSQCoreDataKit` scheme, then &#x2318;-u.

These tests are well commented and serve as further documentation for how to use this library.

## Contribute

Please follow these sweet [contribution guidelines](https://github.com/jessesquires/HowToContribute).

## Credits

Created and maintained by [**@jesse_squires**](https://twitter.com/jesse_squires).

## License

`JSQCoreDataKit` is released under an [MIT License][mitLink]. See `LICENSE` for details.

>**Copyright &copy; 2015-present Jesse Squires.**

*Please provide attribution, it is greatly appreciated.*

[podLink]:https://cocoapods.org/pods/JSQCoreDataKit
[docsLink]:http://www.jessesquires.com/JSQCoreDataKit
[mitLink]:http://opensource.org/licenses/MIT
