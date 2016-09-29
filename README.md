<p align="center">
    <img src="http://raquo.net/images/banner-pantry.png" alt="Storage" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat" alt="Platform: iOS 8+" />
    <a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/language-swift3-f48041.svg?style=flat" alt="Language: Swift 3" /></a>
    <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
    <a href="https://cocoapods.org/pods/Pantry"><img src="https://cocoapod-badges.herokuapp.com/v/Pantry/badge.png" alt="CocoaPods compatible" /></a>
    <a href="http://cocoadocs.org/docsets/Pantry"><img src="https://img.shields.io/cocoapods/metrics/doc-percent/Pantry.svg" alt="Docs" /></a>
    <img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="License: MIT" />
</p>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="https://github.com/nickoneill/Pantry/issues">Issues</a>
  • <a href="#license">License</a>
</p>

#### Please join us in [issues](https://github.com/nickoneill/Pantry/issues) if you'd like to help us get to 1.0. And read about more [use cases for Pantry](https://medium.com/ios-os-x-development/the-missing-light-persistence-layer-for-swift-35ce75d02d47).

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
* [x] Classes
* [x] Arrays of classes and default types
* [x] Nested classes
* [x] Enums with raw types

Check out [the tests](https://github.com/nickoneill/Pantry/blob/master/PantryTests/) for a detailed look at the varied types you can easily store.

## Compatibility

Pantry requires iOS 8+ and is compatible with **Swift 3** projects. Please use release `0.2.2` for the final Swift 2.x supported version, or the `swift2` branch. Objective-C support is unlikely.

## Installation

Installation for [Carthage](https://github.com/Carthage/Carthage) is simple enough:

`github "nickoneill/Pantry" ~> 0.3`

As for [CocoaPods](https://cocoapods.org), use this to get the latest release:

```ruby
use_frameworks!

pod 'Pantry'
```

And `import Pantry` in the files you'd like to use it.

## Usage

### Basic types
Pantry provides serialization of some basic types (`String`, `Int`, `Float`, `Bool`) with no setup. You can use it as a simple expiring cache like this:

```swift
if let available: Bool = Pantry.unpack("promptAvailable") {
    completion(available: available)
} else {
    anExpensiveOperationToDetermineAvailability({ (available) -> () in
      Pantry.pack(available, key: "promptAvailable", expires: .Seconds(60 * 10))
      completion(available: available)
    })
}
```

### Automagic Persistent Variables
Use Swift's get/set to automatically persist the value of a variable on write and get the latest value on read.

```swift
var autopersist: String? {
    set {
        if let newValue = newValue {
            Pantry.pack(newValue, key: "autopersist")
        }
    }
    get {
        return Pantry.unpack("autopersist")
    }
}

...later...

autopersist = "Hello!"
// restart app, reboot phone, etc
print(autopersist) // Hello!
```

### Structs
Add the `Storable` protocol to any struct you want stored and then ensure they comply by implementing an `init` method that gets each property from the warehouse, and a `toDictionary` method that converts the other way:
```swift
struct Basic: Storable {
    let name: String
    let age: Float
    let number: Int

    init(warehouse: Warehouseable) {
        self.name = warehouse.get("name") ?? "default"
        self.age = warehouse.get("age") ?? 20.5
        self.number = warehouse.get("number") ?? 10
    }

    func toDictionary() -> [String : AnyObject] {
        return [ "name": self.name, "age": self.age, "number": self.number ]
    }
}
```

Getters always provide an optional value, leaving you the opportunity to fill in a default if a value isn't available. This makes for hassle-free property additions to your structs.

### Classes

Classes are also supported and can be setup the same way Structs are however the init method must be marked `required` in this case. Class inheritance and nested `Storable` properties are also possible:
```swift
class ModelBase: Storable {
    let id: String
    
    required init(warehouse: Warehouseable) {
        self.id = warehouse.get("id") ?? "default_id"
    }

    func toDictionary() -> [String : AnyObject] {
        return [ "id": self.id ]
    }
}

class BasicClassModel: ModelBase {
    let name: String
    let age: Float
    let number: Int
    
    required init(warehouse: Warehouseable) {
        self.name = warehouse.get("name") ?? "default"
        self.age = warehouse.get("age") ?? 20.5
        self.number = warehouse.get("number") ?? 10
        
        super.init(warehouse: warehouse)
    }

    func toDictionary() -> [String : AnyObject] {
        var dictionary = super.toDictionary()
        dictionary["name"] = self.name
        dictionary["age"] = self.age
        dictionary["number"] = self.number
        return dictionary
    }
}
```

## Also

Pantry works great with network data when paired with a JSON struct decoder such as [Unbox](https://github.com/JohnSundell/Unbox). Download JSON, decode it with Unbox, save it with Pantry and have it available for as long as you need. The architecture of Pantry is heavily influenced by Unbox, it's worth a look in any case.

## License

Pantry uses the MIT license. Please file an issue if you have any questions or if you'd like to share how you're using this tool.

## ack

Pantry "can icon" by [CDH from the Noun Project](https://thenounproject.com/term/soup-can/49680/)
