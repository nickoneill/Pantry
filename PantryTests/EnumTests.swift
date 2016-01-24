//
//  EnumTests.swift
//  Pantry
//
//  Created by Robert Manson on 12/23/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import XCTest
@testable import Pantry

class EnumTests: XCTestCase {

    override func setUp() {
        super.setUp()

        dispatch_once(&token) {
            let testFolder = JSONWarehouse(key: "basic").cacheFileURL().URLByDeletingLastPathComponent!
            print("testing in",testFolder)

            // remove old files before our test
            let urls = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(testFolder, includingPropertiesForKeys: nil, options: [.SkipsSubdirectoryDescendants, .SkipsHiddenFiles])
            if let urls = urls {
                for url in urls {
                    let _ = try? NSFileManager.defaultManager().removeItemAtURL(url)
                }
            }
        }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testEnumStorable() {
        let intEnum = IntEnum.Case1
        let stringEnum = StringEnum.Case1
        let floatEnum = FloatEnum.Case1

        Pantry.pack(intEnum, key: "int_enum")
        Pantry.pack(stringEnum, key: "string_enum")
        Pantry.pack(floatEnum, key: "float_enum")

        if let unpackedIntEnum: IntEnum = Pantry.unpack("int_enum") {
            XCTAssert(unpackedIntEnum == IntEnum.Case1)
        } else {
            XCTFail("no enum storable could be unpacked")
        }
        if let unpackedStringEnum: StringEnum = Pantry.unpack("string_enum") {
            XCTAssert(unpackedStringEnum == StringEnum.Case1)
        } else {
            XCTFail("no enum storable could be unpacked")
        }
        if let unpackedFloatEnum: FloatEnum = Pantry.unpack("float_enum") {
            XCTAssert(unpackedFloatEnum == FloatEnum.Case1)
        } else {
            XCTFail("no enum storable could be unpacked")
        }
    }
    
    func testEnumInStruct() {
        let myStruct = StructWithEnum(lastName: "Plisken", cases: IntEnum.Case2)
        Pantry.pack(myStruct, key: "myStruct")


        if let unpacked: StructWithEnum = Pantry.unpack("myStruct") {
            XCTAssert(unpacked.lastName == "Plisken")
            XCTAssert(unpacked.cases == IntEnum.Case2)
        } else {
            XCTFail("no enum storable could be unpacked")
        }
    }
}
