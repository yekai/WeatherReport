//
//  UIView+Utility.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/31.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit
import Foundation

extension UIView {
    func showHud() {
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.bezelView.backgroundColor = UIColor(rgbValue: 0x999999)
        hud.show(animated: true)
    }
    
    func hideHud() {
        MBProgressHUD.hide(for: self, animated: true)
    }
    
    func showMessage(_ message: String) {
        hideHud()
        UIApplication.shared.keyWindow?.hideHud()
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.label.text = message
        hud.label.numberOfLines = 0
        hud.mode = .customView
        hud.removeFromSuperViewOnHide = true
        hud.bezelView.backgroundColor = UIColor.black
        hud.label.textColor = UIColor.white
        hud.hide(animated: true, afterDelay: 2.0)
        hud.label.font = UIFont(.Regular,14)
        
    }
}
