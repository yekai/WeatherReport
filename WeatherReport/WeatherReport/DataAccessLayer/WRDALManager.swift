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

/**
 * This is a network factory for all work business
 * we can set all business network request in this factory
 * The factory contains request methods, and also format handler
 * we can distingush these requests through swift extension
 * set one each request and format hanlder in one extension
 **/
fileprivate class WRDALFactory: WRDALHttpProtocol {
    /**
     * request weather info from remote
     * city: city name
     * successHandler: success handler
     * failureHandler: fail handler
     **/
    func request(weatherInfo city: String,
                 successHandler: @escaping (WRBasicModel) -> Void,
                 failureHandler: @escaping (Error?) -> Void) {
        var parameters = kWeatherReportRequestParameters
        parameters["city"] = city
        WRDALHttpClient.request(kWeatherReportRequestURL,
                                parameters:parameters,
                                formatterHandler: { (response) -> WRBasicModel in
                                    //format json to WRDALModel
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
    
    /**
     * get the city initial list from local file
     * and later we can set this initial from remote
     **/
    func requestSupportedCityList() -> [WRCityModel] {
        let path:String = Bundle.main.path(forResource: "supportedCityList", ofType: "plist")!
        let citiesInfo: [String: String] = NSDictionary(contentsOfFile: path) as! [String: String]
        let newCities: [WRCityModel] = citiesInfo.keys.compactMap {
            if let value = citiesInfo[$0] {
                let id = String.uniqueID()
                let cityName = $0
                let localizeKey = value
                return WRCityModel(id, cityName:cityName, localizeCityKey: localizeKey)
            }
            return nil
        }
        return newCities
    }
    
    func formattedWRDALModel(_ city: String, dataObj: Any?) -> WRDALModel {
        let id = String.uniqueID()
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

/**
 * This is a database factory for all work business
 * we can set all business datbase operation in this factory
 * The factory contains database business methods,
 * we can distingush these requests through swift extension
 * set one each request and format hanlder in one extension
 **/
fileprivate class WRDatabaseFactory: WRDALDatabaseProtocol {
    private let databaseClient = WRDatabaseClient.sharedInstance
    
    //initial all cached database table while factory creation
    init() {
        databaseClient.register([WRDALModel(), WRCityModel()])
    }
    //request weather info from databse through city name
    func request(weatherInfo city: String,
                 successHandler: @escaping (WRBasicModel) -> Void,
                 failureHandler: @escaping (Error?) -> Void) {
        let model = WRDALModel()
        model.cityName = city
        //get the model in database
        if let queryModel = databaseClient.query(model) {
            //format and deal with model in success handler
            let obj = WRDALModel(queryModel)
            successHandler(obj)
        } else {
            failureHandler(AFError.responseValidationFailed(reason: .dataFileNil))
        }
    }
    //request all stored city list in databse for drop down selector
    func requestSupportedCityList() -> [WRCityModel] {
        let queryList:[[String: Any]] = databaseClient.queryAll(WRCityModel())
        let result:[WRCityModel] = queryList.compactMap { WRCityModel($0) }
        return result
    }
    //save local initialed city list in database
    func saveSupportedCityList(_ models: [WRCityModel]) {
        models.forEach { (model) in
            let _ = databaseClient.saveObj(model)
        }
    }
    //query model data count number in database
    func queryCount(_ model: WRDatabaseModelProtocol) -> Int {
        return databaseClient.queryCount(model)
    }
    //save data model in database
    func saveObj(_ model: WRDatabaseModelProtocol) -> Bool {
        return databaseClient.saveObj(model)
    }
}

/**
 * This is a business manager for all work business that contains
 * complex operation between network and database, we need adopt
 * the development design rul polymerization, set all factories in
 * this manager, manager contains request methods, and then store
 * the remote data in database, or the network is unavailable, we
 * fetch database data for offline mode
 **/

class WRDALManager {
    //Signleton design pattern
    static var sharedInstance: WRDALManager {
        struct Singleton {
            static let instance: WRDALManager = WRDALManager()
        }
        return Singleton.instance
    }
    
    private let remoteFactory: WRDALHttpProtocol = WRDALFactory()
    private let databaseFactory: WRDALDatabaseProtocol = WRDatabaseFactory()
    
    init() {
        saveLocalCityList()
    }
    
    func saveLocalCityList() {
        //there is a rule, we should not delete all the cities from cityList table if
        //there may be functions for delete cities in later development
        let count = databaseFactory.queryCount(WRCityModel())
        if count == 0 {
            let localCitiesList = remoteFactory.requestSupportedCityList()
            databaseFactory.saveSupportedCityList(localCitiesList)
        }
    }
    
    func requestSupportedCityList() -> [WRCityModel] {
        return databaseFactory.requestSupportedCityList()
    }
    
    func request(weatherInfo city: String,
                 successHandler: @escaping (WRBasicModel) -> Void,
                 failureHandler: @escaping (Error?) -> Void) {
        //confirm the network ability while each request from remote
        let manager = NetworkReachabilityManager(host: kWeatherReportRequestURL)
        manager?.listener = { status in
            //if the network is reachable, we can get the data from remote
            if status == .reachable(.ethernetOrWiFi) || status == .reachable(.wwan) {
                self.remoteFactory.request(weatherInfo: city, successHandler: { (model) in
                    if let weatherModel = model as? WRDALModel {
                        //while the remote data is received, deal with in success handler
                        successHandler(weatherModel)
                        //and then store this model in database
                        let _ = self.databaseFactory.saveObj(weatherModel)
                    }
                }, failureHandler: { (error) in
                    //if remote happens error and the nget the data from database
                    self.databaseFactory.request(weatherInfo: city, successHandler: { (model) in
                        //while the database data is received, deal with in success handler
                        successHandler(model)
                    }, failureHandler: { (error) in
                        failureHandler(error)
                    })
                })
            } else {
                //if the network is unreachable and then get the data from database
                self.databaseFactory.request(weatherInfo: city, successHandler: { (model) in
                    //while the database data is received, deal with in success handler
                    successHandler(model)
                }, failureHandler: { (error) in
                    failureHandler(error)
                })
            }
        }
        manager?.startListening()
    }
    
    //store the remote data into database, do nothing for other exceptions
    func store(weatherInfo city: String) {
        //confirm the network ability while each request from remote
        let manager = NetworkReachabilityManager(host: kWeatherReportRequestURL)
        manager?.listener = { status in
            //if the network is reachable, we can get the data from remote
            if status == .reachable(.ethernetOrWiFi) || status == .reachable(.wwan) {
                self.remoteFactory.request(weatherInfo: city, successHandler: { (model) in
                    // do all the operation in global queue
                    DispatchQueue.global().async {
                        if let weatherModel = model as? WRDALModel {
                            //while the remote data is received, store this model in database
                            let _ = self.databaseFactory.saveObj(weatherModel)
                        }
                    }
                }, failureHandler: { (error) in
                    //do nothing
                })
            }
        }
        manager?.startListening()
    }
}


