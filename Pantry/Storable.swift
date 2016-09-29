//
//  Storable.swift
//  Storable
//
//  Created by Nick O'Neill on 10/29/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import Foundation

/**
 ## Storable protocol

 The struct should conform to this protocol.

 ### sample
 ```swift
 struct Basic: Storable {
    let name: String
    let age: Float
    let number: Int

    init(warehouse: JSONWarehouse) {
        self.name = warehouse.get("name") ?? "default"
        self.age = warehouse.get("age") ?? 20.5
        self.number = warehouse.get("number") ?? 10
    }
 }
 ```
 */
public protocol Storable {
    /** 
     Struct initialization  

     - parameter warehouse: the `Warehouseable` object from which you can extract your struct's properties
     */
    init?(warehouse: Warehouseable)

    /**
     Dictionary representation  

     Returns the dictioanry representation of the current struct
     - returns: [String: Any]
     */
    func toDictionary() -> [String: Any]
}

public extension Storable {
    /**
     Dictionary representation
     Returns the dictioanry representation of the current struct
     
     - returns: [String: Any]
     */
    func toDictionary() -> [String: Any] {
        return Mirror(reflecting: self).toDictionary()
    }
}

/**
 Storage expiry
 */
public enum StorageExpiry {
    /// the storage never expires
    case never
    /// the storage expires after a given timeout in seconds (`NSTimeInterval`)
    case seconds(TimeInterval)
    /// the storage expires at a given date (`NSDate`)
    case date(Foundation.Date)

    /**
     Expiry date

     Returns the date of the storage expiration
     - returns NSDate
     */
    func toDate() -> Foundation.Date {
        switch self {
        case .never:
            return Foundation.Date.distantFuture
        case .seconds(let timeInterval):
            return Foundation.Date(timeIntervalSinceNow: timeInterval)
        case .date(let date):
            return date
        }
    }
}

// MARK: default types that are supported

/**
Default storable types

Default types are `Bool`, `String`, `Int`, `Float`, `Double`, `Date`
*/
public protocol StorableDefaultType {
}

extension Bool: StorableDefaultType { }
extension String: StorableDefaultType { }
extension Int: StorableDefaultType { }
extension Float: StorableDefaultType { }
extension Double: StorableDefaultType { }

// MARK: Provide Storable implementation compatible with JSONSerialization
extension Date: Storable {
    public init?(warehouse: Warehouseable) {
        if let value: TimeInterval = warehouse.get("timeSince1970") {
            self.init(timeIntervalSince1970: value)
            return
        }
        return nil
    }

    public func toDictionary() -> [String: Any] {
        return ["timeSince1970": self.timeIntervalSince1970 as Any]
    }
}

// MARK: Enums with Raw Values

/**
*  For enums with a raw value such as ```enum: Int```, adding this protocol makes the enum storable.
*
*  You should not need to implement any of the methods or properties in this protocol.
*  Enums without a raw value e.g. with associated types are not supported.
*/
public protocol StorableRawEnum: Storable {
    associatedtype StorableRawType: StorableDefaultType

    /// Provided automatically for enum's that have a raw value
    var rawValue: StorableRawType { get }
    init?(rawValue: StorableRawType)
}

public extension StorableRawEnum {
    init?(warehouse: Warehouseable) {
        if let value: StorableRawType = warehouse.get("rawValue") {
            self.init(rawValue: value)
            return
        }
        return nil
    }

    func toDictionary() -> [String: Any] {
        return ["rawValue": rawValue as Any]
    }
}
