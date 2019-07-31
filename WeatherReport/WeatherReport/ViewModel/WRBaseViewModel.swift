//
//  MRBaseViewModel.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/31.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit
import Result
import ReactiveCocoa
import ReactiveSwift

class WRBaseViewModel: NSObject {
    var params: [String: AnyObject]?
    
    let (requestShowHudSignal, requestShowHudObserver) = Signal<Int, NoError>.pipe()
    let (requestCommonErrorSignal, requestCommonErrorObserver) = Signal<WRRequestCommonError, NoError>.pipe()
    
    override init() {
        super.init()
        initialBind()
    }
    
    convenience init(params: [String: AnyObject]) {
        self.init()
        self.params = params
    }
    
    func initialBind() {}
}
