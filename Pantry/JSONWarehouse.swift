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

    public func get<T: StorableDefaultType>(valueKey: String) -> T? {
        if let dictionary = loadCache() {
            if let result = dictionary[valueKey] {
                if let result = result as? T {
                    return result
                }
            }
        }
        
        return nil
    }
    
    public func get<T: StorableDefaultType>(valueKey: String) -> [T]? {
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
    
    public func get<T: Storable>(valueKey: String) -> T? {
        if let dictionary = loadCache() as? Dictionary<String, AnyObject> {
            if let result = dictionary[valueKey] {
                let warehouse = JSONWarehouse(context: result)
                return T(warehouse: warehouse)
            }
        }
        
        return nil
    }
    
    public func get<T: Storable>(valueKey: String) -> [T]? {
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
        
        try! NSFileManager.defaultManager().createDirectoryAtURL(writeDirectory, withIntermediateDirectories: true, attributes: nil)
        
        return cacheLocation
    }
}
