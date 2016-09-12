//
//  TestClassTypes.swift
//  Pantry
//
//  Created by Ian Keen on 12/12/2015.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import Foundation
import Pantry

class EmptyWarehouse: Warehouseable {
    func get<T: Storable>(_ valueKey: String) -> [T]? {
        return nil
    }
    func get<T: Storable>(_ valueKey: String) -> T? {
        return nil
    }
    func get<T: StorableDefaultType>(_ valueKey: String) -> [T]? {
        return nil
    }
    func get<T: StorableDefaultType>(_ valueKey: String) -> T? {
        return nil
    }
}

class ClassBase: Storable {
    var name: String
    
    required init(warehouse: Warehouseable) {
        self.name = warehouse.get("name") ?? "default"
    }
}
class BasicClass: ClassBase {
    var age: Float
    var number: Int
    
    convenience init(name: String, age: Float, number: Int) {
        self.init(warehouse: EmptyWarehouse())
        
        self.name = name
        self.age = age
        self.number = number
    }
    required init(warehouse: Warehouseable) {
        self.age = warehouse.get("age") ?? 20.5
        self.number = warehouse.get("number") ?? 10
        
        super.init(warehouse: warehouse)
    }
}
class BasicOptionalClass: Storable {
    var lastName: String?
    var dogsAge: Float?
    var leastFavoriteNumber: Int?
    
    convenience init(lastName: String?, dogsAge: Float?, leastFavoriteNumber: Int?) {
        self.init(warehouse: EmptyWarehouse())
        
        self.lastName = lastName
        self.dogsAge = dogsAge
        self.leastFavoriteNumber = leastFavoriteNumber
    }
    
    required init(warehouse: Warehouseable) {
        self.lastName = warehouse.get("lastName")
        self.dogsAge = warehouse.get("dogsAge")
        self.leastFavoriteNumber = warehouse.get("leastFavoriteNumber")
    }
}

class NestedDefaultClassBase: Storable {
    var names: [String]
    
    required init(warehouse: Warehouseable) {
        self.names = warehouse.get("names") ?? []
    }
}
class NestedDefaultClass: NestedDefaultClassBase {
    var numbers: [Int]
    var ages: [Float]
    
    convenience init(names: [String], numbers: [Int], ages: [Float]) {
        self.init(warehouse: EmptyWarehouse())
        
        self.names = names
        self.numbers = numbers
        self.ages = ages
    }
    
    required init(warehouse: Warehouseable) {
        self.numbers = warehouse.get("numbers") ?? []
        self.ages = warehouse.get("ages") ?? []
        super.init(warehouse: warehouse)
    }
}

class NestedStorableClass: ClassBase {
    var basic: BasicClass?
    
    convenience init(name: String, basic: BasicClass?) {
        self.init(warehouse: EmptyWarehouse())
        
        self.name = name
        self.basic = basic
    }
    
    required init(warehouse: Warehouseable) {
        self.basic = warehouse.get("basic")
        super.init(warehouse: warehouse)
    }
}
class NestedStorableArrayClass: ClassBase {
    var basics: [BasicClass]
    
    convenience init(name: String, basics: [BasicClass]) {
        self.init(warehouse: EmptyWarehouse())
        
        self.name = name
        self.basics = basics
    }
    
    required init(warehouse: Warehouseable) {
        self.basics = warehouse.get("basics") ?? []
        super.init(warehouse: warehouse)
    }
}
class NestedOptionalStorableArrayClass: Storable {
    var name: String?
    var optionals: [BasicOptionalClass]?
    
    convenience init(name: String, optionals: [BasicOptionalClass]?) {
        self.init(warehouse: EmptyWarehouse())
        
        self.name = name
        self.optionals = optionals
    }
    
    required init(warehouse: Warehouseable) {
        self.name = warehouse.get("name") ?? "default"
        self.optionals = warehouse.get("optionals")
    }
}
