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
    func toDictionary() -> [String: AnyObject]
}

extension Storable {
    // Adapted from @IanKeen's https://gist.github.com/IanKeen/3a6c3b9a42aaf9fea982
    func toDictionary() -> [String: AnyObject] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.reduce([:]) { result, child in
            guard let key = child.label else { return result }
            
            let childMirror = Mirror(reflecting: child.value)
            if let style = childMirror.displayStyle where style == .Collection {
                // collections need to be unwrapped, children tested and
                // toDictionary called on each
                let converted: [AnyObject] = childMirror.children
                    .filter { $0.value is Storable || $0.value is AnyObject }
                    .map { collectionChild in
                        if let convertable = collectionChild.value as? Storable {
                            return convertable.toDictionary()
                        } else {
                            return collectionChild.value as! AnyObject
                        }
                    }
                return combine(result, addition: [key: converted])
                
            } else {
                // non-collection types, toDictionary or just cast default types
                // optionals need to be checked and unwrapped
                let childMirror = Mirror(reflecting: child.value)

                if let value = child.value as? Storable {
                    return combine(result, addition: [key: value.toDictionary()])
                } else if let value = child.value as? AnyObject {
                    return combine(result, addition: [key: value])
                } else if childMirror.displayStyle == .Optional {
                    // yes, this is how you detect and unwrap an Optional
                    // disguised as an Any
                    if childMirror.children.count != 0 {
                        let (_, some) = childMirror.children.first!
                        if let some = some as? Storable {
                            return combine(result, addition: [key: some.toDictionary()])
                        }
                    }
                } else {
                    // throw an error? not a type we support
                }
            }
            
            return result
        }
    }
    
    // convenience for combining dictionaries
    func combine(from: [String: AnyObject], addition: [String: AnyObject]) -> [String: AnyObject] {
        var result = [String: AnyObject]()
        [from, addition].forEach { dict in
            dict.forEach { result[$0.0] = $0.1 }
        }
        return result
    }
}

// MARK: the main public class

public class Storage {
    // pack generics
    public static func pack<T: Storable>(object: T, key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        warehouse.write(object.toDictionary())
    }
    
    public static func pack<T: Storable>(objects: [T], key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        var result = [AnyObject]()
        for object in objects {
            result.append(object.toDictionary())
        }

        warehouse.write(result)
    }
    
    public static func pack<T: StorableDefaultType>(object: T?, key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        warehouse.write(object as! AnyObject)
    }

    public static func pack<T: StorableDefaultType>(objects: [T], key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        var result = [AnyObject]()
        for object in objects {
            result.append(object as! AnyObject)
        }
        
        warehouse.write(result)
    }
    
    public static func pack<T: StorableDefaultType>(objects: [T?], key: String) {
        let warehouse = JSONWarehouse(key: key)
        
        var result = [AnyObject]()
        for object in objects {
            result.append(object as! AnyObject)
        }
        
        warehouse.write(result)
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
        
        warehouse.removeCache(key)
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
    
    func write(object: AnyObject) {
        let cacheLocation = cacheFileURL()
        var storableDictionary = [String: AnyObject]()
        
        storableDictionary["storage"] = object
        print("attempting to write",storableDictionary)
        
        let success = (storableDictionary as NSDictionary).writeToURL(cacheLocation, atomically: true)
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