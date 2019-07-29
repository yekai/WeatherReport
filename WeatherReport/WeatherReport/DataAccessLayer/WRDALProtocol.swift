//
//  WRDALProtocol.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/29.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

protocol WRDALHttpProtocol {
    func request(weatherInfo city: String,
                 successHandler: @escaping (WRBasicModel) -> Void,
                 failureHandler: @escaping (Error?) -> Void)
    func requestSupportedCityList() -> [WRCityModel]
}

protocol WRDALDatabaseProtocol {
    func request(weatherInfo city: String,
                 successHandler: @escaping (WRBasicModel) -> Void,
                 failureHandler: @escaping (Error?) -> Void)
    func requestSupportedCityList() -> [WRCityModel]
    func saveSupportedCityList(_ models: [WRCityModel])
    func queryCount(_ model: WRDatabaseModelProtocol) -> Int
    func saveObj(_ model: WRDatabaseModelProtocol) -> Bool
}
