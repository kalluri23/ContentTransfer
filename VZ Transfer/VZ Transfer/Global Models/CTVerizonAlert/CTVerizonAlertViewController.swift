//
//  CTVerizonAlertViewController.swift
//  contenttransfer
//
//  Created by Kalluri, Krishna on 8/2/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

/// This class creates Alert View Controller object that uses configuration from alert model object to style the layout on alert view controller that is presented modally on presenting view controller
@objc public class CTVerizonAlertViewController: UIViewController {
    
    //MARK:- Properties
    @IBOutlet weak var alertBackgroundView: UIView!
    @IBOutlet weak var alertinfoImageView: UIImageView!
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var alertBodyLabel: UILabel!
    @IBOutlet weak var alertButtonContainerView: UIView!
    @IBOutlet weak var primaryButton: CTAlertButton!
    @IBOutlet weak var secondaryButton: CTAlertButton!
    @IBOutlet weak var teritioryButton: CTAlertButton!
    
    //Constraint Outlets
    @IBOutlet weak var alertBackGroundViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertBackGroundViewTrialingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var prBtLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var hSpacingBwPrSecBtn: NSLayoutConstraint!
    @IBOutlet weak var hSpacingBwSecTrBtn: NSLayoutConstraint!
    @IBOutlet weak var prBtnCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var secBtnEqualWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var trBtnEqualWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var prBtnTrialingSpaceAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var secBtnLeadingSpaceAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var secBtnTrialingSpaceToContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak var primaryButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertTitleImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertTitleImageTrailingSpaceConstraint: NSLayoutConstraint!
    
    public var alertModel: CTVerizonAlertViewModel
    
    
    //MARK:- Initializer Methods
    required public init(alertModel: CTVerizonAlertViewModel) {
        self.alertModel = alertModel
        super.init(nibName: "CTVerizonAlertViewController", bundle: Bundle.init(for: CTVerizonAlertViewController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Life Cycle Methods
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.configureAlertFromAlertModel()
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //Reduce the size of button title text so that it accommidates three buttons on alert without clipping anything
        if self.alertModel.alertStyle == .tripleButton{
            self.primaryButton.titleLabel!.font = CTMVMFonts.mvmBoldFont(ofSize: 10.0)
            self.secondaryButton.titleLabel!.font = CTMVMFonts.mvmBoldFont(ofSize: 10.0)
            self.teritioryButton.titleLabel!.font = CTMVMFonts.mvmBoldFont(ofSize: 10.0)
            self.primaryButton.contentEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1)
            self.secondaryButton.contentEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1)
            self.teritioryButton.contentEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1)
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Private Methods
    
    /**
    On click of primary button, viewcontroller is dismissed first and action closure is executed on completion of viewcontroller dismiss
     - parameters:
        - sender: Primary button object
    */
    @objc(handlePrimaryButtonTapped:)
    private func handlePrimaryButtonTapped(_ sender: UIButton){
        CTVerizonAlertManager.dismissVerizonAlert(alertViewController: self) { 
            if self.alertModel.primaryButtonAction != nil {
                self.alertModel.primaryButtonAction!(self)
            }
        }
    }
    
    /**
     On click of secondary button, viewcontroller is dismissed first and action closure is executed on completion of viewcontroller dismiss
     - parameters:
        - sender: Secondary button object
     */
    @objc(handleSecondaryButtonTapped:)
    private func handleSecondaryButtonTapped(_ sender: UIButton){
        CTVerizonAlertManager.dismissVerizonAlert(alertViewController: self) { 
            if self.alertModel.secondaryButtonAction != nil {
                self.alertModel.secondaryButtonAction!(self)
            }
        }
    }
    
    /**
     On click of teritiary button, viewcontroller is dismissed first and action closure is executed on completion of viewcontroller dismiss
     - parameters:
        - sender: Teritiary button object
     */
    @objc(handleTeritioryButtonTapped:)
    private func handleTeritioryButtonTapped(_ sender: UIButton){
        CTVerizonAlertManager.dismissVerizonAlert(alertViewController: self) { 
            if self.alertModel.teritioryButtonAction != nil {
                self.alertModel.teritioryButtonAction!(self)
            }
        }
    }
    
    /**
     This function configures the layout of View controller by taking values of alert model object and constraints of auto layout
    */
    private func configureAlertFromAlertModel() {
        self.view.backgroundColor = UIColor.clear
        //Configure Alert title label and body label
        self.alertinfoImageView.image = self.alertModel.alertinfoImage
        self.alertTitleLabel.font = CTMVMFonts.mvmBoldFont(ofSize: 15.0)
        self.alertTitleLabel.textAlignment = .left
        self.alertBodyLabel.font = CTMVMFonts.mvmBookFont(ofSize: 13.0)
        self.alertBodyLabel.textAlignment = .center
        if let attributedTitle = self.alertModel.attributedAlertTitle,
            let attributedBody = self.alertModel.attributedAlertBody {
            self.alertTitleLabel.attributedText = attributedTitle
            self.alertBodyLabel.attributedText = attributedBody
        }else {
            self.alertTitleLabel.text = self.alertModel.alertTitle
            self.alertBodyLabel.text = self.alertModel.alertBody
        }
        //Set buttons with title and their associated actions
        self.primaryButton.setTitle(self.alertModel.alertPrimaryButtonTitle, for: .normal)
        self.primaryButton.addTarget(self, action: #selector(handlePrimaryButtonTapped), for: UIControlEvents.touchUpInside)
        self.secondaryButton.setTitle(self.alertModel.alertSecondaryButtonTitle, for: .normal)
        self.secondaryButton.addTarget(self, action: #selector(handleSecondaryButtonTapped), for: UIControlEvents.touchUpInside)
        self.teritioryButton.setTitle(self.alertModel.alertTeritioryButtonTitle, for: .normal)
        self.teritioryButton.addTarget(self, action: #selector(handleTeritioryButtonTapped), for: UIControlEvents.touchUpInside)
        //Manipulate constraints so that autolayout will accomodate buttons on the alert based on alert style
        switch self.alertModel.alertStyle {
        case .singleButton:
            self.primaryButtonWidthConstraint.constant = 80
            self.prBtLeadingSpaceConstraint.priority = UILayoutPriority(rawValue: 1.0)
            self.hSpacingBwPrSecBtn.priority = UILayoutPriority(rawValue: 1.0)
            self.hSpacingBwSecTrBtn.priority = UILayoutPriority(rawValue: 1.0)
            self.prBtnCenterXConstraint.priority = UILayoutPriority(rawValue: 999.0)
            self.secondaryButton.isHidden = true
            self.teritioryButton.isHidden = true
            self.secBtnEqualWidthConstraint.priority = UILayoutPriority(rawValue: 1.0)
            self.trBtnEqualWidthConstraint.priority = UILayoutPriority(rawValue: 1.0)
            self.alertBackGroundViewLeadingSpaceConstraint.constant = 40.0
            self.alertBackGroundViewTrialingSpaceConstraint.constant = 40.0
        case .doubleButton:
            self.primaryButtonWidthConstraint.constant = 60
            self.hSpacingBwSecTrBtn.priority = UILayoutPriority(rawValue: 1.0)
            self.trBtnEqualWidthConstraint.priority = UILayoutPriority(rawValue: 1.0)
            self.prBtnTrialingSpaceAlignmentConstraint.priority = UILayoutPriority(rawValue: 999.0)
            self.secBtnLeadingSpaceAlignmentConstraint.priority = UILayoutPriority(rawValue: 999.0)
            self.secBtnTrialingSpaceToContainerConstraint.priority = UILayoutPriority(rawValue: 999.0)
            self.alertBackGroundViewLeadingSpaceConstraint.constant = 40.0
            self.alertBackGroundViewTrialingSpaceConstraint.constant = 40.0
            self.hSpacingBwPrSecBtn.constant = 10.0
            self.prBtLeadingSpaceConstraint.constant = 20
            self.secBtnTrialingSpaceToContainerConstraint.constant = 20.0
            self.teritioryButton.isHidden = true
        case .tripleButton:
            self.primaryButtonWidthConstraint.constant = 40
            self.alertBackGroundViewLeadingSpaceConstraint.constant = 20.0
            self.alertBackGroundViewTrialingSpaceConstraint.constant = 20.0
            self.hSpacingBwPrSecBtn.constant = 10.0
            self.hSpacingBwSecTrBtn.constant = 10.0
            self.alertTitleImageWidthConstraint.constant = 0.0
            self.alertTitleImageTrailingSpaceConstraint.constant = 0.0
        }
    }
    
}
