# CHANGELOG

The changelog for `JSQCoreDataKit`. Also see the [releases](https://github.com/jessesquires/JSQCoreDataKit/releases) on GitHub.

--------------------------------------

7.0.0
-----

- Converted to Swift 4.0
- iOS 9.0 minimum now required
- tvOS 10.0 minimum now required
- watchOS 3.0 minimum now required
- macOS 10.11 minimum now required

6.0.3
-----

- Fixed some warnings from Swift 3.1 / Xcode 8.3

6.0.2
-----

This release closes the [6.0.2 milestone](https://github.com/jessesquires/JSQCoreDataKit/milestone/14).

- Fixed an issue where model migrations would fail. (#106, #109. Thanks @yasserislam, @marius-serban!)

6.0.1
-----

This release closes the [6.0.1 milestone](https://github.com/jessesquires/JSQCoreDataKit/milestone/13).

- Fixed an issue with `carthage` failing. (#100, #101, #102) Thanks @darkhonor and @tonyarnold!

6.0.0
-----

This release closes the [6.0.0 milestone](https://github.com/jessesquires/JSQCoreDataKit/milestone/12).

**Swift 3.0 now required.**

### Breaking

- Migrated to Swift 3.0
- Removed `entity(name: String, context: NSManagedObjectContext) -> NSEntityDescription`
- Removed `FetchRequest<T: NSManagedObject>` (new Swift overlays now provide generic `NSFetchRequest`)
- Remove the `delete()` and `fetch()` extensions on `NSManagedObjectContext` (new Swift overlays now provide these)

### New

- There's a new protocol, `CoreDataEntityProtocol`, which provides a better API for creating entity descriptions and inserting managed objects (#87). It also provides some helpful extensions. Conform to the new `CoreDataEntityProtocol` to take advantage of this. This replaces the (removed) top-level function `entity(name:, context:) -> NSEntityDescription`

5.0.0
-----

This release closes the [5.0.0 milestone](https://github.com/jessesquires/JSQCoreDataKit/issues?q=milestone%3A5.0.0).

**Swift 2.3 now required.**

4.0.2
-----

This release closes the [4.0.2 milestone](https://github.com/jessesquires/JSQCoreDataKit/issues?q=milestone%3A4.0.2).

- Fixed an issue where sqlite temporary files would not be cleaned up when removing the store (#85). Thanks @deemadden!

4.0.1
-----

This release closes the [4.0.1 milestone](https://github.com/jessesquires/JSQCoreDataKit/issues?q=milestone%3A4.0.1).

- Fixed a multithreading concurrency violation while merging (#83). Thanks @saurabytes!

4.0.0
-----

This release closes the [4.0.0 milestone](https://github.com/jessesquires/JSQCoreDataKit/issues?utf8=✓&q=milestone%3A4.0.0+).

This release includes a significant change to `CoreDataStack`, which **no longer uses child contexts**. The `mainContext` and `backgroundContext` are now both connected to the persistent store coordinator. See #60 for the background and rationale behind this change. In short, child contexts **are considered bad practice** for this kind of stack setup and should really only be used for "throw away" work.

While this is *technically* a breaking change, it **likely will not affect most clients**. The behavior should remain largely unchanged — data is still kept in-sync between the 2 contexts. So unless you were specifically relying on this parent-child nesting behavior, you should be fine. 👍

### Thanks

Huge thanks to @Liquidsoul for closing most of the issues for this release and to @wiedem for contributing significantly as well! 🎉

### Breaking changes ⚠️

##### Stack

- The `mainContext` and `backgroundContext` are now both connected to the persistent store coordinator (#60)
- When creating a child context, the `concurrencyType` determines which context is the parent (#73)
- `CoreDataStackFactory` has been simplified. There is now a single `createStack()` method. (#77)

##### Free functions

In alignment with the latest Swift API guidelines, the library now prefers methods/extensions over free functions.

- The `resetStack()` top-level function is now a method on `CoreDataStack` (#75)
- The `deleteObjects()` top-level function is now an extension method on `NSManagedObjectContext` (#76)
- The `fetch()` top-level function is now an extension method on `NSManagedObjectContext` (#78)
- The `migrate()` top-level function is now an extension method `CoreDataModel` (#82)

### Documentation

[All docs](http://www.jessesquires.com/JSQCoreDataKit/) have been updated. As usual, check these out for more details on the changes described above.

### Refinements

There have been other general refinements and additional unit tests have been added. Test coverage is 94% 😎

3.0.0
-----

This release closes the [3.0.0 milestone](https://github.com/jessesquires/JSQCoreDataKit/issues?q=milestone%3A3.0.0).

The goals of this release are primarily to adopt Swift 2.2 and refine the API to make it more *Swifty*, as the definition of *Swifty* has evolved.

### Breaking changes :warning:

There are many breaking changes in this release, however — with the exception of Swift 2.2 — they are all **merely name changes** that aim to reduce verbosity.

- Migrated to Swift 2.2. (#67) **Swift 2.2 and above is now required.**
- Renamed `DefaultStoreOptions` to `defaultStoreOptions`
- Renamed `CoreDataSaveResult` to `SaveResult`
- Renamed `CoreDataStackResult` to `StackResult`
- Renamed `CoreDataModel.removeExistingModelStore()` to `CoreDataModel.removeExistingStore()`
- Renamed all `enum` cases to be lowercase, in line with latest [Swift API guidelines](https://github.com/apple/swift-evolution/blob/master/proposals/0006-apply-api-guidelines-to-the-standard-library.md)
- The `StackResultClosure` typealias has been removed

### New features

- Support for Swift Package Manager (#55) :tada:
- Core Data model migration support! (#46, #66) Thanks @marius-serban ! :tada: See the [README](https://github.com/jessesquires/JSQCoreDataKit/blob/develop/README.md) and [docs](http://www.jessesquires.com/JSQCoreDataKit/Functions.html#/s:F14JSQCoreDataKit7migrateFzVS_13CoreDataModelT_) for details!


2.2.1
-----

This release closes the [2.2.1 milestone](https://github.com/jessesquires/JSQCoreDataKit/issues?q=milestone%3A2.2.1).

### Fixes

- Fixed multithreading violation while saving context (#63, #59, #65). Thanks @saurabytes and @markkrenek!
- On `tvOS`, the default SQLite directory now defaults to `.CacheDirectory` instead of `.DocumentDirectory` (#61, #62). Thanks @cgoldsby !


2.2.0
-----

This release closes the [2.2.0 milestone](https://github.com/jessesquires/JSQCoreDataKit/issues?q=milestone%3A2.2.0).

### New

Added a `resetStack()` top-level function. See the [updated docs](http://www.jessesquires.com/JSQCoreDataKit/Functions.html#/s:F14JSQCoreDataKit10resetStackFTCS_13CoreDataStack5queuePSo17OS_dispatch_queue_10completionFT6resultOS_19CoreDataStackResult_T__T_) for details. Thanks @marius-serban! :tada:

### Changes

:warning: `CoreDataStackFactory.CompletionHandler` was moved from the factory's scope to the module's scope and renamed to `StackResultClosure`. This is *technically* a breaking change, but it is *highly* unlikely that anyone was referring to this closure directly. If so, simply rename to the correct type.

2.1.0
-----

`JSQCoreDataKit` now "officially" supports all Apple platforms: iOS, OSX, tvOS, watchOS. :tada:

:trophy: [2.1.0 milestone](https://github.com/jessesquires/JSQCoreDataKit/issues?q=milestone%3A2.1.0)

2.0.0
-----

### :tada: `JSQCoreDataKit` 2.0 is here! :tada:

![img](http://assets9.pop-buzz.com/2015/36/tim-cook---the-only-thing-thats-changed-is-everything--1441882553-responsive-large-0.jpg)

### Breaking changes

- Swift 2.0

- You must now initialize `CoreDataStack` via a `CoreDataStackFactory`. This will init the stack on a background queue and return to your completion handler on the main queue when finished. This is necessary since adding a persistent store can take an unknown amount of time.

- Rethinking and rewriting of [`CoreDataStack`](http://www.jessesquires.com/JSQCoreDataKit/Classes/CoreDataStack.html). It now has a `mainContext` and a `backgroundContext`. :sunglasses:

- [Saving](http://www.jessesquires.com/JSQCoreDataKit/Functions.html#/s:F14JSQCoreDataKit11saveContextFTCSo22NSManagedObjectContext4waitSb10completionGSqFOS_18CoreDataSaveResultT___T_) a context now returns a [`CoreDataSaveResult`](http://www.jessesquires.com/JSQCoreDataKit/Enums/CoreDataSaveResult.html) to the completion handler, instead of `NSError?`

### New

- New [`CoreDataStackFactory`](http://www.jessesquires.com/JSQCoreDataKit/Structs/CoreDataStackFactory.html) for async stack initialization, as mentioned above. It also support synchronous init if you need it, but this is only recommended for testing. Returns a [`CoreDataStackResult`](http://www.jessesquires.com/JSQCoreDataKit/Enums/CoreDataStackResult.html).

- All types now conform to `CustomStringConvertible` and `Equatable`. :facepunch:

### Issues closed

Find the complete list of closed issues [here](https://github.com/jessesquires/JSQCoreDataKit/issues?q=milestone%3A2.0.0). :bug:

### Documentation

All [documentation](http://www.jessesquires.com/JSQCoreDataKit/) has been updated. :scroll:

## Example app

The [example app](https://github.com/jessesquires/JSQCoreDataKit/tree/develop/ExampleApp) is actually an example app now, check it out! It's a pretty substantial demo.

1.1.0
-----

This release closes the [1.1.0 milestone](https://github.com/jessesquires/JSQCoreDataKit/issues?q=milestone%3A%22Release+1.1.0%22).

* New top-level functions
* Ability to specify store directory other than `~/Documents/`
* No breaking changes

See the [documentation](http://www.jessesquires.com/JSQCoreDataKit/index.html) for more information!

1.0.0
-----

It's here!

Checkout the `README` and documentation.
