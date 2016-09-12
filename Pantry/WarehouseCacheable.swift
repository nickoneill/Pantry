//
//  WarehouseCacheable.swift
//  Pantry
//
//  Created by Robert Manson on 12/7/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import Foundation

protocol WarehouseCacheable {
    func write(_ object: AnyObject, expires: StorageExpiry)
    func removeCache()
    static func removeAllCache()
    func loadCache() -> AnyObject?
    func cacheExists() -> Bool
}
