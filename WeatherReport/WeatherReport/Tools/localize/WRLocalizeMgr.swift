//
//  WRLocalizeMgr.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/22.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

/**
 * used to internationalize the apps data
 **/
class WRLocalizeMgr {
    class func localize(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
