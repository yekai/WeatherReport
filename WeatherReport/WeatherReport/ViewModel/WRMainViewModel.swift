//
//  WRMainViewModel.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/31.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

class WRMainViewModel: WRBaseViewModel {
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
    
    var selectedIndex: Int = 0 {
        didSet {
            if cityList.count > selectedIndex {
                //get current city model
                currentDisplayedCityModel = cityList[selectedIndex]
            }
        }
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
    
    var weatherReportActionSignalProducer: SignalProducer<Bool, WRRequestCommonError>!
    let (requestSelectedIndexSignal, requestSelectedIndexObserver) = Signal<Int, NoError>.pipe()
    
    override func initialBind() {
        weatherReportActionSignalProducer = SignalProducer<Bool, WRRequestCommonError>({ [weak self] (observer, _) in
            //current city name from model and then get weather data from DAL manager
            if let cityName = self?.currentDisplayedCityModel?.cityName {
                WRDALManager.sharedInstance.request(weatherInfo: cityName, successHandler: { (model) in
                    self?.currentDisplayedWeatherModel = model as? WRDALModel
                    observer.send(value: true)
                    observer.sendCompleted()
                }) { (error) in
                    observer.send(value: false)
                    observer.sendCompleted()
                }
            }
        })
    }
}
