//
//  CTSTMSenderViewController.swift
//  contenttransfer
//
//  Created by Zhang, Yichun on 3/22/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit
import Foundation
import MultipeerConnectivity
import CoreBluetooth

enum CTTransferItemsTableBreakDown:Int {
    case Contacts
    case Photos
    case Videos
    case Calenders
    case Reminders
    case Total
}

enum CTSTMSenderDisplayMode
{
    case Connect
    case Content
    case Transfer
}

enum CTSTMContentSelect
{
    case some
    case all
    case none
}



@objc class CTSTMSenderViewController: VZCTViewController,
                                      UITableViewDataSource,
                                      UITableViewDelegate,
                                      CTSTMServiceDelegate2,
                                      PhotoManagerDelegate,
                                      updatePhotoAndVideoNumbersDelegate,
                                      CBCentralManagerDelegate
{
    func recvResourceStart(_ resourcename: String!) {
        
    }


    func startBrowseError(_ service: CTSTMService2!, error: Error!) {
        
    }

    func startServiceError(_ service: CTSTMService2!, error: Error!) {
        
    }

    
    private var contentListView:CTSTMSenderTableView!=nil
    private var title_label:UILabel! = nil
    private var button_action:CTCommonBlackButton! = nil
    private var button_cancel:CTBlackBorderedButton!=nil
    private var button_selectall:CTCustomButton!=nil
    private var qrCodeImageView:UIImageView! = nil
    private var categoryStatus:NSMutableArray!=nil
    private var subTitleLbl: UILabel?
    private var cloudLabel : UILabel?
    private var header     : UILabel?
    private var footerView : UILabel! = nil
    private var warningLabel:UILabel! = nil
    private var seperatorView: UIView?
    
    private let rowHeight = 60
    private let rowHeightDevice = 75
    private let footHeight = 88
    
    private var cellNumber = 0
    
    
    private let deviceCellId  = "CTSTMDeviceTableViewCell"
    
    private let contentCellId = "CTSTMContentTableViewCell"
    
    private let connectCellId = "CTSTMConnectTableViewCell"
    
    private var serviceName = "CTSTM004"
    
    private var senderProcessor:CTSTMSenderProcessor! = CTSTMSenderProcessor.sharedInstance
    
    private var itemsInfo:NSMutableDictionary! = nil
    
    public var totalDataSize:UInt64! = 0
    
    public var displayMode:CTSTMSenderDisplayMode = .Connect
    
    public var contentSelectMode:CTSTMContentSelect = .some
    
    public var qrCode:CTQRCode! = nil
    
    private var allData:NSDictionary! = nil
    
    private let startTime = Date().timeIntervalSince1970
    
    var myBTManager:CBCentralManager!
    
    var bluetoothAvailable = false
    
    var bOldWifiAlert = false
    var bOldBLAlert = false
    
    var fileList: CTFileList = CTFileList.init(fileList: ());
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = CTColor.white
        
        self.automaticallyAdjustsScrollViewInsets = false
//        self.cloudLabel?.isHidden = true
        
#if STANDALONE
        
        self.setNavigationControllerMode(.none)
#else
        self.setNavigationControllerMode(.backAndHamburgar)
#endif
        
        setupData()
        
        switch displayMode
        {
        case .Connect:
            setupConnectUI()
        case .Content:
            setupContentUI()
        case .Transfer:
            setupTransferUI()
        }
        
        contentListView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.contentListView.frame.size.width, height: 1))
        
        myBTManager = CBCentralManager.init(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey : NSNumber.init(value: false)])
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let defaultLeading: CGFloat = 32.0
//        if #available(iOS 8.0, *) {
//             defaultLeading = self.view.layoutMargins.left
//        }
        
        var offsetY:CGFloat = 30
        if (displayMode == .Transfer) {
            offsetY = 90
        }
        
        if title_label != nil
        {
            let width = self.view.frame.width - defaultLeading*2
            let height = title_label.dynamicHeight(for: width)
            title_label.frame = CGRect(x: defaultLeading, y: offsetY, width: width, height: height)
//            title_label.backgroundColor = UIColor.blue
            offsetY += title_label.frame.height
        }
        
        if (self.subTitleLbl != nil) {
            var topPadding: CGFloat = 0
            if (displayMode == .Connect) {
                topPadding = 8
            } else if (displayMode == .Transfer) {
                topPadding = 8
            } else {
                topPadding = 8
            }
            // Only connect mode has subtitle label
            self.subTitleLbl?.frame = CGRect(x: defaultLeading, y: offsetY + topPadding, width: title_label.frame.size.width, height: 34) // same as current design
//            subTitleLbl?.backgroundColor = UIColor.green
            offsetY += topPadding
            offsetY += (self.subTitleLbl?.frame.height)!
        }
        
        offsetY += 8
        
        self.seperatorView?.frame = CGRect(x: defaultLeading, y: offsetY, width: title_label.frame.size.width, height: 4)
        
        let QRCodeWidth = self.view.frame.width - 50*2 - defaultLeading;
        
        if qrCodeImageView != nil
        {
            qrCodeImageView.frame = CGRect(x: 0,
                                           y: 0,
                                           width:  QRCodeWidth,
                                           height: QRCodeWidth)
            qrCodeImageView.center = CGPoint.init(x: self.view.center.x, y: offsetY + QRCodeWidth/2 + 30) // same as current design
            qrCodeImageView.backgroundColor = UIColor.clear
            qrCodeImageView.image = qrCode.toUIImage(from: qrCodeImageView.layer)
            
            offsetY = qrCodeImageView.frame.origin.y + qrCodeImageView.frame.size.height
        }
        
        if warningLabel != nil
        {
            warningLabel.frame = CGRect(x: 0,
                                        y: 0,
                                        width: QRCodeWidth, height: 40)
            warningLabel.center = CGPoint.init(x: self.view.center.x, y: self.view.center.y + 16.5)
        }
        
        if button_selectall != nil
        {
            button_selectall.frame = CGRect(
                x: self.view.frame.size.width - button_selectall.frame.size.width - defaultLeading,
                y: offsetY + 5,
                width: button_selectall.frame.size.width,
                height: button_selectall.frame.size.height)
            
//            offsetY = offsetY + button_selectall.frame.size.height
        }

        if displayMode == .Content
        {
            let marginLenToCenter: CGFloat = 5
            
            if button_cancel != nil
            {
                let buttonWidth = CGFloat(120)
                
                button_cancel?.frame = CGRect(
                    x: self.view.center.x - marginLenToCenter - buttonWidth,
                    y: self.view.frame.size.height - 42 - 8,
                    width: buttonWidth,
                    height: 42)
                
                button_cancel?.configure()
            }
            
            if button_action != nil
            {
                let buttonWidth = CGFloat(120)
                
                button_action?.frame = CGRect(
                    x: self.view.center.x + marginLenToCenter,
                    y: self.view.frame.size.height - 42 - 8,
                    width: buttonWidth,
                    height: 42);
                
                button_action?.configure()
            }
            
            if (self.cloudLabel != nil) {
                let width = self.view.frame.size.width - defaultLeading*2
                let cloudLabelHeight = self.cloudLabel?.dynamicHeight(for: width)
                self.cloudLabel?.frame = CGRect(x: defaultLeading, y: button_cancel.frame.origin.y - 4 - cloudLabelHeight!, width: width, height: cloudLabelHeight!)
            }
        }
        else
        {
            if button_action != nil
            {
                let buttonWidth = CGFloat(120)
        
                var yPos = self.view.frame.size.height - 44 - 10
                if CTDeviceMarco.isiPhoneX() {
                    // If it's iPhone X, move extra 20 pixels for new layout.
                    yPos = self.view.frame.size.height - 44 - 10 - 20
                }
                button_action?.frame = CGRect(
                    x: (self.view.frame.size.width - buttonWidth)/2,
                    y: yPos,
                    width: buttonWidth,
                    height: 44);
        
                button_action?.configure()
            }
        }
        
        if displayMode == .Connect
        {
            contentListView?.frame = CGRect(x: 0,
                                            y: Int(offsetY + 29),
                                            width: Int(self.view.frame.size.width),
                                            height: 46)
            
            offsetY = offsetY + 46
        }
        else if displayMode == .Content
        {
            contentListView?.frame = CGRect(x: 0,
                                            y: Int(offsetY + 35),
                                            width: Int(self.view.frame.size.width),
                                            height: Int(self.view.frame.size.height - offsetY - 35 - 50 - 5 - (self.cloudLabel?.frame.size.height)!))
            
//            contentListView.backgroundColor = UIColor.darkGray
        }
        else
        {
            contentListView?.frame = CGRect(x: 0,
                                            y: Int(offsetY + 20),
                                            width: Int(self.view.frame.size.width),
                                            height: Int(self.view.frame.size.height - offsetY - 20 - 21))
            
            self.footerView.frame = CGRect.init(x: 0, y: self.view.frame.size.height - 21, width: self.view.frame.size.width, height: 21)
            self.view.addSubview(self.footerView)
        }
        
        if displayMode == .Transfer {
            self.cellNumber = Int((self.contentListView.frame.height - (self.header?.frame.height)!) / 75)
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
        self.navigationController?.navigationBar.topItem?.title = ""
        
        if displayMode == .Connect
        {
            self.navigationController?.navigationBar.topItem?.title = CTLocalizedString(CT_WIFI_SETUP_VC_NAV_TITLE, comment: "")
            
            CTSTMService2.sharedInstance().start(true, serviceType: serviceName)
        }
        else
        {
            self.navigationController?.navigationBar.topItem?.title = CTLocalizedString(CT_TRANSFER_NAV_TITLE, comment: "")
            if displayMode == .Transfer &&  CTSTMService2.sharedInstance().getNumOfConnectedDevice() > self.cellNumber {
                footerView.alpha = 1.0
            }
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        if displayMode == .Transfer
        {
            CTSTMService2.sharedInstance().delegate =  nil
            CTSTMService2.sharedInstance().stop()
        }
    }
    override open func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)

    }
    
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    func setupData()
    {
        CTSTMService2.sharedInstance().delegate = self
        
        if displayMode == .Connect
        {
            CTSTMService2.sharedInstance().resetService()
        }
        
        senderProcessor.transferService = CTSTMService2.sharedInstance()
        senderProcessor.photoManager = CTDataCollectionManager.shared().photoManager;
        senderProcessor.videoManager = CTDataCollectionManager.shared().photoManager;
        
        CTDataCollectionManager.shared().delegate = self
        
        if displayMode == .Content
        {
            CTUserDefaults.sharedInstance().tempPhotoLists = []
            CTUserDefaults.sharedInstance().tempVideoLists = []
        
            CTUserDefaults.sharedInstance().numberOfPhotosReceived = 0
            CTUserDefaults.sharedInstance().numberOfVideosReceived = 0
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkWifiConnectionAgain), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name:NSNotification.Name.UIApplicationWillTerminate, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(exitContentTransfer), name: NSNotification.Name(rawValue: CT_NOTIFICATION_EXIT_CONTENT_TRANSFER), object: nil)
        
        
        itemsInfo = NSMutableDictionary(capacity: 0)
        
        categoryStatus = NSMutableArray(capacity: 0)
        
        for _ in 0...CTTransferItemsTableBreakDown.Total.rawValue - 1
        {
            categoryStatus.add(NSNumber(value: false))
        }
        
        serviceName = self.generateServiceName()
        
        qrCode = CTQRCode(plattform: "", andSSID: serviceName, andIPAddreess: "", andPort: "", andPasscode: "", andService: "", andSetupType: "CTSTMM")
        
        if displayMode == .Transfer
        {
            totalDataSize = getTotalTransferSize()
        }

    }
    
    func setupConnectUI()
    {
        title_label = UILabel(frame: .zero)
        title_label.text = CTLocalizedString(CT_SCAN_QR_CODE_TITLE_LABEL, comment: "")
        title_label.textColor = CTColor.black
        title_label.font = CTMVMFonts.mvmBoldFont(ofSize: 25)
        title_label.lineBreakMode = .byWordWrapping
        title_label.numberOfLines = 0
        title_label.textAlignment = .left
        
        title_label.isUserInteractionEnabled = false
        self.view.addSubview(title_label)
        
        subTitleLbl = UILabel(frame: .zero)
        subTitleLbl?.text = CTLocalizedString(CT_SCAN_QR_CODE_SUB_TITLE_LABEL, comment: "")
        subTitleLbl?.textColor = UIColor.black
        subTitleLbl?.font = CTMVMFonts.mvmBookFont(ofSize: 13)
        subTitleLbl?.lineBreakMode = .byWordWrapping
        subTitleLbl?.numberOfLines = 0
        subTitleLbl?.textAlignment = .left
        self.view.addSubview(subTitleLbl!)
        
        seperatorView = UIView(frame: .zero)
        seperatorView?.backgroundColor = .black
        self.view.addSubview(seperatorView!)
        
        contentListView = CTSTMSenderTableView(frame: .zero)
        contentListView.delegate = self
        contentListView.dataSource = self
        contentListView.register(UITableViewCell.self, forCellReuseIdentifier: connectCellId)
        contentListView.allowsMultipleSelection = false
        contentListView.backgroundColor = UIColor.clear
        contentListView.separatorStyle = .none
        contentListView.isScrollEnabled = false
        contentListView.isUserInteractionEnabled = false
        contentListView.tableFooterView = UIView()
        self.view.addSubview(contentListView)
        
        button_action = CTCommonBlackButton(frame: .zero)
        button_action.configure()
        button_action.addTarget(self, action: #selector(button_action_next), for: .touchUpInside)
        button_action.setTitle(CTLocalizedString(CT_NEXT_BUTTON_TITLE, comment: ""), for: .normal)
        button_action.setTitleColor(CTColor.white, for: .normal)
        button_action.sizeToFit()
        button_action.isEnabled = false
        self.view.addSubview(button_action)
        
        qrCodeImageView = UIImageView(frame: .zero)
        
        qrCodeImageView.image = qrCode.toUIImage(from: qrCodeImageView.layer)
        
        self.view.addSubview(qrCodeImageView)
        
        warningLabel = UILabel.init(frame: .zero)
        
        warningLabel.numberOfLines = 0;
        warningLabel.textAlignment = .center;
        warningLabel.lineBreakMode = .byWordWrapping;
        warningLabel.font = CTMVMFonts.mvmBookFont(ofSize: 14)
        
        self.view.addSubview(warningLabel);
    }
    
    func setupContentUI()
    {
        title_label = UILabel(frame: .zero)
        title_label.text = CTLocalizedString(CT_WHAT_ARE_YOU_TRANSFERRING_TITLE_LABEL, comment: "")
        title_label.textColor = CTColor.primaryRed()
        title_label.font = CTMVMFonts.mvmBoldFont(ofSize: 22)
        title_label.lineBreakMode = .byWordWrapping
        title_label.numberOfLines = 0
        title_label.textAlignment = .center
        title_label.isUserInteractionEnabled = false
        self.view.addSubview(title_label)
        
        subTitleLbl = UILabel(frame: .zero)
        subTitleLbl?.text = CTLocalizedString(CT_WHAT_ARE_YOU_TRANSFERRING_SUB_TITLE_LABEL, comment: "")
        subTitleLbl?.textColor = UIColor.black
        subTitleLbl?.font = CTMVMFonts.mvmBookFont(ofSize: 13)
        subTitleLbl?.lineBreakMode = .byWordWrapping
        subTitleLbl?.numberOfLines = 0
        subTitleLbl?.textAlignment = .center
        self.view.addSubview(subTitleLbl!)
        
        seperatorView = UIView(frame: .zero)
        seperatorView?.backgroundColor = .black
        self.view.addSubview(seperatorView!)
        
        contentListView = CTSTMSenderTableView(frame: .zero)
        contentListView.delegate = self
        contentListView.dataSource = self
        contentListView.register(CTSTMContentTableViewCell.self, forCellReuseIdentifier: contentCellId)
        contentListView.allowsMultipleSelection = true
        contentListView.isScrollEnabled = false
        
        self.view.addSubview(contentListView)
        
        button_action = CTCommonBlackButton(frame: .zero)
        button_action.configure()
        button_action.addTarget(self, action: #selector(button_action_start), for: .touchUpInside)
        button_action.setTitle("Start", for: .normal)
        button_action.setTitleColor(CTColor.white, for: .normal)
        button_action.sizeToFit()
        button_action.isEnabled = false
        self.view.addSubview(button_action)
        
        button_cancel = CTBlackBorderedButton(frame: .zero)
        button_cancel.configure()
        button_cancel.addTarget(self, action: #selector(button_action_cancel), for: .touchUpInside)
        button_cancel.setTitle("Cancel", for: .normal)
//        button_cancel.setTitleColor(CTColor.white, for: .normal)
        button_cancel.sizeToFit()
        button_action.isEnabled = false
        self.view.addSubview(button_cancel)
        
        button_selectall = CTCustomButton(frame: .zero)
        button_selectall.addTarget(self, action: #selector(button_action_selectall), for: .touchUpInside)
        button_selectall.setTitle("Select All", for: .normal)
        button_selectall.setTitleColor(CTColor.black, for: .normal)
        button_selectall.titleLabel?.font = CTMVMFonts.mvmBookFont(ofSize: 13)
        button_selectall.sizeToFit()
        self.view.addSubview(button_selectall)
        
        cloudLabel = UILabel(frame: .zero)
        cloudLabel?.text = CTLocalizedString(CT_STM_SENDER_CLOUD_LABEL, comment: "")
        cloudLabel?.textColor = CTMVMColor.mvmPrimaryRedColor()
        cloudLabel?.font = CTMVMFonts.mvmBookFont(ofSize: 12)
        cloudLabel?.lineBreakMode = .byWordWrapping
        cloudLabel?.numberOfLines = 0
        cloudLabel?.textAlignment = .center
        cloudLabel?.isHidden = true
        self.view.addSubview(cloudLabel!)
    }
    
    func setupTransferUI()
    {
        title_label = UILabel(frame: .zero)
        title_label.backgroundColor = CTColor.white
        title_label.text = CTLocalizedString(CT_STM_SENDER_TRANSFER_PROGRESS_TITLE_LABEL, comment: "")
        title_label.textColor = CTColor.black
        title_label.font = CTMVMFonts.mvmBoldFont(ofSize: 25)
        title_label.textAlignment = .center
        title_label.isUserInteractionEnabled = false
        self.view.addSubview(title_label)
        
        subTitleLbl = UILabel(frame: .zero)
        subTitleLbl?.text = CTLocalizedString(CT_STM_SENDER_TRANSFER_PROGRESS_SUB_TITLE_LABEL, comment: "")
        subTitleLbl?.textColor = UIColor.black
        subTitleLbl?.font = CTMVMFonts.mvmBookFont(ofSize: 13)
        subTitleLbl?.lineBreakMode = .byWordWrapping
        subTitleLbl?.numberOfLines = 0
        subTitleLbl?.textAlignment = .center
        self.view.addSubview(subTitleLbl!)
        
        seperatorView = UIView(frame: .zero)
        seperatorView?.backgroundColor = .black
        self.view.addSubview(seperatorView!)
        
        contentListView = CTSTMSenderTableView(frame: .zero)
        contentListView.delegate = self
        contentListView.dataSource = self
        contentListView.register(CTSTMDeviceTableViewCell.self, forCellReuseIdentifier: deviceCellId)
        contentListView.allowsMultipleSelection = false
        contentListView.isUserInteractionEnabled = false
        contentListView.bounces = false

        self.view.addSubview(contentListView)
    
        footerView = UILabel(frame: .zero)
        footerView.backgroundColor = UIColor.init(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)
        footerView.text = CTLocalizedString(CT_STM_SENDER_FOOTER_TEXT, comment: "")
        footerView.textAlignment = .center
        footerView.numberOfLines = 1
        footerView.font = CTMVMFonts.mvmBookFont(ofSize: 12)
        footerView.alpha = 0

        self.header = UILabel(frame: .zero)
        let totalSizeStr = self.formattedDataSizeTextInTransferWhatScreen(byteSize: Double(senderProcessor.totalTransferSize))
        header?.font = CTMVMFonts.mvmBookFont(ofSize: 13)
        header?.text = CTLocalizedString(CT_STM_SENDER_HEADER_TEXT_PART1, comment: "") + "\n" + " \(senderProcessor.totalSentFile!) " + CTLocalizedString(CT_STM_SENDER_HEADER_TEXT_PART2, comment: "") + " \(totalSizeStr)"
        header?.textAlignment = .center
        header?.numberOfLines = 0
        header?.sizeToFit()
        header?.backgroundColor = .white
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
// UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if displayMode == .Transfer
        {
            if (self.header != nil) {
//                self.cellNumber = Int((self.contentListView.frame.height - (self.header?.frame.height)!) / 75)
                if (CTSTMService2.sharedInstance().getNumOfConnectedDevice() > self.cellNumber) {
                    self.footerView.alpha = 1
                    self.contentListView.isUserInteractionEnabled = true
                    self.contentListView.showsVerticalScrollIndicator = true
                    self.contentListView.showsHorizontalScrollIndicator = false
                } else {
                    self.footerView.alpha = 0
                }
                return (self.header?.frame.height)!
            }
        }
        
        return 0
    }

    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if displayMode == .Transfer
        {
            return header
        }
        else
        {
            return nil
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if displayMode == .Connect
        {
            return 1
        }
        else if displayMode == .Transfer
        {
            return CTSTMService2.sharedInstance().getNumOfConnectedDevice()
        }
        else
        {
            return CTTransferItemsTableBreakDown.Total.rawValue
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if displayMode == .Connect
        {
            let cell = CTSTMConnectTableViewCell(style: .subtitle, reuseIdentifier: connectCellId)
            
            cell.backgroundColor = UIColor.clear
            
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = CTMVMFonts.mvmBookFont(ofSize: 13)
            cell.detailTextLabel?.textAlignment = .center
            cell.detailTextLabel?.font =  CTMVMFonts.mvmBookFont(ofSize: 13)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 13)
            
            if indexPath.row == 0
            {
                let myAttribute:[NSAttributedStringKey: Any] = [NSAttributedStringKey.font: CTMVMFonts.mvmBoldFont(ofSize: 13)]
                let attriStr = NSAttributedString.init(string: UIDevice.current.name, attributes: myAttribute)
                let completeStr = NSMutableAttributedString.init(string: CTLocalizedString(CT_STM_SENDER_DEVICE_LABEL, comment: ""))
                completeStr.append(attriStr)
                cell.textLabel?.attributedText = completeStr
                cell.detailTextLabel?.text = CTLocalizedString(CT_STM_SENDER_DEVICE_DETAILED_LABEL, comment: "") + " \(CTSTMService2.sharedInstance().getNumOfConnectedDevice())"
            }
            
            return cell

        }
        else if displayMode == .Transfer
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: deviceCellId) as! CTSTMDeviceTableViewCell
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            cell.isUserInteractionEnabled = false
            
            let device = CTSTMService2.sharedInstance().getDevice(indexPath.row)
            
            if device != nil
            {
                cell.label_name.text = device!.peerId.displayName
                
                switch(device!.status.rawValue)
                {
                 case DeviceStatus2.Connecting.rawValue, DeviceStatus2.Connected.rawValue,DeviceStatus2.Transfer.rawValue:
                    
                    let aV = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                    aV.startAnimating()
                    
                    aV.color = CTColor.mvmDarkGrayColor()
                    
                    cell.accessoryView = aV
                    break;
 
                 case DeviceStatus2.Finished.rawValue:
                     cell.accessoryView = UIImageView.init(image: UIImage.getImageFromBundle(withImageName: "icon-grc-compatible"))
                    break;

                 case DeviceStatus2.Nospace.rawValue,DeviceStatus2.Cancel.rawValue:
                    cell.accessoryView = UIImageView.init(image: UIImage.getImageFromBundle(withImageName: "yellowExclaimation"))
                    break;
                 default:
                    cell.accessoryView = nil
                 break;
                 
                 }
                
                if senderProcessor.totalTransferSize == 0
                {
                    cell.progress.progress = 0
                    cell.progress.isHidden = true
                }
                else
                {
                    cell.progress.isHidden = false
                    let value = Float(device!.dataSentSize) / Float(senderProcessor.totalTransferSize)
                    cell.progress.progress = value
                }
                
                
                let sendSizeStr = self.formattedDataSizeTextInTransferWhatScreen(byteSize: Double(device!.dataSentSize))
                
                let localizedString = CTLocalizedString(CT_STM_SENDER_FILES_PROGRESS_LABEL, comment: "")
                cell.label_numprogress.text = "\(device!.numOfSentFile) " + localizedString + " / \(sendSizeStr)"
                

            }
            
            return cell;
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: contentCellId) as! CTSTMContentTableViewCell
            
            cell.textLabel?.font = CTMVMFonts.mvmBoldFont(ofSize: 13)
            cell.detailTextLabel?.font = CTMVMFonts.mvmBookFont(ofSize: 13)
            
            cell.selectionStyle = .none
            
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicator.startAnimating()
            cell.accessoryView = indicator
            cell.isUserInteractionEnabled = false
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

            NSLog("\(CTTransferItemsTableBreakDown.Contacts.rawValue)")
            switch(indexPath.row)
            {
            case CTTransferItemsTableBreakDown.Contacts.rawValue:
                cell.textLabel?.text = formattedCountText(name: CTLocalizedString(CT_CONTACTS, comment: ""), count:0)
                if CTContactsManager.contactsAuthorizationStatus() == .statusAuthorized
                {
                    if CTDataCollectionManager.shared().isCollectingContactsCompleted
                    {
                        let contactCount = CTDataCollectionManager.shared().getNumberOfContacts()
                        
                        cell.textLabel?.text = formattedCountText(name: CTLocalizedString(CT_CONTACTS, comment: ""), count: contactCount)
                        
                        cell.detailTextLabel?.text = formattedDataSizeTextInTransferWhatScreen(byteSize: Double(CTDataCollectionManager.shared().getSizeOfContacts()))
                        
                        cell.accessoryView = nil;
                        
                        if contactCount > 0
                        {
                            cell.isUserInteractionEnabled = true
                        }
                    }

                }
                else
                {
                    
                }
                break;
            case CTTransferItemsTableBreakDown.Calenders.rawValue:
                cell.textLabel?.text = formattedCountText(name: CTLocalizedString(CT_CONTACTS, comment: ""), count:0)
                if CTEventStoreManager.calendarAuthorizationStatus() == .statusAuthorized
                {
                    if CTDataCollectionManager.shared().isCollectingCalendarsCompleted
                    {
                        let Count = CTDataCollectionManager.shared().getNumberOfCalendars()
                        cell.textLabel?.text = formattedCountText(name: CTLocalizedString(CT_CALENDERS, comment: ""), count: Count);
                        cell.detailTextLabel?.text = formattedDataSizeTextInTransferWhatScreen(byteSize: Double(CTDataCollectionManager.shared().getSizeOfCalendars()))
                        cell.accessoryView = nil;
                        
                        if Count > 0
                        {
                            cell.isUserInteractionEnabled = true
                        }
                    }
                    
                }
                else
                {
                    
                }
                break;
            case CTTransferItemsTableBreakDown.Photos.rawValue:
                
                cell.textLabel?.text = formattedCountText(name: CTLocalizedString(CT_PHOTOS, comment: ""), count:0)
                
                if CTPhotosManager.photoLibraryAuthorizationStatus() == .statusAuthorized
                {
                    if CTDataCollectionManager.shared().isCollectingPhotoCompleted
                    {
                        let Count = CTDataCollectionManager.shared().getNumbersOfPhotos()
                        cell.textLabel?.text = formattedCountText(name: CTLocalizedString(CT_PHOTOS, comment: ""), count: Count);
                    
                        cell.detailTextLabel?.text = formattedDataSizeTextInTransferWhatScreen(byteSize: Double(CTDataCollectionManager.shared().getSizeOfPhotos()))

                        cell.accessoryView = nil;
                        
                        if Count > 0
                        {
                            cell.isUserInteractionEnabled = true
                        }
                        
                        let totalPhotoCloudNumber = CTDataCollectionManager.shared().getNumberOfUnavailableCountPhotosCount() + CTDataCollectionManager.shared().getNumberOfStreamPhotosCount()
                        
                        if totalPhotoCloudNumber > 0
                        {
                            cell.label_right.isHidden = false;
                            self.cloudLabel?.isHidden = false
                            cell.label_right.textColor = CTColor.primaryRed()
                            
                            
                            cell.label_right.text = "\(totalPhotoCloudNumber) " + CTLocalizedString(CT_STM_SENDER_IN_CLOUD, comment: "")
                            
                            UserDefaults.standard.set(true, forKey: "VZTRANSFER_HAS_CLOUD_PHOTO")
                            
                        }
                        else
                        {
                            cell.label_right.isHidden = true;
                            cell.label_right.text = ""
                            UserDefaults.standard.set(false, forKey: "VZTRANSFER_HAS_CLOUD_PHOTO")
                        }
                    }
                    
                }
                else
                {
                    
                }
                break;
            case CTTransferItemsTableBreakDown.Videos.rawValue:
                cell.textLabel?.text = formattedCountText(name: CTLocalizedString(CT_VIDEOS, comment: ""), count:0)
                if CTPhotosManager.photoLibraryAuthorizationStatus() == .statusAuthorized
                {
                    if CTDataCollectionManager.shared().isCollectingVideoCompleted
                    {
                        let Count = CTDataCollectionManager.shared().getNumbersOfVideos()
                        cell.textLabel?.text = formattedCountText(name: CTLocalizedString(CT_VIDEOS, comment: ""), count: Count);
                    
                        cell.detailTextLabel?.text = formattedDataSizeTextInTransferWhatScreen(byteSize: Double(CTDataCollectionManager.shared().getSizeOfVideos()))
                        cell.accessoryView = nil;
                        
                        if Count > 0
                        {
                            cell.isUserInteractionEnabled = true
                        }
                        
                        let totalVideoCloudNumber = CTDataCollectionManager.shared().getNumberOfUnavailableCountVideosCount() + CTDataCollectionManager.shared().getNumberOfStreamVideosCount()
                        
                        if totalVideoCloudNumber > 0
                        {
                            cell.label_right.isHidden = false;
                            self.cloudLabel?.isHidden = false
                            cell.label_right.textColor = CTColor.primaryRed()
                            
                            
                            cell.label_right.text = "\(totalVideoCloudNumber) " + CTLocalizedString(CT_STM_SENDER_IN_CLOUD, comment: "")
                            
                            UserDefaults.standard.set(true, forKey: "VZTRANSFER_HAS_CLOUD_VIDEO")

                        }
                        else
                        {
                            cell.label_right.isHidden = true;
                            cell.label_right.text = ""
                            UserDefaults.standard.set(false, forKey: "VZTRANSFER_HAS_CLOUD_VIDEO")
                        }
                        
                    }
                    
                }
                else
                {
                    
                }
                break;
            case CTTransferItemsTableBreakDown.Reminders.rawValue:
                cell.textLabel?.text = formattedCountText(name: CTLocalizedString(CT_REMINDERS, comment: ""), count:0)
                if CTEventStoreManager.reminderAuthorizationStatus() == .statusAuthorized
                {
                    if CTDataCollectionManager.shared().isCollectingReminderCompleted
                    {
                        let Count = CTDataCollectionManager.shared().getNumberOfReminders()
                        cell.textLabel?.text = formattedCountText(name: CTLocalizedString(CT_REMINDERS, comment: ""), count: Count);
                    
                        cell.detailTextLabel?.text = formattedDataSizeTextInTransferWhatScreen(byteSize: Double(CTDataCollectionManager.shared().getSizeOfReminders()))
                        cell.accessoryView = nil;
                        
                        if Count > 0
                        {
                            cell.isUserInteractionEnabled = true
                        }
                    }
                    
                }
                else
                {
                    
                }
                break;
            default:
                break;
            }
            
            
            DispatchQueue.main.async {
                
                let itemSelected = self.categoryStatus.object(at: indexPath.row) as! NSNumber
                
                if itemSelected.boolValue
                {
                    self.contentListView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }

            
            return cell
        }

    }
    
// UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if displayMode == .Transfer {
            return (self.contentListView.frame.height - (header?.frame.height)!) / CGFloat(self.cellNumber)
        } else if (displayMode == .Connect) {
            return 46
        } else {
            print("height = \(self.contentListView.frame.height / 5)")
            return self.contentListView.frame.height / 5
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if displayMode == .Content
        {
            categoryStatus.replaceObject(at: indexPath.row, with: NSNumber(value: true))

        }
        
        updateButtonStatus()

    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if displayMode == .Content
        {
            categoryStatus.replaceObject(at: indexPath.row, with: NSNumber(value: false))

        }
        
        updateButtonStatus()

    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if displayMode == .Content {
//            let itemSelected = categoryStatus.object(at: indexPath.row) as! NSNumber
        } else if (displayMode == .Transfer) {
            if (indexPath.row == CTSTMService2.sharedInstance().getNumOfConnectedDevice() - 1) {
                // last cell will show
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.3, animations: {
                    self.footerView.alpha = 0;
                    self.footerView.frame = CGRect.init(x: self.footerView.frame.origin.x, y: self.footerView.frame.origin.y, width: self.footerView.frame.size.width, height: 0)
                    self.view.layoutIfNeeded()
                }, completion: { (result) in
                    self.footerView.alpha = 0;
                })
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (displayMode == .Transfer) {
            if (indexPath.row == CTSTMService2.sharedInstance().getNumOfConnectedDevice() - 1) {
                // last cell will gone
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.3, animations: {
                    self.footerView.frame = CGRect.init(x: self.footerView.frame.origin.x, y: self.footerView.frame.origin.y, width: self.footerView.frame.size.width, height: 21)
                    self.footerView.layoutIfNeeded()
                }, completion: { (result) in
                    self.footerView.alpha = 1;
                })
            }
        }
        
    }
    
    
// CTSTMServiceDelegate2
    
    
    func connectRequest(_ host: String!, confirmation confirmHandler: ((Bool) -> Void)!) {
        
        confirmHandler(true)
        
        updateContent()
    }
    
    

 
    func deviceConnted(connected:Bool)
    {
        
    }

    func groupStatusChanged()
    {
        updateContent()
        
        if checkTransferFinished()
        {
            transferDidFinished()
        }
    }
    
    func recvData(_ data: Data!, withPeer peer: MCPeerID!) {
        
        if(data == nil)
        {
            return
        }
        
        senderProcessor.processData(data: data, peer: peer)
    }


// Button Action
    
    @objc public func button_action_next()
    {
        let vc = CTSTMSenderViewController()
        
        if displayMode == .Connect
        {
            vc.displayMode = .Content
        }
        else if (displayMode == .Content)
        {
            vc.displayMode = .Transfer
        }
        
        CTUserDevice().deviceCount = Int(CTSTMService2.sharedInstance().getNumOfConnectedDevice()) // When user connected, get the total number of devices connected in group;
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc public func button_action_start()
    {
        allData = collectItems()
        
        var enoughtSpace = true
        
        var deviceList = ""
        
        var availableDeviceNum = CTSTMService2.sharedInstance().getNumOfConnectedDevice()
        
        for i in 0..<CTSTMService2.sharedInstance().getNumOfConnectedDevice()
        {
            let device = CTSTMService2.sharedInstance().getDevice(i)
            
            if device != nil
            {
                if totalDataSize > device!.freeSpace
                {
                    deviceList = deviceList + "," + device!.peerId.displayName
                    availableDeviceNum = availableDeviceNum - 1
                    device!.status = DeviceStatus2.Nospace
                    enoughtSpace = false
                }
                else
                {
                     device!.status = DeviceStatus2.Connected
                }
            }
        }
        
  
        if enoughtSpace == true
        {
//            let finalData = createStartTransferData().
            let finalData = fileList.createFileListData()
        
            CTSTMService2.sharedInstance().sendPacket(nil, data: finalData)
        
            CTSTMService2.sharedInstance().setStatusofConnectedDevice(.Transfer, peer: nil)
        
            let vc = CTSTMSenderViewController()
        
            vc.displayMode = .Transfer
 
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if availableDeviceNum > 0
        {
            if (CTContentTransferSetting.userCustomVerizonAlert()) {
                CTVerizonAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: "\(deviceList) " + CTLocalizedString(CT_STM_SENDER_NO_DEVICE_SPACE_ALERT_CONTEXT, comment: ""), cancelBtnText: CTLocalizedString(CTAlertGeneralCancelTitle, comment: ""), confirmBtnText: CTLocalizedString(CTAlertGeneralContinueTitle, comment: ""), confirmHandler: { (alertVC: CTVerizonAlertViewController) in
                    
                    let finalData = self.createStartTransferData()
                    
                    CTSTMService2.sharedInstance().sendPacket(nil, data: finalData)
                    
                    CTSTMService2.sharedInstance().setStatusofConnectedDevice(.Transfer, peer: nil)
                    
                    let vc = CTSTMSenderViewController()
                    
                    vc.displayMode = .Transfer
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }, cancelHandler: nil, isGreedy: false, from: self)
            } else {
                CTAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: "\(deviceList) " + CTLocalizedString(CT_STM_SENDER_NO_DEVICE_SPACE_ALERT_CONTEXT, comment: ""), cancelBtnText: CTLocalizedString(CTAlertGeneralCancelTitle, comment: ""), confirmBtnText: CTLocalizedString(CTAlertGeneralContinueTitle, comment: ""), confirmHandler: { (action) in
                    
                    let finalData = self.createStartTransferData()
                    
                    CTSTMService2.sharedInstance().sendPacket(nil, data: finalData)
                    
                    CTSTMService2.sharedInstance().setStatusofConnectedDevice(.Transfer, peer: nil)
                    
                    let vc = CTSTMSenderViewController()
                    
                    vc.displayMode = .Transfer
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }, cancelHandler: { (action) in
                    
                }, isGreedy: false)
            }
        }
        else
        {
            if (!CTContentTransferSetting.userCustomVerizonAlert()) {
                CTAlertCreateFactory.showSingleButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: CTLocalizedString(CT_STM_SENDER_NO_DEVICES_SPACE_ALERT_CONTEXT, comment: ""), btnText: CTLocalizedString(CTAlertGeneralOKTitle, comment: ""), handler: nil, isGreedy: false)
            } else {
                CTVerizonAlertCreateFactory.showSingleButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: CTLocalizedString(CT_STM_SENDER_NO_DEVICES_SPACE_ALERT_CONTEXT, comment: ""), btnText: CTLocalizedString(CTAlertGeneralOKTitle, comment: ""), handler: nil, isGreedy: false, from: self)
            }
        }
    }
    
    @objc public func button_action_cancel()
    {
        CTUserDefaults.sharedInstance().isCancel = true

        if (CTContentTransferSetting.userCustomVerizonAlert()) {
            CTVerizonAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CT_STOP_TRANSFER_ALERT_TITLE, comment: ""), context: CTLocalizedString(CT_STOP_TRANSFER_ALERT_CONTEXT, comment: ""), cancelBtnText: CTLocalizedString(CTAlertGeneralCancelTitle, comment: ""), confirmBtnText: CTLocalizedString(CT_CONFIRM_ALERT_BUTTON_TITLE, comment: ""), confirmHandler: { (alertVC: CTVerizonAlertViewController) in
                CTSTMService2.sharedInstance().stop()
                
                let vc = CTErrorViewController.initialise(from: CTStoryboardHelper.commonStoryboard())
                
                vc?.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, comment: "")
                vc?.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, comment: "")
                vc?.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_TRY_AGAIN, comment: "")
                vc?.leftButtonTitle = CTLocalizedString(BUTTON_TITLE_RECAP, comment: "")
                vc?.transferStatusAnalytics = CTTransferStatus.cancelled
                vc?.totalDataSentUntillInterrupted = NSNumber(value: 0)
                vc?.totalDataAmount = 0
                vc?.transferSpeed = "0 Mbps"
                vc?.transferTime = ""
                vc?.cancelInTransferWhatPage = true
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }, cancelHandler: nil, isGreedy: false, from: self)
        } else {
            CTAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CT_STOP_TRANSFER_ALERT_TITLE, comment: ""), context: CTLocalizedString(CT_STOP_TRANSFER_ALERT_CONTEXT, comment: ""), cancelBtnText: CTLocalizedString(CTAlertGeneralCancelTitle, comment: ""), confirmBtnText: CTLocalizedString(CT_CONFIRM_ALERT_BUTTON_TITLE, comment: ""), confirmHandler: { (action) in
                CTSTMService2.sharedInstance().stop()
                
                let vc = CTErrorViewController.initialise(from: CTStoryboardHelper.commonStoryboard())
                
                vc?.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, comment: "")
                vc?.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, comment: "")
                vc?.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_TRY_AGAIN, comment: "")
                vc?.leftButtonTitle = CTLocalizedString(BUTTON_TITLE_RECAP, comment: "")
                vc?.transferStatusAnalytics = CTTransferStatus.cancelled
                vc?.totalDataSentUntillInterrupted = NSNumber(value: 0)
                vc?.totalDataAmount = 0
                vc?.transferSpeed = "0 Mbps"
                vc?.transferTime = ""
                vc?.cancelInTransferWhatPage = true
                
                self.navigationController?.pushViewController(vc!, animated: true)
            }, cancelHandler: nil, isGreedy: false)
        }
    }
    
    @objc public func button_action_selectall()
    {

        var flag = true
        
        if contentSelectMode == .all
        {
            contentSelectMode = .none
            
            flag = false
        }
        else
        {
            contentSelectMode = .all
            
            flag = true
        }

        DispatchQueue.main.async {
        
            if flag == true
            {
                self.button_selectall.setTitle(CTLocalizedString(CT_DESELECT_ALL_BTN_TITLE, comment: ""), for: .normal)
            }
            else
            {
                self.button_selectall.setTitle(CTLocalizedString(CT_SELECT_ALL_BTN_TITLE, comment: ""), for: .normal)
            }
            
            self.button_selectall.sizeToFit()
            self.button_selectall.frame = CGRect(
                x: self.button_selectall.frame.origin.x,
                y: self.button_selectall.frame.origin.y,
                width: self.button_selectall.frame.size.width,
                height: self.button_selectall.frame.size.height)
        }

        if CTDataCollectionManager.shared().getNumberOfContacts() > 0
        {
            categoryStatus.replaceObject(at: CTTransferItemsTableBreakDown.Contacts.rawValue, with: NSNumber(value: flag))
        }
        
        if CTDataCollectionManager.shared().getSizeOfCalendars() > 0
        {
            categoryStatus.replaceObject(at: CTTransferItemsTableBreakDown.Calenders.rawValue, with: NSNumber(value: flag))
        }
        
        if CTDataCollectionManager.shared().getSizeOfReminders() > 0
        {
            categoryStatus.replaceObject(at: CTTransferItemsTableBreakDown.Reminders.rawValue, with: NSNumber(value: flag))
        }
        
        if CTDataCollectionManager.shared().getSizeOfPhotos() > 0
        {
            categoryStatus.replaceObject(at: CTTransferItemsTableBreakDown.Photos.rawValue, with: NSNumber(value: flag))
        }
        
        if CTDataCollectionManager.shared().getSizeOfVideos() > 0
        {
            categoryStatus.replaceObject(at: CTTransferItemsTableBreakDown.Videos.rawValue, with: NSNumber(value: flag))
        }
        
        self.updateContent()
    }
    
    public func updateContent()
    {
        DispatchQueue.main.async {
            self.contentListView?.reloadData()
            self.updateButtonStatus()
        }
    }
    
    func formattedCountText(name:String, count: Int) ->String
    {
        return name + "(" + "\(count)" + ")"
    }
    
    func formattedDataSizeTextInTransferWhatScreen(byteSize:Double) ->String
    {

        if(byteSize == 0)
        {
            return "0 MB"
        }
        else if(byteSize < 1024 * 1024)
        {
            return CTLocalizedString(CT_STM_SENDER_LESS_THAN_1MB, comment: "")
        }
        else if(byteSize < 1024 * 1204 * 1024)
        {
            return String(format: "%.1f MB", byteSize/(1024 * 1024))
        }
        else
        {
            return String(format: "%.1f GB", byteSize/(1024 * 1024 * 1024))

        }
    }

    
    public func updatePhotoCount(fromDataCollectionManager count: Int) {
        
    }
    
    public func updateVideosCount(fromDataCollectionManager count: Int) {
        
    }
    
    public func updateCalendarCount(fromDataCollectionManager count: Int) {
        
    }
    
    public func photoFetchingIsCompleted() {
        updateContent()
    }
    
    public func videoFetchingIsCompleted() {
        updateContent()
    }
    
    public func contactFetchingIsCompleted() {
        updateContent()
        
    }
    
    public func remindersFetchingIsCompleted() {
        updateContent()

    }
    
    public func calendarsFetchingIsCompleted() {
        updateContent()

    }
    
    public func audioFetchingIsCompleted() {
        print("Do nothing for now.");
    }
    
//  PhotoManagerDelegate
    
    public func viewShouldUpdatePhotoCount(_ count: Int) {
        updateContent()
    }
    
    public func viewShouldUpdateVideoCount(_ count: Int) {
        updateContent()
    }
    
// Notification Handling
    
    func appWillTerminate(notification:Notification)
    {
        
    }
    
    func exitContentTransfer(notification:Notification)
    {
        
    }
    
//  Collect Sending Info
    
    func collectItems() ->NSDictionary
    {
        fileList.initItem(METADATA_ITEMLIST_KEY_CONTACTS, withCount: CTDataCollectionManager.shared().getNumberOfContacts(), withSize: Int64(CTDataCollectionManager.shared().getSizeOfContacts()))
        fileList.initItem(METADATA_ITEMLIST_KEY_CALENDARS, withCount: CTDataCollectionManager.shared().getNumberOfCalendars(), withSize: Int64(CTDataCollectionManager.shared().getSizeOfCalendars()))
        fileList.initItem(METADATA_ITEMLIST_KEY_REMINDERS, withCount: CTDataCollectionManager.shared().getNumberOfReminders(), withSize: Int64(CTDataCollectionManager.shared().getSizeOfReminders()))
        fileList.initItem(METADATA_ITEMLIST_KEY_PHOTOS, withCount: CTDataCollectionManager.shared().getNumbersOfPhotos(), withSize: Int64(CTDataCollectionManager.shared().getSizeOfPhotos()))
        fileList.initItem(METADATA_ITEMLIST_KEY_VIDEOS, withCount: CTDataCollectionManager.shared().getNumbersOfVideos(), withSize: Int64(CTDataCollectionManager.shared().getSizeOfVideos()))
        
        fileList.creatComplete(contentListView.indexPathsForSelectedRows)
        
        totalDataSize = UInt64(fileList.totalDataSize())
        senderProcessor.totalTransferSize = UInt64(fileList.totalDataSize())
        
        senderProcessor.totalSentFile = UInt64(fileList.totalFileCount)
        
        return fileList.listObject()! as NSDictionary
    }
    
    func setItemSelected(itemType:String, flag:Bool)
    {
        let item = itemsInfo.object(forKey: itemType)
        
        if item != nil
        {
            if(flag)
            {
                (item as! NSMutableDictionary).setObject("true", forKey: "status" as NSCopying)
            }
            else
            {
                (item as! NSMutableDictionary).setObject("false", forKey: "status" as NSCopying)

            }
        }
    }
    
    func createItem(count:Int,size:Int64) ->NSMutableDictionary
    {
        let itemData = NSMutableDictionary(capacity: 0)
        
        itemData.setObject("false", forKey: "status" as NSCopying)
        itemData.setObject(NSNumber.init(value: count) , forKey: "totalCount" as NSCopying)
        itemData.setObject(NSNumber.init(value: size), forKey: "totalSize" as NSCopying)
        
        return itemData

    }
    
    func createStartTransferData()-> Data
    {

        
        var finaldata = Data()
       
        do {
            
            let fileListData = try JSONSerialization.data(withJSONObject: allData, options: .prettyPrinted)

            let tempstr = String(format: "%@%010d", CT_SEND_FILE_LIST_HEADER,fileListData.count)
            
            let requestData = tempstr.data(using: .ascii)
            
            finaldata.append(requestData!)
            finaldata.append(fileListData)

            
        } catch let error {
            
            NSLog("%@", "Error for create Photo: \(error)")
        }
        
        return finaldata
    }
    
    func updateButtonStatus()
    {
        let devices = CTSTMService2.sharedInstance().getNumOfConnectedDevice()
        
        if  displayMode == .Connect
        {
            if devices > 0
            {
                button_action.isEnabled = true
            }
            else
            {
                button_action.isEnabled = false
            }
        }
        else if displayMode == .Content
        {
            var flag = false
            
            for obj in categoryStatus
            {
                if (obj as! NSNumber).boolValue == true
                {
                    flag = true
                    break;
                }
            }
            
            button_action.isEnabled = flag
        }
        else if displayMode == .Transfer
        {
        }
        
    }
    
    func getTotalTransferSize()->UInt64
    {
        return UInt64(CTDataCollectionManager.shared().getSizeOfContacts()) + UInt64(CTDataCollectionManager.shared().getSizeOfReminders()) + UInt64(CTDataCollectionManager.shared().getSizeOfPhotos()) + UInt64(CTDataCollectionManager.shared().getSizeOfVideos()) + UInt64(CTDataCollectionManager.shared().getSizeOfCalendars());
    }
    
    func generateServiceName()->String
    {
        let uuid = UUID().uuidString
        
        return "CT" + uuid.substring(from: uuid.count - 4)
    }
    
    func checkTransferFinished()->Bool
    {
        let count = CTSTMService2.sharedInstance().getNumOfConnectedDevice()
        
        if displayMode != .Transfer
        {
            return false
        }
    
        for i in 0..<count
        {
            let device = CTSTMService2.sharedInstance().getDevice(i)
            
            NSLog("Device Status \(String(describing: device?.status))")
            
            if device?.status != DeviceStatus2.Finished && device?.status != DeviceStatus2.Cancel && device?.status != DeviceStatus2.Disconnected
            {
                return false
            }
        }
        
        return true
    }
    
    func transferDidFinished()
    {
        DispatchQueue.main.async {
            
            let transferStoryboard = CTStoryboardHelper.transferStoryboard()
            
            let vc = CTTransferFinishViewController.initialise(from: transferStoryboard)
            
            if vc != nil
            {
            
                vc?.transferFlow = .sender
                vc?.bMultiDevices = true
                vc?.transferStatusAnalytics = .success
                vc?.fileList = self.fileList
                vc?.totalDataTransferred = NSNumber.init(value:self.senderProcessor.totalTransferSize)
                vc?.dataTransferred = NSNumber.init(value:self.senderProcessor.totalTransferSize)

                let endTime = Date().timeIntervalSince1970
                
                var speed = Double(self.senderProcessor.totalTransferSize) / (endTime - self.startTime) * 8 / (1024 * 1024)
                if (speed < 1) {
                    speed = 1
                }
                
                let speedStr = String.init(format: "%.1f Mbps", speed)
                
                vc?.transferSpeed = speedStr
            
                vc?.transferTime = String(format: "%d", endTime - self.startTime)
                
                if self.navigationController?.topViewController == self
                {
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }
        }
    }
    
    func checkConnectivity()
    {
        var msg = ""
        
        var bWifiAlert = false
        var bBLAlert = false
        if CTNetworkUtility.isWiFiEnabled() == false
        {
            bWifiAlert = true
            
            msg = msg.appending(CTLocalizedString(ALERT_MESSAGE_PLEASE_TURN_ON_WIFI, comment: ""))
        }
        
        if bluetoothAvailable == true
        {
            
            if bWifiAlert == false
            {
                msg = msg.appending(CTLocalizedString(CT_TURN_OFF_BT_ALERT_CONTEXT, comment: ""))
            }
            else
            {
                msg = msg.appending(" " + CTLocalizedString(CT_AND_TURN_OFF_BT_STRING, comment: ""))
            }
            bBLAlert = true
            
        }
        
        msg = msg.appending("." )
        
        if bWifiAlert && !bBLAlert {
           msg = msg.appending(CTLocalizedString(CT_WIFI_PATH, comment: ""))
        }
        
        if !bWifiAlert && bBLAlert {
           msg = msg.appending(CTLocalizedString(CT_BT_PATH, comment: ""))
        }
        
        if bWifiAlert && bBLAlert {
           msg = msg.appending(CTLocalizedString(CT_WIFI_AND_BT_PATH, comment: ""))
        }
        
        
        if bWifiAlert == true || bBLAlert == true
        {
            qrCodeImageView.isHidden = true;
            
            warningLabel.text = msg;
            
            if bWifiAlert != bOldWifiAlert || bBLAlert != bOldBLAlert
            {
                if (CTContentTransferSetting.userCustomVerizonAlert()) {
                    CTVerizonAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: msg, cancelBtnText: CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, comment: ""), confirmBtnText: CTLocalizedString(CTAlertGeneralIgnoreTitle, comment: ""), confirmHandler: nil, cancelHandler: { (alertVC: CTVerizonAlertViewController) in
                        
                        if bWifiAlert == true && bBLAlert == true
                        {
                            CTSettingsUtility.openRootSettings()
                        }
                        else if bWifiAlert == true
                        {
                            CTSettingsUtility.openWifiSettings()
                        }
                        else
                        {
                            CTSettingsUtility.openBluetoothSettings()
                        }
                        
                    }, isGreedy: false, from: self)
                } else {
                    CTAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CTAlertGeneralTitle, comment: ""), context: msg, cancelBtnText: CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, comment: ""), confirmBtnText: CTLocalizedString(CTAlertGeneralIgnoreTitle, comment: ""), confirmHandler: { (action) in
                    }, cancelHandler: { (action) in
                        
                        if bWifiAlert == true && bBLAlert == true
                        {
                            CTSettingsUtility.openRootSettings()
                        }
                        else if bWifiAlert == true
                        {
                            CTSettingsUtility.openWifiSettings()
                        }
                        else
                        {
                            CTSettingsUtility.openBluetoothSettings()
                        }
                    }, isGreedy: false)
                }
            }
        }
        else
        {
            if displayMode == .Connect
            {
                qrCodeImageView.isHidden = false;
                warningLabel.text = ""
            }
        }
        
        bOldBLAlert = bBLAlert
        bOldWifiAlert = bWifiAlert
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Checking state")
        switch (central.state)
        {
        case .poweredOn:

            bluetoothAvailable = true;
            
        default:
            
            bluetoothAvailable = false
        }
        
        checkConnectivity()
    }
    
    @objc private func checkWifiConnectionAgain() {
        
        checkConnectivity()
    }
    

    
}

// CTTransferSenderViewController
extension UILabel {
    func dynamicHeight(for width:CGFloat) -> CGFloat {
        let constraint: CGSize = CGSize.init(width: width, height: CGFloat.greatestFiniteMagnitude)
        let context = NSStringDrawingContext()
        let text: NSString = self.text! as NSString
        let boundingBox = text.boundingRect(with: constraint, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font:self.font], context: context).size
        
        return ceil(boundingBox.height)
    }
}
