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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
