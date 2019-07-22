//
//  Date+Utility.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/22.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

extension Date {
    
    func currentFormat() -> DateFormatter {
        let threadDict = Thread.current.threadDictionary
        if let formatter = threadDict[kCurrentThreadDatFormatter] {
            return formatter as! DateFormatter
        }
        let dateFormatter = DateFormatter()
        threadDict[kCurrentThreadDatFormatter] = dateFormatter
        return dateFormatter
    }
    
    func stringFrom(format: String) -> String? {
        let currentFormatter = currentFormat()
        currentFormatter.isLenient = true
        currentFormatter.dateFormat = format
        return currentFormatter.string(from: self)
    }
    
    func stringOfYYYYMMDD() -> String? {
        return stringFrom(format: "yyyy-MM-dd")
    }
    
    func stringOfYYYYMMDDHHMMSS() -> String? {
        return stringFrom(format: "yyyy-MM-dd HH:mm:ss")
    }
    
    func stringOfEEEEHHMMAA() -> String? {
        return stringFrom(format: "EEEE HH:mm aa")
    }
}

