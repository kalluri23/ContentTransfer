//
//  CTSTMSenderRecapViewController.swift
//  contenttransfer
//
//  Created by Zhang, Yichun on 4/24/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

public class CTSTMSenderRecapViewController: CTViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var title_label:UILabel! = nil
    private var contentView:UITableView! = nil
    private let deviceCellId  = "CTSTMDeviceTableViewCell"
    private var button_action:CTCommonRedButton! = nil

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = CTColor.white
        
        #if STANDALONE
            
            self.setNavigationControllerMode(.none)
        #else
            self.setNavigationControllerMode(.backAndHamburgar)
        #endif
        
        title_label = UILabel(frame: .zero)
        title_label.backgroundColor = CTColor.white
        title_label.text = CTLocalizedString(CT_STM_SENDER_RECAP_LABEL, comment: "")
        title_label.font = CTMVMFonts.mvmBoldFont(ofSize: 24)
        title_label.textAlignment = .center
        title_label.textColor = CTColor.primaryRed()
        
        
        contentView = UITableView(frame: .zero, style: .plain)
        
        contentView.dataSource = self
        contentView.delegate = self
        contentView.separatorStyle = .singleLine
        contentView.tableFooterView = UIView()
        
        contentView.register(CTSTMRecapTableViewCell.self, forCellReuseIdentifier: deviceCellId)
        
        self.view.addSubview(title_label)
        
        self.view.addSubview(contentView)
        
        
        button_action = CTCommonRedButton(frame: .zero)
        button_action.configure()
        button_action.addTarget(self, action: #selector(button_action_done), for: .touchUpInside)
        button_action.setTitle(CTLocalizedString(CT_STM_SENDER_RECAP_DONE_BUTTON, comment: ""), for: .normal)
        button_action.setTitleColor(CTColor.white, for: .normal)
        button_action.sizeToFit()
        button_action.isEnabled = true
        self.view.addSubview(button_action)
        
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.title = CTLocalizedString(CT_TRANSFER_SUMMARY_VC_NAV_TITLE, comment: "")
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var offsetY:CGFloat = 44 + 20 + 10
        
        if title_label != nil
        {
            title_label.frame = CGRect(x: 0, y: offsetY, width: self.view.frame.size.width, height: 50)
            
            offsetY = offsetY + 50
            
        }

        contentView.frame = CGRect(x: 0, y: offsetY, width: self.view.frame.size.width, height: self.view.frame.size.height - offsetY - 54 - 10)
        
        let buttonWidth = CGFloat(120)
        
        button_action?.frame = CGRect(
            x: (self.view.frame.size.width - buttonWidth)/2,
            y: self.view.frame.size.height - 44 - 10,
            width: buttonWidth,
            height: 44);
        
        button_action?.configure()
    }

    override public func didReceiveMemoryWarning() {
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
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 44
    }
    
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UILabel(frame: .zero)
        header.backgroundColor = CTColor.white
            
        let totalSizeStr = self.formattedDataSizeTextInTransferWhatScreen(byteSize: Double(CTSTMSenderProcessor.sharedInstance.totalTransferSize))
            
        header.text = CTLocalizedString(CT_STM_SENDER_HEADER_TEXT_PART1, comment: "") + "\n" + " \(CTSTMSenderProcessor.sharedInstance.totalSentFile!) " + CTLocalizedString(CT_STM_SENDER_HEADER_TEXT_PART2, comment: "") + " \(totalSizeStr.lowercased())"
        header.textAlignment = .center
        header.numberOfLines = 0
        header.textColor = CTColor.black
        header.font = CTMVMFonts.mvmBookFont(ofSize: 14)
        header.sizeToFit()
            
        return header
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return CTSTMService2.sharedInstance().getNumOfConnectedDevice()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: deviceCellId) as! CTSTMRecapTableViewCell
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            cell.isUserInteractionEnabled = false
            
            let device = CTSTMService2.sharedInstance().getDevice(indexPath.row)
            
            if device != nil
            {
                cell.label_name.text = device!.peerId.displayName
                
                switch(device!.status.rawValue)
                {
                case DeviceStatus2.Connecting.rawValue,DeviceStatus2.Connected.rawValue,DeviceStatus2.Transfer.rawValue:
                    
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
                
                let sendSizeStr = self.formattedDataSizeTextInTransferWhatScreen(byteSize: Double(device!.dataSentSize))
                
                let localizedString = CTLocalizedString(CT_STM_SENDER_FILES_PROGRESS_LABEL, comment: "")
                cell.label_numprogress.text = "\(device!.numOfSentFile) " + localizedString + " / \(sendSizeStr)"
                
                
            }
            
            return cell;
        
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
    
    @objc func button_action_done()
    {
        self.navigationController?.popViewController(animated: true)
    }
    



}
