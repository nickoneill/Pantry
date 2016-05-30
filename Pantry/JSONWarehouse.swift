//
//  JSONWarehouse.swift
//  JSONWarehouse
//
//  Created by Nick O'Neill on 10/29/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import Foundation

/** 
JSONWarehouse serializes and deserializes data 

A `JSONWarehouse` is passed in the init function of a struct that conforms to `Storable`
*/
public class JSONWarehouse: Warehouseable, WarehouseCacheable {
    var key: String
    var context: AnyObject?
    
    public init(key: String) {
        self.key = key
    }
    
    public init(context: AnyObject) {
        self.key = ""
        self.context = context
    }

    /**
     Retrieve a `StorableDefaultType` for a given key
     - parameter valueKey: The item's key
     - returns: T?

     - SeeAlso: `StorableDefaultType`
     */
    public func get<T: StorableDefaultType>(valueKey: String) -> T? {

        guard let dictionary = loadCache(),
            let result = dictionary[valueKey] as? T else {
                return nil
        }
        return result
    }

    /**
     Retrieve a collection of `StorableDefaultType`s for a given key
     - parameter valueKey: The item's key
     - returns: [T]?

     - SeeAlso: `StorableDefaultType`
     */
    public func get<T: StorableDefaultType>(valueKey: String) -> [T]? {

        guard let dictionary = loadCache() as? Dictionary<String, AnyObject>,
            let result = dictionary[valueKey] as? Array<AnyObject> else {
                return nil
        }

        var unpackedItems = [T]()
        for case let item as T in result {
            unpackedItems.append(item)
        }

        return unpackedItems
    }

    /**
     Retrieve a generic object conforming to `Storable` for a given key
     - parameter valueKey: The item's key
     - returns: T?

     - SeeAlso: `Storable`
     */
    public func get<T: Storable>(valueKey: String) -> T? {

        guard let dictionary = loadCache() as? Dictionary<String, AnyObject>,
            let result = dictionary[valueKey] else {
                return nil
        }

        let warehouse = JSONWarehouse(context: result)
        return T(warehouse: warehouse)
    }

    /**
     Retrieve a collection of generic objects conforming to `Storable` for a given key
     - parameter valueKey: The item's key
     - returns: [T]?

     - SeeAlso: `Storable`
     */
    public func get<T: Storable>(valueKey: String) -> [T]? {

        guard let dictionary = loadCache() as? Dictionary<String, AnyObject>,
            let result = dictionary[valueKey] as? Array<AnyObject> else {
                return nil
        }

        var unpackedItems = [T]()
        for case let item as Dictionary<String, AnyObject> in result {
            let warehouse = JSONWarehouse(context: item)
            if let item = T(warehouse: warehouse) {
                unpackedItems.append(item)
            }
        }

        return unpackedItems
    }
    
    func write(object: AnyObject, expires: StorageExpiry) {
        let cacheLocation = cacheFileURL()
        var storableDictionary = [String: AnyObject]()
        
        storableDictionary["expires"] = expires.toDate().timeIntervalSince1970
        storableDictionary["storage"] = object
        
        let _ = (storableDictionary as NSDictionary).writeToURL(cacheLocation, atomically: true)
    }
    
    func removeCache() {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(cacheFileURL())
        } catch {
            print("error removing cache",error)
        }
    }
    
    static func removeAllCache() {
        try! NSFileManager.defaultManager().removeItemAtURL(JSONWarehouse.cacheDirectory)
    }
    
    func loadCache() -> AnyObject? {

        guard context == nil else {
            return context
        }

        let cacheLocation = cacheFileURL()
        
        if let metaDictionary = NSDictionary(contentsOfURL: cacheLocation),
            let cache = metaDictionary["storage"] {
                return cache
        }

        return nil
    }
    
    func cacheExists() -> Bool {

        guard NSFileManager.defaultManager().fileExistsAtPath(cacheFileURL().path!),
            let metaDictionary = NSDictionary(contentsOfURL: cacheFileURL()) else {
                return false
        }

        guard let expires = metaDictionary["expires"] as? NSTimeInterval else {
            // no expire time means old cache, never expires
            return true
        }

        let nowInterval = NSDate().timeIntervalSince1970
        
        if expires > nowInterval {
            return true
        } else {
            removeCache()
            return false
        }
    }
    
    static var cacheDirectory: NSURL {
        let url = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
        
        let writeDirectory = url.URLByAppendingPathComponent("com.thatthinginswift.pantry")
        return writeDirectory
    }
    
    func cacheFileURL() -> NSURL {
        let cacheDirectory = JSONWarehouse.cacheDirectory
        let cacheLocation = cacheDirectory.URLByAppendingPathComponent(self.key)
        try! NSFileManager.defaultManager().createDirectoryAtURL(cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        
        return cacheLocation
    }
}
