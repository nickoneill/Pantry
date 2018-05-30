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
open class JSONWarehouse: Warehouseable, WarehouseCacheable {
    
    var storageType: StorageType
    var key: String
    var context: Any?

    public init(storageType: StorageType, key: String) {
        self.storageType = storageType
        self.key = key
    }

    public init(storageType: StorageType, context: Any) {
        self.storageType = storageType
        self.key = ""
        self.context = context
    }

    /**
     Retrieve a `StorableDefaultType` for a given key
     - parameter valueKey: The item's key
     - returns: T?

     - SeeAlso: `StorableDefaultType`
     */
    open func get<T: StorableDefaultType>(_ valueKey: String) -> T? {

        guard let dictionary = loadCache() as? [String: Any],
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
    open func get<T: StorableDefaultType>(_ valueKey: String) -> [T]? {

        guard let dictionary = loadCache() as? [String: Any],
            let result = dictionary[valueKey] as? [Any] else {
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
    open func get<T: Storable>(_ valueKey: String) -> T? {

        guard let dictionary = loadCache() as? [String: Any],
            let result = dictionary[valueKey] else {
                return nil
        }

        let warehouse = JSONWarehouse(storageType: storageType, context: result)
        return T(warehouse: warehouse)
    }

    /**
     Retrieve a collection of generic objects conforming to `Storable` for a given key
     - parameter valueKey: The item's key
     - returns: [T]?

     - SeeAlso: `Storable`
     */
    open func get<T: Storable>(_ valueKey: String) -> [T]? {

        guard let dictionary = loadCache() as? [String: Any],
            let result = dictionary[valueKey] as? [Any] else {
                return nil
        }

        var unpackedItems = [T]()
        for case let item as [String: Any] in result {
            let warehouse = JSONWarehouse(storageType: storageType, context: item)
            if let item = T(warehouse: warehouse) {
                unpackedItems.append(item)
            }
        }

        return unpackedItems
    }

    func write(_ object: Any, expires: StorageExpiry) {
        let cacheLocation = storageFileUrl()
        var storableDictionary: [String: Any] = [:]
        
        storableDictionary["expires"] = expires.toDate().timeIntervalSince1970
        storableDictionary["storage"] = object

        guard JSONSerialization.isValidJSONObject(storableDictionary) else {
            debugPrint("Not a valid JSON object: \(object)")
            return
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: storableDictionary, options: .prettyPrinted)

            try data.write(to: cacheLocation, options: .atomic)
        } catch {
            debugPrint("\(error)")
        }
    }
    
    func removeCache() {
        do {
            try FileManager.default.removeItem(at: storageFileUrl())
        } catch {
            print("error removing cache", error)
        }
    }
    
    static func removeAllCache(for storageType: StorageType) {
        do {
            try FileManager.default.removeItem(at: JSONWarehouse.storageDirectory(for: storageType))
        } catch {
            print("error removing all cache",error)
        }
    }
    
    func loadCache() -> Any? {
        guard context == nil else {
            return context
        }

        let cacheLocation = storageFileUrl()

        // legacy format
        if let metaDictionary = NSDictionary(contentsOf: cacheLocation),
            let cache = metaDictionary["storage"] {
            return cache
        }
        
        if let data = try? Data(contentsOf: cacheLocation),
            let metaDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let cache = metaDictionary?["storage"] {
            return cache
        }

        if let data = try? Data(contentsOf: cacheLocation),
            let metaDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let cache = metaDictionary?["storage"] {
            return cache
        }

        return nil
    }
    
    func cacheExists() -> Bool {
        let cacheFileURL = self.cacheFileURL()
        
        guard FileManager.default.fileExists(atPath: storageFileUrl.path) else { return false }
        
        var optionalDictionary: [String: Any?]? = nil
        
        // legacy format
        if let dictionary = NSDictionary(contentsOf: storageFileUrl) as? [String: Any?] {
            optionalDictionary = dictionary
        }
        
        // new format
        if let data = try? Data(contentsOf: storageFileUrl),
        let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            optionalDictionary = dictionary
        }
        
        guard let metaDictionary = optionalDictionary else {
            return false
        }

        guard let expires = metaDictionary["expires"] as? TimeInterval else {
            // no expire time means old cache, never expires
            return true
        }

        let nowInterval = Date().timeIntervalSince1970
        
        if expires > nowInterval {
            return true
        } else {
            removeCache()
            return false
        }
    }
    
    static func storageDirectory(for storageType: StorageType) -> URL {
        switch storageType {
        case .volatile:     return cacheDirectory
        case .permanent:    return applicationSupportDirectory
        }
    }
    
    private func storageFileUrl() -> URL {
        switch storageType {
        case .volatile:     return cacheFileURL()
        case .permanent:    return applicationSupportFileURL()
        }
    }
    
    static var applicationSupportDirectory: URL {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        
        let writeDirectory = url.appendingPathComponent("com.thatthinginswift.pantry")
        return writeDirectory
    }
    
    func applicationSupportFileURL() -> URL {
        let applicationSupportDirectory = JSONWarehouse.applicationSupportDirectory
        
        let applicationSupportLocation = applicationSupportDirectory.appendingPathComponent(self.key)
        
        do {
            try FileManager.default.createDirectory(at: applicationSupportDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("couldn't create directories to \(applicationSupportLocation)")
        }
        
        return applicationSupportLocation
    }
    
    static var cacheDirectory: URL {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        let writeDirectory = url.appendingPathComponent("com.thatthinginswift.pantry")
        return writeDirectory
    }
    
    func cacheFileURL() -> URL {
        let cacheDirectory = JSONWarehouse.cacheDirectory

        let cacheLocation = cacheDirectory.appendingPathComponent(self.key)

        do {
            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("couldn't create directories to \(cacheLocation)")
        }

        return cacheLocation
    }
}
