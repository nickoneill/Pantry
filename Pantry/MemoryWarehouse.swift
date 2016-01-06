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
                        let warehouse = MemoryWarehouse(context: item, inMemoryIdentifier: inMemoryIdentifier)
                        if let item = T(warehouse: warehouse) {
                            unpackedItems.append(item)
                        }
                    }
                }
                return unpackedItems
            }
        }

        return nil
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

    func loadCache() -> AnyObject? {
        if context == nil {
            if let memoryCache = MemoryWarehouse.globalCache[inMemoryIdentifier],
                let cacheItem = memoryCache[key],
                let item = cacheItem["storage"] {
                    return item
            }
        } else {
            return context
        }

        return nil
    }

    func cacheExists() -> Bool {
        return true
    }
}
