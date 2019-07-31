//
//  WRRequestCommonError.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/31.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

class WRResultData {
    var code: Int = -1
    var msg: String = ""
    var timestamp: Int = -1
}

class WRRequestCommonError: Swift.Error {
    var resultData: WRResultData?
    var error: Error?
    var abnormal: Bool?
    
    convenience init(error: Error) {
        self.init()
        self.error = error
    }
    
    convenience init(error: Error?, abnormal: Bool) {
        self.init()
        self.error = error
        self.abnormal = abnormal
    }
    
    convenience init(result: WRResultData) {
        self.init()
        self.resultData = result
    }
    
    convenience init(result: WRResultData, abnormal: Bool) {
        self.init()
        self.resultData = result
        self.abnormal = abnormal
    }
}
