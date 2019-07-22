//
//  WeatherReportProtocol.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/22.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

protocol WRDALProtocol {
    func request(weatherInfo city: String,
                 successHandler: @escaping (WRBasicModel) -> Void,
                 failureHandler: @escaping (Error?) -> Void)
    func requestSupportedCityList() -> [String: String]
}
