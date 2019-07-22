//
//  String+Utility.swift
//  WeatherReport
//
//  Created by Ice on 2019/7/22.
//  Copyright © 2019 testOrg. All rights reserved.
//

import UIKit

extension String {
    func currentFormat() -> DateFormatter {
        let threadDict = Thread.current.threadDictionary
        if let formatter = threadDict[kCurrentThreadDatFormatter] {
            return formatter as! DateFormatter
        }
        let dateFormatter = DateFormatter()
        threadDict[kCurrentThreadDatFormatter] = dateFormatter
        return dateFormatter
    }
    
    func dateFrom(format: String) -> Date? {
        let currentFormatter = currentFormat()
        currentFormatter.isLenient = true
        currentFormatter.dateFormat = format
        return currentFormatter.date(from: self)
    }
    
    func dateOfYYYYMMDDHHMMSS() -> Date? {
        return dateFrom(format: "yyyy-MM-dd HH:mm:ss")
    }
    
    func uniqueID() -> String {
        let id: String = NSUUID.init().uuidString
        let idComponents = id.components(separatedBy: "-")
        return idComponents.joined(separator: "*")
    }
}
