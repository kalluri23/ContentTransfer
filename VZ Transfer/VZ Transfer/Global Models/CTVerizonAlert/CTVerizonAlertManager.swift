//
//  CTVerizonAlertManager.swift
//  contenttransfer
//
//  Created by Kalluri, Krishna on 8/2/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import Foundation
import UIKit

/// This is the manager object for all custom verizon Alerts. Contains logic to show and dismiss alert.
@objc public class CTVerizonAlertManager: NSObject {
    
    //MARK:- Show Methods
    
    /**
     Shows custom alert by creating custom alert view controller form alert model object
     - parameters:
        - viewController: viewController on which alert needs to be presented
        - alertModel: custom alert model object that is used to create view controller object
    */
    
    @objc (showVerizonAlertfrom:alertModel:)
    static public func showVerizonAlert(from viewController: UIViewController, alertModel: CTVerizonAlertViewModel) {
        
        let alertViewController = CTVerizonAlertViewController(alertModel: alertModel)
        alertModelLogic(alertViewController: alertViewController, from: viewController, alertModel: alertModel)
    }
    
    /**
     Shows custom alert by creating custom alert view controller form alert model object
     - parameters:
        - viewController: viewController on which alert needs to be presented
        - alertModel: custom alert model object that is used to create view controller object
        - completion: Alert view controller object is returned inside this closure, in order to carry on any custom actions once the alert view controller presentation is completed
     */
    
    static public func showVerizonAlert(from viewController: UIViewController, alertModel: CTVerizonAlertViewModel, completion: @escaping ((_ alertVC: CTVerizonAlertViewController) -> Void)) {
        
        let alertViewController = CTVerizonAlertViewController(alertModel: alertModel)
        alertModelLogic(alertViewController: alertViewController, from: viewController, alertModel: alertModel, completion: completion)
    }
    
    /**
     This function is responsible for configuring the presentation style and background of alert view controller that is presented modally on top of presenting view conroller
     - parameters:
        - alertViewController: alert viewController object that needs to be presented
        - viewController: viewController on which alert needs to be presented
        - alertModel:  alert model object that was used to configure alert viewcontroller.
            ## This parameter is currently unused.
        - completion: completion handler that is used to perform any custom actions once alert view controller presentation is completed. Alert View controller object is  supplied to this closure.
     */
    
    static private func alertModelLogic(alertViewController: CTVerizonAlertViewController, from viewController: UIViewController, alertModel: CTVerizonAlertViewModel, completion: ((_ alertVC: CTVerizonAlertViewController) -> Void)? = nil) {
        
        if #available(iOS 8.0, *) {
            alertViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        } else {
            alertViewController.modalPresentationStyle = UIModalPresentationStyle.currentContext
        }
        alertViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        alertViewController.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        alertViewController.alertBackgroundView.layer.cornerRadius = 10.0
        alertViewController.alertBackgroundView.layer.borderWidth = 0.75
        alertViewController.alertBackgroundView.layer.borderColor = UIColor.black.cgColor
        alertViewController.alertBackgroundView.clipsToBounds = true
        
        viewController.present(alertViewController, animated: true, completion: {
            completion?(alertViewController)
        })
    }
    
    //MARK:- Update Methods
    
    /**
     Updates custom alert body with the text provided to this function
     - parameters:
     - alert: alert viewController object that needs to be updated
     - text: text with which the alert body needs to be updated
     */
    
    @objc (updateAlertBodyOf:withText:)
    static public func updateAlertBody(ofAlert alert: CTVerizonAlertViewController, withText text:String){
        alert.alertBodyLabel.text = text
    }
    
    /**
     Dismisses alert view controller and provides alert view controller object inside completion handler
     - parameters:
        - alertViewController: alert viewController object that needs to be dismissed
        - completion: completion handler that is used to perform any custom actions once alert view controller dismissal is completed. Alert View controller object is  supplied to this closure.
    */
    
    
    //MARK:- Dismiss Methods
    @objc (dismissVerizonAlertViewController:completion:)
    static public func dismissVerizonAlert(alertViewController: CTVerizonAlertViewController, completion:(() -> Swift.Void)? = nil) {
        alertViewController.dismiss(animated: false, completion: completion)
    }
    
}
