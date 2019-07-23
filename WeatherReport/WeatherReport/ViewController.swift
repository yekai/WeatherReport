//
//  ViewController.swift
//  WeatherReport
//
//  Created by Ice on 2019/7/20.
//  Copyright © 2019 testOrg. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        request()
    }
    
    func request() {
//        WRDALFactory().request(weatherInfo: "Sydney", successHandler: { (model) in
//
//        }) { (error) in
//
//        }
        let manager = WRDALManager.sharedInstance
        manager.saveLocalCityList()
    }

}

