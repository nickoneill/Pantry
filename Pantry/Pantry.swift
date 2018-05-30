//
//  Pantry.swift
//  Pantry
//
//  Created by Nick O'Neill on 10/29/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import Foundation

/** 
 # Pantry 

 Pantry is a lightweight way to persist structs containing user data, 
 cached content or other relevant objects for later retrieval.
 
 ### Storage sample

 ```swift
 let someCustomStruct = SomeCustomStruct(...)
 Pantry.pack(someCustomStruct, "user_data")
 ```

 ### Retrieval sample

 ```swift
 if let unpackedCustomStruct: SomeCustomStruct = Pantry.unpack("user_data") {
    eprint("got my data out", unpackedCustomStruct)
 } else {
    print("there was no struct data to get")
 }
 ```
 */
open class Pantry {
    // Set to a string identifier to enable in memory mode with no persistent caching. Useful for unit testing.
    open static var enableInMemoryModeWithIdentifier: String?

    // MARK: pack generics

    /**
     Packs a generic struct that conforms to the `Storable` protocol
     - parameter object: Generic object that will be stored
     - parameter key: The object's key
     - parameter expires: The storage expiration. Defaults to `Never`
     - parameter storageType: The storage type. Defaults to `.permanent`
     */
    open static func pack<T: Storable>(_ object: T, key: String, expires: StorageExpiry = .never, storageType: StorageType = .permanent) {
        let warehouse = getWarehouse(key, storageType: storageType)
        
        warehouse.write(object.toDictionary() as Any, expires: expires)
    }

    /**
     Packs a generic collection of structs that conform to the `Storable` protocol
     - parameter objects: Generic collection of objects that will be stored
     - parameter key: The objects' key
     - parameter storageType: The storage type. Defaults to `.permanent`
     */
    open static func pack<T: Storable>(_ objects: [T], key: String, expires: StorageExpiry = .never, storageType: StorageType = .permanent) {
        let warehouse = getWarehouse(key, storageType: storageType)
        
        var result = [Any]()
        for object in objects {
            result.append(object.toDictionary() as Any)
        }

        warehouse.write(result as Any, expires: expires)
    }

    /**
     Packs a default storage type.
     - parameter object: Default object that will be stored
     - parameter key: The object's key
     - parameter expires: The storage expiration. Defaults to `Never`
     - parameter storageType: The storage type. Defaults to `.permanent`
     
     - SeeAlso: `StorableDefaultType`
     */
    open static func pack<T: StorableDefaultType>(_ object: T, key: String, expires: StorageExpiry = .never, storageType: StorageType = .permanent) {
        let warehouse = getWarehouse(key, storageType: storageType)
        
        warehouse.write(object as Any, expires: expires)
    }

    /**
     Packs a collection of default storage types.
     - parameter objects: Collection of objects that will be stored
     - parameter key: The object's key
     - parameter expires: The storage expiration. Defaults to `Never`
     - parameter storageType: The storage type. Defaults to `.permanent`

     - SeeAlso: `StorableDefaultType`
     */
    open static func pack<T: StorableDefaultType>(_ objects: [T], key: String, expires: StorageExpiry = .never, storageType: StorageType = .permanent) {
        let warehouse = getWarehouse(key, storageType: storageType)
        
        var result = [Any]()
        for object in objects {
            result.append(object as Any)
        }
        
        warehouse.write(result as Any, expires: expires)
    }

    /**
     Packs a collection of optional default storage types.
     - parameter objects: Collection of optional objects that will be stored
     - parameter key: The object's key
     - parameter expires: The storage expiration. Defaults to `Never`
     - parameter storageType: The storage type. Defaults to `.permanent`

     - SeeAlso: `StorableDefaultType`
     */
    open static func pack<T: StorableDefaultType>(_ objects: [T?], key: String, expires: StorageExpiry = .never, storageType: StorageType = .permanent) {
        let warehouse = getWarehouse(key, storageType: storageType)
        
        var result = [Any]()
        for object in objects {
            result.append(object as Any)
        }
        
        warehouse.write(result as Any, expires: expires)
    }


    // MARK: unpack generics
    
    /**
    Unpacks a generic struct that conforms to the `Storable` protocol
    - parameter key: The object's key
    - parameter storageType: The storage type. Defaults to `.permanent`
    - returns: T?
    */
    open static func unpack<T: Storable>(_ key: String, storageType: StorageType = .permanent) -> T? {
        let warehouse = getWarehouse(key, storageType: storageType)
        
        if warehouse.cacheExists() {
            return T(warehouse: warehouse)
        }
        
        return nil
    }
    
    /**
     Unpacks a generic collection of structs that conform to the `Storable` protocol
     - parameter key: The objects' key
     - parameter storageType: The storage type. Defaults to `.permanent`
     - returns: [T]?
     */
    open static func unpack<T: Storable>(_ key: String, storageType: StorageType = .permanent) -> [T]? {
        let warehouse = getWarehouse(key, storageType: storageType)

        guard warehouse.cacheExists(),
            let cache = warehouse.loadCache() as? Array<Any> else {
            return nil
        }
        
        var unpackedItems = [T]()
        for case let item as [String: Any] in cache  {
            if let unpackedItem: T = unpack(item) {
                unpackedItems.append(unpackedItem)
            }
        }
        return unpackedItems
    }
    
    /**
     Unpacks a collection of default storage types.
     - parameter key: The object's key
     - parameter storageType: The storage type. Defaults to `.permanent`
     - returns: [T]?

     - SeeAlso: `StorableDefaultType`
     */
    open static func unpack<T: StorableDefaultType>(_ key: String, storageType: StorageType = .permanent) -> [T]? {
        let warehouse = getWarehouse(key, storageType: storageType)
        
        guard warehouse.cacheExists(),
            let cache = warehouse.loadCache() as? Array<Any> else {
                return nil
        }
        
        var unpackedItems = [T]()
        for case let item as T in cache {
            unpackedItems.append(item)
        }
        return unpackedItems
    }
    
    /**
     Unacks a default storage type.
     - parameter key: The object's key
     - parameter storageType: The storage type. Defaults to `.permanent`

     - SeeAlso: `StorableDefaultType`
     */
    open static func unpack<T: StorableDefaultType>(_ key: String, storageType: StorageType = .permanent) -> T? {
        let warehouse = getWarehouse(key, storageType: storageType)

        guard warehouse.cacheExists(),
            let cache = warehouse.loadCache() as? T else {
                return nil
        }

        return cache
    }

    /**
     Expire a given object
     - parameter key: The object's key
     - parameter storageType: The storage type. Defaults to `.permanent`
     */
    open static func expire(_ key: String, storageType: StorageType = .permanent) {
        let warehouse = getWarehouse(key, storageType: storageType)

        warehouse.removeCache()
    }
    
    /**
     Deletes all the cache
     - parameter storageType: The storage type. Defaults to `.permanent`
 
     - Note: This will clear in-memory as well as JSON cache
     */
    open static func removeAllCache(for storageType: StorageType = .permanent) {
        ///Blindly remove all the data!
        MemoryWarehouse.removeAllCache(for: storageType)
        JSONWarehouse.removeAllCache(for: storageType)
    }

    /**
     Checks if an item exists for a given key
     - parameter key: The object's key
     - parameter storageType: The storage type. Defaults to `.permanent`
     
     - Note: This will clear in-memory as well as JSON cache
     */
    open static func itemExistsForKey(_ key: String, storageType: StorageType = .permanent) -> Bool {
        let warehouse = getWarehouse(key, storageType: storageType)
        return warehouse.cacheExists()
    }

    static func unpack<T: Storable>(_ dictionary: [String: Any], storageType: StorageType = .permanent) -> T? {
        let warehouse = getWarehouse(dictionary as Any, storageType: storageType)
        
        return T(warehouse: warehouse)
    }

    static func getWarehouse(_ forKey: String, storageType: StorageType) -> Warehouseable & WarehouseCacheable {
        if let inMemoryIdentifier = Pantry.enableInMemoryModeWithIdentifier {
            return MemoryWarehouse(key: forKey, inMemoryIdentifier: inMemoryIdentifier)
        } else {
            return JSONWarehouse(storageType: storageType, key: forKey)
        }
    }

    static func getWarehouse(_ forContext: Any, storageType: StorageType) -> Warehouseable {
        if let inMemoryIdentifier = Pantry.enableInMemoryModeWithIdentifier {
            return MemoryWarehouse(context: forContext, inMemoryIdentifier: inMemoryIdentifier)
        } else {
            return JSONWarehouse(storageType: storageType, context: forContext)
        }
    }
}
