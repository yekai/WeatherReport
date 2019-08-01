//
//  WRDALModel.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/22.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

/**
 * this protocol is used to receive
 * related database info from model
 * all models cached in database should
 * implement this protocol
 **/
protocol WRDatabaseModelProtocol {
    //table name
    func sqlTableName() -> String
    //create table sql string
    func sqlTableString() -> String
    //insert or update table all keys
    func sqlTableKeys() -> String
    //insert or update table all values
    func sqlTableValues() -> String
    //current model city name
    func cityString() -> String
    //query table order by parameter
    func sqlTableOrderBy() -> String?
    //not persist keys in database
    func sqlExceptKeys() -> [String]
}

/**
 * This is a basic model for all apps
 * all other data mode from remote should
 * extend from this class, we can get parsed
 * remote model through this class in http client
 **/
class WRBasicModel: NSObject {
    //maybe used this id in cached database
    var id: String
    //whether this model is valid from remote or not
    var successModel: Bool = false
    
    init(_ id:String) {
        self.id = id
    }
}

/**
 * This model stands for weather data info model
 * used to display weather info in main view, and
 * also should be cached in database for diplaying
 * weather info while the network is offline mode
 **/
class WRDALModel: WRBasicModel {
    //stored in database, city name
    var cityName: String
    //stored in database, produced time
    var updatedTime: Date
    //stored in database, weather
    var weather: String?
    //stored in database, temperature
    var temperature: String?
    //stored in database, wind speed
    var wind: String?
    //displayed produced weather info time
    var displayedUpdatedTime: String {
        return updatedTime.stringOfEEEEHHMMAA() ?? ""
    }
    //displayed weather
    var displayedWeather: String {
        return weather ?? "unknown"
    }
    //displayed temperature
    var displayedTemperature: String {
        if let temperature = temperature {
            return "\(temperature)°C"
        }
        return "unknown"
    }
    //displayed wind speed
    var displayedWind: String {
        if let wind = wind {
            return "\(wind)km/h"
        }
        return "unknown"
    }
    
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
    
    func displayedKeys() -> [String] {
        let networkState = WRLocalizeMgr.localize("com.main.weather.key.networkMode")
        let city = WRLocalizeMgr.localize("com.main.weather.key.city")
        let updatedTime = WRLocalizeMgr.localize("com.main.weather.key.updatedTime")
        let weather = WRLocalizeMgr.localize("com.main.weather.key.weather")
        let temperature = WRLocalizeMgr.localize("com.main.weather.key.temperature")
        let wind = WRLocalizeMgr.localize("com.main.weather.key.wind")
        
        return [networkState, city, updatedTime, weather, temperature, wind]
    }
    
    func displayedValues(_ netState: String, cityDisplayedValue: String) -> [String] {
        return [netState, cityDisplayedValue, displayedUpdatedTime, displayedWeather, displayedTemperature, displayedWind]
    }
}

/**
 * implemnt all database related operation function
 **/
extension WRDALModel: WRDatabaseModelProtocol {
    func sqlExceptKeys() -> [String] {
        return ["successModel"]
    }
    
    //current model city name
    func cityString() -> String {
        return cityName
    }
    //model table name related in database
    func sqlTableName() -> String {
        return "weatherReport"
    }
    //create model table name
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
    //all updated or inserted keys for saving or updating model in database
    func sqlTableKeys() -> String {
        return self.propertyKeys(without: sqlExceptKeys()).joined(separator: ",")
    }
    //all updated or inserted values for saving or updating model in database
    func sqlTableValues() -> String {
        let values = [id, cityName, self.updatedTime.stringOfYYYYMMDDHHMMSS() ?? "", self.weather ?? "", self.temperature ?? "", self.wind ?? ""]
        return values.compactMap{"'\($0)'"}.joined(separator: ",")
    }
    //query table order by parameters
    func sqlTableOrderBy() -> String? {
        return "ORDER BY updatedTime DESC"
    }
}

/**
 * This model stands for city info model
 * used to display city info in main view, and
 * also should be cached in database for future extended
 * city info
 **/
class WRCityModel: WRBasicModel {
    //stored in database, city name
    var cityName: String
    //stored in database, city localize key
    var localizeCityKey: String
    //displayed city name depends on ios system language
    var displayedCityName: String {
        return WRLocalizeMgr.localize(localizeCityKey)
    }
    
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
}
/**
 * implemnt all database related operation function
 **/
extension WRCityModel: WRDatabaseModelProtocol {
    func sqlExceptKeys() -> [String] {
        return ["successModel"]
    }
    
    func cityString() -> String {
        return cityName
    }
    
    func sqlTableName() -> String {
        return "cityList"
    }
    
    func sqlTableOrderBy() -> String? {
        return nil
    }
    
    func sqlTableString() -> String {
        return """
        CREATE TABLE IF NOT EXISTS \(sqlTableName()) (id text PRIMARY KEY,
        cityName text NOT NULL,
        localizeCityKey text NOT NULL)
        """
    }
    
    func sqlTableKeys() -> String {
        return self.propertyKeys(without: sqlExceptKeys()).joined(separator: ",")
    }
    
    func sqlTableValues() -> String {
        return self.propertyValues(without: sqlExceptKeys()).compactMap{"'\($0)'"}.joined(separator: ",")
    }

}
