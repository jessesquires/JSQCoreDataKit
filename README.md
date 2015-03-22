# JSQCoreDataKit
[![Build Status](https://secure.travis-ci.org/jessesquires/JSQCoreDataKit.svg)](http://travis-ci.org/jessesquires/JSQCoreDataKit) [![Version Status](http://img.shields.io/cocoapods/v/JSQCoreDataKit.png)][docsLink] [![license MIT](http://img.shields.io/badge/license-MIT-orange.png)][mitLink]

*A swifter Core Data stack*

## About
This project is a Swift rewrite and rethinking of [RSTCoreDataKit](https://github.com/rosettastone/RSTCoreDataKit). 

This framework aims to simplify the processes of standing up and testing your [Core Data](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/cdProgrammingGuide.html) stack, and reduces the boilerplate involved in getting started with Core Data. 

![stack](https://developer.apple.com/library/ios/documentation/DataManagement/Devpedia-CoreData/Art/single_persistent_stack.jpg)

*The Core Data Stack, via Apple [Core Data Core Competencies](https://developer.apple.com/library/ios/documentation/DataManagement/Devpedia-CoreData/coreDataStack.html#//apple_ref/doc/uid/TP40010398-CH25-SW1) Guide*

## Requirements

* iOS 8
* Swift 1.2

## Installation

>TODO:

## Documentation

Read the fucking [docs](http://www.jessesquires.com/JSQCoreDataKit/). Generated with [jazzy](https://github.com/realm/jazzy). Hosted by [GitHub Pages](https://pages.github.com).

````bash
# regenerate documentation
$ cd /path/to/JSQCoreDataKit/
$ ./build_docs.sh
$ open _docs/
````

## Getting Started

````swift
import JSQCoreDataKit
````

>TODO:

## Unit tests

There's a suite of unit tests for the `JSQCoreDataKit.framework`. To run them, open `JSQCoreDataKit.xcworkspace`, select the `JSQCoreDataKit` scheme, then &#x2318;-u.

These tests are well commented and serve as further documentation for how to use this library.


## Contribute

Please follow these sweet [contribution guidelines](https://github.com/jessesquires/HowToContribute).

## Credits

Created and maintained by [**@jesse_squires**](https://twitter.com/jesse_squires)

This project is a Swift rewrite of [RSTCoreDataKit](https://github.com/rosettastone/RSTCoreDataKit).

## License

`JSQCoreDataKit` is released under an [MIT License][mitLink]. See `LICENSE` for details.

>**Copyright &copy; 2015 Jesse Squires.**

*Please provide attribution, it is greatly appreciated.*

[mitLink]:http://opensource.org/licenses/MIT
[docsLink]:http://www.jessesquires.com/JSQCoreDataKit
