//
//  WRDALManager.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/22.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WRDALFactory: WRDALProtocol {
    
    func request(weatherInfo city: String,
                 successHandler: @escaping (WRBasicModel) -> Void,
                 failureHandler: @escaping (Error?) -> Void) {
        var parameters = kWeatherReportRequestParameters
        parameters["city"] = city
        WRDALHttpClient.request(kWeatherReportRequestURL,
                                parameters:parameters,
                                formatterHandler: { (response) -> WRBasicModel in
                                    return self.formattedWRDALModel(city, dataObj: response)
        }, successHandler: { (model) in
            if model.successModel {
                successHandler(model)
            } else {
                let error: Error = AFError.responseValidationFailed(reason: .dataFileNil)
                failureHandler(error)
            }
        }) { (error) in
            failureHandler(error)
        }
    }
    
    func requestSupportedCityList() -> [String: String] {
        let path:String = Bundle.main.path(forResource: "supportedCityList", ofType: "plist")!
        let citiesInfo: [String: String] = NSDictionary(contentsOfFile: path) as! [String: String]
        var newCities = citiesInfo
        for key in citiesInfo.keys {
            if let value = newCities[key] {
                newCities[key] = WRLocalizeMgr.localize(value)
            }
        }
        return newCities
    }
    
    func formattedWRDALModel(_ city: String, dataObj: Any?) -> WRDALModel {
        let id = NSUUID.init(uuidString: Date().stringOfYYYYMMDDHHMMSS()!)?.uuidString ?? ""
        let cityName = city
        let updatedTime = Date()

        if let dataObj = dataObj {
            let jsonObj = JSON(dataObj)
            if let code = jsonObj["code"].string, code == kWeatherReportRequestSuccessCode {
                let weather = jsonObj["result"]["HeWeather5"][0]["now"]["cond"]["txt"].string
                let temperature = jsonObj["result"]["HeWeather5"][0]["now"]["tmp"].string
                let wind = jsonObj["result"]["HeWeather5"][0]["now"]["wind"]["spd"].string
                let model = WRDALModel(id, cityName: cityName, updatedTime: updatedTime, weather: weather, temperature: temperature, wind: wind)
                model.successModel = true
                return model
            }
        }
        
        return WRDALModel(id, cityName: cityName, updatedTime: updatedTime, weather: nil, temperature: nil, wind: nil)
    }
}

class WRDatabaseFactory: WRDALProtocol {
    func request(weatherInfo city: String,
                 successHandler: @escaping (WRBasicModel) -> Void,
                 failureHandler: @escaping (Error?) -> Void) {
        
    }
    
    func requestSupportedCityList() -> [String : String] {
        return ["":""]
    }
}


