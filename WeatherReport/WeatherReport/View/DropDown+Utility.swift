//
//  DropDown+Utility.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/23.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit
import iOSDropDown

extension DropDown {
    func hideListWithoutAnimation() {
        //this is a tricky solution for hide dropdown, we have to develop it better if we have more time
        for subview in self.superview!.subviews {
            if subview != self && type(of: subview) != UILabel.classForCoder() && subview.tag != kWeatherReportTableViewInfoTag {
                subview.removeFromSuperview()
            }
        }
        self.isSelected = false
    }
}
