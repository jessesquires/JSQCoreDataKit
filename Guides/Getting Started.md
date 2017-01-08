# Getting Started

This guide provides a brief overview for how to get started using `JSQCoreDataKit`.

````swift
import JSQCoreDataKit
````

## Standing up the stack

````swift
// Initialize the Core Data model, this class encapsulates the notion of a .xcdatamodeld file
// The name passed here should be the name of an .xcdatamodeld file
let bundle = Bundle(identifier: "com.MyApp.MyModelFramework")!
let model = CoreDataModel(name: "MyModel", bundle: bundle)

// Initialize a stack with a factory
let factory = CoreDataStackFactory(model: model)

let stack: CoreDataStack?
factory.createStack { (result: StackResult) in
    switch result {
        case .success(let s):
            stack = s

        case .failure(let e):
            print("Error: \(e)")
    }
}
````

## In-memory stacks for testing

````swift
let inMemoryModel = CoreDataModel(name: myName, bundle: myBundle, storeType: .inMemory)
let factory = CoreDataStackFactory(model: inMemoryModel)

let stack: CoreDataStack?
factory.createStack { (result: StackResult) in
    switch result {
        case .success(let s):
            stack = s

        case .failure(let e):
            print("Error: \(e)")
    }
}
````

## Saving a managed object context

````swift
saveContext(stack.mainContext) { result in
    switch result {
        case .success:
            print("save succeeded")

        case .failure(let error):
            print("save failed: \(error)")
    }
}
````

## Deleting the store

````swift
let bundle = Bundle(identifier: "com.MyApp.MyModelFramework")!
let model = CoreDataModel(name: "MyModel", bundle: bundle)
do {
    try model.removeExistingStore()
} catch {
    print("Error: \(error)")
}
````

## Performing migrations

````swift
let bundle = Bundle(identifier: "com.MyApp.MyModelFramework")!
let model = CoreDataModel(name: "MyModel", bundle: bundle)
if model.needsMigration {
    do {
        try model.migrate()
    } catch {
        print("Failed to migrate model: \(error)")
    }
}
````

## Using child contexts

````swift
// Create a main queue child context from the main context
let childContext = stack.childContext(concurrencyType: .mainQueueConcurrencyType)

// Create a background queue child context from the background context
let childContext = stack.childContext(concurrencyType: .privateQueueConcurrencyType)
````

## Example app

There's an example app in the `Example/` directory. Open the `ExampleApp.xcodeproj` to run it. The project exercises all basic functionality of the library.
