//
//  WRMainViewPresenter.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/24.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

class WRMainViewPresenter {
    //the model for displaying weather info while the customer choose one city
    var currentDisplayedWeatherModel: WRDALModel?
    //the model that customer choose one city
    var currentDisplayedCityModel: WRCityModel?
    //all the city models from cached database
    var cityList:[WRCityModel] = WRDALManager.sharedInstance.requestSupportedCityList()
    //the data that will be used for drop selector, constains localize depends on language
    var displayedCityList: [String] {
        return cityList.map{$0.displayedCityName}
    }
    //weather rows number displayed for customer
    var numberOfWeatherRows: Int {
        return currentDisplayedWeatherModel?.displayedKeys().count ?? 0
    }
    //weather info List all keys
    var currentDisplayedWeatherKeys: [String]? {
        if let currentDisplayedWeatherModel = currentDisplayedWeatherModel {
            return currentDisplayedWeatherModel.displayedKeys()
        }
        return nil
    }
    //weather info List all Values
    var currentDisplayedWetherValues: [String]? {
        if let currentDisplayedWeatherModel = currentDisplayedWeatherModel, let cityKeyValue = currentDisplayedCityModel?.displayedCityName {
            //the successModel attribute is used to confirem the data is from remote or not
            let onOfflineMode =  WRLocalizeMgr.localize(currentDisplayedWeatherModel.successModel ? "com.main.weather.value.onlineMode" : "com.main.weather.value.offlineMode")
            return currentDisplayedWeatherModel.displayedValues(onOfflineMode, cityDisplayedValue: cityKeyValue)
        }
        return nil
    }
    //is current weather data is from remote
    var doescurrentWeatherDataFromRemote: Bool {
        if let currentDisplayedWeatherModel = currentDisplayedWeatherModel {
            return currentDisplayedWeatherModel.successModel
        }
        return false
    }
    
    func requestWeatherInfo(selectedIndex:Int,
                            successHandler: @escaping () -> Void,
                            failureHandler: @escaping (Error?) -> Void) {
        //cross List index error
        if cityList.count > selectedIndex {
            //get current city model
            currentDisplayedCityModel = cityList[selectedIndex]
            //current city name from model and then get weather data from DAL manager
            if let cityName = currentDisplayedCityModel?.cityName {
                WRDALManager.sharedInstance.request(weatherInfo: cityName, successHandler: { [weak self] (model) in
                    self?.currentDisplayedWeatherModel = model as? WRDALModel
                    successHandler()
                }) { (error) in
                    failureHandler(error)
                }
            }
        }
    }
    
}
