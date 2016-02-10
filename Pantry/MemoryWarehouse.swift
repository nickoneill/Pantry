//
//  MemoryWarehouse.swift
//  Pantry
//
//  Created by Robert Manson on 12/7/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import Foundation

public class MemoryWarehouse {
    var key: String
    var context: AnyObject?
    let inMemoryIdentifier: String

    static var globalCache: [String: [String: AnyObject]] = [: ]

    required public init(key: String, inMemoryIdentifier: String) {
        self.key = key
        self.inMemoryIdentifier = inMemoryIdentifier
    }

    required public init(context: AnyObject, inMemoryIdentifier: String) {
        self.key = ""
        self.context = context
        self.inMemoryIdentifier = inMemoryIdentifier
    }
}

extension MemoryWarehouse: Warehouseable {

    public func get<T: StorableDefaultType>(valueKey: String) -> T? {

        guard let dictionary = loadCache(),
            let result = dictionary[valueKey] as? T else {
            return nil
        }
        return result
    }

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

    public func get<T: Storable>(valueKey: String) -> T? {

        guard let dictionary = loadCache() as? Dictionary<String, AnyObject>,
            let result = dictionary[valueKey] else {
                return nil
        }

        let warehouse = MemoryWarehouse(context: result, inMemoryIdentifier: inMemoryIdentifier)
        return T(warehouse: warehouse)
    }

    public func get<T: Storable>(valueKey: String) -> [T]? {

        guard let dictionary = loadCache() as? Dictionary<String, AnyObject>,
            let result = dictionary[valueKey] as? Array<AnyObject> else {
                return nil
        }

        var unpackedItems = [T]()

        for case let item as Dictionary<String, AnyObject> in result {
            let warehouse = MemoryWarehouse(context: item, inMemoryIdentifier: inMemoryIdentifier)
            if let item = T(warehouse: warehouse) {
                unpackedItems.append(item)
            }
        }
        
        return unpackedItems
    }
}

extension MemoryWarehouse: WarehouseCacheable {

    public func write(object: AnyObject, expires: StorageExpiry) {
        var storableDictionary = [String: AnyObject]()

        storableDictionary["expires"] = expires.toDate().timeIntervalSince1970
        storableDictionary["storage"] = object

        var memoryCache = MemoryWarehouse.globalCache[inMemoryIdentifier] ?? [String: AnyObject]()
        memoryCache[key] = storableDictionary
        MemoryWarehouse.globalCache[inMemoryIdentifier] = memoryCache
    }

    func removeCache() {
        MemoryWarehouse.globalCache.removeValueForKey(key)
    }
    
    static func removeAllCache() {
        MemoryWarehouse.globalCache = [:]
    }

    func loadCache() -> AnyObject? {

        guard context == nil else {
            return context
        }

        if let memoryCache = MemoryWarehouse.globalCache[inMemoryIdentifier],
            let cacheItem = memoryCache[key],
            let item = cacheItem["storage"] {
                return item
        }

        return nil
    }

    func cacheExists() -> Bool {
        return true
    }
}
