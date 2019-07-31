//
//  WRBaseVMViewController.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/31.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

class WRBaseVMViewController: UIViewController {

    var viewModel: WRBaseViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        bindModel()
        
        self.viewModel?.requestShowHudSignal.observe(on: UIScheduler()).observeValues { [weak self] (flag) in
            switch flag {
            case 1:
                self?.view.showHud()
            case 2:
                self?.view.hideHud()
            case 3:
                if let keyWindow = UIApplication.shared.keyWindow {
                    keyWindow.showHud()
                }
            case 4:
                if let keyWindow = UIApplication.shared.keyWindow {
                    keyWindow.hideHud()
                }
            default:
                break
            }
        }
        
        self.viewModel?.requestCommonErrorSignal.observe(on: UIScheduler()).observeValues { [weak self] (requestError) in
            if let error = requestError.error {
                if error.localizedDescription.contains("The request timed out") {
                    self?.view.showMessage("网络链接超时...")
                } else {
                    self?.view.showMessage("网络异常")
                }
            }
            
            if let result = requestError.resultData {
                if result.code == 600 {
                    //提示错误
                    self?.view.showMessage(result.msg)
                } else {
                    UIApplication.shared.keyWindow?.hideHud()
                }
            }
        };
    }
    
    func setUpUI() {}
    func bindModel() {}

}
