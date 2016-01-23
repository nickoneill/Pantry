//
//  TestEnumTypes.swift
//  Pantry
//
//  Created by Arthur Myronenko on 1/23/16.
//  Copyright © 2016 That Thing in Swift. All rights reserved.
//

import Foundation

enum IntEnum: Int, StorableRawEnum {
    case Case1 = 1
    case Case2 = 2
    case Case3 = 3
}

enum StringEnum: String, StorableRawEnum {
    case Case1 = "First"
    case Case2 = "Second"
    case Case3 = "Third"
}

enum FloatEnum: Float, StorableRawEnum {
    case Case1 = 1.0
    case Case2 = 2.0
    case Case3 = 3.0
}

struct StructWithEnum: Storable {
    let lastName: String?
    let cases: IntEnum
    
    init(lastName: String?, cases: IntEnum) {
        self.lastName = lastName
        self.cases = cases
    }
    
    init(warehouse: Warehouseable) {
        self.lastName = warehouse.get("lastName")
        self.cases = warehouse.get("cases") ?? .Case3
    }
}