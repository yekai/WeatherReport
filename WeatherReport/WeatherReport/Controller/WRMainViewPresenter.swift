//
//  WRMainViewPresenter.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/24.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

class WRMainViewPresenter {
    var currentDisplayedWeatherModel: WRDALModel?
    var currentDisplayedCityModel: WRCityModel?
    var cityList:[WRCityModel]?
    var displayedCityList: [String] {
        var cityValues: [String] = [String]()
        if let cityList =  cityList {
            cityValues = cityList.map{$0.displayedCityName}
        }
        return cityValues
    }
    var numberOfWeatherRows: Int {
        return currentDisplayedWeatherModel?.displayedKeys().count ?? 0
    }
    var currentDisplayedWeatherKeys: [String]? {
        if let currentDisplayedWeatherModel = currentDisplayedWeatherModel {
            return currentDisplayedWeatherModel.displayedKeys()
        }
        return nil
    }
    var currentDisplayedWetherValues: [String]? {
        if let currentDisplayedWeatherModel = currentDisplayedWeatherModel, let cityKeyValue = currentDisplayedCityModel?.displayedCityName {
            let onOfflineMode =  WRLocalizeMgr.localize(currentDisplayedWeatherModel.successModel ? "com.main.weather.value.onlineMode" : "com.main.weather.value.offlineMode")
            return currentDisplayedWeatherModel.displayedValues(onOfflineMode, cityDisplayedValue: cityKeyValue)
        }
        return nil
    }
    var doesWcurrentWeatherDataFromRemote: Bool {
        if let currentDisplayedWeatherModel = currentDisplayedWeatherModel {
            return currentDisplayedWeatherModel.successModel
        }
        return false
    }
    
    init() {
        cityList = WRDALManager.sharedInstance.requestSupportedCityList()
    }
    
    func requestWeatherInfo(selectedIndex:Int,
                            successHandler: @escaping () -> Void,
                            failureHandler: @escaping (Error?) -> Void) {
        if let cityList = cityList, cityList.count > selectedIndex {
            currentDisplayedCityModel = cityList[selectedIndex]
            if let cityName = currentDisplayedCityModel?.cityName {
                WRDALManager.sharedInstance.request(weatherInfo: cityName, successHandler: { (model) in
                    self.currentDisplayedWeatherModel = model as? WRDALModel
                    successHandler()
                }) { (error) in
                    failureHandler(error)
                }
            }
        }
    }
    
}
