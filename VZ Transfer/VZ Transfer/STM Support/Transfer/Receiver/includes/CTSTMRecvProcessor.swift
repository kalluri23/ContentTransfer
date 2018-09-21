//
//  CTSTMRecvProcessor.swift
//  contenttransfer
//
//  Created by Zhang, Yichun on 3/28/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

public enum RecvStatus:Int {
    case Idle
    case Contact
    case Calender
    case Reminder
    case Photo
    case Video
    case Finished
    case Cancel
    case NoEnoughStorage
}

public protocol CTSTMRecvProcessorDelegate {
    func transferFinishRequestDidSent()
    func duplicateFileShouldUpdateUI()
}

public class CTSTMRecvProcessor: NSObject {
    
    public var recvStatus = RecvStatus.Idle
    
    private var recvData:Data!
    
    private var fileList:NSDictionary!=nil

    private var photoLists = [Array<Any>]() // Save the photos list, not necessary, but just follow the pattern so we can re-use the saving code.
    private var videoLists = [Array<Any>]() // Save the videos list, not necessary, but just follow the pattern so we can re-use the saving code.
    
    private var actualSaveVideoList = NSMutableArray()
    private var actualSavePhotoList = NSMutableArray()
    private var duplicateMap = NSMutableDictionary()
    
    private var calenderIndex = 0
    
    private var photoIndex = 0 // Number of photo transfered, include duplicate
    private var videoIndex = 0 // Number of video transfered, include duplicate
    
    private var calenderCount = 0 // Number of calendar count
    
    private var photoCount = 0
    private var videoCount = 0
    
    private var photoActualCount = 0 // Actual photo saved count, not file transfered, because of duplicate
    private var videoActualCount = 0 // Actual video saved count, not file transfered, because of duplicate
    
    private var totalDataSize:UInt64 = 0
    @objc private dynamic var receivedDataSize:UInt64 = 0
//    private var receivedDataSizeHold:UInt64 = 0
    private var sizeMap: NSMutableDictionary = [:]
    
    private let maxRequests = 1
    private var currentRequests = 0
    
    private var contactSize: UInt64 = 0
    private var calenderSize:UInt64 = 0
    private var reminderSize:UInt64 = 0
    private var photoSize:UInt64 = 0
    private var videoSize:UInt64 = 0
    private var availableStorage:UInt64 = 0
    
    private var startTime: Date?
    private var transferSpeed: Double = 0
    private var timeLeft: Double = 0
    
    @objc public var transferService:CTSTMService2?
    private var fileManager:CTFileLogManager?
    
    public var delegate: CTSTMRecvProcessorDelegate?
    
    // For duplicate logic
//    private var duplicateStartTime: Date? // Mark the the timestamp when start receiving as duplicate.
//    private var duplicateDuration : TimeInterval? // Time duration for receiving all duplicate files, when calculate the speed, should remove it from the total time duration.
    
    private var isDuplicate: Bool = false
    
    public var receiveFlags: NSMutableArray = []
    
    override public init(){
        
        fileManager = CTFileLogManager()
        
        super.init()
        
        self.resetData()
    }
    
    func resetData()
    {
        recvData             = Data(capacity: 0)
        calenderIndex        = 0
        photoIndex           = 0
        videoIndex           = 0
        calenderCount        = 0
        photoCount           = 0
        videoCount           = 0
        receivedDataSize     = 0
//        receivedDataSizeHold = 0
        totalDataSize        = 0
        transferSpeed        = 0
        timeLeft             = 0
        availableStorage     = getFreeSpace()
        recvStatus           = .Idle
        isDuplicate          = false
        receiveFlags         = ["false", "false", "false", "false", "false"] // contact, calendar, reminder, photo, video
    }
    
    
    func sendNextRequest()
    {
        // means no more action
        
//        let itemList = fileList.object(forKey: "itemList")

        switch(recvStatus)
        {
        case .Idle:
            break;
        case .Contact:
            // Send Contact Request
            self.isDuplicate = false
            
//            if itemList != nil
//            {
//                let contactInfo = (itemList as! NSDictionary).object(forKey: METADATA_ITEMLIST_KEY_CONTACTS)
            
//                if contactInfo != nil
//                {
//                    let status = (contactInfo as! NSDictionary).object(forKey: "status")
            
                    if (self.fileManager?.fileList.contactSelected)!
                    {
                        self.fileManager?.contactStarted = true
                        self.receiveFlags[0] = "true"
                        let reqData = CT_REQUEST_FILE_CONTACT_HEADER.data(using: .utf8)
                        
                        transferService?.sendPacket(transferService?.hostDevice.peerId, data: reqData!)
                    }
                    else
                    {
                        recvStatus = .Calender
                        
                        DispatchQueue.main.async{
                            self.sendNextRequest()
                        }
                        
                    }
//                }
//            }
            break;
        case .Calender:
            
            self.isDuplicate = false
            
//            if itemList != nil
//            {
//                let calInfo = (itemList as! NSDictionary).object(forKey: METADATA_ITEMLIST_KEY_CALENDARS)
            
//                if calInfo != nil
//                {
//                    let status = (calInfo as! NSDictionary).object(forKey: "status")
            
                    if (self.fileManager?.fileList.calendarSelected)!
                    {
                        self.receiveFlags[1] = "true"
                        self.fileManager?.calendarStarted = true
                        let obj = UserDefaults.standard.object(forKey: "calFileList")
                        
                        if obj != nil
                        {
                            let calFileList = obj as! NSArray
                            self.calenderCount = calFileList.count
                            
                            if calenderIndex < calFileList.count
                            {
                                let calFileInfo = calFileList[calenderIndex] as! NSDictionary
                                let reqStr = CT_REQUEST_FILE_CALENDARS_HEADER + (calFileInfo["Path"] as! String)
                                let reqData = reqStr.data(using: .utf8)
                                
                                transferService?.sendPacket(transferService?.hostDevice.peerId, data: reqData!)
                            }
                            else
                            {
                                recvStatus = .Reminder
                                DispatchQueue.main.async{
                                    self.sendNextRequest()
                                }
                            }
                            
                            
                        }
                    }
                    else
                    {
                        recvStatus = .Reminder
                        DispatchQueue.main.async{
                            self.sendNextRequest()
                        }
                    }
//                }
//            }
            break;
        case .Reminder:
            
            self.isDuplicate = false
            
//            if itemList != nil
//            {
//                let reminderInfo = (itemList as! NSDictionary).object(forKey: METADATA_ITEMLIST_KEY_REMINDERS)
            
//                if reminderInfo != nil
//                {
//                    let status = (reminderInfo as! NSDictionary).object(forKey: "status")
            
                    if (self.fileManager?.fileList.reminderSelected)!
                    {
                        self.receiveFlags[2] = "true"
                        self.fileManager?.reminderStarted = true
                        let reqData = CT_REQUEST_FILE_REMINDER_HEADER.data(using: .utf8)
                        transferService?.sendPacket(transferService?.hostDevice.peerId, data: reqData!)
                    }
                    else
                    {
                        recvStatus = .Photo
                        DispatchQueue.main.async{
                            self.sendNextRequest()
                        }
                    }
//                }
//            }
            break;
        case .Photo:
//            if itemList != nil
//            {
//                let photoInfo = (itemList as! NSDictionary).object(forKey: METADATA_ITEMLIST_KEY_PHOTOS)
            
//                if photoInfo != nil
//                {
//                    let status = (photoInfo as! NSDictionary).object(forKey: "status")
            
                    if (self.fileManager?.fileList.photoSelected)!
                    {
                        self.receiveFlags[3] = "true"
                        self.fileManager?.photoStarted = true
                        let obj = UserDefaults.standard.object(forKey: "photoFilteredFileList")
                        
                        if obj != nil
                        {
                            let photoFileList = obj as! NSArray
                            
                            photoCount = photoFileList.count
                            
                            if photoIndex + currentRequests < photoFileList.count
                            {
                                
                                let photoFileInfo = photoFileList[photoIndex + currentRequests] as! NSDictionary
                                
                                let photoName = photoFileInfo["Path"]  as! String
                                
                                if !self.checkDuplicateFile(name: photoName, type: "photo")
                                {
                                    self.isDuplicate = false
                                    self.duplicateMap.setObject(photoFileInfo, forKey: photoName as NSCopying)
                                    
                                    let reqStr = CT_REQUEST_FILE_PHOTO_HEADER + (photoFileInfo["Path"] as! String)
                                    let reqData = reqStr.data(using: .utf8)
                                
                                    transferService?.sendPacket(transferService?.hostDevice.peerId, data: reqData!)
                                
                                    currentRequests = currentRequests + 1
                                
                                    if currentRequests < maxRequests && (photoFileList.count - photoIndex - currentRequests > 0)
                                    {
                                        DispatchQueue.main.async{
                                            self.sendNextRequest()
                                        }
                                    }
                                }
                                else
                                {   // Duplicate file for photos
                                    self.isDuplicate = true
                                    self.transferSpeed = 1
                                    
                                    let fileSize =  UInt64(photoFileInfo["Size"] as! String)
                                    let reqStr = CT_REQUEST_FILE_PHOTO_HEADER + "DUPLICATE_\(fileSize!)";
                                    
                                    let reqData = reqStr.data(using: .utf8)
                                    
                                    receivedDataSize += fileSize!
                                    
                                    transferService?.sendPacket(transferService?.hostDevice.peerId, data: reqData!)
                                    
                                    photoIndex += 1
                                    
                                    self.delegate?.duplicateFileShouldUpdateUI()
                                    
                                    let popTime = 0.05 // Delay 0.05 for UI and user friendly purpose
                                    DispatchQueue.main.asyncAfter(deadline: .now() + popTime, execute: {
                                        if self.photoIndex == photoFileList.count
                                        {
                                            // end of the photo
                                            self.photoLists.append(self.actualSavePhotoList as! Array<Any>)
                                            CTUserDefaults.sharedInstance().tempPhotoLists = self.photoLists
                                            
                                            // Number of received and number of saved could be different beacuse the duplicate logic.
                                            CTUserDefaults.sharedInstance().numberOfPhotosReceived = photoFileList.count
                                            UserDefaults.standard.setValue(self.photoActualCount, forKey: "ACTUAL_SAVE_PHOTO")
                                            
                                            self.currentRequests = 0
                                            self.recvStatus = .Video
                                        }
                                        
                                        DispatchQueue.main.async{
                                            self.sendNextRequest()
                                        }
                                    })
                                }
                            }
                            
                        }
                    }
                    else
                    {
                        recvStatus = .Video
                        DispatchQueue.main.async{
                            self.sendNextRequest()
                        }
                    }
//                }
//            }
            break;
        case .Video:
//            if itemList != nil
//            {
//                let videoInfo = (itemList as! NSDictionary).object(forKey: METADATA_ITEMLIST_KEY_VIDEOS)
//            
//                if videoInfo != nil
//                {
//                    let status = (videoInfo as! NSDictionary).object(forKey: "status")
            
                    if (self.fileManager?.fileList.videoSelected)!
                    {
                        print("---->Selected video file")
                        self.receiveFlags[4] = "true"
                        self.fileManager?.videoStarted = true
                        let obj = UserDefaults.standard.object(forKey: "videoFilteredFileList")
                        
                        if obj != nil
                        {
                            let videoFileList = obj as! NSArray
                            
                            videoCount = videoFileList.count
                            
                            if videoIndex  + currentRequests < videoFileList.count
                            {
                                
                                let videoFileInfo = videoFileList[videoIndex + currentRequests] as! NSDictionary
                                print("---->Request video info: \(videoFileInfo)")
                                let videoName = videoFileInfo["Path"]  as! String
                                
                                if !self.checkDuplicateFile(name: videoName, type: "video")
                                {
                                    print("---->No duplicate file")
                                    self.isDuplicate = false
                                    self.duplicateMap.setObject(videoFileInfo, forKey: videoName as NSCopying)
                                    
                                    let reqStr = CT_REQUEST_FILE_VIDEO_HEADER + (videoFileInfo["Path"] as! String)
                                    let reqData = reqStr.data(using: .utf8)
                                    print("---->Sending video request: \(reqStr), \(reqData?.count ?? 0)")
                                
                                    transferService?.sendPacket(transferService?.hostDevice.peerId, data: reqData!)
                                    
                                    currentRequests = currentRequests + 1
                                    print("---->Requested video \(videoIndex) of \(videoCount)")
                                    if currentRequests < maxRequests && videoIndex + currentRequests < videoCount
                                    {
                                        DispatchQueue.main.async{
                                        
                                            self.sendNextRequest()
                                    
                                        }
                                    }
                                    
                                }
                                else
                                {
                                    self.isDuplicate = true
                                    self.transferSpeed = 1
                                    
                                    let fileSize =  UInt64(videoFileInfo["Size"] as! String)
                                    let reqStr = CT_REQUEST_FILE_VIDEO_HEADER + "DUPLICATE_\(fileSize!)";
                                    
                                    let reqData = reqStr.data(using: .utf8)
                                    
                                    receivedDataSize += fileSize!
                                    
                                    transferService?.sendPacket(transferService?.hostDevice.peerId, data: reqData!)
                                    
                                    videoIndex += 1
                                    
                                    self.delegate?.duplicateFileShouldUpdateUI()
                                    
                                    let popTime = 0.05 // Delay 0.05 for UI and user friendly purpose
                                    DispatchQueue.main.asyncAfter(deadline: .now() + popTime, execute: {
                                        if self.videoIndex == videoFileList.count {
                                            self.videoLists.append(self.actualSaveVideoList as! Array<Any>)
                                            CTUserDefaults.sharedInstance().tempVideoLists = self.videoLists
                                            
                                            // Number of received and number of saved could be different beacuse the duplicate logic.
                                            CTUserDefaults.sharedInstance().numberOfVideosReceived = videoFileList.count
                                            UserDefaults.standard.setValue(self.videoActualCount, forKey: "ACTUAL_SAVE_VIDEO")
                                            
                                            self.currentRequests = 0
                                            self.recvStatus = .Finished
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.sendNextRequest()
                                        }
                                    })
                                }
                            }
 /*                           else
                            {
			    	
                                recvStatus = .Finished
                                DispatchQueue.main.async{
                                    self.sendNextRequest()
                                }
                            }*/
                            
                        }
                    }
                    else
                    {
                        recvStatus = .Finished
                        DispatchQueue.main.async{
                            self.sendNextRequest()
                        }
                    }
//                }
//            }
            break;
        case .Finished:
            
            self._calulateSpeed()
            
            UserDefaults.standard.set(self.receiveFlags, forKey: USER_DEFAULTS_RECEIVE_FLAGS)
            
            let reqData = CT_REQUEST_FILE_COMPLETED.data(using: .utf8)
             transferService?.sendPacket(transferService?.hostDevice.peerId, data: reqData!)
	     
            // Notify finish request already sent
            self.delegate?.transferFinishRequestDidSent()
	     
            break;
        case .Cancel:
            
            self._calulateSpeed()
            
            UserDefaults.standard.set(self.receiveFlags, forKey: USER_DEFAULTS_RECEIVE_FLAGS)
            
            if CTSTMService2.sharedInstance().hostDevice != nil && CTSTMService2.sharedInstance().hostDevice.status != DeviceStatus2.Cancel
            {
                let reqData = CT_REQUEST_FILE_CANCEL.data(using: .utf8)
            
                transferService?.sendPacket(transferService?.hostDevice.peerId, data: reqData!)
            }
            else
            {
                CTSTMService2.sharedInstance().delegate = nil;
            }
            
            saveInfoForCancel()
            
            // Notify finish request already sent
            self.delegate?.transferFinishRequestDidSent()

            break;
        case .NoEnoughStorage:
            
            CTUserDefaults.sharedInstance().isCancel = true
            recvStatus = .Cancel
        
            DispatchQueue.main.async{
                self.sendNextRequest()
            }
            break;
        }
    }
    
    func saveInfoForCancel()
    {
        if self.receiveFlags[3] as! String == "true"
        {
            if photoIndex != photoCount
            {
                let obj = UserDefaults.standard.object(forKey: "photoFilteredFileList")
                if obj != nil
                {
//                    let photoFileList = obj as! NSArray
                    // Photo transfer done, should save the photo temp file process for saving logic
                    // TODO: This only work for finish transfer photo, what about cancel in the middle of transfer photos?
                    self.photoLists.append(self.actualSavePhotoList as! Array<Any>)
                    CTUserDefaults.sharedInstance().tempPhotoLists = self.photoLists
                    
                    // Number of received and number of saved could be different beacuse the duplicate logic.
                    CTUserDefaults.sharedInstance().numberOfPhotosReceived = self.actualSavePhotoList.count
                    UserDefaults.standard.setValue(self.photoActualCount, forKey: "ACTUAL_SAVE_PHOTO")
                }
            }
        }
        
        if self.receiveFlags[4] as! String == "true"
        {
            if videoIndex < videoCount
            {
                let obj = UserDefaults.standard.object(forKey: "videoFilteredFileList")
                
                if obj != nil
                {
//                    let videoFileList = obj as! NSArray
                    // Photo transfer done, should save the photo temp file process for saving logic
                    // TODO: This only work for finish transfer photo, what about cancel in the middle of transfer photos?
                    self.videoLists.append(self.actualSaveVideoList as! Array<Any>)
                    CTUserDefaults.sharedInstance().tempVideoLists = self.videoLists
                    
                    // Number of received and number of saved could be different beacuse the duplicate logic.
                    CTUserDefaults.sharedInstance().numberOfVideosReceived = self.actualSaveVideoList.count
                    UserDefaults.standard.setValue(self.videoActualCount, forKey: "ACTUAL_SAVE_VIDEO")
                }
            }
        }
    }
    
    @objc public func processData(data:Data) // TDOO: Is this bool type necessary?
    {
        // Capture the start time when receive the first package
        self.startTime = Date()
        
        recvData.append(data)
        
        switch(recvStatus)
        {
        case .Idle:
            
            let headerSize = CT_SEND_FILE_LIST_HEADER.count + CTSTMContents.DATAHEADERLENGTH
            
            if recvData.count >= headerSize
            {
                let headerData = recvData.subdata(in: 0..<headerSize )
                
                let Tag = String.init(data: headerData, encoding: .utf8)
                
                if (Tag?.contains(CT_SEND_FILE_LIST_HEADER))!
                {
                    // we found the header
                    let fileListSizeData = headerData.subdata(in: CT_SEND_FILE_LIST_HEADER.count..<headerSize)
                    
                    let fileListStr = String.init(data: fileListSizeData, encoding: .utf8)
                    
                    let fileListSize = Int(fileListStr!)
                    
                    
                    if(data.count >= headerSize + fileListSize!)
                    {
                        // we got data
                        print("-->Received file list")
                        let fileListData = recvData.subdata(in: headerSize..<headerSize + fileListSize!)
                        
                        do
                        {
                            fileList = try JSONSerialization.jsonObject(with: fileListData, options: .mutableContainers) as! NSDictionary
                            print("--->Parse file list data: \(fileList)")
                            if fileList != nil
                            {
                                resetData()
                                
                                fileManager?.storeFileList(fileListData)
                                
                                calculatetotalDownloadableDataSize()
                                
                                
                                if(self.availableStorage > self.totalDataSize)
                                {
                                    recvStatus = .Contact
                                    DispatchQueue.main.async{
                                        self.sendNextRequest()
                                    
                                    }
                                }
                                else
                                {
                                    recvStatus = .NoEnoughStorage
                                    
                                    DispatchQueue.main.async{
                                        
                                        self.sendNextRequest()
                                        
                                    }
                                }
                                
                                recvData.removeAll()
//                                return true
                            }
                            else
                            {
                                // should never be in here
                            }
                            
                        } catch let error
                        {
                            NSLog("%@", "Error for parsing JSON: \(error)")
                        }
                    }
                    else
                    {
                        // need more data
//                        return false
                    }
                }
            }
        case .Contact:
            break;
        case  .Calender:
            break;
        case .Reminder:
            break;
        case .Photo:
            break;
        case .Video:
            break;
        default:
            break;
        }
//        return false
    }
    
    // TODO: I think still hold back the transfer
    func storeTempFile(_ resoucename: String, localURL: URL) -> UInt64 {
        
        let documentPath: String = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))[0]
        
        var fileURL: URL?
        switch recvStatus {
        case .Contact:
            fileURL = URL.init(fileURLWithPath: documentPath).appendingPathComponent("VZAllContactBackup.vcf")
            break
        case .Photo:
//            // No need to create when on-to-many comes after select device, otherwise need to change the create folder place. For now just read it.
            print("->try to save photo: \(resoucename)")
            self.photoActualCount += 1 // add real saving count, should not call this when it is duplicate logic
            self.actualSavePhotoList.add(self.duplicateMap.object(forKey: resoucename) as! NSDictionary)
            let folderPath: URL = URL.init(fileURLWithPath: CTUserDefaults.sharedInstance().photoTempFolder)
            fileURL = folderPath.appendingPathComponent(resoucename)
            break
        case .Video:
            print("--->Try to save video: \(resoucename)")
            self.videoActualCount += 1 // add real saving count, should not call this when it is duplicate logic
            self.actualSaveVideoList.add(self.duplicateMap.object(forKey: resoucename) as! NSDictionary)
            let folderPath: URL = URL.init(fileURLWithPath: CTUserDefaults.sharedInstance().videoTempFolder)
            fileURL = folderPath.appendingPathComponent(resoucename)
            break
        case .Calender:
            let folderPath: URL = URL.init(fileURLWithPath: documentPath).appendingPathComponent("ReceivedCal")
            self._createFolderForPaht(folderPath)
            
            let calFileList: NSArray = UserDefaults.standard.object(forKey: "calFileList") as! NSArray
            let calendar: NSDictionary = calFileList[self.calenderIndex] as! NSDictionary // Get current calendar info
            let calName = String.init(format: "%@_%@", calendar.value(forKey: "CalColor") as! String, calendar.value(forKey: "Path") as! String)
            fileURL = folderPath.appendingPathComponent(calName)
            
            break
        case .Reminder:
            fileURL = URL.init(fileURLWithPath: documentPath).appendingPathComponent("reminderLogFile.txt")
            break
        default:
            break
        }
    
        if fileURL != nil
        {
            return self._writeFileIntoDisk(fileURL!, from: localURL)
        }
        else
        {
            return 0
        }
    }
    
    private func _createFolderForPaht(_ url: URL) {
        if (!FileManager.default.fileExists(atPath: url.path)) { // folder doesn't exist, create one
            do  {
                try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("Directory created error: \(error)")
            }
        }
    }
    
    private func _writeFileIntoDisk(_ fileURL: URL, from localURL: URL) -> UInt64 {
        var fileSize: UInt64 = 0
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: localURL.path)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            
            if FileManager.default.fileExists(atPath: fileURL.path){
                try FileManager.default.removeItem(at: fileURL) // Remove old file. Basically won't happen, because we remove from very first screen.
            }
            
            try FileManager.default.moveItem(at: localURL, to: fileURL)
        } catch {
            NSLog("%@", "Error for recvResource: \(error)")
        }
        
        return fileSize
    }
    
    func processResource(_ resoucename:String, localURL: URL)
    {
        print("-->Process received file")
        let size: UInt64 = self.storeTempFile(resoucename, localURL: localURL)
        print("-->File size:\(size)")
//        self.receivedDataSizeHold = self.receivedDataSize // hold static data size when one file completely transfered
        CTSTMContents.synchronized(lock: self) {
            self.sizeMap.removeObject(forKey: resoucename) // remove the finished file from hash table
        }
        
        switch(recvStatus)
        {
        case .Contact:
            recvStatus = .Calender
            break;
        case .Calender:
            calenderIndex = calenderIndex + 1
            break;
        case .Reminder:
            recvStatus = .Photo
            break;
        case .Photo:
            photoIndex = photoIndex + 1
            currentRequests = currentRequests - 1
//            receivedDataSize = receivedDataSize + size;
            if photoIndex == photoCount
            {
                let obj = UserDefaults.standard.object(forKey: "photoFilteredFileList")
                if obj != nil
                {
                    let photoFileList = obj as! NSArray
                    // Photo transfer done, should save the photo temp file process for saving logic
                    // TODO: This only work for finish transfer photo, what about cancel in the middle of transfer photos?
                    self.photoLists.append(self.actualSavePhotoList as! Array<Any>)
                    CTUserDefaults.sharedInstance().tempPhotoLists = self.photoLists
                    
                    // Number of received and number of saved could be different beacuse the duplicate logic.
                    CTUserDefaults.sharedInstance().numberOfPhotosReceived = photoFileList.count
                    UserDefaults.standard.setValue(self.photoActualCount, forKey: "ACTUAL_SAVE_PHOTO")
                }

                currentRequests = 0
                recvStatus = .Video
            }
            break;
        case .Video:
            videoIndex = videoIndex + 1
            print("-->current video index:\(videoIndex)")
            currentRequests = currentRequests - 1
//            receivedDataSize = receivedDataSize + size;
            
            if videoIndex == videoCount
            {
                print("-->video all received, come to finish page")
                let obj = UserDefaults.standard.object(forKey: "videoFilteredFileList")
                
                if obj != nil
                {
                    let videoFileList = obj as! NSArray
                    // Photo transfer done, should save the photo temp file process for saving logic
                    // TODO: This only work for finish transfer photo, what about cancel in the middle of transfer photos?
                    self.videoLists.append(self.actualSaveVideoList as! Array<Any>)
                    CTUserDefaults.sharedInstance().tempVideoLists = self.videoLists
                    
                    // Number of received and number of saved could be different beacuse the duplicate logic.
                    CTUserDefaults.sharedInstance().numberOfVideosReceived = videoFileList.count
                    UserDefaults.standard.setValue(self.videoActualCount, forKey: "ACTUAL_SAVE_VIDEO")
                }
	    
                currentRequests = 0
                recvStatus = .Finished
            }
            break;
        default:
            break
        }
        
        DispatchQueue.main.async{
            print("-->Send next request")
            print("===================================")
            self.sendNextRequest()
        }
    }
    
    /**
     * Get total data size which should be received
     * @return size in Byte
     */
    func getTotalDataSize()->UInt64
    {
        return totalDataSize
    }
    
    /**
     * Get total data size which should be received
     * @return size in MB
     */
    func getTotalDataSizeInMB() -> Double {
        var size = Double(self.totalDataSize) / Double(1024 * 1024) // MB
        if (size > 0 && size < 0.1) {
            size = 0.1
        }
        return size
    }
    
    /**
     * Get total data size which actually received
     * @return size in Byte
     */
    func getRecvDataSize()->UInt64
    {
        return receivedDataSize
    }

    /**
     * Get total data size which actually received
     * @return size in MB
     */
    func getRecvDataSizeInMB() -> Double {
        var size = Double(self.receivedDataSize) / Double(1024 * 1024)
        if (size > 0 && size < 0.1) {
            size = 0.1
        }
        return size
    }
    
    func getRecvStatus() -> String! {
        return String.getMediaType(self.recvStatus)
    }
    
    func getCountsForCurrentSection() -> (Int, Int) {
        switch self.recvStatus {
        case .Photo:
            return (self.photoIndex+1, self.photoCount) // start from 1 not 0, when readable
        case .Video:
            return (self.videoIndex+1, self.videoCount)
        case .Calender:
            return (self.calenderIndex+1, self.calenderCount)
        default:
            return (1, 1) // dummy value, no need count for other data type;
        }
    }
    
    func calculatetotalDownloadableDataSize()
    {

        let dict = UserDefaults.standard.object(forKey:"itemsList_MF") as? NSDictionary
        
        if dict != nil {
            
            let photoItem = dict!.object(forKey: "photos") as? NSDictionary
            
            if photoItem != nil  &&  Bool(photoItem?.object(forKey:"status") as! String)!
            {
                self.photoSize = (photoItem?.object(forKey:"totalSize") as! NSNumber).uint64Value
                
                UserDefaults.standard.setValue(photoItem?.object(forKey:"totalCount"), forKey: "PHOTO_TOTAL_COUNT")
            }
            
            let videoItem = dict!.object(forKey: "videos") as? NSDictionary
            
            if videoItem != nil  &&  Bool(videoItem?.object(forKey:"status") as! String)!
            {
                self.videoSize = (videoItem?.object(forKey:"totalSize") as! NSNumber).uint64Value
                
                UserDefaults.standard.setValue(videoItem?.object(forKey:"totalCount"), forKey: "VIDEO_TOTAL_COUNT")
            }
            
            let contactItem = dict!.object(forKey: "contacts") as? NSDictionary
            
            if contactItem != nil  &&  Bool(contactItem?.object(forKey:"status") as! String)!
            {
                self.contactSize = (contactItem?.object(forKey:"totalSize") as! NSNumber).uint64Value
                
                UserDefaults.standard.setValue(contactItem?.object(forKey:"totalCount"), forKey: "CONTACTS_TOTAL_COUNT")
            }
            
            let calenderItem = dict!.object(forKey: "calendar") as? NSDictionary
            
            if calenderItem != nil  &&  Bool(calenderItem?.object(forKey:"status") as! String)!
            {
                self.calenderSize = (calenderItem?.object(forKey:"totalSize") as! NSNumber).uint64Value
                
                UserDefaults.standard.setValue(calenderItem?.object(forKey:"totalCount"), forKey: "CALENDAR_TOTAL_COUNT")
            }
            
            let reminderItem = dict!.object(forKey: "reminder") as? NSDictionary
            
            if reminderItem != nil  &&  Bool(reminderItem?.object(forKey:"status") as! String)!
            {
                self.reminderSize = (reminderItem?.object(forKey:"totalSize") as! NSNumber).uint64Value
                
                UserDefaults.standard.setValue(reminderItem?.object(forKey:"totalCount"), forKey: "REMINDER_TOTAL_COUNT")
            }

            self.totalDataSize = self.photoSize + self.videoSize + self.contactSize + self.reminderSize + self.calenderSize // total size in byte
        }
    }
    
    func getFreeSpace()->UInt64
    {
        do
        {
            let obj =  try (FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) as NSDictionary).object(forKey: FileAttributeKey.systemFreeSize) as! NSNumber
            

            
            return obj.uint64Value
        }
        catch
        {
    		print("Error catched when getting the free space of the device: \(error)")
            return 0
        }
        
    }
    
    func checkDuplicateFile(name:String,type:String)->Bool
    {
        var localIdentifier: NSString? = nil
        
        if type == "photo"
        {
            if CTDuplicateLists.uniqueList().checkPhotoFile(inDuplicateList: name, localIdentifierReturn: &localIdentifier) == true
            {
                if CTPhotosManager.checkPhoto(withID: localIdentifier as String!)
                {
                    return true
                }
                else
                {
                    CTDuplicateLists.uniqueList().removePhotoFile(fromDuplicateList: localIdentifier as String!)
                }
            }
            else
            {
                
            }
        }
        else if type == "video"
        {
            if CTDuplicateLists.uniqueList().checkVideoFile(inDuplicateList: name, localIdentifierReturn: &localIdentifier)
            {
                if CTPhotosManager.checkVideo(withID: localIdentifier as String!)
                {
                    return true
                }
                else
                {
                    CTDuplicateLists.uniqueList().removeVideoFile(fromDuplicateList: name)
                }
            }
            else
            {
                
            }
        }
        
        return false

    }
    
    @objc public func sendFreeSpaceToHost()
    {
        let freeSpace = self.getFreeSpace()
        
        let buildversion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        let reqStr = "VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#" + buildversion + "#" + BUILD_SAME_PLATFORM_MIN_VERSION + "#space\(freeSpace)"
        
        self.transferService?.sendPacket(transferService?.hostDevice.peerId, data: reqStr.data(using: .utf8)!)
        
        
    }
    
    func cancelTransfer()
    {
        recvStatus = .Cancel
        
        DispatchQueue.main.async {
            
            self.sendNextRequest()
        }
    }
    
    func getStartTime() -> Date {
        return self.startTime!
    }
    
    func getTransferSpeed() -> Double {
        return self.transferSpeed
    }
    var localTotal: UInt64 = 0
    
    func updateReceivedSize(_ size: UInt64, totalSize total: UInt64, for resoucesname:String) {
        
        CTSTMContents.synchronized(lock: self) {
            let sizeObj = self.sizeMap.value(forKey: resoucesname)
            var minusSize: UInt64 = 0
            if (sizeObj != nil) {
                minusSize = sizeObj as! UInt64
            }
            
            self.sizeMap.setValue(size, forKey: resoucesname)
            
            self.receivedDataSize = self.receivedDataSize - minusSize + size ; // replace the current
        }
        
        self._calulateSpeed()
        self._calulateTimeLeft()
    }
    
    private func _calulateSpeed() {
        let currentTimeStamp: Date = Date()
        let timeDiff: TimeInterval = currentTimeStamp.timeIntervalSince(self.startTime!)
        
        if (timeDiff == 0) {
            self.transferSpeed = 1.0
            return
        }
        // TODO: Should use actual received data size to calulate the speed, when transfer with duplicate, duplicate file always consider as 1 Mbps
        self.transferSpeed = (Double(self.receivedDataSize) / Double(1024 * 1024)) / timeDiff * 8
        if (self.transferSpeed < 1.0) {
            self.transferSpeed = 1.0
        }
//        if ([[mediaInfo objectForKey:@"isDuplicate"] boolValue]) { // if it's duplicate, speed always 1, and calulate the estimate time based on this speed
//            currentDataDownloadSpeed = 1.0f;
//        }
    }
    
    private func _calulateTimeLeft() {
        if (self.transferSpeed != 0) {
            self.timeLeft = (Double(self.totalDataSize - self.receivedDataSize) / Double(1024 * 1024)) / self.transferSpeed * 8
        }
    }
    
    func getTimeLeftString() -> String {
        
        let timeLeftInt: Int = Int(self.timeLeft)
        let hr  = timeLeftInt / 3600
        let min = (timeLeftInt / 60) % 60
        let sec = timeLeftInt % 60
        
        return String.init(format: "%02d:%02d:%02d", hr, min, sec)
    }
}

extension String {
    static func getMediaType(_ type: RecvStatus) -> String! {
        switch type {
        case .Contact:
            return "contacts"
        case .Calender:
            return "calendars"
        case .Reminder:
            return "reminders"
        case .Photo:
            return "photos"
        case .Video:
            return "videos"
        default:
            print("No transfer type, do nothing.")
            
            return "file list"
        }
    }
}
