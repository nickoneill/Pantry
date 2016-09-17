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
public class Pantry {
    // Set to a string identifier to enable in memory mode with no persistent caching. Useful for unit testing.
    public static var enableInMemoryModeWithIdentifier: String?

    // MARK: pack generics

    /**
     Packs a generic struct that conforms to the `Storable` protocol
     - parameter object: Generic object that will be stored
     - parameter key: The object's key
     - parameter expires: The storage expiration. Defaults to `Never`
     */
    public static func pack<T: Storable>(object: T, key: String, expires: StorageExpiry = .Never) {
        let warehouse = getWarehouse(key)
        
        warehouse.write(object.toDictionary(), expires: expires)
    }

    /**
     Packs a generic collection of structs that conform to the `Storable` protocol
     - parameter objects: Generic collection of objects that will be stored
     - parameter key: The objects' key
     */
    public static func pack<T: Storable>(objects: [T], key: String, expires: StorageExpiry = .Never) {
        let warehouse = getWarehouse(key)
        
        var result = [AnyObject]()
        for object in objects {
            result.append(object.toDictionary())
        }

        warehouse.write(result, expires: expires)
    }

    /**
     Packs a default storage type.
     - parameter object: Default object that will be stored
     - parameter key: The object's key
     - parameter expires: The storage expiration. Defaults to `Never`
     
     - SeeAlso: `StorableDefaultType`
     */
    public static func pack<T: StorableDefaultType>(object: T, key: String, expires: StorageExpiry = .Never) {
        let warehouse = getWarehouse(key)
        
        warehouse.write(object as! AnyObject, expires: expires)
    }

    /**
     Packs a collection of default storage types.
     - parameter objects: Collection of objects that will be stored
     - parameter key: The object's key

     - SeeAlso: `StorableDefaultType`
     */
    public static func pack<T: StorableDefaultType>(objects: [T], key: String, expires: StorageExpiry = .Never) {
        let warehouse = getWarehouse(key)
        
        var result = [AnyObject]()
        for object in objects {
            result.append(object as! AnyObject)
        }
        
        warehouse.write(result, expires: expires)
    }

    /**
     Packs a collection of optional default storage types.
     - parameter objects: Collection of optional objects that will be stored
     - parameter key: The object's key

     - SeeAlso: `StorableDefaultType`
     */
    public static func pack<T: StorableDefaultType>(objects: [T?], key: String, expires: StorageExpiry = .Never) {
        let warehouse = getWarehouse(key)
        
        var result = [AnyObject]()
        for object in objects {
            result.append(object as! AnyObject)
        }
        
        warehouse.write(result, expires: expires)
    }

    /**
     Packs a generic object that conforms to the `NSCoding` protocol
     - parameter object: Default object that will be stored
     - parameter key: The object's key
     - parameter expires: The storage expiration. Defaults to `Never`
     
     - SeeAlso: `NSCoding`
     */
    public static func pack<T: NSCoding>(object: T, key: String, expires: StorageExpiry = .Never) {
        let warehouse = getWarehouse(key)
        
        warehouse.write(object.toDictionary(), expires: expires)
    }
    
    /**
     Packs a collection of generic objects that conform to the `NSCoding` protocol.
     - parameter objects: Collection of objects that will be stored
     - parameter key: The object's key
     
     - SeeAlso: `NSCoding`
     */
    public static func pack<T: NSCoding>(objects: [T], key: String) {
        let warehouse = getWarehouse(key)
        
        var result = [AnyObject]()
        for object in objects {
            result.append(object.toDictionary())
        }
        
        warehouse.write(result, expires: .Never)
    }

    // MARK: unpack generics
    
    /**
    Unpacks a generic struct that conforms to the `Storable` protocol
    - parameter key: The object's key
    - returns: T?
    */
    public static func unpack<T: Storable>(key: String) -> T? {
        let warehouse = getWarehouse(key)
        
        if warehouse.cacheExists() {
            return T(warehouse: warehouse)
        }
        
        return nil
    }
    
    /**
     Unpacks a generic collection of structs that conform to the `Storable` protocol
     - parameter key: The objects' key
     - returns: [T]?
     */
    public static func unpack<T: Storable>(key: String) -> [T]? {
        let warehouse = getWarehouse(key)

        guard warehouse.cacheExists(),
            let cache = warehouse.loadCache() as? Array<AnyObject> else {
            return nil
        }
        
        var unpackedItems = [T]()
        for case let item as Dictionary<String, AnyObject> in cache  {
            if let unpackedItem: T = unpack(item) {
                unpackedItems.append(unpackedItem)
            }
        }
        return unpackedItems
    }
    
    /**
     Unpacks a collection of default storage types.
     - parameter key: The object's key
     - returns: [T]?

     - SeeAlso: `StorableDefaultType`
     */
    public static func unpack<T: StorableDefaultType>(key: String) -> [T]? {
        let warehouse = getWarehouse(key)
        
        guard warehouse.cacheExists(),
            let cache = warehouse.loadCache() as? Array<AnyObject> else {
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

     - SeeAlso: `StorableDefaultType`
     */
    public static func unpack<T: StorableDefaultType>(key: String) -> T? {
        let warehouse = getWarehouse(key)

        guard warehouse.cacheExists(),
            let cache = warehouse.loadCache() as? T else {
                return nil
        }

        return cache
    }
    
    /**
     Unpacks an object that conforms to the `NSCoding` protocol
     - parameter key: The object's key
     - returns: T?
     */
    public static func unpack<T: NSCoding>(key: String) -> T? {
        let warehouse = getWarehouse(key)
        
        if warehouse.cacheExists() {
            let dataString: String? = warehouse.get("NSKeyedArchiverDataString")
            let data = dataString.flatMap { NSData(base64EncodedString: $0, options: []) }
            return data.flatMap { NSKeyedUnarchiver.unarchiveObjectWithData($0) } as? T
        }
        
        return nil
    }


    /**
     Expire a given object
     - parameter key: The object's key
     */
    public static func expire(key: String) {
        let warehouse = getWarehouse(key)

        warehouse.removeCache()
    }
    
    /// Deletes all the cache
    ///
    /// - Note: This will clear in-memory as well as JSON cache
    public static func removeAllCache() {
        ///Blindly remove all the data!
        MemoryWarehouse.removeAllCache()
        JSONWarehouse.removeAllCache()
    }

    public static func itemExistsForKey(key: String) -> Bool {
        let warehouse = getWarehouse(key)
        return warehouse.cacheExists()
    }

    static func unpack<T: Storable>(dictionary: Dictionary<String, AnyObject>) -> T? {
        let warehouse = getWarehouse(dictionary)
        
        return T(warehouse: warehouse)
    }

    static func getWarehouse(forKey: String) -> protocol<Warehouseable, WarehouseCacheable> {
        if let inMemoryIdentifier = Pantry.enableInMemoryModeWithIdentifier {
            return MemoryWarehouse(key: forKey, inMemoryIdentifier: inMemoryIdentifier)
        } else {
            return JSONWarehouse(key: forKey)
        }
    }

    static func getWarehouse(forContext: AnyObject) -> Warehouseable {
        if let inMemoryIdentifier = Pantry.enableInMemoryModeWithIdentifier {
            return MemoryWarehouse(context: forContext, inMemoryIdentifier: inMemoryIdentifier)
        } else {
            return JSONWarehouse(context: forContext)
        }
    }
}
