//
//  WRDALHttpClient.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/22.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit
import Alamofire

/**
 * This is a deep network layer for our apps
 * which is used to get remote data through Alamofire
 * and then transform the json data to one WRBasicModel
 * success handler and fail handler can deal with this model
 * directly
 **/
class WRDALHttpClient {
    class func request(_ url: String,
                       method: HTTPMethod = .get,
                       parameters: Parameters? = nil,
                       headers: HTTPHeaders? = nil,
                       formatterHandler: @escaping (Any?) -> WRBasicModel,
                       successHandler: @escaping (WRBasicModel) -> Void,
                       failureHandler: @escaping (Error?) -> Void) {
        Alamofire.request(url,
                          method: method,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: headers)
            .responseJSON { (response) in
                response.result.withValue({ (value) in
                    successHandler(formatterHandler(value))
                }).withError({ (error) in
                    failureHandler(error)
                })
        }
    }
}
