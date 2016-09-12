//
//  PantryClassTests.swift
//  Pantry
//
//  Created by Ian Keen on 12/12/2015.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import XCTest
@testable import Pantry

var classToken: Int = 0

class PantryClassTests: XCTestCase {
    private static var __once: () = {
            let testFolder = JSONWarehouse(key: "classes").cacheFileURL().deletingLastPathComponent()
            print("testing in", testFolder)
            
            // remove old files before our test
            let urls = try? FileManager.default.contentsOfDirectory(at: testFolder, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])
            if let urls = urls {
                for url in urls {
                    let _ = try? FileManager.default.removeItem(at: url)
                }
            }
        }()
    override func setUp() {
        super.setUp()
        
        _ = PantryClassTests.__once
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testStorableClass() {
        let basic = BasicClass(name: "Nick", age: 31.5, number: 42)
        
        Pantry.pack(basic, key: "basic")
        
        if let unpackedBasic: BasicClass = Pantry.unpack("basic") {
            XCTAssert(unpackedBasic.name == "Nick", "basic string was incorrect")
            XCTAssert(unpackedBasic.age == 31.5, "basic float was incorrect")
            XCTAssert(unpackedBasic.number == 42, "basic int was incorrect")
        } else {
            XCTFail("no basic struct could be unpacked")
        }
    }
    
    func testStorableClassArray() {
        let first = BasicClass(name: "Nick", age: 31.5, number: 42)
        let second = BasicClass(name: "Rebecca", age: 28.3, number: 87)
        let third = BasicClass(name: "Bob", age: 60, number: 23)
        let fourth = BasicClass(name: "Mike", age: 45.4, number: 0)
        
        let basics = [BasicClass](arrayLiteral: first, second, third, fourth)
        
        Pantry.pack(basics, key: "basic_array")
        
        if let unpackedBasicArray: [BasicClass] = Pantry.unpack("basic_array") {
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
    func testNestedStorableClass() {
        let first = BasicClass(name: "Nick", age: 31.5, number: 42)
        
        let nested = NestedStorableClass(name: "Top", basic: first)
        
        Pantry.pack(nested, key: "nested_storable")
        
        if let unpackedNested: NestedStorableClass = Pantry.unpack("nested_storable") {
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
    func testClassNestedArray() {
        let nested = NestedDefaultClass(names: ["Nested", "Default", "Array"], numbers: [1, 3, 5, 7, 9], ages: [31.5, 42.0, 23.1])
        
        Pantry.pack(nested, key: "nested_default")
        
        if let unpackedNested: NestedDefaultClass = Pantry.unpack("nested_default") {
            let names = unpackedNested.names
            
            if names.count == 3 {
                XCTAssert(names[0] == "Nested", "nested string was incorrect")
                XCTAssert(names[1] == "Default", "nested string was incorrect")
                XCTAssert(names[2] == "Array", "nested string was incorrect")
            } else {
                XCTFail("nested string array was incorrect")
            }
            
            let numbers = unpackedNested.numbers
            
            if numbers.count == 5 {
                XCTAssert(numbers[0] == 1, "nested int was incorrect")
                XCTAssert(numbers[1] == 3, "nested int was incorrect")
                XCTAssert(numbers[2] == 5, "nested int was incorrect")
                XCTAssert(numbers[3] == 7, "nested int was incorrect")
                XCTAssert(numbers[4] == 9, "nested int was incorrect")
            } else {
                XCTFail("nested int array was incorrect")
            }
            
            let ages = unpackedNested.ages
            
            if ages.count == 3 {
                XCTAssert(ages[0] == 31.5, "nested float was incorrect")
                XCTAssert(ages[1] == 42.0, "nested float was incorrect")
                XCTAssert(ages[2] == 23.1, "nested float was incorrect")
            } else {
                XCTFail("nested float array was incorrect")
            }
        } else {
            XCTFail("no nested defaults array could be unpacked")
        }
    }
    
    // nested arrays of storable types
    func testNestedClassArray() {
        let first = BasicClass(name: "Nick", age: 31.5, number: 42)
        let second = BasicClass(name: "Rebecca", age: 28.3, number: 87)
        
        let nested = NestedStorableArrayClass(name: "Nested", basics: [first, second])
        
        Pantry.pack(nested, key: "nested_storable_array")
        
        if let unpackedNested: NestedStorableArrayClass = Pantry.unpack("nested_storable_array") {
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
    
    func testOptionalClassValueShouldCache() {
        let optional1 = BasicOptionalClass(lastName: "Jhihguan", dogsAge: nil, leastFavoriteNumber: 1)
        let optional2 = BasicOptionalClass(lastName: "Wane", dogsAge: 10, leastFavoriteNumber: nil)
        let optional3 = BasicOptionalClass(lastName: nil, dogsAge: nil, leastFavoriteNumber: 1)
        let optional4 = BasicOptionalClass(lastName: nil, dogsAge: 5, leastFavoriteNumber: nil)
        
        Pantry.pack(optional1, key: "optionalValueTest1")
        Pantry.pack(optional2, key: "optionalValueTest2")
        Pantry.pack(optional3, key: "optionalValueTest3")
        Pantry.pack(optional4, key: "optionalValueTest4")
        
        if let unpackOption1: BasicOptionalClass = Pantry.unpack("optionalValueTest1") {
            XCTAssert(unpackOption1.lastName == "Jhihguan", "unpackOption1 field lastName should have value")
            XCTAssert(unpackOption1.dogsAge == nil, "unpackOption1 field dogsAge should be nil")
            XCTAssert(unpackOption1.leastFavoriteNumber == 1, "unpackOption1 field leastFavoriteNumber should have value")
        } else {
            XCTFail("no basicoptional struct could be unpacked")
        }
        
        if let unpackOption2: BasicOptionalClass = Pantry.unpack("optionalValueTest2") {
            XCTAssert(unpackOption2.lastName == "Wane", "unpackOption2 field lastName should have value")
            XCTAssert(unpackOption2.dogsAge == 10, "unpackOption2 field dogsAge should have value")
            XCTAssert(unpackOption2.leastFavoriteNumber == nil, "unpackOption2 field leastFavoriteNumber should not be nil")
        } else {
            XCTFail("no basicoptional struct could be unpacked")
        }
        
        if let unpackOption3: BasicOptionalClass = Pantry.unpack("optionalValueTest3") {
            XCTAssert(unpackOption3.lastName == nil, "unpackOption3 field lastName should be nil")
            XCTAssert(unpackOption3.dogsAge != 10 && unpackOption3.dogsAge == nil, "unpackOption3 field dogsAge should be nil")
            XCTAssert(unpackOption3.leastFavoriteNumber != nil, "unpackOption3 field leastFavoriteNumber should have value")
        } else {
            XCTFail("no basicoptional struct could be unpacked")
        }
        
        if let unpackOption4: BasicOptionalClass = Pantry.unpack("optionalValueTest4") {
            XCTAssert(unpackOption4.lastName == nil, "unpackOption4 field lastName should be nil")
            XCTAssert(unpackOption4.dogsAge != 10 && unpackOption4.dogsAge != nil, "unpackOption4 field dogsAge should be nil")
            XCTAssert(unpackOption4.leastFavoriteNumber == nil, "unpackOption4 field leastFavoriteNumber should be nil")
        } else {
            XCTFail("no basicoptional struct could be unpacked")
        }
    }
    
    func testNestedOptionalClassArray() {
        let optional1 = BasicOptionalClass(lastName: "Jhihguan", dogsAge: nil, leastFavoriteNumber: 1)
        let optional2 = BasicOptionalClass(lastName: "Wane", dogsAge: 10, leastFavoriteNumber: nil)
        let optional3 = BasicOptionalClass(lastName: nil, dogsAge: nil, leastFavoriteNumber: 1)
        let nestedOptionalArray1 = NestedOptionalStorableArrayClass(name: "Wanew", optionals: [optional1, optional2, optional3])
        let nestedOptionalArray2 = NestedOptionalStorableArrayClass(name: "Wanewww", optionals: nil)
        
        Pantry.pack(nestedOptionalArray1, key: "nestedOptionalArrayTest1")
        Pantry.pack(nestedOptionalArray2, key: "nestedOptionalArrayTest2")
        
        if let unpackNestedOption1: NestedOptionalStorableArrayClass = Pantry.unpack("nestedOptionalArrayTest1") {
            XCTAssert(unpackNestedOption1.name == "Wanew", "unpackNestedOption1 field name should have value")
            if let optionals = unpackNestedOption1.optionals {
                XCTAssert(optionals.count == 3, "unpackNestedOption1 field optionals should have 3 variables")
                if let optionalValue1: BasicOptionalClass = optionals[0] {
                    XCTAssert(optionalValue1.lastName == "Jhihguan", "optionalValue1 field lastName should have value")
                    XCTAssert(optionalValue1.dogsAge == nil, "optionalValue1 field dogsAge should be nil")
                    XCTAssert(optionalValue1.leastFavoriteNumber == 1, "optionalValue1 field leastFavoriteNumber should have value")
                } else {
                    XCTFail("no basicoptional struct at optionals[0]")
                }
                
                if let optionalValue2: BasicOptionalClass = optionals[1] {
                    XCTAssert(optionalValue2.lastName == "Wane", "optionalValue2 field lastName should have value")
                    XCTAssert(optionalValue2.dogsAge == 10, "optionalValue2 field dogsAge should have value")
                    XCTAssert(optionalValue2.leastFavoriteNumber == nil, "optionalValue2 field leastFavoriteNumber should not be nil")
                } else {
                    XCTFail("no basicoptional struct at optionals[1]")
                }
                
                if let optionalValue3: BasicOptionalClass = optionals[2] {
                    XCTAssert(optionalValue3.lastName == nil, "optionalValue3 field lastName should be nil")
                    XCTAssert(optionalValue3.dogsAge != 10 && optionalValue3.dogsAge == nil, "optionalValue3 field dogsAge should be nil")
                    XCTAssert(optionalValue3.leastFavoriteNumber != nil, "optionalValue3 field leastFavoriteNumber should have value")
                } else {
                    XCTFail("no basicoptional struct at optionals[2]")
                }
            } else {
                XCTFail("nested optional array should have value")
            }
        } else {
            XCTFail("no basicoptional nested array struct could be unpacked")
        }
        
        if let unpackNestedOption2: NestedOptionalStorableArrayClass = Pantry.unpack("nestedOptionalArrayTest2") {
            XCTAssert(unpackNestedOption2.name == "Wanewww", "unpackNestedOption2 field name should have value")
            XCTAssert(unpackNestedOption2.optionals == nil, "unpackNestedOption2 field optionals should be nil")
        } else {
            XCTFail("no basicoptional nested array struct could be unpacked")
        }
    }
}
