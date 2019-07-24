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
    
    func configureValue(forCell key: String, value: String, highlight: Bool) {
        weatherKeylabel.text = key
        weatherContentLabel.text = value
        let color = highlight ? UIColor.red : UIColor.black
        weatherKeylabel.textColor = color
        weatherContentLabel.textColor = color
    }
}
