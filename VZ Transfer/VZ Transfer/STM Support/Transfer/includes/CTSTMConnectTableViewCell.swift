//
//  CTSTMConnectTableViewCell.swift
//  contenttransfer
//
//  Created by Zhang, Yichun on 4/11/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

class CTSTMConnectTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLabel?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height/2)
        
        self.detailTextLabel?.frame = CGRect(x: 0, y: self.frame.size.height/2, width: self.frame.size.width, height: self.frame.size.height/2)
    }

}
