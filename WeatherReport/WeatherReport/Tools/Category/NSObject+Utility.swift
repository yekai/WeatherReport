//
//  NSObject+Utility.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/8/1.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

extension NSObject {
    func properties() -> [[String: Any]] {
        var properties: [[String: Any]] = []
        var mirror: Mirror? = Mirror(reflecting: self)
        while mirror != nil {
            if let pairs = mirror?.children.compactMap({$0.label != nil ? [$0.label!:$0.value] : nil})  {
                properties.insert(contentsOf: pairs, at: 0)
            }
            mirror = mirror?.superclassMirror
        }
        
        return properties
    }
    
    func propertyKeys() -> [String] {
        return properties().compactMap{$0.keys.first}
    }
    
    func propertyValues() -> [Any] {
        return properties().compactMap{$0.values.first}
    }
    
    func propertyKeys(without keys:[String]) -> [String] {
        return propertyKeys().filter({ !keys.contains($0) })
    }
    
    func propertyValues(without keys:[String]) -> [Any] {
        return properties().compactMap{!keys.contains($0.keys.first!) ? $0.values.first : nil}
    }
    
    func propertyPairs() -> [String: Any] {
        var pairs: [String: Any] = [:]
        properties().forEach { (pair) in
            pairs[pair.keys.first!] = pair.values.first
        }
        return pairs
    }
    
    subscript(key: String) -> Any? {
        return propertyPairs()[key]
    }
}

