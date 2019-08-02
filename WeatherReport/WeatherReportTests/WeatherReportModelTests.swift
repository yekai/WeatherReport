//
//  WeatherReportTests.swift
//  WeatherReportTests
//
//  Created by Ice on 2019/7/20.
//  Copyright © 2019 testOrg. All rights reserved.
//

import XCTest
@testable import WeatherReport

class WeatherReportModelTests: XCTestCase {
    var weatherModel: WRDALModel?
    var cityModel: WRCityModel?
    var cityModelData: [String: String] = ["id":"AAA-BBB-CCC-DDD", "cityName":"Sydney","localizeCityKey":"com.city.Sydney"]
    var weatherModelData: [String: String] = ["id":"AAA-BBB-CCC-DDD", "cityName":"Sydney","updatedTime":"2019-02-14 02:14:23","weather":"rainy","temperature":"13","wind":"12"]
    
    override func setUp() {
        cityModel = WRCityModel(cityModelData["id"]!, cityName: cityModelData["cityName"]!, localizeCityKey:  cityModelData["localizeCityKey"]!)
        weatherModel = WRDALModel(weatherModelData["id"]!, cityName: weatherModelData["cityName"]!, updatedTime: weatherModelData["updatedTime"]!.dateOfYYYYMMDDHHMMSS()!, weather: weatherModelData["weather"], temperature: weatherModelData["temperature"], wind: weatherModelData["wind"])
    }

    override func tearDown() {
    }

    func testCityModel() {
        assertCityModel()
    }
    
    func testWeatherModel() {
        assertWeatherModel()
    }
    
    func testEmptyCityModel() {
        cityModel = WRCityModel()
        XCTAssertTrue(cityModel?.cityName == "")
        XCTAssertTrue(cityModel?.id == "")
        XCTAssertTrue(cityModel?.localizeCityKey == "")
        XCTAssertTrue(cityModel?.displayedCityName == "")
    }
    
    func testCityModelFromDict() {
        cityModel = WRCityModel(cityModelData)
        assertCityModel()
    }
    
    func testWeatherModelFromDict() {
        weatherModel = WRDALModel(weatherModelData)
        assertWeatherModel()
    }
    
    func testEmptyWeatherModel() {
        weatherModel = WRDALModel()
        XCTAssertTrue(weatherModel?.cityName == "")
        XCTAssertTrue(weatherModel?.id == "")
        XCTAssertTrue(weatherModel?.weather == nil)
        XCTAssertTrue(weatherModel?.updatedTime != nil)
        XCTAssertTrue(weatherModel?.temperature == nil)
        XCTAssertTrue(weatherModel?.wind == nil)
    }
    
    func assertCityModel() {
        XCTAssertTrue(cityModel?.cityName == "Sydney")
        XCTAssertTrue(cityModel?.id == "AAA-BBB-CCC-DDD")
        XCTAssertTrue(cityModel?.localizeCityKey == "com.city.Sydney")
        XCTAssertTrue(cityModel?.displayedCityName == "Sydney")
        
        XCTAssertTrue(cityModel?.cityString() == "Sydney")
        XCTAssertTrue(cityModel?.sqlTableName() == "cityList")
        XCTAssertTrue(cityModel?.sqlTableOrderBy() == nil)
        XCTAssertTrue(cityModel?.sqlTableString() ==  """
            CREATE TABLE IF NOT EXISTS cityList (id text PRIMARY KEY,
            cityName text NOT NULL,
            localizeCityKey text NOT NULL)
            """)
        XCTAssertTrue(cityModel?.sqlTableKeys() == "id,cityName,localizeCityKey")
        XCTAssertTrue(cityModel?.sqlTableValues() ==  "'AAA-BBB-CCC-DDD','Sydney','com.city.Sydney'")
    }
    
    func assertWeatherModel() {
        XCTAssertTrue(weatherModel?.cityName == "Sydney")
        XCTAssertTrue(weatherModel?.id == "AAA-BBB-CCC-DDD")
        XCTAssertTrue(weatherModel?.updatedTime != nil)
        XCTAssertTrue(weatherModel?.weather == "rainy")
        XCTAssertTrue(weatherModel?.temperature == "13")
        XCTAssertTrue(weatherModel?.wind == "12")
        XCTAssertTrue(weatherModel?.displayedWind == "12km/h")
        XCTAssertTrue(weatherModel?.displayedWeather == "rainy")
        XCTAssertTrue(weatherModel?.displayedTemperature == "13°C")
        XCTAssertTrue(weatherModel?.displayedUpdatedTime == "Thursday 02:14 AM")
        
        XCTAssertTrue(weatherModel?.cityString() == "Sydney")
        XCTAssertTrue(weatherModel?.sqlTableName() == "weatherReport")
        XCTAssertTrue(weatherModel?.sqlTableOrderBy() == "ORDER BY updatedTime DESC")
        XCTAssertTrue(weatherModel?.sqlTableString() ==  """
            CREATE TABLE IF NOT EXISTS weatherReport (id text PRIMARY KEY,
            cityName text NOT NULL,
            updatedTime DateTime NOT NULL,
            weather text NOT NULL,
            temperature text NOT NULL,
            wind text NOT NULL)
            """)
        XCTAssertTrue(weatherModel?.sqlTableKeys() == "id,cityName,updatedTime,weather,temperature,wind")
        XCTAssertTrue(weatherModel?.sqlTableValues() ==  "'AAA-BBB-CCC-DDD','Sydney','2019-02-14 02:14:23','rainy','13','12'")
    }

}
