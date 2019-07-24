//
//  WRTimeTaskManager.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/24.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

/**
 * This is a time task manger for our apps to store
 * weather data info with a backend task, all these
 * operations are operated in global queue, it is used to
 * store weather data every 5 minutes, and while the apps lost network
 * customer can get the latest weather info for our customer,
 * which is a suggestion for customer while the network is offline
 */
class WRTimeTaskManager {
    private var timer: Timer?
    private var dalManager:WRDALManager = WRDALManager.sharedInstance
    private var availableCities:[String]
    
    init() {
        dalManager = WRDALManager.sharedInstance
        availableCities = dalManager.requestSupportedCityList().compactMap{$0.cityName}
    }
    
    func fire() {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(kWeatherReportFetchDataTime), target: self, selector: #selector(fetchWeatherData), userInfo: nil, repeats: true)
        //add in common runloop since this timer will continue work while scroll view scrolling
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    func invalidate() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func fetchWeatherData() {
        DispatchQueue.global().async {
            for city in self.availableCities {
                self.dalManager.store(weatherInfo: city)
            }
        }
    }
}
