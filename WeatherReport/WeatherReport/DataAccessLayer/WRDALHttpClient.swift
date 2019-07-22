//
//  WRDALHttpClient.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/22.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit
import Alamofire

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
                          encoding: URLEncoding.default ,
                          headers: headers)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    let basicModel: WRBasicModel = formatterHandler(response.result.value)
                    successHandler(basicModel)
                case .failure:
                    failureHandler(response.result.error)
                }
        }
    }
}
