//
//  WRDALModel.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/22.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

class WRBasicModel: NSObject {
    var id: String
    var successModel: Bool = false
    
    init(_ id:String) {
        self.id = id
    }
    
}

class WRDALModel: WRBasicModel, WRDatabaseModelProtocol {
    var cityName: String
    var updatedTime: Date
    var weather: String?
    var temperature: String?
    var wind: String?
    
    init(_ id: String, cityName: String, updatedTime: Date, weather: String?, temperature: String?, wind: String?) {
        self.cityName = cityName
        self.updatedTime = updatedTime
        self.weather = weather
        self.temperature = temperature
        self.wind = wind
        super.init(id)
    }
    
    convenience init() {
        self.init("", cityName: "", updatedTime: Date(), weather: nil, temperature: nil, wind: nil)
    }
    
    convenience init(_ dict: [String: Any]) {
        let id = dict["id"] as! String
        let cityName = dict["cityName"] as! String
        let weather = dict["weather"] as? String
        let temperature = dict["temperature"] as? String
        let wind = dict["wind"] as? String
        let updatedTime = (dict["updatedTime"] as! String).dateOfYYYYMMDDHHMMSS()!
        self.init(id, cityName: cityName, updatedTime: updatedTime, weather: weather, temperature: temperature, wind: wind)
    }
    
    func displayedUpdatedTime() -> String {
        return updatedTime.stringOfEEEEHHMMAA() ?? ""
    }
    
    func displayedWeather() -> String {
        return weather ?? "unknown"
    }
    
    func displayedTemperature() -> String {
        if let temperature = temperature {
            return "\(temperature)°C"
        }
        return "unknown"
    }
    
    func displayedWind() -> String {
        if let wind = wind {
            return "\(wind)km/h"
        }
        return "unknown"
    }
    
    func sqlTableName() -> String {
        return "weatherReport"
    }
    
    func sqlTableString() -> String {
        return """
        CREATE TABLE IF NOT EXISTS \(sqlTableName()) (id text PRIMARY KEY,
                                                      cityName text NOT NULL,
                                                      updatedTime DateTime NOT NULL,
                                                      weather text NOT NULL,
                                                      temperature text NOT NULL,
                                                      wind text NOT NULL)
        """
    }
    
    func sqlTableKeys() -> String {
        return "id,cityName,updatedTime,weather,temperature,wind"
    }
    
    func sqlTableValues() -> String {
        return "'\(id)','\(cityName)','\(String(describing: updatedTime.stringOfYYYYMMDDHHMMSS()))','\(String(describing: weather))','\(String(describing: temperature))','\(String(describing: wind))'"
    }
}

class WRCityModel: WRBasicModel, WRDatabaseModelProtocol {
    var cityName: String
    var localizeCityKey: String
    
    init(_ id: String, cityName: String, localizeCityKey: String) {
        self.cityName = cityName
        self.localizeCityKey = localizeCityKey
        super.init(id)
        self.successModel = true
    }
    
    convenience init() {
        self.init("", cityName: "", localizeCityKey: "")
    }
    
    convenience init(_ dict: [String: Any]) {
        let id = dict["id"] as! String
        let cityName = dict["cityName"] as! String
        let localizeCityKey = dict["localizeCityKey"] as! String
        self.init(id, cityName: cityName, localizeCityKey: localizeCityKey)
    }
    
    func displayedCityName() -> String {
        return WRLocalizeMgr.localize(localizeCityKey)
    }
    
    func sqlTableName() -> String {
        return "cityList"
    }
    
    func sqlTableString() -> String {
        return """
        CREATE TABLE IF NOT EXISTS \(sqlTableName()) (id text PRIMARY KEY,
                                                      cityName text NOT NULL,
                                                      localizeCityKey text NOT NULL)
        """
    }
    
    func sqlTableKeys() -> String {
        return "id,cityName,localizeCityKey"
    }
    
    func sqlTableValues() -> String {
        return "'\(id)','\(cityName)','\(localizeCityKey)'"
    }
}
