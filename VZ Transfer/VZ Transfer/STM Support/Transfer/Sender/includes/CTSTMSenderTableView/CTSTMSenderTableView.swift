//
//  CTSTMSenderTableView.swift
//  contenttransfer
//
//  Created by Zhang, Yichun on 4/19/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

class CTSTMSenderTableView: UITableView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.tableFooterView != nil
        {
            tableFooterView?.frame = CGRect(x: 0, y: self.frame.size.height - (tableFooterView?.frame.size.height)!, width: self.frame.size.width, height: (tableFooterView?.frame.size.height)!);
        }
    }
}
