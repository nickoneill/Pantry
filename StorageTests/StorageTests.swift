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
    
//    struct NestedStorable: Storable {
//        let name: String
//        let basics: [Basic]
//        
//        init(name: String, basics: [Basic]) {
//            self.name = name
//            self.basics = basics
//        }
//        
//        init(warehouse: JSONWarehouse) {
//            self.name = warehouse.get("name") ?? "default"
//            self.basics = warehouse.get("basics") ?? []
//        }
//    }
    
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
    
    //
    func testNestedArray() {
        let nested = NestedDefault(names: ["Nested","Default","Array"], numbers: [1,3,5,7,9], ages: [31.5, 42.0, 23.1])
        
        Storage.pack(nested, key: "nested_default")
        
        if let unpackedNested: NestedDefault = Storage.unpack("nested_default") {
            let names = unpackedNested.names
            
            XCTAssert(names.count == 3, "nested string array was incorrect")
            XCTAssert(names[2] == "Array", "nested string was incorrect")

            let numbers = unpackedNested.numbers
            
            XCTAssert(numbers.count == 5, "nested int array was incorrect")
            XCTAssert(numbers[0] == 1, "nested int was incorrect")

            let ages = unpackedNested.ages
            
            XCTAssert(ages.count == 3, "nested float array was incorrect")
            XCTAssert(ages[1] == 42.0, "nested float was incorrect")
        } else {
            XCTFail("no nested defaults array could be unpacked")
        }
    }
    
//    func testNestedStorableArray() {
//        let first = Basic(name: "Nick", age: 31.5, number: 42)
//        let second = Basic(name: "Rebecca", age: 28.3, number: 87)
//        
//        let nested = NestedStorable(name: "Nested", basics: [first, second])
//        
//        Storage.pack(nested, key: "nested_storable")
//    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
