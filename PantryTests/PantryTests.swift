//
//  PantryTests.swift
//  PantryTests
//
//  Created by Nick O'Neill on 10/29/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import XCTest
@testable import Pantry

var token: Int = 0

class PantryTests: XCTestCase {
    private static var __once: () = {
            let testFolder = JSONWarehouse(key: "basic").cacheFileURL().deletingLastPathComponent()
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
        
        _ = PantryTests.__once
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDefaultTypes() {
        let string: String = "Hello"
        let int: Int = 4
        let float: Float = 10.2
        let double: Double = 20.6
        let date: Date = Date(timeIntervalSince1970: 1459355217)

        Pantry.pack(string, key: "ourTestString")
        Pantry.pack(int, key: "ourTestInt")
        Pantry.pack(float, key: "ourTestFloat")
        Pantry.pack(double, key: "ourTestDouble")
        Pantry.pack(date, key: "ourTestDate")

        if let unpackedString: String = Pantry.unpack("ourTestString") {
            XCTAssert(unpackedString == "Hello", "default string was incorrect")
        } else {
            XCTFail("no default string could be unpacked")
        }
        if let unpackedInt: Int = Pantry.unpack("ourTestInt") {
            XCTAssert(unpackedInt == 4, "default int was incorrect")
        } else {
            XCTFail("no default int could be unpacked")
        }
        if let unpackedFloat: Float = Pantry.unpack("ourTestFloat") {
            XCTAssert(unpackedFloat == 10.2, "default float was incorrect")
        } else {
            XCTFail("no default float could be unpacked")
        }
        if let unpackedDouble: Double = Pantry.unpack("ourTestDouble") {
            XCTAssert(unpackedDouble == 20.6, "default double was incorrect")
        } else {
            XCTFail("no default double could be unpacked")
        }
        if let unpackedDate: Date = Pantry.unpack("ourTestDate") {
            XCTAssert(unpackedDate.timeIntervalSince1970 == 1459355217, "default date was incorrect")
        } else {
            XCTFail("no default double could be unpacked")
        }
    }

    func testDefaultArray() {
        let defaultStrings = ["Default","Types","Strings"]
        let defaultInts = [0, 1, 2, 3, 4]
        let defaultFloats: [Float] = [10.2, 31.5, 28.3]
        
        Pantry.pack(defaultStrings, key: "default_strings_array")
        Pantry.pack(defaultInts, key: "default_ints_array")
        Pantry.pack(defaultFloats, key: "default_floats_array")

        if let unpackedDefaultStringsArray: [String] = Pantry.unpack("default_strings_array") {
            
            if unpackedDefaultStringsArray.count == 3 {
                XCTAssert(unpackedDefaultStringsArray[0] == "Default", "string array first was incorrect")
                XCTAssert(unpackedDefaultStringsArray[1] == "Types", "string array second was incorrect")
                XCTAssert(unpackedDefaultStringsArray[2] == "Strings", "string array third was incorrect")
            } else {
                XCTFail("string array was incorrect")
            }
        } else {
            XCTFail("no string array could be unpacked")
        }

        if let unpackedDefaultIntsArray: [Int] = Pantry.unpack("default_ints_array") {
            
            if unpackedDefaultIntsArray.count == 5 {
                XCTAssert(unpackedDefaultIntsArray[0] == 0, "int array first was incorrect")
                XCTAssert(unpackedDefaultIntsArray[2] == 2, "int array second was incorrect")
                XCTAssert(unpackedDefaultIntsArray[4] == 4, "int array third was incorrect")
                
            } else {
                XCTFail("int array was incorrect")
            }
        } else {
            XCTFail("no int array could be unpacked")
        }
        
        if let unpackedDefaultFloatsArray: [Float] = Pantry.unpack("default_floats_array") {
            
            if unpackedDefaultFloatsArray.count == 3 {
                XCTAssert(unpackedDefaultFloatsArray[0] == 10.2, "float array first was incorrect")
                XCTAssert(unpackedDefaultFloatsArray[1] == 31.5, "float array second was incorrect")
                XCTAssert(unpackedDefaultFloatsArray[2] == 28.3, "float array third was incorrect")
            } else {
                XCTFail("float array was incorrect")
            }
        } else {
            XCTFail("no float array could be unpacked")
        }
    }
    
    func testStorableStruct() {
        let basic = Basic(name: "Nick", age: 31.5, number: 42)
        
        Pantry.pack(basic, key: "basic")
        
        if let unpackedBasic: Basic = Pantry.unpack("basic") {
            XCTAssert(unpackedBasic.name == "Nick", "basic string was incorrect")
            XCTAssert(unpackedBasic.age == 31.5, "basic float was incorrect")
            XCTAssert(unpackedBasic.number == 42, "basic int was incorrect")
        } else {
            XCTFail("no basic struct could be unpacked")
        }
    }

    func testStorableFailingStruct() {
        let failing = FailingBasic(name: "Rob", age: 28.3, number: 5)

        Pantry.pack(failing, key: "failing")

        let unpacked: FailingBasic? = Pantry.unpack("failing")
        XCTAssert(unpacked == nil)
    }

    func testStorableArray() {
        let first = Basic(name: "Nick", age: 31.5, number: 42)
        let second = Basic(name: "Rebecca", age: 28.3, number: 87)
        let third = Basic(name: "Bob", age: 60, number: 23)
        let fourth = Basic(name: "Mike", age: 45.4, number: 0)

        let basics = [Basic](arrayLiteral: first, second, third, fourth)
        
        Pantry.pack(basics, key: "basic_array")
        
        if let unpackedBasicArray: [Basic] = Pantry.unpack("basic_array") {
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
    func testNestedStorable() {
        let first = Basic(name: "Nick", age: 31.5, number: 42)
        
        let nested = NestedStorable(name: "Top", basic: first)
        
        Pantry.pack(nested, key: "nested_storable")
        
        if let unpackedNested: NestedStorable = Pantry.unpack("nested_storable") {
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
        
        Pantry.pack(nested, key: "nested_default")
        
        if let unpackedNested: NestedDefault = Pantry.unpack("nested_default") {
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
    func testNestedStorableArray() {
        let first = Basic(name: "Nick", age: 31.5, number: 42)
        let second = Basic(name: "Rebecca", age: 28.3, number: 87)
        
        let nested = NestedStorableArray(name: "Nested", basics: [first, second])
        
        Pantry.pack(nested, key: "nested_storable_array")
        
        if let unpackedNested: NestedStorableArray = Pantry.unpack("nested_storable_array") {
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
    
    func testOptionalValueShouldCache() {
        let optional1 = BasicOptional(lastName: "Jhihguan", dogsAge: nil, leastFavoriteNumber: 1)
        let optional2 = BasicOptional(lastName: "Wane", dogsAge: 10, leastFavoriteNumber: nil)
        let optional3 = BasicOptional(lastName: nil, dogsAge: nil, leastFavoriteNumber: 1)
        let optional4 = BasicOptional(lastName: nil, dogsAge: 5, leastFavoriteNumber: nil)
        
        Pantry.pack(optional1, key: "optionalValueTest1")
        Pantry.pack(optional2, key: "optionalValueTest2")
        Pantry.pack(optional3, key: "optionalValueTest3")
        Pantry.pack(optional4, key: "optionalValueTest4")
        
        if let unpackOption1: BasicOptional = Pantry.unpack("optionalValueTest1") {
            XCTAssert(unpackOption1.lastName == "Jhihguan", "unpackOption1 field lastName should have value")
            XCTAssert(unpackOption1.dogsAge == nil, "unpackOption1 field dogsAge should be nil")
            XCTAssert(unpackOption1.leastFavoriteNumber == 1, "unpackOption1 field leastFavoriteNumber should have value")
        } else {
            XCTFail("no basicoptional struct could be unpacked")
        }
        
        if let unpackOption2: BasicOptional = Pantry.unpack("optionalValueTest2") {
            XCTAssert(unpackOption2.lastName == "Wane", "unpackOption2 field lastName should have value")
            XCTAssert(unpackOption2.dogsAge == 10, "unpackOption2 field dogsAge should have value")
            XCTAssert(unpackOption2.leastFavoriteNumber == nil, "unpackOption2 field leastFavoriteNumber should not be nil")
        } else {
            XCTFail("no basicoptional struct could be unpacked")
        }
        
        if let unpackOption3: BasicOptional = Pantry.unpack("optionalValueTest3") {
            XCTAssert(unpackOption3.lastName == nil, "unpackOption3 field lastName should be nil")
            XCTAssert(unpackOption3.dogsAge != 10 && unpackOption3.dogsAge == nil, "unpackOption3 field dogsAge should be nil")
            XCTAssert(unpackOption3.leastFavoriteNumber != nil, "unpackOption3 field leastFavoriteNumber should have value")
        } else {
            XCTFail("no basicoptional struct could be unpacked")
        }
        
        if let unpackOption4: BasicOptional = Pantry.unpack("optionalValueTest4") {
            XCTAssert(unpackOption4.lastName == nil, "unpackOption4 field lastName should be nil")
            XCTAssert(unpackOption4.dogsAge != 10 && unpackOption4.dogsAge != nil, "unpackOption4 field dogsAge should be nil")
            XCTAssert(unpackOption4.leastFavoriteNumber == nil, "unpackOption4 field leastFavoriteNumber should be nil")
        } else {
            XCTFail("no basicoptional struct could be unpacked")
        }
    }
    
    func testNestedOptionalArray() {
        let optional1 = BasicOptional(lastName: "Jhihguan", dogsAge: nil, leastFavoriteNumber: 1)
        let optional2 = BasicOptional(lastName: "Wane", dogsAge: 10, leastFavoriteNumber: nil)
        let optional3 = BasicOptional(lastName: nil, dogsAge: nil, leastFavoriteNumber: 1)
        let nestedOptionalArray1 = NestedOptionalStorableArray(name: "Wanew", optionals: [optional1, optional2, optional3])
        let nestedOptionalArray2 = NestedOptionalStorableArray(name: "Wanewww", optionals: nil)
        
        Pantry.pack(nestedOptionalArray1, key: "nestedOptionalArrayTest1")
        Pantry.pack(nestedOptionalArray2, key: "nestedOptionalArrayTest2")
        
        if let unpackNestedOption1: NestedOptionalStorableArray = Pantry.unpack("nestedOptionalArrayTest1") {
            XCTAssert(unpackNestedOption1.name == "Wanew", "unpackNestedOption1 field name should have value")
            if let optionals = unpackNestedOption1.optionals {
                XCTAssert(optionals.count == 3, "unpackNestedOption1 field optionals should have 3 variables")
                if let optionalValue1: BasicOptional = optionals[0] {
                    XCTAssert(optionalValue1.lastName == "Jhihguan", "optionalValue1 field lastName should have value")
                    XCTAssert(optionalValue1.dogsAge == nil, "optionalValue1 field dogsAge should be nil")
                    XCTAssert(optionalValue1.leastFavoriteNumber == 1, "optionalValue1 field leastFavoriteNumber should have value")
                } else {
                    XCTFail("no basicoptional struct at optionals[0]")
                }
                
                if let optionalValue2: BasicOptional = optionals[1] {
                    XCTAssert(optionalValue2.lastName == "Wane", "optionalValue2 field lastName should have value")
                    XCTAssert(optionalValue2.dogsAge == 10, "optionalValue2 field dogsAge should have value")
                    XCTAssert(optionalValue2.leastFavoriteNumber == nil, "optionalValue2 field leastFavoriteNumber should not be nil")
                } else {
                    XCTFail("no basicoptional struct at optionals[1]")
                }
                
                if let optionalValue3: BasicOptional = optionals[2] {
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
        
        if let unpackNestedOption2: NestedOptionalStorableArray = Pantry.unpack("nestedOptionalArrayTest2") {
            XCTAssert(unpackNestedOption2.name == "Wanewww", "unpackNestedOption2 field name should have value")
            XCTAssert(unpackNestedOption2.optionals == nil, "unpackNestedOption2 field optionals should be nil")
        } else {
            XCTFail("no basicoptional nested array struct could be unpacked")
        }
    }

    func testUpgradedStructFieldRemoved() {
        let basic = Basic(name: "Nick", age: 31.5, number: 42)

        Pantry.pack(basic, key: "basic")

        if let unpackedBasic: BasicUpgradedFieldRemoved = Pantry.unpack("basic") {
            XCTAssert(unpackedBasic.name == "Nick", "basic string was incorrect")
            XCTAssert(unpackedBasic.age == 31.5, "basic float was incorrect")
        } else {
            XCTFail("no basic struct could be unpacked")
        }
    }

    func testUpgradedStructFieldAdded() {
        let basic = Basic(name: "Nick", age: 31.5, number: 42)

        Pantry.pack(basic, key: "basic")

        if let unpackedBasic: BasicUpgradedFieldAdded = Pantry.unpack("basic") {
            XCTAssert(unpackedBasic.name == "Nick", "basic upgraded (field added) string was incorrect")
            XCTAssert(unpackedBasic.age == 31.5, "basic upgraded (field added) float was incorrect")
            XCTAssert(unpackedBasic.number == 42, "basic upgraded (field added) int was incorrect")
            XCTAssert(unpackedBasic.seniorCitizen == false, "basic upgraded (field added) bool was incorrect")
        } else {
            XCTFail("no basic struct could be unpacked")
        }
    }

}
