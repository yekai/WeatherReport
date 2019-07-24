//
//  WeatherInfoTableViewCell.swift
//  WeatherReport
//
//  Created by LonchIT on 2019/7/23.
//  Copyright © 2019年 testOrg. All rights reserved.
//

import UIKit

class WeatherInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var weatherKeylabel: UILabel!
    @IBOutlet weak var weatherContentLabel: UILabel!
    
    /**
     * display cell info
     * key: key info, for example: city Name
     * value: value infom for example: Sydney
     * highlight: whether highlight this row since it will be more important info
     **/
    func configureValue(forCell key: String, value: String, highlight: Bool) {
        weatherKeylabel.text = key
        weatherContentLabel.text = value
        let color = highlight ? UIColor.red : UIColor.black
        weatherKeylabel.textColor = color
        weatherContentLabel.textColor = color
    }
}
