//
//  CTSingleChoiceTableViewCell.swift
//  contenttransfer
//
//  Created by Sun, Xin on 4/21/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

/**
    Cell for user choosing one to many transfer flow.
 
    This cell will contain one main text label and one circle selection indicator.
 */
class CTSingleChoiceTableViewCell: UITableViewCell {
    /** ImageView for circle selection indicator. This is IBOutlet object.*/
    @IBOutlet weak var checkBoxImage: UIImageView!
    /** Main label for table view cell. This is IBOutlet object.*/
    @IBOutlet weak var cellLabel: CTBoldFontLabel!
    @IBOutlet weak var cellSubLabel: CTRomanFontLabel!
    
    // MARK: - UITableViewCell life cycle.
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.isUserInteractionEnabled = true
        self.selectionStyle = .none
        self.checkBoxImage.image = UIImage.getImageFromBundle(withImageName:"oval25Copy3")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for subView in (self.contentView.superview?.subviews)! {
            if (String(describing: subView).hasSuffix("SeparatorView")) {
                subView.isHidden = false
            }
        }
    }
    
    // MARK: - Public APIs
    /**
     Hightlight the current cell when user select it.
     - parameters:
        - highlight: Bool value indicate that this cell is hightlighted or not.
     */
    func highlightCell(_ highlight: Bool) {
        if (highlight) {
            self.checkBoxImage.image = UIImage.getImageFromBundle(withImageName: "RadioButtonChecked")
        } else {
            self.checkBoxImage.image = UIImage.getImageFromBundle(withImageName: "oval25Copy3")
        }
    }
    /**
     Change user interaction enable status for current table view cell.
     - parameters:
        - shouldEnable: Bool vlaue indicate that current cell should be enable or not.
     */
    func enableUserInteraction(_ shouldEnable: Bool) {
        self.isUserInteractionEnabled = shouldEnable
    }
}
