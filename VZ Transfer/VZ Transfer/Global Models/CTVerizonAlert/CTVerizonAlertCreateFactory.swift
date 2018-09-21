//
//  CTVerizonAlertCreateFactory.swift
//  contenttransfer
//
//  Created by Kalluri, Krishna on 8/8/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

/// This class creates and shows custom verizon alerts with 1, 2 or 3 buttons on it using CTVerizonAlertModel object
@objc public class CTVerizonAlertCreateFactory: NSObject {
    
    /**
     Creates alert with three buttons. Method will create a alert and show on the current presenting view controller. No alert object will be returned. This implementation is similar to CTAlertCreateFactory class
     String value represents class name
     - parameters:
     - title: title text for alert.
     - context: context body text for alert.
     - primaryBtnText: primary button title text for button
     - secondaryBtnText: secondary button title text for button
     - teritiaryBtnText: teritiary button title text for button
     - primaryBtnHandler: primary button action closure
     - secondaryBtnHandler: primary button action closure
     - teritiaryBtnHandler: primary button action closure
     - isGreedy: this parameter is unused as of now. This is for future use to design greedy alerts similar to MVM alerts
     - viewController: presenting view controller
     */
    
    @objc(showThreeButtonsAlertAlertWithTitle:context:primaryBtnText:secondaryBtnText:teritiaryBtnText:primaryBtnHandler:secondaryBtnHandler:teritiaryBtnHandler:isGreedy:from:)
    
    public class func showThreeButtonsAlert(withTitle title: String,
                                            context: String,
                                            primaryBtnText: String,
                                            secondaryBtnText: String,
                                            teritiaryBtnText: String,
                                            primaryBtnHandler: ((_ alertVC: CTVerizonAlertViewController) -> Void)?,
                                            secondaryBtnHandler: ((_ alertVC: CTVerizonAlertViewController) -> Void)?,
                                            teritiaryBtnHandler: ((_ alertVC: CTVerizonAlertViewController) -> Void)?,
                                            isGreedy: Bool,
                                            from viewController: UIViewController) {
        
        DispatchQueue.main.async {
            let alertModel = CTVerizonAlertViewModel(alertStyle: .tripleButton, alertinfoImage: UIImage(named: "icon_infor"), alertTitle: title, alertBody: context, alertPrimaryButtonTitle: primaryBtnText, primaryButtonAction: {(alertVC: CTVerizonAlertViewController) in
                primaryBtnHandler?(alertVC)
            }, alertSecondaryButtonTitle: secondaryBtnText, secondaryButtonAction: {(alertVC: CTVerizonAlertViewController) in
                secondaryBtnHandler?(alertVC)
            }, alertTeritioryButtonTitle: teritiaryBtnText, teritioryButtonAction: {(alertVC: CTVerizonAlertViewController) in
                teritiaryBtnHandler?(alertVC)
            })
            CTVerizonAlertManager.showVerizonAlert(from: viewController, alertModel: alertModel)
        }
        
    }
    
    /**
     Creates alert with two buttons. Method will create a alert and show on the current presenting view controller. Alert View Controller will be returned in completion handler. This implementation is similar to CTAlertCreateFactory class
     String value represents class name
     - parameters:
     - title: title text for alert.
     - context: context body text for alert.
     - cancelBtnText: primary button title text for button
     - confirmBtnText: secondary button title text for button
     - confirmHandler: secondary button action closure
     - cancelHandler: primary button action closure
     - isGreedy: this parameter is unused as of now. This is for future use to design greedy alerts similar to MVM alerts
     - viewController: presenting view controller
     - completion: completion handler that tracks alert viewcontroller inside the closure
     */
    
    @objc(showTwoButtonsAlertWithTitle:context:cancelBtnText:confirmBtnText:confirmHandler:cancelHandler:isGreedy:from:completion:)
    
    public class func showTwoButtonsAlert(withTitle title: String,
                                          context: String,
                                          cancelBtnText: String,
                                          confirmBtnText: String,
                                          confirmHandler: ((_ alertVC: CTVerizonAlertViewController) -> Void)?,
                                          cancelHandler: ((_ alertVC: CTVerizonAlertViewController) -> Void)?,
                                          isGreedy: Bool,
                                          from viewController: UIViewController,
                                          completion: @escaping ((_ alertVC: CTVerizonAlertViewController) -> Void)) {
        
        DispatchQueue.main.async {
            let alertModel = CTVerizonAlertViewModel(alertStyle: .doubleButton, alertinfoImage: UIImage(named: "icon_infor"), alertTitle: title, alertBody: context, alertPrimaryButtonTitle: cancelBtnText, primaryButtonAction: {(alertVC: CTVerizonAlertViewController) in
                cancelHandler?(alertVC)
            }, alertSecondaryButtonTitle: confirmBtnText, secondaryButtonAction: {(alertVC: CTVerizonAlertViewController) in
                confirmHandler?(alertVC)
            }, alertTeritioryButtonTitle: nil, teritioryButtonAction: nil)
            
            CTVerizonAlertManager.showVerizonAlert(from: viewController, alertModel: alertModel, completion:completion)
        }
        
    }
    
    /**
     Creates alert with two buttons. Method will create a alert and show on the current presenting view controller. No alert object will be returned. This implementation is similar to CTAlertCreateFactory class
     String value represents class name
     - parameters:
     - title: title text for alert.
     - context: context body text for alert.
     - cancelBtnText: primary button title text for button
     - confirmBtnText: secondary button title text for button
     - confirmHandler: secondary button action closure
     - cancelHandler: primary button action closure
     - isGreedy: this parameter is unused as of now. This is for future use to design greedy alerts similar to MVM alerts
     - viewController: presenting view controller
     */
    
    @objc(showTwoButtonsAlertWithTitle:context:cancelBtnText:confirmBtnText:confirmHandler:cancelHandler:isGreedy:from:)
    
    public class func showTwoButtonsAlert(withTitle title: String,
                                          context: String,
                                          cancelBtnText: String,
                                          confirmBtnText: String,
                                          confirmHandler: ((_ alertVC: CTVerizonAlertViewController) -> Void)?,
                                          cancelHandler: ((_ alertVC: CTVerizonAlertViewController) -> Void)?,
                                          isGreedy: Bool,
                                          from viewController: UIViewController) {
        
        DispatchQueue.main.async {
            let alertModel = CTVerizonAlertViewModel(alertStyle: .doubleButton, alertinfoImage: UIImage(named: "icon_infor"), alertTitle: title, alertBody: context, alertPrimaryButtonTitle: cancelBtnText, primaryButtonAction: {(alertVC: CTVerizonAlertViewController) in
                cancelHandler?(alertVC)
            }, alertSecondaryButtonTitle: confirmBtnText, secondaryButtonAction: {(alertVC: CTVerizonAlertViewController) in
                confirmHandler?(alertVC)
            }, alertTeritioryButtonTitle: nil, teritioryButtonAction: nil)
            
            CTVerizonAlertManager.showVerizonAlert(from: viewController, alertModel: alertModel)
        }
        
    }
    
    /**
     Creates attributed alert with two buttons. Method will create a alert and show on the current presenting view controller. No alert object will be returned. This implementation is similar to CTAlertCreateFactory class
     - parameters:
     - title: attributed title text for alert.
     - context: attributed context body text for alert.
     - cancelBtnText: primary button title text for button
     - confirmBtnText: secondary button title text for button
     - confirmHandler: secondary button action closure
     - cancelHandler: primary button action closure
     - isGreedy: this parameter is unused as of now. This is for future use to design greedy alerts similar to MVM alerts
     - viewController: presenting view controller
     */
    
    @objc(showTwoButtonsAlertWithAttributedTitle:attributedContext:cancelBtnText:confirmBtnText:confirmHandler:cancelHandler:isGreedy:from:)
    
    public class func showTwoButtonsAlert(withAttributedTitle title: NSAttributedString,
                                          context: NSAttributedString,
                                          cancelBtnText: String,
                                          confirmBtnText: String,
                                          confirmHandler: ((_ alertVC: CTVerizonAlertViewController) -> Void)?,
                                          cancelHandler: ((_ alertVC: CTVerizonAlertViewController) -> Void)?,
                                          isGreedy: Bool,
                                          from viewController: UIViewController) {
        
        DispatchQueue.main.async {
            let alertModel = CTVerizonAlertViewModel(alertStyle: .doubleButton, alertinfoImage: UIImage(named: "icon_infor"), attributedAlertTitle: title, attributedAlertBody: context, alertPrimaryButtonTitle: cancelBtnText, primaryButtonAction: {(alertVC: CTVerizonAlertViewController) in
                cancelHandler?(alertVC)
            }, alertSecondaryButtonTitle: confirmBtnText, secondaryButtonAction: {(alertVC: CTVerizonAlertViewController) in
                confirmHandler?(alertVC)
            }, alertTeritioryButtonTitle: nil, teritioryButtonAction: nil)
            
            CTVerizonAlertManager.showVerizonAlert(from: viewController, alertModel: alertModel)
        }
        
    }
    
    /**
     Create alert with single button. Method will create a alert and show on the current presenting view controller. Alert View Controller will be returned in completion handler.
     - parameters:
     - title: attributed title text for alert.
     - context: attributed context body text for alert.
     - btnText: btnText title text for button
     - handler: handler closure to define the operation after user click button.
     - isGreedy: Bool value represents the way of showing the alert. true means no matter there is an alert showing or not. Always try to show current alert on top of the view structure. false means current alert will go into a queue and wait for other alert to dimiss. This parameter is unused as of now
     - viewController: presenting view controller
     - completion: completion handler that tracks alert viewcontroller inside the closure
     */
    
    @objc(showSingleButtonsAlertWithTitle:context:btnText:handler:isGreedy:from:completion:)
    
    public class func showSingleButtonsAlert(withTitle title: String,
                                             context: String,
                                             btnText: String,
                                             handler: ((_ alertVC: CTVerizonAlertViewController) -> Void)?,
                                             isGreedy: Bool,
                                             from viewController: UIViewController,
                                             completion: @escaping ((_ alertVC: CTVerizonAlertViewController) -> Void)) {
        DispatchQueue.main.async {
            let alertModel = CTVerizonAlertViewModel(alertStyle: .singleButton, alertinfoImage: UIImage(named: "icon_infor"), alertTitle: title, alertBody: context, alertPrimaryButtonTitle: btnText, primaryButtonAction: {(alertVC: CTVerizonAlertViewController) in
                handler?(alertVC)
            }, alertSecondaryButtonTitle: nil, secondaryButtonAction: nil, alertTeritioryButtonTitle: nil, teritioryButtonAction: nil)
            
            CTVerizonAlertManager.showVerizonAlert(from: viewController, alertModel: alertModel, completion:completion)
        }
    }
    
    /**
     Creates an alert with single button. Method will create a alert and show on the current presenting view controller. No alert object will be returned. This implementation is similar to CTAlertCreateFactory class
     - parameters:
     - title: title text for alert
     - context: context body text for alert
     - btnText: btnText title text for button
     - handler: handler closure to define the operation after user click button.
     - isGreedy: Bool value represents the way of showing the alert. true means no matter there is an alert showing or not. Always try to show current alert on top of the view structure. false means current alert will go into a queue and wait for other alert to dimiss. This parameter is unused as of now
     - viewController: presenting view controller
     */
    
    @objc(showSingleButtonsAlertWithTitle:context:btnText:handler:isGreedy:from:)
    
    public class func showSingleButtonsAlert(withTitle title: String,
                                             context: String,
                                             btnText: String,
                                             handler: ((_ alertVC: CTVerizonAlertViewController) -> Void)?,
                                             isGreedy: Bool,
                                             from viewController: UIViewController) {
        DispatchQueue.main.async {
            let alertModel = CTVerizonAlertViewModel(alertStyle: .singleButton, alertinfoImage: UIImage(named: "icon_infor"), alertTitle: title, alertBody: context, alertPrimaryButtonTitle: btnText, primaryButtonAction: {(alertVC: CTVerizonAlertViewController) in
                handler?(alertVC)
            }, alertSecondaryButtonTitle: nil, secondaryButtonAction: nil, alertTeritioryButtonTitle: nil, teritioryButtonAction: nil)
            
            CTVerizonAlertManager.showVerizonAlert(from: viewController, alertModel: alertModel)
        }
    }
    
    
}

