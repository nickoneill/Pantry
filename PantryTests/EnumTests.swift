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

    enum TestEnum: Int, StorableRawEnum {
        case Case1 = 1
        case Case2 = 2
    }

    struct TestStruct: Storable {
        let lastName: String?
        let cases: TestEnum

        init(lastName: String?, cases: TestEnum) {
            self.lastName = lastName
            self.cases = cases
        }

        init(warehouse: Warehouseable) {
            self.lastName = warehouse.get("lastName")
            self.cases = warehouse.get("cases")!
        }
    }

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
        let first = TestEnum.Case1

        Pantry.pack(first, key: "enum")

        if let unpackedNested: TestEnum = Pantry.unpack("enum") {
            XCTAssert(first == unpackedNested)
        } else {
            XCTFail("enum storable could be unpacked")
        }
    }

    func testEnumInStruct() {
        let myStruct = TestStruct(lastName: "Plisken", cases: TestEnum.Case2)
        Pantry.pack(myStruct, key: "myStruct")


        if let unpacked: TestStruct = Pantry.unpack("myStruct") {
            XCTAssert(unpacked.lastName == "Plisken")
            XCTAssert(unpacked.cases == TestEnum.Case2)
        } else {
            XCTFail("enum storable could be unpacked")
        }
    }
}
