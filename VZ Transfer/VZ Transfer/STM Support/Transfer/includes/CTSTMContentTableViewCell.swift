//
//  CTSTMContentTableViewCell.swift
//  contenttransfer
//
//  Created by Zhang, Yichun on 3/24/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

class CTSTMContentTableViewCell: UITableViewCell {
    
    public var label_right:UILabel! = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        label_right = UILabel(frame: .zero)
        label_right.textAlignment = .right
        label_right.font = CTMVMFonts.mvmBookFont(ofSize: 12)
        
        self.addSubview(label_right);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var defaultTrailing: CGFloat = 16
        if #available(iOS 8.0, *) {
            defaultTrailing = self.contentView.layoutMargins.right
        }
        
        self.imageView?.frame = CGRect(x: 20, y: (self.frame.size.height - 24)/2, width: 24, height: 24)
        
        if label_right.text?.count == 0
        {
            label_right.frame = .zero
        }
        else
        {
            label_right.sizeToFit()
            
            label_right.frame = CGRect(
                x: self.frame.size.width - label_right.frame.size.width - defaultTrailing,
                y: ((self.textLabel?.frame.origin.y)! + (self.textLabel?.frame.height)! + 1),
                width: label_right.frame.size.width,
                height: label_right.frame.size.height)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        if(selected)
        {
            self.imageView?.image = UIImage.getImageFromBundle(withImageName: "36PxNavigationConfirmationAKQAOLD")
        }
        else
        {
            self.imageView?.image = UIImage.getImageFromBundle(withImageName: "oval25Copy3")
        }
        
    }
    
    func highlightCell(highlight:Bool)
    {
        if(highlight)
        {
            self.imageView?.image = UIImage.getImageFromBundle(withImageName: "36PxNavigationConfirmationAKQAOLD")
        }
        else
        {
            self.imageView?.image = UIImage.getImageFromBundle(withImageName: "oval25Copy3")
        }
    }

}
