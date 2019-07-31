//
//  UIFont+Utility.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/31.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

enum SystemFontName: String {
    case Regular = ".PingFangSC-Regular"
    case Medium = ".PingFangSC-Medium"
}

extension UIFont {
    convenience init(_ fontName: SystemFontName, _ size: CGFloat) {
        self.init(name: fontName.rawValue, size: size)!
    }
    
    convenience init(_ fontName: SystemFontName) {
        self.init(name: fontName.rawValue, size: 17)!
    }
}
