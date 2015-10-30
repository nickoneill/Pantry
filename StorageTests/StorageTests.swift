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
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        let basicLocation = JSONWarehouse(key: "basic").cacheFileURL()
        let _ = try? NSFileManager.defaultManager().removeItemAtURL(basicLocation)
        let basicArrayLocation = JSONWarehouse(key: "basic_array").cacheFileURL()
        let _ = try? NSFileManager.defaultManager().removeItemAtURL(basicArrayLocation)
        
        super.tearDown()
    }
    
    func testBasicStruct() {
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
    
    func testBasicStructArray() {
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
    
    func testDefaultTypes() {
        let string: String = "Hello"
        let int: Int = 4
        let float: Float = 10.2
        
        Storage.pack(string, key: "ourTestString")
        Storage.pack(int, key: "ourTestInt")
        Storage.pack(float, key: "ourTestFloat")
        
        if let unpackedString: String = Storage.unpack("ourTestString") {
            XCTAssert(unpackedString == "Hello", "default string was incorrect")
        }
        if let unpackedInt: Int = Storage.unpack("ourTestInt") {
            XCTAssert(unpackedInt == 4, "default int was incorrect")
        }
        if let unpackedFloat: Float = Storage.unpack("ourTestFloat") {
            XCTAssert(unpackedFloat == 10.2, "default float was incorrect")
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
        }
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
