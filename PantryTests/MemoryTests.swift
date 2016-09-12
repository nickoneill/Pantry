//
//  MemoryTests.swift
//  Pantry
//
//  Created by Robert Manson on 12/7/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import XCTest
import Pantry

class MemoryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Pantry.enableInMemoryModeWithIdentifier = self.name
    }

    override func tearDown() {
        super.tearDown()
        Pantry.enableInMemoryModeWithIdentifier = nil
    }

    func testDefaultTypes() {
        let string: String = "Hello"
        let int: Int = 4
        let float: Float = 10.2
        let double: Double = 12.7
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
            XCTAssert(unpackedDouble == 12.7, "default double was incorrect")
        } else {
            XCTFail("no default double could be unpacked")
        }
        if let unpackedDate: Date = Pantry.unpack("ourTestDate") {
            XCTAssert(unpackedDate.timeIntervalSince1970 == 1459355217, "default date was incorrect")
        } else {
            XCTFail("no default double could be unpacked")
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
}
