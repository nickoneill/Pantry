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
     - returns: [String: AnyObject]
     */
    func toDictionary() -> [String: AnyObject] {
        let output = self.children.reduce([:]) { (result: [String: AnyObject], child) in
            guard let key = child.label else { return result }
            var actualValue = child.value
            var childMirror = Mirror(reflecting: child.value)
            if let style = childMirror.displayStyle where style == .Optional && childMirror.children.count > 0 {
                // unwrap Optional type first
                actualValue = childMirror.children.first!.value
                childMirror = Mirror(reflecting: childMirror.children.first!.value)
            }
            
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
                if let value = actualValue as? Storable {
                    return combine(result, addition: [key: value.toDictionary()])
                } else if let value = actualValue as? AnyObject {
                    return combine(result, addition: [key: value])
                } else {
                    // throw an error? not a type we support
                }
            }
            
            return result
        }
        
        if let superClassMirror = self.superclassMirror() {
            return combine(output, addition: superClassMirror.toDictionary())
        }
        return output
    }
    
    // convenience for combining dictionaries
    private func combine(from: [String: AnyObject], addition: [String: AnyObject]) -> [String: AnyObject] {
        var result = [String: AnyObject]()
        [from, addition].forEach { dict in
            dict.forEach { result[$0.0] = $0.1 }
        }
        return result
    }
}