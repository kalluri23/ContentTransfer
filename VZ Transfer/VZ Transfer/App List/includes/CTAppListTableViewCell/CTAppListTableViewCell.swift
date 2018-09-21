//
//  AppListTableViewCell.swift
//  test
//
//  Created by Sun, Xin on 4/4/17.
//  Copyright © 2017 Sun, Xin. All rights reserved.
//

import UIKit
/** Delegate for CTAppListTableViewCell.*/
protocol AppListTableViewCellDelegate {
    /**
     Call this method when "Get App" button clicked by user. **This method is mandatory**.
     - parameters:
        - appID: Integer value represents the index of the app in table view cell.
     */
    func getAppButtonDidClicked(appID: Int)
}

/** Custom tableview cell for app list.*/
class CTAppListTableViewCell: UITableViewCell {
    /** Delegate parameter for CTAppListTableViewCell. Default value is nil.*/
    var delegate: AppListTableViewCellDelegate?
    /** Blue color definition using after user clicked the "Get App" button.*/
    var blueButtonColor: UIColor = UIColor.init(red: 52/255.0, green: 107/255.0, blue: 217/255.0, alpha: 1)

    /** UIImageView for showing the icon of apps. This is IBOutlet object.*/
    @IBOutlet weak var appIcon: UIImageView!
    /** UILable for showing the name of apps. This is IBOutlet object.*/
    @IBOutlet weak var appNameLabel: UILabel!
    /** UIButton for starting search progress for apps. This is IBOutlet object.*/
    @IBOutlet weak var getAppButton: UIButton!
    
    // MARK: - UITableViewCell lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.appNameLabel.font = CTMVMFonts.mvmBookFont(ofSize: 12.0)
    }
    
    // MARK: - User Actions
    /**
     Action call when user click the button. This method will change the button color lighter to let user know they already clicked the button.
     
     Also delegate will be called to initiate the app searching progress.
     - parameters:
        - sender: UIButton object represents the button that triggered this event.
     */
    @IBAction func getAppButtonDidClicked(_ sender: UIButton) {
        self.getAppButton.setTitleColor(self.blueButtonColor.mixLighter(0.6), for: .normal) // Change to lighter button title color to indicate user that they clicked that row already
        
        delegate?.getAppButtonDidClicked(appID: sender.tag)
    }
}

extension UIColor {
    /**
     UIColor extension method. Try to make the color with same RGB code lighter by adding white value.
     - parameters:
        - amount: CGFloat value represents the scale of white need to be added into current color. Default value is 0.25(25%).
     - returns: UIColor with white added.
     */
    func mixLighter (_ amount: CGFloat = 0.25) -> UIColor {
        return mixWithColor(UIColor.white, amount:amount)
    }
    /**
     UIColor extension method. Try to make the color with same RGB code darker by adding black value.
     - parameters:
        - amount: CGFloat value represents the scale of black need to be added into current color. Default value is 0.25(25%).
     - returns: UIColor with black added.
     - SeeAlso: mixWithColor
     */
    func mixDarker (_ amount: CGFloat = 0.25) -> UIColor {
        return mixWithColor(UIColor.black, amount:amount)
    }
    /**
     Mix the current color with specific color.
     - parameters:
        - color: UIColor represents the color use to mix the current color.
        - amount: CGFloat valur represents the scale that target color needs to be mixed. Defaut value is 0.25(25%).
     - returns: New UIColor object for the new color created.
     */
    func mixWithColor(_ color: UIColor, amount: CGFloat = 0.25) -> UIColor {
        var r1     : CGFloat = 0
        var g1     : CGFloat = 0
        var b1     : CGFloat = 0
        var alpha1 : CGFloat = 0
        var r2     : CGFloat = 0
        var g2     : CGFloat = 0
        var b2     : CGFloat = 0
        var alpha2 : CGFloat = 0
        
        self.getRed (&r1, green: &g1, blue: &b1, alpha: &alpha1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &alpha2)
        return UIColor( red:r1*(1.0-amount)+r2*amount,
                        green:g1*(1.0-amount)+g2*amount,
                        blue:b1*(1.0-amount)+b2*amount,
                        alpha: alpha1 )
    }
}
