//
//  Mirror+Serialization.swift
//  Pantry
//
//  Created by Ian Keen on 12/12/2015.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import Foundation

extension Mirror {
    /**
     Dictionary representation
     Returns the dictioanry representation of the current `Mirror`
     
     _Adapted from [@IanKeen](https://gist.github.com/IanKeen/3a6c3b9a42aaf9fea982)_
     - returns: [String: Any]
     */
    func toDictionary() -> [String: Any] {
        let output = self.children.reduce([:]) { (result: [String: Any], child) in
            guard let key = child.label else { return result }
            var actualValue = child.value
            var childMirror = Mirror(reflecting: child.value)
            if let style = childMirror.displayStyle, style == .optional && childMirror.children.count > 0 {
                // unwrap Optional type first
                actualValue = childMirror.children.first!.value
                childMirror = Mirror(reflecting: childMirror.children.first!.value)
            }
            
            if let style = childMirror.displayStyle, style == .collection {
                // collections need to be unwrapped, children tested and
                // toDictionary called on each
                let converted: [Any] = childMirror.children
                    .map { collectionChild in
                        if let convertable = collectionChild.value as? Storable {
                            return convertable.toDictionary() as Any
                        } else {
                            return collectionChild.value as Any
                        }
                }
                return combine(result, addition: [key: converted as Any])
                
            } else {
                // non-collection types, toDictionary or just cast default types
                if let value = actualValue as? Storable {
                    return combine(result, addition: [key: value.toDictionary() as Any])
                } else {
                    if let style = childMirror.displayStyle, style == .optional,
                        childMirror.children.first == nil {
                        actualValue = NSNull()
                    }
                    return combine(result, addition: [key: actualValue as Any])
                }
            }
        }
        
        if let superClassMirror = self.superclassMirror {
            return combine(output, addition: superClassMirror.toDictionary())
        }
        return output
    }
    
    // convenience for combining dictionaries
    fileprivate func combine(_ from: [String: Any], addition: [String: Any]) -> [String: Any] {
        var result = [String: Any]()
        [from, addition].forEach { dict in
            dict.forEach { result[$0.0] = $0.1 }
        }
        return result
    }
}
