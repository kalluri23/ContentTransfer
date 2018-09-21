//
//  CTAlertButton.swift
//  Alert
//
//  Created by Kalluri, Krishna on 8/3/17.
//  Copyright © 2017 verizonwireless. All rights reserved.
//

import UIKit

/// Buttons present on CTVerizonAlertViewController alerts are CTAlertButton type
public class CTAlertButton: UIButton {
    
    //MARK:- Initializer methods
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.configure()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    //MARK:- Private methods
    /**
     Configures button on CTVerizonAlertViewController, following are the style properties it applies to CTAlertButton
     - red border with 1.0 pt thickness
     - gray background with 0.1 aplha
     - center alignment of button title text with a mvm bold font syle
     - default content edge insets of (1, 10, 1, 10)
    */
    private func configure() {
        self.setTitleColor(UIColor.black, for: .normal)
        self.contentEdgeInsets = UIEdgeInsetsMake(1, 10, 1, 10)
        self.titleLabel?.font = CTMVMFonts.mvmBoldFont(ofSize: 13.0)
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 10.0
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.lineBreakMode = .byClipping
    }

}
