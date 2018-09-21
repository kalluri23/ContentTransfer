//
//  CTSTMSenderProcessor.swift
//  contenttransfer
//
//  Created by Zhang, Yichun on 3/28/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit
import Foundation
import MultipeerConnectivity
import Photos

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex..<self.endIndex])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

class CTSTMSenderProcessor: NSObject {
    public var transferService:CTSTMService2?
    public var photoManager : CTPhotosManager! = nil
    public var videoManager : CTPhotosManager! = nil
    public var totalTransferSize:UInt64! = 0
    public var totalTransferFile:UInt! = 0
    public var totalSendOutSize:UInt64! = 0
    public var totalSentFile:UInt64! = 0
    
    static let sharedInstance = CTSTMSenderProcessor()
    
    func processData(data:Data, peer:MCPeerID)
    {
        let requestStr = String.init(data: data, encoding: .utf8)
        
        NSLog("Sender Receive Request \(String(describing: requestStr))")
        
        if(requestStr?.contains("VZCONTENTTRANSFERSECURITYKEYFROMSENIOS"))!
        {
            let param = requestStr!.components(separatedBy: "#")
            
            if param.count == 4
            {
                //                let buildVersion = param[1]
                //                let minVersion = param[2]
                let space = param[3]
                
                let freespace = UInt64(space.substring(from:"space".count))
                
                if freespace != nil
                {
                    transferService?.updateDeviceFreeSpace(freespace!, peer: peer)
                }
            }
        }
        if (requestStr?.contains(CT_REQUEST_FILE_CONTACT_HEADER))!
        {
            DispatchQueue.main.async{
                self.sendContact(peer: peer)
            }
        }
        else if (requestStr?.contains(CT_REQUEST_FILE_CALENDARS_HEADER))!
        {
            
            let path = requestStr?.substring(from: CT_REQUEST_FILE_CALENDARS_HEADER.count)
            
            DispatchQueue.main.async{
                
                self.sendCalender(path: path!, peer: peer)
            }
            
        }
        else if (requestStr?.contains(CT_REQUEST_FILE_REMINDER_HEADER))!
        {
            DispatchQueue.main.async{
                self.sendReminder(peer: peer)
            }
        }
        else if (requestStr?.contains(CT_REQUEST_FILE_PHOTO_HEADER + "DUPLICATE_"))!
        {
            let offset = (CT_REQUEST_FILE_PHOTO_HEADER + "DUPLICATE_").count
            
            let param = requestStr?.substring(from: offset)
            
            let fileSize = UInt64(param!)
            
            transferService?.updateDataReceived(fileSize!, peer: peer, name: "", isInitTransfer: true)
            
        }
        else if (requestStr?.contains(CT_REQUEST_FILE_PHOTO_HEADER))!
        {
            let path = requestStr?.substring(from: CT_REQUEST_FILE_PHOTO_HEADER.count)
            
            DispatchQueue.main.async{
                self.sendPhoto(path: path!, peer: peer)
            }
        }
        else if (requestStr?.contains(CT_REQUEST_FILE_VIDEO_HEADER + "DUPLICATE_"))!
        {
            let str = requestStr?.substring(from: (CT_REQUEST_FILE_VIDEO_HEADER + "DUPLICATE_").count)
            
            transferService?.updateDataReceived(UInt64(str!)!, peer: peer, name: "", isInitTransfer: true)
        }
        else if (requestStr?.contains(CT_REQUEST_FILE_VIDEO_HEADER))!
        {
            let path = requestStr?.substring(from: CT_REQUEST_FILE_VIDEO_HEADER.count)
            
            DispatchQueue.main.async{
                
                self.sendVideo(path: path!, peer: peer)
            }
        }
        else if (requestStr?.contains(CT_REQUEST_FILE_COMPLETED))!
        {
            DispatchQueue.main.async{
                
                self.processTransferFinished(peer: peer, status:.Finished)
                
            }
        }
        else if (requestStr?.contains(CT_REQUEST_FILE_CANCEL))!
        {
            DispatchQueue.main.async{
                
                self.processTransferFinished(peer: peer, status: .Cancel)
                
            }
        }
        
        transferService?.delegate?.groupStatusChanged()
    }
    
    func sendContact(peer:MCPeerID)
    {
        let url = getContactUrl()
        
        transferService?.startSendResource(url, name: "Contacts", peer: peer)
    }
    
    func sendCalender(path:String, peer:MCPeerID)
    {
        let filePath = (CTUserDefaults.sharedInstance().calendarList! as NSDictionary).object(forKey: path)
        
        let url = URL(fileURLWithPath: filePath as! String)
        
        transferService?.startSendResource(url, name: path, peer: peer)
        
    }
    
    func sendReminder(peer:MCPeerID)
    {
        let url = getReminderUrl()
        
        transferService?.startSendResource(url, name: "Reminders", peer: peer)
    }
    
    func sendPhoto(path:String, peer:MCPeerID)
    {
        NSLog("Send Photo \(path) to \(peer.displayName)")
        
        photoManager.requestPhotoData(forName: path, forLive: false, handler: { (data, error) -> () in
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            
            let documentsDirectory = paths[0]
            
            let fileURL = URL.init(fileURLWithPath: documentsDirectory).appendingPathComponent("photo")
            
            do
            {
                if FileManager.default.fileExists(atPath: fileURL.path)
                {
                    try FileManager.default.removeItem(at: fileURL)
                }
                
                try data?.write(to: fileURL)
                
                self.transferService?.startSendResource(fileURL, name: path, peer: peer)
                
            } catch {
                print("send photo error: \(error)")
                // how to handle the error
            }
        })
    }
    
    func sendVideo(path:String, peer:MCPeerID)
    {
        photoManager.requestVideoData(forName: path, handler: { (obj) -> () in
            
            let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)
            guard iOS8 else {
                fatalError("No iOS 7 supported.")
            }
            
            let asset = obj as? AVURLAsset
            
            if asset != nil {
                self.transferService?.startSendResource((asset?.url)!, name: path, peer: peer)
            }
        })
    }
    
    func processTransferFinished(peer:MCPeerID,status:DeviceStatus2)
    {
        transferService?.setStatusofConnectedDevice(status, peer: peer)
    }
    
    func getContactUrl()->URL
    {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let documentsDirectory = paths[0]
        
        let filePath = documentsDirectory + "/Contacts/ContactsFile.vcf"
        
        
        let fileURL = URL.init(fileURLWithPath: filePath)
        
        /*       do
         {
         
         let data = try Data.init(contentsOf: fileURL, options: .mappedIfSafe)
         
         
         NSLog("cannot open file")
         
         
         } catch let error
         {
         NSLog("cannot open file")
         }*/
        
        return fileURL
    }
    
    func getReminderUrl()->URL
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let documentsDirectory = paths[0]
        
        let fileURL = URL.init(fileURLWithPath: documentsDirectory).appendingPathComponent("Reminders/RemindersFile.txt")
        
        return fileURL
    }
    
}

