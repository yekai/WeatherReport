//
//  ViewController.swift
//  WeatherReport
//
//  Created by Ice on 2019/7/20.
//  Copyright © 2019 testOrg. All rights reserved.
//

import UIKit
import iOSDropDown

class WRMainViewController: UIViewController {
    @IBOutlet weak var weatherTitleLbl: UILabel!
    @IBOutlet weak var weatherInfoTable: UITableView!
    @IBOutlet weak var maincityListDropDown: DropDown!
    var currentDisplayedWeatherModel: WRDALModel?
    var currentDisplayedCityModel: WRCityModel?

    var cityList:[WRCityModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        requestCityList()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if !maincityListDropDown.isHidden {
            maincityListDropDown.hideListWithoutAnimation()
        }
    }
    
    func commonInit() {
        title = WRLocalizeMgr.localize("com.main.title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCity))
        weatherInfoTable.isHidden = true
        weatherInfoTable.isScrollEnabled = false
        weatherInfoTable.tag = kWeatherReportTableViewInfoTag
        weatherInfoTable.rowHeight = CGFloat(kWeatherReportTableViewCellHeight)
        self.edgesForExtendedLayout = []
        self.navigationController?.navigationBar.isTranslucent = false;
        initConstraints()
    }
    
    func initConstraints() {
        weatherTitleLbl.mas_makeConstraints{ (make) in
            make?.centerX.offset()(0)
            make?.height.offset()(50)
            make?.top.offset()(0)
        }
        maincityListDropDown.mas_makeConstraints { (make) in
            make?.centerX.offset()(0)
            make?.height.offset()(40)
            make?.top.equalTo()(weatherTitleLbl)?.offset()(50)
            make?.leading.offset()(40)
        }
        weatherInfoTable.mas_makeConstraints { (make) in
            make?.centerX.offset()(0)
            make?.height.offset()(180)
            make?.top.equalTo()(maincityListDropDown)?.offset()(50)
            make?.leading.offset()(40)
        }
    }
    
    @objc func addCity() {
        let title = WRLocalizeMgr.localize("com.main.warning")
        let content = WRLocalizeMgr.localize("com.main.addCity.content")
        let alertController = UIAlertController(title: title, message: content, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Go", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func requestCityList() {
        cityList = WRDALManager.sharedInstance.requestSupportedCityList()
        if let cityList = cityList {
            var cityValues: [String] = [String]()
            for cityModel in cityList {
                cityValues.append(cityModel.displayedCityName())
            }
            maincityListDropDown.optionArray = cityValues
            maincityListDropDown.checkMarkEnabled = false
            maincityListDropDown.isSearchEnable = false
            maincityListDropDown.selectedRowColor = UIColor.init(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1)
            maincityListDropDown.didSelect { (selectedText, index, id) in
                self.requestWeatherInfo(index)
            }
            maincityListDropDown.arrowSize = 10
        }
    }
    
    func requestWeatherInfo(_ selectedIndex:Int) {
        if let cityList = cityList, cityList.count > selectedIndex {
            currentDisplayedCityModel = cityList[selectedIndex]
            if let cityName = currentDisplayedCityModel?.cityName {
                WRDALManager.sharedInstance.request(weatherInfo: cityName, successHandler: { (model) in
                    self.currentDisplayedWeatherModel = model as? WRDALModel
                    self.weatherInfoTable.isHidden = false
                    self.weatherInfoTable.reloadData()
                }) { (error) in
                    self.showNetworkUnavailable()
                }
            }
        }
    }
    
    func showNetworkUnavailable() {
        currentDisplayedWeatherModel = nil
        self.weatherInfoTable.isHidden = true
        self.weatherInfoTable.reloadData()
        let title = WRLocalizeMgr.localize("com.main.warning")
        let content = WRLocalizeMgr.localize("com.main.warning.network.unavailable")
        let alertController = UIAlertController(title: title, message: content, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Go", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension WRMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDisplayedWeatherModel?.displayedKeys().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentDisplayedWeatherModel = currentDisplayedWeatherModel, let cityKeyValue = currentDisplayedCityModel?.displayedCityName() {
            let displayedKeys = currentDisplayedWeatherModel.displayedKeys()
            let onOfflineMode =  WRLocalizeMgr.localize(currentDisplayedWeatherModel.successModel ? "com.main.weather.value.onlineMode" : "com.main.weather.value.offlineMode")
            let displayedValues = currentDisplayedWeatherModel.displayedValues(onOfflineMode, cityDisplayedValue: cityKeyValue)
            let weatherInfoCell: WeatherInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: kWeatherReportCellIdentifier) as! WeatherInfoTableViewCell
            weatherInfoCell.weatherKeylabel.text = displayedKeys[indexPath.row]
            weatherInfoCell.weatherContentLabel.text = displayedValues[indexPath.row]
            return weatherInfoCell
        }
        return UITableViewCell()
    }
}
