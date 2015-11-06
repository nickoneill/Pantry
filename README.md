<p align="center">
    <img src="http://raquo.net/images/banner-storage.png" alt="Storage" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat" alt="Platform: iOS 8+" />
    <a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/language-swift2-f48041.svg?style=flat" alt="Language: Swift 2" /></a>
    <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
    <a href="https://cocoapods.org/pods/Storage"><img src="https://cocoapod-badges.herokuapp.com/v/Storage/badge.png" alt="Cocoapods compatible" /></a>
    <img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="License: MIT" />
</p>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="https://github.com/nickoneill/Storage/issues">Issues</a>
  • <a href="#license">License</a>
</p>

#### Storage is new! Please join us in [issues](https://github.com/nickoneill/Storage/issues) if you'd like to help us get to 1.0

Storage is a lightweight way to persist structs containing user data, cached content or other relevant objects for later retrieval.

```swift
let someCustomStruct = SomeCustomStruct(...)
Storage.pack(someCustomStruct, "user_data")

... later ...

if let unpackedCustomStruct: SomeCustomStruct = Storage.unpack("user_data") {
  print("got my data out",unpackedCustomStruct)
} else {
  print("there was no struct data to get")
}
```

You can store:
* [x] Structs
* [x] Strings, Ints and Floats (our default types)
* [x] Arrays of structs and default types
* [x] Nested structs
* [ ] Nested Arrays

Check out [the tests](https://github.com/nickoneill/Storage/blob/master/StorageTests/StorageTests.swift) for a detailed look at the varied types you can easily store.

## Compatibility

Storage requires iOS 8+ and is compatible with **Swift 2** projects. Objective-C support is unlikely.

## Installation

Installation for [Carthage](https://github.com/Carthage/Carthage) is simple enough:

`github "nickoneill/Storage" ~> 0.1`

As for [Cocoapods](https://cocoapods.org), use this to get the latest release:

```ruby
use_frameworks!

pod 'Storage'
```

And `import Storage` in the files you'd like to use it.

## Usage

Add the `Storable` protocol to any struct you want stored and then ensure they comply by implementing an init method:
```swift
struct Basic: Storable {
    let name: String
    let age: Float
    let number: Int

    init(warehouse: JSONWarehouse) {
        self.name = warehouse.get("name") ?? "default"
        self.age = warehouse.get("age") ?? 20.5
        self.number = warehouse.get("number") ?? 10
    }
}
```

## License

Storage uses the MIT license. Please file an issue if you have any questions or if you'd like to share how you're using this tool.
