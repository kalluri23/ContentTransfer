//
//  CTSTMDeviceTableViewCell.swift
//  contenttransfer
//
//  Created by Zhang, Yichun on 3/22/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

class CTSTMDeviceTableViewCell: UITableViewCell {
    
    public var label_name:UILabel! = nil
    public var label_status:UILabel! = nil
    public var label_sizeprogress:UILabel! = nil
    public var label_numprogress:UILabel! = nil
    public var progress:CTProgressView! = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label_name = UILabel(frame: .zero);
        label_name.textAlignment = .left
        label_name.font = CTMVMFonts.mvmBoldFont(ofSize: 13)
        
        label_status = UILabel(frame: .zero);
        label_status.textAlignment = .right
        
        label_sizeprogress = UILabel(frame: .zero);
        label_sizeprogress.textAlignment = .right
        label_sizeprogress.font = CTMVMFonts.mvmBookFont(ofSize: 12)
        
        label_numprogress = UILabel(frame: .zero)
        label_numprogress.textAlignment = .center
        label_numprogress.font = CTMVMFonts.mvmBookFont(ofSize: 12)
        
        progress = CTProgressView(frame: .zero)
        progress.trackColor = CTColor.mvmBackgroundGrayColor2()
        progress.progressColor = CTColor.progressGreen()
        
        self.addSubview(progress)
        
        self.addSubview(label_name)
        
        self.addSubview(label_status)
        
        self.addSubview(label_sizeprogress)

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
        


        label_sizeprogress.frame = CGRect(x: Int(self.frame.size.width / 2) , y: yoffset, width: Int(self.frame.size.width/2) - gap, height: h)
        
        yoffset += h + gap
        
        label_status.frame = CGRect(x:Int(self.frame.size.width * 2/3), y: Int(self.frame.size.height - CGFloat(h)), width: Int(self.frame.size.width/3), height: h)
        
        
        label_numprogress.frame = CGRect(x:gap,
                                         y:Int(self.frame.size.height - CGFloat(h)) - gap/2,
                                         width: Int(self.frame.size.width) - gap * 2,
                                         height: h)
        
        
        progress.frame = CGRect(x:gap,
                                y: Int(self.frame.size.height - CGFloat(h)) - gap/2,
                                width:Int(self.frame.size.width) - gap * 2 ,
                                height: Int(h))
        
        if self.accessoryView != nil
        {
            self.accessoryView?.frame = CGRect(x: self.frame.size.width - CGFloat(gap) - self.frame.size.height/2,
                                               y: 10,
                                               width: self.frame.size.height/2 - 5,
                                               height: self.frame.size.height/2 - 5)
        }

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
