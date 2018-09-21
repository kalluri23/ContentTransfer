//
//  CTSTMRecapTableViewCell.swift
//  contenttransfer
//
//  Created by Zhang, Yichun on 4/26/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

class CTSTMRecapTableViewCell: UITableViewCell {

    public var label_name:UILabel! = nil
    public var label_numprogress:UILabel! = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label_name = UILabel(frame: .zero);
        label_name.textAlignment = .left
        label_name.font = CTMVMFonts.mvmBoldFont(ofSize: 15)
        
        label_numprogress = UILabel(frame: .zero)
        label_numprogress.textAlignment = .left
        label_numprogress.font = CTMVMFonts.mvmBookFont(ofSize: 13)
        
        
        self.addSubview(label_name)
        
        self.addSubview(label_numprogress)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gap = 10
        
        let h = 25
        
        var yoffset = 10
        
        label_name.frame =   CGRect(x: gap , y: yoffset, width: Int(self.frame.size.width) - gap * 2 , height: h)
        
        yoffset = yoffset + h + gap
        
        yoffset += h + gap
        
        label_numprogress.frame = CGRect(
            x:gap,
            y:Int(self.frame.size.height - CGFloat(h)) - gap,
            width: Int(self.frame.size.width) - gap * 2,
            height: h)
        
        
        if self.accessoryView != nil
        {
            self.accessoryView?.frame = CGRect(
                x: self.frame.size.width - self.frame.size.height/2 - CGFloat(gap),
                y: (self.frame.size.height - self.frame.size.height/2)/2,
                width: self.frame.size.height/2,
                height: self.frame.size.height/2)
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }


}
