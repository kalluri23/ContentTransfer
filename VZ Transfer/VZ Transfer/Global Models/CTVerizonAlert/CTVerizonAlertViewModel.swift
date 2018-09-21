//
//  CTVerizonAlertViewModel.swift
//  contenttransfer
//
//  Created by Kalluri, Krishna on 8/2/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

/// This class creates model object that will be used by Verizon Alert create factory methods
@objc public class CTVerizonAlertViewModel: NSObject {
    
    /**
     Alert syle that specifies number of buttons on the custom alert
     
     - singleButton: Alert that contains only a single button
     - doubleButton: Alert that contains two buttons on it , cancel action is assigned to left button
     - tripleButton: Alert that contains three buttons on it
    */
    
    @objc public enum VZWAlertStyle: Int {
        case singleButton
        case doubleButton
        case tripleButton
    }
    
    public var alertStyle: VZWAlertStyle
    public var alertinfoImage: UIImage?
    public var alertTitle: String?
    public var alertBody: String?
    public var attributedAlertTitle: NSAttributedString?
    public var attributedAlertBody: NSAttributedString?
    public var alertPrimaryButtonTitle: String?
    public var alertSecondaryButtonTitle: String?
    public var alertTeritioryButtonTitle: String?
    public var primaryButtonAction:((_ alertVC: CTVerizonAlertViewController) -> Void)?
    public var secondaryButtonAction:((_ alertVC: CTVerizonAlertViewController) -> Void)?
    public var teritioryButtonAction:((_ alertVC: CTVerizonAlertViewController) -> Void)?

    /**
      Initializes a custom style alert object with attributed title and body.
    - parameters:
        - alertStyle: VZWAlertStyle that signifies number of buttons on custom alert
        - alertinfoImage: Image in the alert title of custom alert
        - alertTitle: alert title text - String
        - alertBody: alert body text - String
        - alertPrimaryButtonTitle: first button title text
        - primaryButtonAction: first button action closure - nil closure dismisses the alert
        - alertSecondaryButtonTitle: second button title text
        - secondaryButtonAction: second button action closure - nil closure dismisses the alert
        - alertTeritioryButtonTitle: third button title text
        - teritioryButtonAction: third button action closure - nil closure dismisses the alert
    */
    
    
    @objc(initWithAlertStyle:alertinfoImage:alertTitle:alertBody:alertPrimaryButtonTitle:primaryButtonAction:alertSecondaryButtonTitle:secondaryButtonAction:alertTeritioryButtonTitle:teritioryButtonAction:)
    
    required public init(alertStyle: VZWAlertStyle, alertinfoImage: UIImage?, alertTitle: String?, alertBody: String?, alertPrimaryButtonTitle: String?, primaryButtonAction: ((_ alertVC: CTVerizonAlertViewController) -> Void)?, alertSecondaryButtonTitle: String?, secondaryButtonAction: ((_ alertVC: CTVerizonAlertViewController) -> Void)?, alertTeritioryButtonTitle: String?, teritioryButtonAction : ((_ alertVC: CTVerizonAlertViewController) -> Void)?) {
        self.alertStyle = alertStyle
        self.alertTitle = alertTitle
        self.alertBody = alertBody
        self.alertPrimaryButtonTitle = alertPrimaryButtonTitle
        self.alertSecondaryButtonTitle = alertSecondaryButtonTitle
        self.alertTeritioryButtonTitle = alertTeritioryButtonTitle
        self.alertinfoImage = alertinfoImage
        self.primaryButtonAction = primaryButtonAction
        self.secondaryButtonAction = secondaryButtonAction
        self.teritioryButtonAction = teritioryButtonAction
    }
    
    /**
     Initializes a custom style alert object with title and body.
     - parameters:
        - alertStyle: VZWAlertStyle that signifies number of buttons on custom alert
        - alertinfoImage: Image in the alert title of custom alert
        - alertTitle: alert title text - Attributed String
        - alertBody: alert body text - Attributed String
        - alertPrimaryButtonTitle: first button title text
        - primaryButtonAction: first button action closure - nil closure dismisses the alert
        - alertSecondaryButtonTitle: second button title text
        - secondaryButtonAction: second button action closure - nil closure dismisses the alert
        - alertTeritioryButtonTitle: third button title text
        - teritioryButtonAction: third button action closure - nil closure dismisses the alert
     */
    
    @objc(initWithAlertStyle:alertinfoImage:attributedAlertTitle:attributedAlertBody:alertPrimaryButtonTitle:primaryButtonAction:alertSecondaryButtonTitle:secondaryButtonAction:alertTeritioryButtonTitle:teritioryButtonAction:)
    
    required public init(alertStyle: VZWAlertStyle, alertinfoImage: UIImage?, attributedAlertTitle: NSAttributedString?, attributedAlertBody: NSAttributedString?, alertPrimaryButtonTitle: String?, primaryButtonAction: ((_ alertVC: CTVerizonAlertViewController) -> Void)?, alertSecondaryButtonTitle: String?, secondaryButtonAction: ((_ alertVC: CTVerizonAlertViewController) -> Void)?, alertTeritioryButtonTitle: String?, teritioryButtonAction : ((_ alertVC: CTVerizonAlertViewController) -> Void)?) {
        self.alertStyle = alertStyle
        self.attributedAlertTitle = attributedAlertTitle
        self.attributedAlertBody = attributedAlertBody
        self.alertPrimaryButtonTitle = alertPrimaryButtonTitle
        self.alertSecondaryButtonTitle = alertSecondaryButtonTitle
        self.alertTeritioryButtonTitle = alertTeritioryButtonTitle
        self.alertinfoImage = alertinfoImage
        self.primaryButtonAction = primaryButtonAction
        self.secondaryButtonAction = secondaryButtonAction
        self.teritioryButtonAction = teritioryButtonAction
    }
    
    
}
