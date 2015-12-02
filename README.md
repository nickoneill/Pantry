<p align="center">
    <img src="http://raquo.net/images/banner-pantry.png" alt="Storage" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat" alt="Platform: iOS 8+" />
    <a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/language-swift2-f48041.svg?style=flat" alt="Language: Swift 2" /></a>
    <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
    <a href="https://cocoapods.org/pods/Pantry"><img src="https://cocoapod-badges.herokuapp.com/v/Pantry/badge.png" alt="Cocoapods compatible" /></a>
    <img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="License: MIT" />
</p>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="https://github.com/nickoneill/Pantry/issues">Issues</a>
  • <a href="#license">License</a>
</p>

#### Pantry is new! Please join us in [issues](https://github.com/nickoneill/Pantry/issues) if you'd like to help us get to 1.0

Pantry is a lightweight way to persist structs containing user data, cached content or other relevant objects for later retrieval.

```swift
let someCustomStruct = SomeCustomStruct(...)
Pantry.pack(someCustomStruct, "user_data")

... later ...

if let unpackedCustomStruct: SomeCustomStruct = Pantry.unpack("user_data") {
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

Check out [the tests](https://github.com/nickoneill/Pantry/blob/master/PantryTests/PantryTests.swift) for a detailed look at the varied types you can easily store.

## Compatibility

Pantry requires iOS 8+ and is compatible with **Swift 2** projects. Objective-C support is unlikely.

## Installation

Installation for [Carthage](https://github.com/Carthage/Carthage) is simple enough:

`github "nickoneill/Pantry" ~> 0.2.1`

As for [Cocoapods](https://cocoapods.org), use this to get the latest release:

```ruby
use_frameworks!

pod 'Pantry'
```

And `import Pantry` in the files you'd like to use it.

## Usage

Add the `Storable` protocol to any struct you want stored and then ensure they comply by implementing an init method that gets each property from the warehouse:
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

Getters always provide an optional value, leaving you the opportunity to fill in a default if a value isn't available. This makes for hassle-free property additions to your structs.

## Also

Pantry works great with network data when paired with a JSON struct decoder such as [Unbox](https://github.com/JohnSundell/Unbox). Download JSON, decode it with Unbox, save it with Pantry and have it available for as long as you need. The architecture of Pantry is heavily influenced by Unbox, it's worth a look in any case.

## License

Pantry uses the MIT license. Please file an issue if you have any questions or if you'd like to share how you're using this tool.

## ack

Pantry "can icon" by [CDH from the Noun Project](https://thenounproject.com/term/soup-can/49680/)
