//
//  CTSTMRecvScannerViewController.swift
//  contenttransfer
//
//  Created by Sun, Xin on 4/13/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit
import CoreBluetooth
import AVFoundation

@objc class CTSTMRecvScannerViewController: CTViewController, CBCentralManagerDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var viewPreview: UIView!
    @IBOutlet weak var secondaryLabel: CTRomanFontLabel!
    
    // MARK: - Varables
    private var hasWifiErr          = false
    private var hasBlueToothErr     = false
    private var somethingChanged    = true
//    private var startScanning       = false
//    private var stopScanning        = false
//    private var moreCodeAlertShowed = false
    private var firstLoad           = false
    
    private var checkPassed         : NSInteger = 0
//    private var onlyOneBarCodeCount : NSInteger = 0
    
//    private static let CTOnlyOneBarCodeLimit    = 15
    
//    private var captureSession    : AVCaptureSession?
//    private var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    private var centralManager    : CBCentralManager?
//    private var hightlightView    : UIView?
    private var scanner: CTQRScanner = CTQRScanner.shared()
    
    private var tempActivityIndicator : CTProgressHUD?
    private lazy var activityIndicator : CTProgressHUD = {
        if (self.tempActivityIndicator == nil) {
            self.tempActivityIndicator = CTProgressHUD.init(view: self.view)
        }
        
        if(!self.view.subviews.contains(self.tempActivityIndicator!)) {
            self.view.addSubview(self.tempActivityIndicator!)
            self.view.bringSubview(toFront: self.tempActivityIndicator!)
        }
        
        return self.tempActivityIndicator!
    }()

    // MARK: - Life Cycle
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.firstLoad = true
        
#if STANDALONE
        self.setNavigationControllerMode(CTNavigationControllerMode.none)
#else
        self.setNavigationControllerMode(CTNavigationControllerMode.backAndHamburgar)
#endif
        self.navigationItem.title = CTLocalizedString(CT_WIFI_SETUP_VC_NAV_TITLE, comment: "")
        
        self.transferFlow = .receiver // always be receiver side
        
        self.viewPreview.isHidden = true
        self.secondaryLabel.isHidden = true
        
        self.scanner.enableScannerforTarget(self.viewPreview)
        self.scanner.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // UI adaptation
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (self.firstLoad) {
            self.firstLoad = false
            self.disableUserInteraction()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkWifiConnectionAgain), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAllCheck), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        if (CTDeviceMarco.isiPhone4AndBelow()) {
            self.hasWifiErr = false
        } else if (!CTNetworkUtility.isWiFiEnabled()) { // WiFi is not enabled
            self.hasWifiErr = true
        }
        
        self.checkPassed += 1
        
        // Test bluetooth status
        if (self.centralManager == nil) {
            self.centralManager = CBCentralManager.init(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:0])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Selectors
    @objc private func checkWifiConnectionAgain() {
        self.disableUserInteraction()
        
        if (!CTDeviceMarco.isiPhone4AndBelow()) {
            if (!CTNetworkUtility.isWiFiEnabled()) {
                if (!self.hasWifiErr) {
                    self.somethingChanged = true
                }
                self.hasWifiErr = true
            } else {
                if (self.hasWifiErr) {
                    self.somethingChanged = true
                }
                self.hasWifiErr = false
            }
        } else {
            self.hasWifiErr = false
        }
        
        self.checkPassed += 1
        print("WiFi error: \(self.hasWifiErr)")
        
        // Test bluetooth status
        if (self.centralManager == nil) {
            self.centralManager = CBCentralManager.init(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:0])
        }
    }
    
    @objc private func removeAllCheck() {
        if (self.centralManager != nil) {
            self.centralManager = nil
            self.checkPassed    = 0
        }
    }
    
    // MARK: - Other Methods
    private func disableUserInteraction() {
        self.activityIndicator.show(animated: true)
    }
    
    private func enableUserInteractionWithDelay(delay: Double) {
        self.activityIndicator.hide(animated: true, afterDelay: delay)
    }
    
    private func checkHandleFunction() {
        self.somethingChanged = false
        self.enableUserInteractionWithDelay(delay: 0)
        if (self.hasWifiErr || self.hasBlueToothErr) {
            // Show alert information on secondary label
            if (self.scanner.scannerStarted) {
                self.scanner.stop();
                self.scanner.detach();
                self.viewPreview.isHidden = true
            }
            
            self.secondaryLabel.isHidden = false
            self.secondaryLabel.alpha    = 0
            UIView.animate(withDuration: 0.5, animations: { 
                self.secondaryLabel.alpha = 1
                self.secondaryLabel.textAlignment = .center
            })
        
            self.customizeConditionCheckAlert()
            
            return
        }
        
        // Hide the info label and open the camera
        self.disableUserInteraction()
        if (self.secondaryLabel.isHidden) {
            self.secondaryLabel.isHidden = false
            self.secondaryLabel.textAlignment = .center
        }
        self.secondaryLabel.text = CTLocalizedString(CT_OPENING_CAMERA_LABEL, comment: "")
        
        if (self.scanner.isScannerEnabled) {
            self.secondaryLabel.isHidden = true
            self.viewPreview.isHidden    = false
            self.scanner.attach();
            self.scanner.start();
        } else {
            self.secondaryLabel.text = CTLocalizedString(CT_BACK_CAMERA_ERROR_MESSAGE_LABEL, comment: "")
            self.showCameraDisabledPrompt()
        }
        
        self.enableUserInteractionWithDelay(delay: 0)
    }
    
    private func customizeConditionCheckAlert() {
        let btnTitle: String? = CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, comment: "")
        var string  : String?
        
        if (self.hasWifiErr) {
            string = CTLocalizedString(CT_TURN_ON_WIFI_ALERT_CONTEXT, comment: "")
        }
        
        if (self.hasBlueToothErr) {
            if (string == nil) {
                string = CTLocalizedString(CT_TURN_OFF_BT_ALERT_CONTEXT, comment: "")
            } else {
                string = string! + " " + CTLocalizedString(CT_AND_TURN_OFF_BT_STRING, comment: "")
            }
        }
        
        string = string! + CTLocalizedString(CT_START_PAIRING_DEVICES_STRING, comment: "")
        
        if (self.hasWifiErr && !self.hasBlueToothErr) {
            string = string! + CTLocalizedString(CT_WIFI_PATH, comment: "")
        }
        if (self.hasBlueToothErr && !self.hasWifiErr) {
            string = string! + CTLocalizedString(CT_BT_PATH, comment: "")
        }
        if (self.hasBlueToothErr && self.hasWifiErr) {
            string = string! + CTLocalizedString(CT_WIFI_AND_BT_PATH, comment: "")
        }
        
        self.secondaryLabel.text = string
        if (CTContentTransferSetting.userCustomVerizonAlert()) {
            CTVerizonAlertCreateFactory.showTwoButtonsAlert(withTitle: CTAlertGeneralTitle, context: string ?? "", cancelBtnText: btnTitle ?? "", confirmBtnText: CTAlertGeneralIgnoreTitle, confirmHandler: nil, cancelHandler: { (alertVC: CTVerizonAlertViewController) in
                if (self.hasBlueToothErr && self.hasWifiErr) {
                    CTSettingsUtility.openRootSettings()
                } else if (self.hasBlueToothErr) {
                    CTSettingsUtility.openBluetoothSettings()
                } else {
                    CTSettingsUtility.openWifiSettings()
                }
            }, isGreedy: false, from: self)
        } else {
            CTAlertCreateFactory.showTwoButtonsAlert(withTitle: CTAlertGeneralTitle, context: string, cancelBtnText: btnTitle, confirmBtnText: CTAlertGeneralIgnoreTitle, confirmHandler: nil, cancelHandler: { (action) in
                if (self.hasBlueToothErr && self.hasWifiErr) {
                    CTSettingsUtility.openRootSettings()
                } else if (self.hasBlueToothErr) {
                    CTSettingsUtility.openBluetoothSettings()
                } else {
                    CTSettingsUtility.openWifiSettings()
                }
            }, isGreedy: false)
        }
    }
    
    private func showCameraDisabledPrompt() {
        if (CTContentTransferSetting.userCustomVerizonAlert()) {
            CTVerizonAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: CTLocalizedString(CT_BACK_CAMERA_ALERT_CONTEXT, comment: ""), cancelBtnText: CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, comment: ""), confirmBtnText: CTLocalizedString(CTAlertGeneralContinueTitle, comment: ""), confirmHandler: nil, cancelHandler: { (alertVC: CTVerizonAlertViewController) in
                CTSettingsUtility.openAppCustomSettings()
            }, isGreedy: false, from: self)
        } else {
            CTAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: CTLocalizedString(CT_BACK_CAMERA_ALERT_CONTEXT, comment: ""), cancelBtnText: CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, comment: ""), confirmBtnText: CTLocalizedString(CTAlertGeneralContinueTitle, comment: ""), confirmHandler: nil, cancelHandler: { (action) in
                CTSettingsUtility.openAppCustomSettings()
            }, isGreedy: false)
        }
    }
    
    // MARK: - CBCenterManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn) {
            if (!self.hasBlueToothErr) {
                self.somethingChanged = true
            }
            self.hasBlueToothErr = true
        } else {
            if (self.hasBlueToothErr) {
                self.somethingChanged = true
            }
            self.hasBlueToothErr = false
        }
        print("Bluetooth error: \(self.hasBlueToothErr)")
        
        self.checkPassed += 1
        if (self.checkPassed == 2 && self.somethingChanged) {
//            self.backgroundMode = false
            self.checkHandleFunction()
        } else {
            self.enableUserInteractionWithDelay(delay: 0)
        }
    }
    
    // MARK: - QR Scanner Logic
    func processQRCode(str:String)
    {
        // 3.4.2#10.2.1##CTSTM004###bonjour&router#CTSTMM#
//        let decodedStr = str.decodeTo64()
        // TODO: It will return invalid code, since one to many is not working now. Will enable if business ask for one-to-many.
        let decodedStr = str
//        if decodedStr != nil {
            let params = decodedStr.components(separatedBy: "#")
            
            if (params.count == 9) {
                let serviceType = params[7]
                let serviceName = params[3]
                
                if serviceType.contains("CTSTMM") == true && serviceName.count > 0 {
                    // Valid QR code, should proceed to receiving waiting page.
                    let targetViewController: CTReceiverReadyViewController = CTReceiverReadyViewController.initialise(from: CTStoryboardHelper.transferStoryboard())
                    targetViewController.transferFlow = CTTransferFlow.receiver
                    targetViewController.serviceName  = serviceName
                    
                    self.navigationController?.pushViewController(targetViewController, animated: true)
                    
                    return
                }
            }
//        }
        
        self.scanner.scannerShouldIgnoreFutherReadForAlert()
        if CTContentTransferSetting.userCustomVerizonAlert() {
            CTVerizonAlertCreateFactory.showSingleButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: CTLocalizedString(CT_INVALID_QR_CODE_ALERT_CONTEXT, comment: ""), btnText: CTLocalizedString(CTAlertGeneralOKTitle, comment: ""), handler: { (alertVC: CTVerizonAlertViewController) in
                self.scanner.scannerShouldstartReading()
            }, isGreedy: false, from: self)
        } else {
            CTAlertCreateFactory.showSingleButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: CTLocalizedString(CT_INVALID_QR_CODE_ALERT_CONTEXT, comment: ""), btnText: CTLocalizedString(CTAlertGeneralOKTitle, comment: ""), handler: { (action) in
                self.scanner.scannerShouldstartReading()
            }, isGreedy: false)
        }
        
        self.viewPreview.isHidden = false
        self.secondaryLabel.isHidden = true
        
        self.scanner.attach()
        self.scanner.start()
    }
}

extension CTSTMRecvScannerViewController: CTQRScannerDelegate {
    
    func qrScanner(_ scanner: CTQRScanner!, didSuccessfullyScannedQRCode qrCodeString: String!) {
        print("Connected information: \(qrCodeString)")
        processQRCode(str: qrCodeString)
    }
    
    func qrScanner(_ scanner: CTQRScanner!, didFailedScannedQRCode reason: String!, handler: (() -> Void)!) {
        if (CTContentTransferSetting.userCustomVerizonAlert()) {
            CTVerizonAlertCreateFactory.showSingleButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: reason, btnText: CTLocalizedString(CTAlertGeneralOKTitle, comment: ""), handler: { (alertVC: CTVerizonAlertViewController) in
                handler()
            }, isGreedy: false, from: self)
        } else {
            CTAlertCreateFactory.showSingleButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: reason, btnText: CTLocalizedString(CTAlertGeneralOKTitle, comment: ""), handler: { (action) in
                handler()
            }, isGreedy: false)
        }
    }
    
}
