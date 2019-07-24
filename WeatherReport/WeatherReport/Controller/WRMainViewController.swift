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
    
    var presenter: WRMainViewPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
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
        
        presenter = WRMainViewPresenter()
        
        initConstraints()
        configureDropDownCityList()
        
        self.edgesForExtendedLayout = []
        self.navigationController?.navigationBar.isTranslucent = false;
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
    
    func configureDropDownCityList() {
        maincityListDropDown.optionArray = presenter!.displayedCityList
        maincityListDropDown.checkMarkEnabled = false
        maincityListDropDown.isSearchEnable = false
        maincityListDropDown.selectedRowColor = UIColor.init(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1)
        maincityListDropDown.didSelect { (selectedText, index, id) in
            self.requestWeatherInfo(index)
        }
        maincityListDropDown.arrowSize = 20
    }
    
    func requestWeatherInfo(_ selectedIndex:Int) {
        presenter?.requestWeatherInfo(selectedIndex: selectedIndex,
                                     successHandler: {
                                        self.weatherInfoTable.isHidden = false
                                        self.weatherInfoTable.reloadData()
        },
                                     failureHandler: { (error) in
                                        self.showNetworkUnavailable()
        })
    }
    
    func showNetworkUnavailable() {
        presenter?.currentDisplayedWeatherModel = nil
        weatherInfoTable.isHidden = true
        weatherInfoTable.reloadData()
        
        let title = WRLocalizeMgr.localize("com.main.warning")
        let content = WRLocalizeMgr.localize("com.main.warning.network.unavailable")
        let alertController = UIAlertController(title: title, message: content, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Go", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension WRMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter!.numberOfWeatherRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let displayedKeys = presenter?.currentDisplayedWeatherKeys, let displayedValues = presenter?.currentDisplayedWetherValues {
            let weatherInfoCell: WeatherInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: kWeatherReportCellIdentifier) as! WeatherInfoTableViewCell
            weatherInfoCell.configureValue(forCell: displayedKeys[indexPath.row],
                                           value: displayedValues[indexPath.row],
                                           highlight: !presenter!.doesWcurrentWeatherDataFromRemote &&
                                                        indexPath.row == 0)
            return weatherInfoCell
        }
        return UITableViewCell()
    }
}
