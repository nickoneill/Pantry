//
//  Pantry.swift
//  Pantry
//
//  Created by Nick O'Neill on 10/29/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import Foundation

// MARK: the main public class

public class Pantry {
    // pack generics
    public static func pack<T: Storable>(object: T, key: String, expires: StorageExpiry = .Never) {
        let warehouse = JSONWarehouse(key: key)
        
        warehouse.write(object.toDictionary(), expires: expires)
    }
    
    public static func pack<T: Storable>(objects: [T], key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        var result = [AnyObject]()
        for object in objects {
            result.append(object.toDictionary())
        }

        warehouse.write(result, expires: .Never)
    }
    
    public static func pack<T: StorableDefaultType>(object: T, key: String, expires: StorageExpiry = .Never) {
        let warehouse = JSONWarehouse(key: key)
        
        warehouse.write(object as! AnyObject, expires: expires)
    }

    public static func pack<T: StorableDefaultType>(objects: [T], key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        var result = [AnyObject]()
        for object in objects {
            result.append(object as! AnyObject)
        }
        
        warehouse.write(result, expires: .Never)
    }
    
    public static func pack<T: StorableDefaultType>(objects: [T?], key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        var result = [AnyObject]()
        for object in objects {
            result.append(object as! AnyObject)
        }
        
        warehouse.write(result, expires: .Never)
    }


    // MARK: unpack generics
    
    // storable type (struct)
    public static func unpack<T: Storable>(key: String) -> T? {
        let json = JSONWarehouse(key: key)
        
        if json.cacheExists() {
            return T(warehouse: json)
        }
        
        return nil
    }
    
    // arrays of storable type
    public static func unpack<T: Storable>(key: String) -> [T]? {
        let json = JSONWarehouse(key: key)
        
        if json.cacheExists() {
            if let cache = json.loadCache() as? Array<AnyObject> {
                var unpackedItems = [T]()
                
                for item in cache {
                    if let item = item as? Dictionary<String, AnyObject> {
                        if let unpackedItem: T = unpack(item) {
                            unpackedItems.append(unpackedItem)
                        }
                    }
                }
                return unpackedItems
            }
        }
        
        return nil
    }
    
    // arrays of default types
    public static func unpack<T: StorableDefaultType>(key: String) -> [T]? {
        let json = JSONWarehouse(key: key)
        
        if json.cacheExists() {
            if let cache = json.loadCache() as? Array<AnyObject> {
                var unpackedItems = [T]()
                
                for item in cache {
                    if let item = item as? T {
                        unpackedItems.append(item)
                    }
                }
                return unpackedItems
            }
        }
        
        return nil
    }
    
    // regular default types
    public static func unpack<T: StorableDefaultType>(key: String) -> T? {
        let json = JSONWarehouse(key: key)
        
        if json.cacheExists() {
            if let cache = json.loadCache() as? T {
                return cache
            }
        }
        
        return nil
    }
    
    //
    static func unpack<T: Storable>(dictionary: Dictionary<String, AnyObject>) -> T? {
        let json = JSONWarehouse(context: dictionary)
        
        return T(warehouse: json)
    }
    
    public static func expire(key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        warehouse.removeCache()
    }
}

// MARK: default types that are supported

public protocol StorableDefaultType {
}

extension Bool: StorableDefaultType { }
extension String: StorableDefaultType { }
extension Int: StorableDefaultType { }
extension Float: StorableDefaultType { }

// MARK: warehouse is a thing that serializes and deserializes data

public class JSONWarehouse {
    var key: String
    var context: AnyObject?
    
    init(key: String) {
        self.key = key
    }
    
    init(context: AnyObject) {
        self.key = ""
        self.context = context
    }

    func get<T: StorableDefaultType>(valueKey: String) -> T? {
        if let dictionary = loadCache() {
            if let result = dictionary[valueKey] {
                if let result = result as? T {
                    return result
                }
            }
        }
        
        return nil
    }
    
    func get<T: StorableDefaultType>(valueKey: String) -> [T]? {
        if let dictionary = loadCache() as? Dictionary<String, AnyObject> {
            if let result = dictionary[valueKey] as? Array<AnyObject> {
                var unpackedItems = [T]()
                
                for item in result {
                    if let item = item as? T {
                        unpackedItems.append(item)
                    }
                }
                return unpackedItems
            }
        }
        
        return nil
    }
    
    func get<T: Storable>(valueKey: String) -> T? {
        if let dictionary = loadCache() as? Dictionary<String, AnyObject> {
            if let result = dictionary[valueKey] {
                let warehouse = JSONWarehouse(context: result)
                return T(warehouse: warehouse)
            }
        }
        
        return nil
    }
    
    func get<T: Storable>(valueKey: String) -> [T]? {
        if let dictionary = loadCache() as? Dictionary<String, AnyObject> {
            if let result = dictionary[valueKey] as? Array<AnyObject> {
                var unpackedItems = [T]()
                
                for item in result {
                    if let item = item as? Dictionary<String, AnyObject> {
                        let warehouse = JSONWarehouse(context: item)
                        let item = T(warehouse: warehouse)
                        unpackedItems.append(item)
                    }
                }
                return unpackedItems
            }
        }
        
        return nil
    }
    
    func write(object: AnyObject, expires: StorageExpiry) {
        let cacheLocation = cacheFileURL()
        var storableDictionary = [String: AnyObject]()
        
        storableDictionary["expires"] = expires.toDate().timeIntervalSince1970
        storableDictionary["storage"] = object
        
        let _ = (storableDictionary as NSDictionary).writeToURL(cacheLocation, atomically: true)
    }
    
    func removeCache() {
        try! NSFileManager.defaultManager().removeItemAtURL(cacheFileURL())
    }
    
    func loadCache() -> AnyObject? {
        if context == nil {
            let cacheLocation = cacheFileURL()
            
            if let metaDictionary = NSDictionary(contentsOfURL: cacheLocation) {
                if let cache = metaDictionary["storage"] {
                    return cache
                }
            }
        } else {
            return context
        }
        
        return nil
    }
    
    func cacheExists() -> Bool {
        if NSFileManager.defaultManager().fileExistsAtPath(cacheFileURL().path!) {
            let cacheLocation = cacheFileURL()
            
            if let metaDictionary = NSDictionary(contentsOfURL: cacheLocation) {
                if let expires = metaDictionary["expires"] as? NSTimeInterval {
                    let nowInterval = NSDate().timeIntervalSince1970
                    
                    if expires > nowInterval {
                        return true
                    } else {
                        removeCache()
                        return false
                    }
                } else {
                    // no expires time means old cache, never expires
                    return true
                }
            }
        }
        
        return false
    }
    
    func cacheFileURL() -> NSURL {
        let url = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
        
        let writeDirectory = url.URLByAppendingPathComponent("com.thatthinginswift.pantry")
        let cacheLocation = writeDirectory.URLByAppendingPathComponent(self.key)
        //        print("cache",writeDirectory)
        
        try! NSFileManager.defaultManager().createDirectoryAtURL(writeDirectory, withIntermediateDirectories: true, attributes: nil)
        
        return cacheLocation
    }
}
