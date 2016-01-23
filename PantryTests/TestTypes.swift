//
//  TestTypes.swift
//  Pantry
//
//  Created by Robert Manson on 12/7/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import Foundation
import Pantry

struct Basic: Storable {
    let name: String
    let age: Float
    let number: Int

    init(name: String, age: Float, number: Int) {
        self.name = name
        self.age = age
        self.number = number
    }

    init(warehouse: Warehouseable) {
        self.name = warehouse.get("name") ?? "default"
        self.age = warehouse.get("age") ?? 20.5
        self.number = warehouse.get("number") ?? 10
    }
}

struct BasicUpgradedFieldAdded: Storable {
    let name: String
    let age: Float
    let number: Int
    let seniorCitizen: Bool

    init(name: String, age: Float, number: Int, seniorCitizen: Bool) {
        self.name = name
        self.age = age
        self.number = number
        self.seniorCitizen = seniorCitizen
    }

    init(warehouse: Warehouseable) {
        self.name = warehouse.get("name") ?? "default"
        self.age = warehouse.get("age") ?? 20.5
        self.number = warehouse.get("number") ?? 10
        self.seniorCitizen = warehouse.get("seniorCitizen") ?? false
    }
}

struct BasicUpgradedFieldRemoved: Storable {
    let name: String
    let age: Float

    init(name: String, age: Float) {
        self.name = name
        self.age = age
    }

    init(warehouse: Warehouseable) {
        self.name = warehouse.get("name") ?? "default"
        self.age = warehouse.get("age") ?? 20.5
    }
}

struct FailingBasic: Storable {
    let name: String
    let age: Float
    let number: Int

    init(name: String, age: Float, number: Int) {
        self.name = name
        self.age = age
        self.number = number
    }

    init?(warehouse: Warehouseable) {
        return nil
    }
}

struct BasicOptional: Storable {
    let lastName: String?
    let dogsAge: Float?
    let leastFavoriteNumber: Int?

    init(lastName: String?, dogsAge: Float?, leastFavoriteNumber: Int?) {
        self.lastName = lastName
        self.dogsAge = dogsAge
        self.leastFavoriteNumber = leastFavoriteNumber
    }

    init(warehouse: Warehouseable) {
        self.lastName = warehouse.get("lastName")
        self.dogsAge = warehouse.get("dogsAge")
        self.leastFavoriteNumber = warehouse.get("leastFavoriteNumber")
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

    init(warehouse: Warehouseable) {
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

    init(warehouse: Warehouseable) {
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

    init(warehouse: Warehouseable) {
        self.name = warehouse.get("name") ?? "default"
        self.basics = warehouse.get("basics") ?? []
    }
}

struct NestedOptionalStorableArray: Storable {
    let name: String?
    let optionals: [BasicOptional]?
    
    init(name: String, optionals: [BasicOptional]?) {
        self.name = name
        self.optionals = optionals
    }
    
    init(warehouse: Warehouseable) {
        self.name = warehouse.get("name") ?? "default"
        self.optionals = warehouse.get("optionals")
    }
}
