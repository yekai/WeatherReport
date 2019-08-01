//
//  NetworkReachabilityManager.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/8/1.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit
import Alamofire

extension NetworkReachabilityManager {
    static func startListening(_ host: String,
                     reachableHandler: @escaping () -> Void,
                   unReachableHandler: @escaping () -> Void) {
        let manager = NetworkReachabilityManager(host: host)
        manager?.listener = { status in
            if status == .reachable(.ethernetOrWiFi) || status == .reachable(.wwan) {
                reachableHandler()
            } else {
                unReachableHandler()
            }
        }
        manager?.startListening()
    }
}
