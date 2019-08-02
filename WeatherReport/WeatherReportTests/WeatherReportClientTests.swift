//
//  WeatherReportTests.swift
//  WeatherReportTests
//
//  Created by Ice on 2019/7/20.
//  Copyright © 2019 testOrg. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import WeatherReport

class WeatherReportClientTests: XCTestCase {
    var databaseClient: WRDatabaseClient?
    var weatherModel: WRDALModel?
    var cityModel: WRCityModel?
    var cityModelData: [String: String] = ["id":String.uniqueID(), "cityName":"Beijing","localizeCityKey":"com.city.Beijing"]
    var weatherModelData: [String: String] = ["id":String.uniqueID(), "cityName":"Beijing","updatedTime":"2019-02-14 02:14:23","weather":"rainy","temperature":"13","wind":"12"]
    
    override func setUp() {
        databaseClient = WRDatabaseClient(forTest: true)
        databaseClient?.register([WRDALModel(), WRCityModel()])
        cityModel = WRCityModel(cityModelData["id"]!, cityName: cityModelData["cityName"]!, localizeCityKey:  cityModelData["localizeCityKey"]!)
        weatherModel = WRDALModel(weatherModelData["id"]!, cityName: weatherModelData["cityName"]!, updatedTime: weatherModelData["updatedTime"]!.dateOfYYYYMMDDHHMMSS()!, weather: weatherModelData["weather"], temperature: weatherModelData["temperature"], wind: weatherModelData["wind"])
    }
    
    override func tearDown() {
    }
    
    func testDataBaseClient() {
        XCTAssertTrue(databaseClient!.isDatabaseAvailable())
        let _ = databaseClient?.saveObj(cityModel!)
        let cities: [[String: Any]]? = databaseClient?.queryAll(WRCityModel())
        XCTAssertTrue(cities!.count > 0)
        let city:[String: Any]? = databaseClient?.query(cityModel!)
        XCTAssertTrue(city!["cityName"]! as! String == "Beijing")
        var count = databaseClient?.queryCount(cityModel!)
        XCTAssertTrue(count! > 0)
        
        let _ = databaseClient?.saveObj(weatherModel!)
        let weathers: [[String: Any]]? = databaseClient?.queryAll(WRDALModel())
        XCTAssertTrue(weathers!.count > 0)
        let weather:[String: Any]? = databaseClient?.query(weatherModel!)
        XCTAssertTrue(weather!["cityName"]! as! String == "Beijing")
        count = databaseClient?.queryCount(cityModel!)
        XCTAssertTrue(count! > 0)
    }
    
    func testHttpClient() {
        let expect = expectation(description: "wrTest")
        let timeout = 15 as TimeInterval
        var parameters = kWeatherReportRequestParameters
        parameters["city"] = "Sydney"
        WRDALHttpClient.request(kWeatherReportRequestURL,
                                parameters:parameters,
                                formatterHandler: { (response) -> WRBasicModel in
                                    XCTAssertTrue(response != nil)
                                    XCTAssertTrue((JSON(response!).rawString() != nil))
                                    return WRBasicModel("zzzz-zzzz-zzzz")
            }, successHandler: { (model) in
                XCTAssertTrue(model.id == "zzzz-zzzz-zzzz")
                expect.fulfill()
                
        }) { (error) in
            expect.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testHttpErrorClient() {
        let expect = expectation(description: "wrTest")
        let timeout = 15 as TimeInterval
        WRDALHttpClient.request("https://goo.com.cn",
                                parameters:nil,
                                formatterHandler: { (response) -> WRBasicModel in
                                    return WRBasicModel("zzzz-zzzz-zzzz")
        }, successHandler: { (model) in
        }) { (error) in
            XCTAssertTrue(error != nil)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
