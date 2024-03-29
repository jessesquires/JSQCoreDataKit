# JSQCoreDataKit [![CI](https://github.com/jessesquires/JSQCoreDataKit/workflows/CI/badge.svg)](https://github.com/jessesquires/JSQCoreDataKit/actions)

*A swifter Core Data stack*

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjessesquires%2FJSQCoreDataKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/jessesquires/JSQCoreDataKit) <br> [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjessesquires%2FJSQCoreDataKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/jessesquires/JSQCoreDataKit)

## About

This library aims to do the following:

* Encode Core Data best practices, so you don't have to think "is this correct?" or "is this the right way to do this?"
* Provide better interoperability with Swift
* Harness Swift features and enforce Swift paradigms
* Bring functional paradigms to Core Data
* Make Core Data more *Swifty*
* Simplify the processes of standing up the Core Data stack
* Aid in testing your Core Data models
* Reduce the boilerplate involved with Core Data

## Requirements

#### Tooling

* Xcode 15.0+
* Swift 5.9+
* [SwiftLint](https://github.com/realm/SwiftLint)

#### Platforms

* iOS 11.0+
* macOS 10.12+
* tvOS 11.0+
* watchOS 4.0+

## Installation

### [CocoaPods](http://cocoapods.org)

````ruby
pod 'JSQCoreDataKit', '~> 9.0.0'
````

### [Swift Package Manager](https://swift.org/package-manager/)

Add `JSQCoreDataKit` to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/jessesquires/JSQCoreDataKit.git", from: "9.0.0")
]
```

Alternatively, you can add the package [directly via Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Documentation

You can read the [documentation here](https://jessesquires.github.io/JSQCoreDataKit). Generated with [jazzy](https://github.com/realm/jazzy). Hosted by [GitHub Pages](https://pages.github.com).

## Additional Resources

* [Core Data Programming Guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/cdProgrammingGuide.html)
* [Core Data Core Competencies Guide](https://developer.apple.com/library/ios/documentation/DataManagement/Devpedia-CoreData/coreDataStack.html#//apple_ref/doc/uid/TP40010398-CH25-SW1)
* [objc.io issue #4 on Core Data](https://www.objc.io/issue-4/)
* [Concurrent Core Data Stacks – Performance Shootout](http://floriankugler.com/2013/04/29/concurrent-core-data-stack-performance-shootout/)
* [Backstage with Nested Managed Object Contexts](http://floriankugler.com/2013/05/13/backstage-with-nested-managed-object-contexts/)

## Contributing

Interested in making contributions to this project? Please review the guides below.

- [Contributing Guidelines](https://github.com/jessesquires/.github/blob/master/CONTRIBUTING.md)
- [Code of Conduct](https://github.com/jessesquires/.github/blob/master/CODE_OF_CONDUCT.md)
- [Support and Help](https://github.com/jessesquires/.github/blob/master/SUPPORT.md)
- [Security Policy](https://github.com/jessesquires/.github/blob/master/SECURITY.md)

Also, consider [sponsoring this project](https://www.jessesquires.com/sponsor/) or [buying my apps](https://www.hexedbits.com)! ✌️

## Credits

Created and maintained by [**@jesse_squires**](https://twitter.com/jesse_squires).

## License

Released under the MIT License. See `LICENSE` for details.

> **Copyright &copy; 2015-present Jesse Squires.**
