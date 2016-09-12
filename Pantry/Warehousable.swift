//
//  Warehousable.swift
//  Pantry
//
//  Created by Robert Manson on 12/7/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import Foundation

public protocol Warehouseable: class {
    /**
     Retrieve a `StorableDefaultType` for a given key
     - parameter valueKey: The item's key
     - returns: T?

     - SeeAlso: `StorableDefaultType`
     */
    func get<T: StorableDefaultType>(_ valueKey: String) -> T?

    /**
     Retrieve a collection of `StorableDefaultType`s for a given key
     - parameter valueKey: The item's key
     - returns: [T]?

     - SeeAlso: `StorableDefaultType`
     */
    func get<T: StorableDefaultType>(_ valueKey: String) -> [T]?


    /**
     Retrieve a generic object conforming to `Storable` for a given key
     - parameter valueKey: The item's key
     - returns: T?

     - SeeAlso: `Storable`
     */
    func get<T: Storable>(_ valueKey: String) -> T?

    /**
     Retrieve a collection of generic objects conforming to `Storable` for a given key
     - parameter valueKey: The item's key
     - returns: [T]?

     - SeeAlso: `Storable`
     */
    func get<T: Storable>(_ valueKey: String) -> [T]?


}
