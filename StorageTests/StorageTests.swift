//
//  StorageTests.swift
//  StorageTests
//
//  Created by Nick O'Neill on 10/29/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import XCTest
@testable import Storage

class StorageTests: XCTestCase {
    struct Basic: Storable {
        let name: String
        let age: Float
        let number: Int
        
        init(name: String, age: Float, number: Int) {
            self.name = name
            self.age = age
            self.number = number
        }
        
        init(warehouse: JSONWarehouse) {
            self.name = warehouse.get("name") ?? "default"
            self.age = warehouse.get("age") ?? 20.5
            self.number = warehouse.get("number") ?? 10
        }
    }
    
    struct NestedDefault: Storable {
        let names: [String]
        let numbers: [Int]
        let ages: [Float]
        
        init(names: [String], numbers: [Int], ages: [Float]) {
            self.names = names
            self.numbers = numbers
            self.ages = ages
        }
        
        init(warehouse: JSONWarehouse) {
            self.names = warehouse.get("names") ?? []
            self.numbers = warehouse.get("numbers") ?? []
            self.ages = warehouse.get("ages") ?? []
        }
    }
    
    struct NestedStorable: Storable {
        let name: String
        let basic: Basic?
        
        init(name: String, basic: Basic? = nil) {
            self.name = name
            self.basic = basic
        }
        
        init(warehouse: JSONWarehouse) {
            self.name = warehouse.get("name") ?? "default"
            self.basic = warehouse.get("basic")
        }
    }
    
    struct NestedStorableArray: Storable {
        let name: String
        let basics: [Basic]
        
        init(name: String, basics: [Basic]) {
            self.name = name
            self.basics = basics
        }
        
        init(warehouse: JSONWarehouse) {
            self.name = warehouse.get("name") ?? "default"
            self.basics = warehouse.get("basics") ?? []
        }
    }
    
    override func setUp() {
        super.setUp()
        
        var token: dispatch_once_t = 0
        dispatch_once(&token) {
            print("testing in",JSONWarehouse(key: "basic").cacheFileURL())
        }
    }
    
    override func tearDown() {
        let basicLocation = JSONWarehouse(key: "basic").cacheFileURL()
        let _ = try? NSFileManager.defaultManager().removeItemAtURL(basicLocation)
        let basicArrayLocation = JSONWarehouse(key: "basic_array").cacheFileURL()
        let _ = try? NSFileManager.defaultManager().removeItemAtURL(basicArrayLocation)
        
        super.tearDown()
    }
    
    func testDefaultTypes() {
        let string: String = "Hello"
        let int: Int = 4
        let float: Float = 10.2
        
        Storage.pack(string, key: "ourTestString")
        Storage.pack(int, key: "ourTestInt")
        Storage.pack(float, key: "ourTestFloat")
        
        if let unpackedString: String = Storage.unpack("ourTestString") {
            XCTAssert(unpackedString == "Hello", "default string was incorrect")
        } else {
            XCTFail("no default string could be unpacked")
        }
        if let unpackedInt: Int = Storage.unpack("ourTestInt") {
            XCTAssert(unpackedInt == 4, "default int was incorrect")
        } else {
            XCTFail("no default int could be unpacked")
        }
        if let unpackedFloat: Float = Storage.unpack("ourTestFloat") {
            XCTAssert(unpackedFloat == 10.2, "default float was incorrect")
        } else {
            XCTFail("no default float could be unpacked")
        }
    }
    
    func testDefaultArray() {
        let defaults = [0,1,2,3,4]
        
        Storage.pack(defaults, key: "defaults_array")
        
        if let unpackedDefaultsArray: [Int] = Storage.unpack("defaults_array") {
            let first = unpackedDefaultsArray[0]
            let second = unpackedDefaultsArray[2]
            let third = unpackedDefaultsArray[4]
            
            XCTAssert(first == 0, "default array first was incorrect")
            XCTAssert(second == 2, "default array second was incorrect")
            XCTAssert(third == 4, "default array third was incorrect")
        } else {
            XCTFail("no default array could be unpacked")
        }
    }
    
    func testStorableStruct() {
        let basic = Basic(name: "Nick", age: 31.5, number: 42)
        
        Storage.pack(basic, key: "basic")
        
        if let unpackedBasic: Basic = Storage.unpack("basic") {
            XCTAssert(unpackedBasic.name == "Nick", "basic string was incorrect")
            XCTAssert(unpackedBasic.age == 31.5, "basic float was incorrect")
            XCTAssert(unpackedBasic.number == 42, "basic int was incorrect")
        } else {
            XCTFail("no basic struct could be unpacked")
        }
    }
    
    func testStorableArray() {
        let first = Basic(name: "Nick", age: 31.5, number: 42)
        let second = Basic(name: "Rebecca", age: 28.3, number: 87)
        let third = Basic(name: "Bob", age: 60, number: 23)
        let fourth = Basic(name: "Mike", age: 45.4, number: 0)

        let basics = [Basic](arrayLiteral: first, second, third, fourth)
        
        Storage.pack(basics, key: "basic_array")
        
        if let unpackedBasicArray: [Basic] = Storage.unpack("basic_array") {
            XCTAssert(unpackedBasicArray.count == 4, "basic array didn't contain the right amount of structs")
            
            let unpackedFirst = unpackedBasicArray[0]
            
            XCTAssert(unpackedFirst.name == "Nick", "basic string first was incorrect")
            XCTAssert(unpackedFirst.age == 31.5, "basic float first was incorrect")
            XCTAssert(unpackedFirst.number == 42, "basic int first was incorrect")

            let unpackedThird = unpackedBasicArray[2]

            XCTAssert(unpackedThird.name == "Bob", "basic string third was incorrect")
            XCTAssert(unpackedThird.age == 60, "basic float third was incorrect")
            XCTAssert(unpackedThird.number == 23, "basic int third was incorrect")
        } else {
            XCTFail("no basic struct array could be unpacked")
        }
    }
    
    // nested storable types
    // TODO: this doesn't work because we can't infer the nested type, see issue #1
    func testNestedStorable() {
        let first = Basic(name: "Nick", age: 31.5, number: 42)
        
        let nested = NestedStorable(name: "Top", basic: first)
        
        Storage.pack(nested, key: "nested_storable")
        
        if let unpackedNested: NestedStorable = Storage.unpack("nested_storable") {
            XCTAssert(unpackedNested.name == "Top", "nested name was incorrect")
            
            if let basic = unpackedNested.basic {
                XCTAssert(basic.name == "Nick", "nested storable name was incorrect")
                XCTAssert(basic.age == 31.5, "nested storable age was incorrect")
                XCTAssert(basic.number == 42, "nested storable number was incorrect")
            } else {
                XCTFail("nested storable doesn't exist")
            }
            
        } else {
            XCTFail("no nested storable could be unpacked")
        }
    }
    
    // nested arrays of default types
    func testNestedArray() {
        let nested = NestedDefault(names: ["Nested","Default","Array"], numbers: [1,3,5,7,9], ages: [31.5, 42.0, 23.1])
        
        Storage.pack(nested, key: "nested_default")
        
        if let unpackedNested: NestedDefault = Storage.unpack("nested_default") {
            let names = unpackedNested.names
            
            XCTAssert(names.count == 3, "nested string array was incorrect")
            XCTAssert(names[0] == "Nested", "nested string was incorrect")
            XCTAssert(names[1] == "Default", "nested string was incorrect")
            XCTAssert(names[2] == "Array", "nested string was incorrect")

            let numbers = unpackedNested.numbers
            
            XCTAssert(numbers.count == 5, "nested int array was incorrect")
            XCTAssert(numbers[0] == 1, "nested int was incorrect")
            XCTAssert(numbers[1] == 3, "nested int was incorrect")
            XCTAssert(numbers[2] == 5, "nested int was incorrect")
            XCTAssert(numbers[3] == 7, "nested int was incorrect")
            XCTAssert(numbers[4] == 9, "nested int was incorrect")

            let ages = unpackedNested.ages
            
            XCTAssert(ages.count == 3, "nested float array was incorrect")
            XCTAssert(ages[0] == 31.5, "nested float was incorrect")
            XCTAssert(ages[1] == 42.0, "nested float was incorrect")
            XCTAssert(ages[2] == 23.1, "nested float was incorrect")
        } else {
            XCTFail("no nested defaults array could be unpacked")
        }
    }
    
    // nested arrays of storable types
    // TODO: this doesn't work because we can't infer the nested type, see issue #1
    func testNestedStorableArray() {
        let first = Basic(name: "Nick", age: 31.5, number: 42)
        let second = Basic(name: "Rebecca", age: 28.3, number: 87)
        
        let nested = NestedStorableArray(name: "Nested", basics: [first, second])
        
        Storage.pack(nested, key: "nested_storable_array")
        
        if let unpackedNested: NestedStorableArray = Storage.unpack("nested_storable_array") {
            XCTAssert(unpackedNested.name == "Nested", "nested name was incorrect")
            
            XCTAssert(unpackedNested.basics.count == 2, "nested storable array count was incorrect")
            
            if let unpackedFirst = unpackedNested.basics.first {
                XCTAssert(unpackedFirst.name == "Nick", "nested storable array name was incorrect")
                XCTAssert(unpackedFirst.age == 31.5, "nested storable array age was incorrect")
                XCTAssert(unpackedFirst.number == 42, "nested storable array number was incorrect")
            } else {
                XCTFail("first nested storable incorrect")
            }

            if let unpackedSecond = unpackedNested.basics.last {
                XCTAssert(unpackedSecond.name == "Rebecca", "nested storable array name was incorrect")
                XCTAssert(unpackedSecond.age == 28.3, "nested storable array age was incorrect")
                XCTAssert(unpackedSecond.number == 87, "nested storable array number was incorrect")
            } else {
                XCTFail("second nested storable incorrect")
            }
        } else {
            XCTFail("no nested storable array could be unpacked")
        }
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
