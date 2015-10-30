//
//  Storage.swift
//  Storage
//
//  Created by Nick O'Neill on 10/29/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import Foundation

// MARK: the protocol your stuff should adhere to

public protocol Storable {
    init(warehouse: JSONWarehouse)
}

// MARK: the main public class

public class Storage {
    // pack generics
    static func pack<T: Storable>(object: T, key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        if let json = warehouse.toJSON(object) {
            warehouse.write(json)
        }
    }
    
    static func pack<T: Storable>(objects: [T], key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        if let json = warehouse.toJSON(objects) {
            warehouse.write(json)
        }
    }
    
    static func pack<T: StorableDefaultType>(objects: [T], key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        if let json = warehouse.toJSON(objects) {
            warehouse.write(json)
        }
    }

    static func pack<T: StorableDefaultType>(object: T, key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        if let json = warehouse.toJSON(object) {
            warehouse.write(json)
        }
    }

    // MARK: unpack generics
    
    // storable type (struct)
    static func unpack<T: Storable>(key: String) -> T? {
        let json = JSONWarehouse(key: key)
        
        if json.cacheExists() {
            return T(warehouse: json)
        }
        
        return nil
    }
    
    // arrays of storable type
    static func unpack<T: Storable>(key: String) -> [T]? {
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
    static func unpack<T: StorableDefaultType>(key: String) -> [T]? {
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
    static func unpack<T: StorableDefaultType>(key: String) -> T? {
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
    
    static func expire(key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        warehouse.removeCache(key)
    }
}

// MARK: default types that are supported

public protocol StorableDefaultType { }

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
    
//  TODO: I'm not sure why I can't do <T: StorableDefaultType> here
    func toJSON<T>(object: T) -> AnyObject? {
        return object as? AnyObject
    }
    
    func toJSON<T: Storable>(object: T) -> AnyObject? {
        let mirror = Mirror(reflecting: object)
        
        if mirror.children.count > 0 {
            var result = Dictionary<String, AnyObject>()
            
            for (key, value) in mirror.children {
                if let value = value as? StorableDefaultType {
                    result[key!] = self.toJSON(value)
                }
            }
            
            return result
        } else {
            return object as? AnyObject
        }
    }
    
    func toJSON<T: Storable>(objects: [T]) -> AnyObject? {
        var subobject = [AnyObject]()
        for item in objects {
            if let itemInJSON = self.toJSON(item) {
                subobject.append(itemInJSON)
            }
        }
        
        return subobject as AnyObject
    }
    
    func write(object: AnyObject) {
        let cacheLocation = cacheFileURL()
        var storableDictionary = Dictionary<String, AnyObject>()
        
        storableDictionary["storage"] = object
        
        let success = (storableDictionary as NSDictionary).writeToURL(cacheLocation, atomically: true)
        //        print("wrote to",cacheLocation)
        print("writing",success)
    }
    
    func removeCache(key: String) {
        if cacheExists() {
            try! NSFileManager.defaultManager().removeItemAtURL(cacheFileURL())
        }
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
            return true
        }
        
        return false
    }
    
    func cacheFileURL() -> NSURL {
        let url = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
        
        let writeDirectory = url.URLByAppendingPathComponent("com.thatthinginswift.storage")
        let cacheLocation = writeDirectory.URLByAppendingPathComponent(self.key)
        //        print("cache",writeDirectory)
        
        try! NSFileManager.defaultManager().createDirectoryAtURL(writeDirectory, withIntermediateDirectories: true, attributes: nil)
        
        return cacheLocation
    }
}