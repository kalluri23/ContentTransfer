//
//  CTSTMRecvViewController.swift
//  contenttransfer
//
//  Created by Zhang, Yichun on 3/22/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit
import Foundation
import MultipeerConnectivity

enum RecvInfo:Int {
    case host
    case status
    case resource
    case progress
    case endOfInfo
}

@objc public class CTSTMRecvViewController: CTTransferInProgressViewController , CTSTMServiceDelegate2, UITableViewDelegate, UITableViewDataSource, CTSTMRecvProcessorDelegate {
    
//    private var contentView:UITableView!=nil
    
//    private var label_host:UILabel! = nil
//    private var label_name:UILabel! = nil
//    private var label_status:UILabel! = nil
//    private var label_resource:UILabel! = nil
//    private var progress:UIProgressView! = nil
//    private let cellHigh = 66
    
    // Heights for receive progress view tableview cell
    private let kProgressViewTableCellHeight_iPhone: CGFloat =  80.0
    private let kDefaultTableViewCellheight_iPhone : CGFloat =  67.0
    private let kProgressViewTableCellHeight_iPad  : CGFloat = 110.0
    private let kDefaultTableViewCellheight_iPad   : CGFloat =  80.0
    
    
//    private var resourceName:String!=nil
    
    @objc public var recvProcessor = CTSTMRecvProcessor()
    
    private var updateObject: CTSTMDataUpdateObject?
    
//    public var serviceName:String! = nil

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Change delegate from upper class to this class
        CTUserDefaults.sharedInstance().isCancel = false
        CTSTMService2.sharedInstance().delegate = self
        recvProcessor.delegate = self

        self.transferInProgressTableView.register(UINib.init(nibName: "CTTransferInProgressTableCell", bundle: nil), forCellReuseIdentifier: "CTTransferInProgressTableCell")
        self.transferInProgressTableView.register(UINib.init(nibName: "CTProgressViewTableCell", bundle: nil), forCellReuseIdentifier: "CTProgressViewTableCell")
        
        self.cancelButton.addTarget(self, action: #selector(self.handleCancelButtonTapped(_:)), for: .touchUpInside)
        
        self.recvProcessor.addObserver(self, forKeyPath: "receivedDataSize", options: .new, context: nil)
        
        // TODO: CRACK USE KILL THE APP?
//        [[NSNotificationCenter defaultCenter] addObserver:self
//            selector:@selector(applicationWillTerminate:)
//        name:UIApplicationWillTerminateNotification
//        object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitContentTransfer:) name:CT_NOTIFICATION_EXIT_CONTENT_TRANSFER object:nil];

    }
    
    @objc func handleCancelButtonTapped(_ sender:UIButton) {
        
        CTUserDevice().transferStatus = CTTransferStatus.cancelled.rawValue

        if (CTContentTransferSetting.userCustomVerizonAlert()) {
            CTVerizonAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CT_STOP_TRANSFER_ALERT_TITLE, comment: ""), context: CTLocalizedString(CT_STOP_TRANSFER_ALERT_CONTEXT, comment: ""), cancelBtnText: CTLocalizedString(CTAlertGeneralCancelTitle, comment: ""), confirmBtnText: CTLocalizedString(CT_CONFIRM_ALERT_BUTTON_TITLE, comment: ""), confirmHandler: { (alertVC: CTVerizonAlertViewController) in
                
                self.cancelButton.isEnabled = false
                
                self.cancelButton.alpha     = 0.4
                
                self.recvProcessor.cancelTransfer()
                
                CTUserDefaults.sharedInstance().isCancel = true
            }, cancelHandler: nil, isGreedy: true, from: self)
        } else {
            CTAlertCreateFactory.showTwoButtonsAlert(withTitle: CTLocalizedString(CT_STOP_TRANSFER_ALERT_TITLE, comment: ""), context: CTLocalizedString(CT_STOP_TRANSFER_ALERT_CONTEXT, comment: ""), cancelBtnText: CTLocalizedString(CTAlertGeneralCancelTitle, comment: ""), confirmBtnText: CTLocalizedString(CT_CONFIRM_ALERT_BUTTON_TITLE, comment: ""), confirmHandler: { (action) in
                
                self.cancelButton.isEnabled = false
                
                self.cancelButton.alpha     = 0.4
                
                self.recvProcessor.cancelTransfer()
                
                CTUserDefaults.sharedInstance().isCancel = true
            }, cancelHandler: nil, isGreedy: true)
        }
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.recvProcessor.removeObserver(self, forKeyPath: "receivedDataSize") // remove attached observer
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - CTSTMServiceDelegate
    
        
    public func connectRequest(_ host: String!, confirmation confirmHandler: ((Bool) -> Void)!) {
        
        confirmHandler(true)
    }
    
    public func startBrowseError(_ service: CTSTMService2!, error: Error!) {
        
    }
    
    public func startServiceError(_ service: CTSTMService2!, error: Error!) {
        
    }

    public func groupStatusChanged()
    {

    }

    public func recvResourceDidUpdateProgressInfo(_ progress: Progress, resourcename: String) {
        
        self.recvProcessor.updateReceivedSize(UInt64(progress.completedUnitCount), totalSize: UInt64(progress.totalUnitCount), for: resourcename)
        
        // update the received data size in total, not for each file
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "receivedDataSize") {
            // Update UI
            let countClosure = self.recvProcessor.getCountsForCurrentSection()
            
            CTSTMContents.synchronized(lock: self, block: {
                self.updateObject = CTSTMDataUpdateObject.init(receviedSize: self.recvProcessor.getRecvDataSizeInMB(), and: self.recvProcessor.getTotalDataSizeInMB(), and: self.recvProcessor.getTransferSpeed(), and: self.recvProcessor.getTimeLeftString(), and: self.recvProcessor.getRecvStatus(), and: countClosure.0, and: countClosure.1)
            })
            
            if (!Thread.isMainThread) {
                DispatchQueue.main.async {
                    self.transferInProgressTableView.reloadData()
                }
            } else {
                self.transferInProgressTableView.reloadData()
            }
        } else { // Should not happened anywhere
            print("unknown observer:\(String(describing: keyPath))")
        }
    }
    
    //MARK: - UITableViewDataSource & Delegate
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) {
            if (indexPath.row == CTTransferInProgressTableBreakDown.currentTransferringContent.rawValue) {
                return self.kProgressViewTableCellHeight_iPad;
            }
            return self.kDefaultTableViewCellheight_iPad;
        } else {
            if (indexPath.row == CTTransferInProgressTableBreakDown.currentTransferringContent.rawValue) {
                return self.kProgressViewTableCellHeight_iPhone;
            }
            
            if (CTDeviceMarco.isiPhone4AndBelow()) {
                return 40.0;
            } else {
                return self.kDefaultTableViewCellheight_iPhone;
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var localUpdateObj: CTSTMDataUpdateObject?
        
        CTSTMContents.synchronized(lock: self) {
            localUpdateObj = self.updateObject
        }
        
        if (indexPath.row == CTTransferInProgressTableBreakDown.timeLeft.rawValue) {
            let cell: CTTransferInProgressTableCell = tableView.dequeueReusableCell(withIdentifier: "CTTransferInProgressTableCell", for: indexPath) as! CTTransferInProgressTableCell
            cell.keyLabel.text = "Time left"
            if (localUpdateObj != nil) {
                cell.valueLabel.text = localUpdateObj?.timeLeft
            } else {
                cell.valueLabel.text = ""
            }
            
            return cell
        } else if (indexPath.row == CTTransferInProgressTableBreakDown.transferredAmount.rawValue) {
            let cell: CTTransferInProgressTableCell = tableView.dequeueReusableCell(withIdentifier: "CTTransferInProgressTableCell", for: indexPath) as! CTTransferInProgressTableCell
            cell.keyLabel.text = "Received"
            cell.widthOfValueLabel.constant = 180.0
            
            if (localUpdateObj != nil) {
                cell.valueLabel.text = String.init(format: CTLocalizedString(CT_STM_RECEIVER_RATE_FORMATTER, comment: ""), localUpdateObj!.receviedDataSize, (localUpdateObj?.totalDataSize)!)
            } else {
                cell.valueLabel.text = String.init(format: CTLocalizedString(CT_STM_RECEIVER_TOTAL_RATE_FORMATTER, comment: ""), self.recvProcessor.getTotalDataSizeInMB())
            }
            
            return cell;
        } else if (indexPath.row == CTTransferInProgressTableBreakDown.speed.rawValue) {
            let cell: CTTransferInProgressTableCell = tableView.dequeueReusableCell(withIdentifier: "CTTransferInProgressTableCell", for: indexPath) as! CTTransferInProgressTableCell
            cell.keyLabel.text = "Speed";
            if (localUpdateObj != nil) {
                cell.valueLabel.text = String.init(format: "%.1f Mbps", (localUpdateObj?.transferSpeed)!)
            } else {
                cell.valueLabel.text = ""
            }
            
            return cell;
        } else {
            
            let cell: CTProgressViewTableCell = tableView.dequeueReusableCell(withIdentifier: "CTProgressViewTableCell", for: indexPath) as! CTProgressViewTableCell
            
            if (localUpdateObj != nil) {
                cell.keyLabel.text = String.init(format: CTLocalizedString(CT_RECEIVING_AMOUNT, comment: ""), (localUpdateObj?.currentType)!)
                if (localUpdateObj?.currentType == "reminders" || localUpdateObj?.currentType == "contacts") {
                    cell.valueLabel.text = "" // No value for reminders & contacts
                } else {
                    cell.valueLabel.text = String.init(format: "%d/%d", (localUpdateObj?.currentTypeCount)!, (localUpdateObj?.totalCurrentTypeCount)!)
                }
                
                if localUpdateObj?.percentage != nil && (Float((localUpdateObj?.percentage)!) > cell.customProgressView.progress + 0.01)
                {
                    cell.customProgressView.progress = Float((localUpdateObj?.percentage)!);
                }
                
            } else {
                cell.keyLabel.text = CTLocalizedString(CT_STM_RECEIVER_FILE_LIST_LITERAL, comment: "")
                cell.valueLabel.text = ""
                
                cell.customProgressView.progress = 0;
            }
            
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            return cell;
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  CTTransferInProgressTableBreakDown.total.rawValue
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func recvData(_ data: Data!, withPeer peer: MCPeerID!)  {
        
        if (data?.count)! >= CT_SEND_FILE_HOST_HEADER.count
        {
            let headerData = data?.subdata(in: 0..<CT_SEND_FILE_HOST_HEADER.count )
            
            let headStr = String.init(data: headerData!, encoding: .utf8)
            
            if headStr != nil
            {
                if headStr!.contains(CT_SEND_FILE_HOST_HEADER)
                {
                    CTSTMService2.sharedInstance().setupHost(peer)
                    
                    DispatchQueue.main.async {
                        
                        self.recvProcessor.sendFreeSpaceToHost()
                        
//                        self.updateContent()
                    }
                    return
                }
            }
        }
        
        let _ = recvProcessor.processData(data: data!)
    }
    
    public func recvResource(_ resourcename: String!, localURL: URL!) {
        
        recvProcessor.processResource(resourcename, localURL: localURL)
        
    }
    
    public func recvResourceStart(_ resourcename: String) {
        // Should set up the delegate and data resouce
        if (self.transferInProgressTableView.delegate == nil) {
            self.transferInProgressTableView.delegate = self
            self.transferInProgressTableView.dataSource = self
            
            DispatchQueue.main.async {
                self.transferInProgressTableView.reloadData()
            }
        }
    }
    
    // MARK: - CTSTMRecvProcessorDelegate Methods
    public func transferFinishRequestDidSent() {
        print("Transfer did finish, should pop to saving page. Should reuse the same saving logic")
        
        // Need to clean something?
        if (!Thread.isMainThread) {
            DispatchQueue.main.async {
                self._viewShouldGoToSavingView()
            }
        } else {
            self._viewShouldGoToSavingView()
        }
    }
    
    public func recvLostHost()
    {
 //       DispatchQueue.main.async {
        
            if recvProcessor.recvStatus == .Contact ||
                recvProcessor.recvStatus == .Calender ||
                recvProcessor.recvStatus == .Reminder ||
                recvProcessor.recvStatus == .Photo ||
                recvProcessor.recvStatus == .Video
            {
                CTUserDevice().transferStatus = CTTransferStatus.interrupted.rawValue
            
                CTUserDefaults.sharedInstance().isCancel = true
        
                self.cancelButton.isEnabled = false
            
                self.cancelButton.alpha     = 0.4
            
                self.recvProcessor.cancelTransfer()
            
                CTSTMService2.sharedInstance().delegate = nil;

            }
 //       }

    }
    
    
    private func _viewShouldGoToSavingView() {
        
        if self.navigationController?.topViewController != self
        {
            return
        }
        let targetViewController: CTDataSavingViewController = CTDataSavingViewController.init(nibName: NSStringFromClass(CTTransferInProgressViewController.self), bundle: CTBundle.resourceBundle())
        
        targetViewController.transferFlow = CTTransferFlow.receiver
        
        targetViewController.allowSave    = true
        
        // Get the average speed
        let speedStr = String.init(format: "%.1f Mbps", self.recvProcessor.getTransferSpeed())
        targetViewController.transferSpeed = speedStr
        
        // Get transfer time in timestamp
        let stopTime = Date()
        print("Transfer finished at \(stopTime)")
        let startTime: Date = self.recvProcessor.getStartTime()
        let timeTaken: TimeInterval = stopTime.timeIntervalSince(startTime)
        print("Transfer time taken:\(timeTaken)")
        
        targetViewController.transferTime = String.init(format: "%f", timeTaken)
        
        // Get the total amount data size which should be transferred.
        targetViewController.totalDataAmount = NSNumber.init(value:self.recvProcessor.getTotalDataSize())
        print("Total data amount: \(targetViewController.totalDataAmount)")
        
        /** 
          * Get the total amount data size which actually getting trasferred
          * Type: MB
          */
        targetViewController.transferredDataAmount = NSNumber.init(value: self.recvProcessor.getRecvDataSizeInMB())
        
        self.navigationController?.pushViewController(targetViewController, animated: true)
    }
    
    public func duplicateFileShouldUpdateUI() {
        // Should set up the delegate and data resouce
        if (self.transferInProgressTableView.delegate == nil) {
            self.transferInProgressTableView.delegate = self
            self.transferInProgressTableView.dataSource = self
            
            DispatchQueue.main.async {
                self.transferInProgressTableView.reloadData()
            }
        }
    }
}
