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
    //used to display weather info list for city, and alos can extend more information
    //while there are more requirements on this list
    @IBOutlet weak var weatherInfoTable: UITableView!
    //used to choose city which seems like the drop down in HTML
    @IBOutlet weak var maincityListDropDown: DropDown!
    //MVP design pattern, Presenter
    var presenter: WRMainViewPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //used to hide the pop choose selector while device rotate
        if !maincityListDropDown.isHidden {
            maincityListDropDown.hideListWithoutAnimation()
        }
    }
    
    func commonInit() {
        //navigation bar
        title = WRLocalizeMgr.localize("com.main.title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCity))
        //table view initial
        weatherInfoTable.isHidden = true
        weatherInfoTable.isScrollEnabled = false
        weatherInfoTable.tag = kWeatherReportTableViewInfoTag
        weatherInfoTable.rowHeight = CGFloat(kWeatherReportTableViewCellHeight)
        //Presenter initial
        presenter = WRMainViewPresenter()
        //configure all subviews' constraints
        initConstraints()
        //configure drop down selector
        configureDropDownCityList()
        //configure view controller layout guide
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
        self.present(alertController, animated: true, completion: nil)
    }
    
    func configureDropDownCityList() {
        maincityListDropDown.optionArray = presenter!.displayedCityList
        maincityListDropDown.checkMarkEnabled = false
        maincityListDropDown.isSearchEnable = false
        maincityListDropDown.selectedRowColor = UIColor.init(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1)
        //drop down selector choose event, which is implemented from block
        maincityListDropDown.didSelect { (selectedText, index, id) in
            self.requestWeatherInfo(index)
        }
        maincityListDropDown.arrowSize = 20
    }
    
    func requestWeatherInfo(_ selectedIndex:Int) {
        //we can get the selected index fromdrop down selector, and then
        //we need to get the city name to receive the weather info from remote
        presenter?.requestWeatherInfo(selectedIndex: selectedIndex,
                                     successHandler: {
                                        //while we get the weather data, reload table view to display weather info
                                        self.weatherInfoTable.isHidden = false
                                        self.weatherInfoTable.reloadData()
        },
                                     failureHandler: { (error) in
                                        //this is the only error displayed for customer, need to do more work on
                                        //the error
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
                                           highlight: !presenter!.doescurrentWeatherDataFromRemote &&
                                                        indexPath.row == 0)
            return weatherInfoCell
        }
        return UITableViewCell()
    }
}
