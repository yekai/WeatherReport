//
//  WRMainVMViewController.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/31.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit
import iOSDropDown
import SnapKit
import ReactiveCocoa
import ReactiveSwift

class WRMainVMViewController: WRBaseVMViewController {
    @IBOutlet weak var weatherTitleLbl: UILabel!
    //used to display weather info list for city, and alos can extend more information
    //while there are more requirements on this list
    @IBOutlet weak var weatherInfoTable: UITableView!
    //used to choose city which seems like the drop down in HTML
    @IBOutlet weak var maincityListDropDown: DropDown!
    //MVVM design pattern, ViewModel
    lazy var mainViewModel: WRMainViewModel = {
       return self.viewModel as! WRMainViewModel
    }()
    
    var taskManager: WRTimeTaskManager = WRTimeTaskManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskManager.fire()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        taskManager.invalidate()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //used to hide the pop choose selector while device rotate
        if !maincityListDropDown.isHidden {
            maincityListDropDown.hideListWithoutAnimation()
        }
    }
    
    override func setUpUI() {
        //navigation bar
        title = WRLocalizeMgr.localize("com.main.title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCity))
        //table view initial
        weatherInfoTable.isHidden = true
        weatherInfoTable.isScrollEnabled = false
        weatherInfoTable.tag = kWeatherReportTableViewInfoTag
        weatherInfoTable.rowHeight = CGFloat(kWeatherReportTableViewCellHeight)

        //configure all subviews' constraints
        initConstraints()
        //configure drop down selector
        configureDropDownCityList()
        //configure view controller layout guide
        self.edgesForExtendedLayout = []
        self.navigationController?.navigationBar.isTranslucent = false;
    }
    
    override func bindModel() {
        self.mainViewModel.requestSelectedIndexSignal.observe(on: UIScheduler()).observeValues { [weak self] (selectedIndex) in
            self?.mainViewModel.selectedIndex = selectedIndex
            self?.mainViewModel.requestShowHudObserver.send(value: 3)
            self?.mainViewModel.weatherReportActionSignalProducer.startWithResult {
                self?.mainViewModel.requestShowHudObserver.send(value: 4)
                if $0.error == nil && $0.value! {
                    //while we get the weather data, reload table view to display weather info
                    self?.weatherInfoTable.isHidden = false
                    self?.weatherInfoTable.reloadData()
                } else {
                    //this is the only error displayed for customer, need to do more work on
                    //the error
                    self?.showNetworkUnavailable()
                }
            }
        }
    }
    
    func initConstraints() {
        weatherTitleLbl.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
        }
        maincityListDropDown.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.leading.equalTo(40)
            make.height.equalTo(40)
            make.top.equalTo(weatherTitleLbl.snp.bottom)
        }
        weatherInfoTable.snp.makeConstraints { (make) in
            make.height.equalTo(180)
            make.centerX.equalToSuperview()
            make.top.equalTo(maincityListDropDown.snp.bottom).offset(10)
            make.leading.equalTo(40)
        }
    }
    
    /**
     * This is a later function that is used to add more cities for
     * our drop down city selector, all the added cities will be saved
     * in our database cache, and load them while the apps launches, now
     * we provide an alert for this function
     **/
    @objc func addCity() {
        let title = WRLocalizeMgr.localize("com.main.warning")
        let content = WRLocalizeMgr.localize("com.main.addCity.content")
        let alertController = UIAlertController(title: title, message: content, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Go", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func configureDropDownCityList() {
        maincityListDropDown.optionArray = mainViewModel.displayedCityList
        maincityListDropDown.checkMarkEnabled = false
        maincityListDropDown.isSearchEnable = false
        maincityListDropDown.selectedRowColor = UIColor(rgbValue: 0xC8C8C8)
        //drop down selector choose event, which is implemented from block
        maincityListDropDown.didSelect { (selectedText, index, id) in
           self.mainViewModel.requestSelectedIndexObserver.send(value: index)
        }
        maincityListDropDown.arrowSize = 20
    }
    
    func showNetworkUnavailable() {
        mainViewModel.currentDisplayedWeatherModel = nil
        weatherInfoTable.isHidden = true
        weatherInfoTable.reloadData()
        
        let title = WRLocalizeMgr.localize("com.main.warning")
        let content = WRLocalizeMgr.localize("com.main.warning.network.unavailable")
        let alertController = UIAlertController(title: title, message: content, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Go", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
    
extension WRMainVMViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainViewModel.numberOfWeatherRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let displayedKeys = mainViewModel.currentDisplayedWeatherKeys,
           let displayedValues = mainViewModel.currentDisplayedWetherValues {
            let weatherInfoCell = tableView.dequeueReusableCell(withIdentifier: kWeatherReportCellIdentifier) as! WeatherInfoTableViewCell
            weatherInfoCell.configureValue(forCell: displayedKeys[indexPath.row],
                                           value: displayedValues[indexPath.row],
                                           highlight: !mainViewModel.doescurrentWeatherDataFromRemote &&
                                            indexPath.row == 0)
            return weatherInfoCell
        }
        return UITableViewCell()
    }
}
