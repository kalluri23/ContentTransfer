//
//  CTSTMService.swift
//  contenttransfer
//
//  Created by Zhang, Yichun on 3/20/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit
import Foundation
import MultipeerConnectivity


@objc public protocol CTSTMServiceDelegate {
    
    func connectRequest(host:String,confirmation:(_ success:Bool) -> ())
    func groupStatusChanged()
    
    
    // recv status update
    func recvData(data:Data?,peer:MCPeerID)
    func recvResourceStart(resourcename:String)
    @objc optional func recvLostHost()
    @objc optional func recvResource(resourcename: String, localURL: URL)
    @objc optional func recvResourceDidUpdateProgressInfo(progress: Progress, for resourcename: String)
    
}

@objc public class ResourceObject:NSObject
{
    public var progress:Progress!
    public var resourceUrl:URL!
    public var isSending:Bool!
    public var peer:MCPeerID!
    public var name:String!
    
    public func resourceSize()->UInt64
    {
        var fileSize : UInt64 = 0
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: resourceUrl.path)
            
            fileSize = attr[FileAttributeKey.size] as! UInt64
            
            //if you convert to NSDictionary, you can get file size old way as well.
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
        } catch {
            print("Error: \(error)")
        }
        
        return fileSize;
    }
}

/*

public class CTSTMServiceSwift: NSObject,
                             MCSessionDelegate,
                             MCNearbyServiceAdvertiserDelegate,
                             MCNearbyServiceBrowserDelegate{
    
    private var CTSTMServiceType_Main   = "CTSTM"
    private var serviceMainAdvertiser : MCNearbyServiceAdvertiser!
    private var serviceMainBrowser:MCNearbyServiceBrowser!
    
    
    public  var thisDevice:CTSTMDevice! = nil
    
    public  var hostDevice:CTSTMDevice! = nil
    
    private var devices:NSMutableArray!
    
    public  var delegate : CTSTMServiceDelegate?
    
    public  var sendResources:NSMutableArray!=nil
    
    public  var recvResources:NSMutableArray?
    
    private var recvData:Data!=nil

    private var contextMap: [Any] = []
    private var availableCount = 0

    public static let sharedInstance = CTSTMServiceSwift()
    
    
    lazy var mainSession : MCSession! = {
        let session = MCSession(peer: self.thisDevice.peerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session

    }()
    
    lazy var secondSession : MCSession! = {
        let session = MCSession(peer: self.thisDevice.peerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
        
    }()
    
    private var bMainSession = true
    
    private var bAppTerminated = false
    
    override public init()
    {
        devices = NSMutableArray()
        
        sendResources = NSMutableArray()
        recvResources = NSMutableArray()
        
        recvData = Data()
        
        thisDevice = CTSTMDevice(name:MCPeerID(displayName: UIDevice.current.name),mode:false)
        
        delegate = nil
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppTermination), name: NSNotification.Name(rawValue: CTApplicationWillTerminate), object: nil)
        


    }
    
    public func handleAppTermination()
    {
        NSLog("handleAppTermination");
        
        bAppTerminated = true

    }
    
    public func resetService()
    {
        self.devices.removeAllObjects()
        
        self.sendResources.removeAllObjects()
        self.recvResources?.removeAllObjects()
    }
    
    public func startService(senderMode:Bool, serviceType:String)
    {
        thisDevice.senderMode = senderMode
        
        CTSTMServiceType_Main = serviceType
        
        self.serviceMainAdvertiser = MCNearbyServiceAdvertiser(peer: thisDevice.peerId, discoveryInfo: nil, serviceType: CTSTMServiceType_Main)
        
        self.serviceMainBrowser  = MCNearbyServiceBrowser(peer: thisDevice.peerId, serviceType: CTSTMServiceType_Main)
        
        self.serviceMainAdvertiser.delegate  = self;
        
        self.serviceMainBrowser.delegate = self;
        


        self.serviceMainAdvertiser.startAdvertisingPeer()

        self.serviceMainBrowser.startBrowsingForPeers()

    }
    
    func stopService()
    {
        for obj in sendResources
        {
            let resObj = obj as! ResourceObject
            
            resObj.progress.removeObserver(self, forKeyPath: "fractionCompleted")
        }
        
        for obj in recvResources!
        {
            let resObj = obj as! ResourceObject
            
            resObj.progress.removeObserver(self, forKeyPath: "fractionCompleted")
        }
        
        self.serviceMainAdvertiser.stopAdvertisingPeer()
        self.serviceMainBrowser.stopBrowsingForPeers()
        

    }
    
    func isConnected()->Bool
    {
        if(thisDevice != nil)
        {
            return thisDevice.status != DeviceStatus.disconnected
        }
        else
        {
            return false
        }
    }
    
    func getHostName()->String?
    {
        if(hostDevice != nil)
        {
            return hostDevice.peerId.displayName
        }
        else
        {
            return nil
        }
    }
    
    func getDevice(index:Int) -> CTSTMDevice?
    {
        if index >= devices.count
        {
            return nil
        }
        else
        {
            return devices[index] as? CTSTMDevice
        }
    }
    
    func getNumOfConnectedDevice()->Int
    {
        return devices.count
    }
    
    func getNameOfConnectedDevice(index:Int)->String?
    {
        if mainSession.connectedPeers.count <= index || index < 0
        {
            return nil
        }
        else
        {
            let device = devices[index] as! CTSTMDevice
            return device.peerId.displayName
        }
    }
    
    func getStatusOfConnectedDevice(index:Int)
    {

    }
    
    func updateDeviceFreeSpace(size:UInt64, peer:MCPeerID)
    {
        for obj in devices
        {
            let device = obj as! CTSTMDevice
            
            if device.peerId.hash == peer.hash
            {
                device.freeSpace = size
                
                self.delegate?.groupStatusChanged()
                
            }
        }
    }
    
    func setStatusofConnectedDevice(status:DeviceStatus, peer: MCPeerID?)
    {
        for obj in devices
        {
            let device = obj as! CTSTMDevice
            
            if peer == nil || device.peerId.hash == peer!.hash
            {
                device.status = status
                

            }
        }
        
        thisDevice.status = status
        
        self.delegate?.groupStatusChanged()
    }
    
    func addDevice(name:MCPeerID)
    {
        for obj in devices
        {
            let device = obj as! CTSTMDevice
            if device.peerId.hash == name.hash
            {
                return;
            }
        }
        
        let newDevice = CTSTMDevice(name: name, mode: false)
        
        devices.add(newDevice)
    }
    
    func removeDevice(name:MCPeerID)
    {
        for obj in devices
        {
            let device = obj as! CTSTMDevice
            
            if device.peerId.hash == name.hash
            {
                devices.remove(device)
                return;
            }
        }
    }
    
    public func setupHost(peer:MCPeerID)
    {
        hostDevice = CTSTMDevice(name: peer, mode: true)
        hostDevice.status = DeviceStatus.connected
    }
    
    func broadcastHostMode()
    {
        
        if mainSession.connectedPeers.count > 0 {
            do {
                let data = CT_SEND_FILE_HOST_HEADER.data(using: .utf8)!

                try self.mainSession.send(data as Data, toPeers: mainSession.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for broadcasting: \(error)")
            }
        }
    }
    
    func sendPacket(peer:MCPeerID?, data:Data)
    {
        if(peer == nil) // broadcasting
        {
            if mainSession.connectedPeers.count > 0 {
                do {
                
                    let connectedCount = mainSession.connectedPeers.count
                    try self.mainSession.send(data as Data, toPeers: mainSession.connectedPeers, with: .reliable)
                }
                catch let error {
                    NSLog("%@", "Error for broadcasting: \(error)")
                }
            }
        }
        else
        {
            do {
                NSLog("Send Package to \(peer!.displayName)")
                try self.mainSession.send(data as Data, toPeers: [peer!], with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
    
    func startSendResource(url:URL,name:String,peer:MCPeerID)
    {
        if bAppTerminated
        {
            return;
        }
        
        let progress = self.mainSession.sendResource(at: url, withName: name, toPeer: peer, withCompletionHandler:
                    {(error: Error?) -> Void in
                        
                        if(error != nil)
                        {
                            NSLog(error!.localizedDescription)
                        }
                        
        })
        
        
        if progress != nil
        {
            let resObj = ResourceObject()
        
            sendResources.add(resObj)
        
            resObj.resourceUrl = url
        
            resObj.peer = peer
        
            resObj.isSending = true
        
            resObj.name = name;
            
            resObj.progress = progress
        
            resObj.progress.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: nil)
            
            
            do{
                let attr = try FileManager.default.attributesOfItem(atPath: url.path)
                
                let fileSize = attr[FileAttributeKey.size] as! UInt64
                
                self.updateDataReceived(size: fileSize, peer: peer, name: name)
            }
            catch let Error
            {
                
            }
        }

    }
    
    func updateDataReceived(size:UInt64, peer: MCPeerID, name:String)
    {
        for obj in devices
        {
            let device = obj as! CTSTMDevice
            
            if device.peerId.hash == peer.hash
            {
                
                device.resourceName = name
                
                device.dataSentSize = device.dataSentSize + size
                device.numOfSentFile = device.numOfSentFile + 1
                
                self.delegate?.groupStatusChanged()
                
                break;
            }
        }
    }
    
    func startSendSteam()
    {
        
    }
    
//  MCNearbyServiceAdvertiserDelegate
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")

    }
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        
        //  Confirm?
        
        self.delegate?.connectRequest(host:thisDevice.peerId.displayName,confirmation:{ (success) -> () in
            
            if advertiser == self.serviceMainAdvertiser
            {
                 invitationHandler(true, self.mainSession)
            }
            else
            {
                invitationHandler(true, self.secondSession)
            }
            
                
            thisDevice.status = DeviceStatus.connected
        })


    }
    
//  MCNearbyServiceBrowserDelegate
    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?)
    {
        if browser == self.serviceMainBrowser
        {
            browser.invitePeer(peerID, to: self.mainSession, withContext: "mainSession".data(using: .utf8), timeout: 100)
        }
        else
        {
            browser.invitePeer(peerID, to: self.secondSession, withContext: "secondSession".data(using: .utf8), timeout: 100)
        }
        
        if thisDevice.senderMode == true
        {
            addDevice(name: peerID)
        }
    
    }
    
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        
        if thisDevice.senderMode == true
        {
            if thisDevice.status == DeviceStatus.connected  ||
               thisDevice.status == DeviceStatus.connecting ||
               thisDevice.status == DeviceStatus.disconnected
            {
                removeDevice(name: peerID)
            }
            else
            {
                for obj in devices
                {
                    let device = obj as! CTSTMDevice
                    
                    if device.peerId.hash == peerID.hash
                    {
                        device.status = DeviceStatus.cancel
                    }
                }
            }
            
            self.delegate?.groupStatusChanged()
        }
        else
        {
            if hostDevice != nil && hostDevice.peerId.hash == peerID.hash
            {
                for obj in recvResources!
                {
                    let recv = obj as! ResourceObject
                    
                    recv.progress.removeObserver(self, forKeyPath: "fractionCompleted")
                }
                
                recvResources?.removeAllObjects();
                
                mainSession.disconnect()
                
                
                if thisDevice.status == DeviceStatus.transfer || thisDevice.status == DeviceStatus.connected
                {
                    self.cleanUp()
                    self.delegate?.recvLostHost!()
                }
            }
            else if thisDevice.peerId.hash == peerID.hash
            {
                self.cleanUp()
                self.delegate?.recvLostHost!()

            }
            
        }
    }
    
    private func cleanUp() {
        self.mainSession.disconnect()
        self.mainSession.delegate = nil
        self.mainSession = nil
    }
    
//  MCSessionDelegate
    
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        
        NSLog("%@","\(peerID.displayName) StatusChanged to \(state.rawValue)")
        
        
        if thisDevice.senderMode == true
        {
            for obj in devices
            {
                let device = obj as! CTSTMDevice
            
                if device.peerId.hash == peerID.hash
                {
                    if state == .notConnected
                    {
                        if device.status != DeviceStatus.cancel
                        {
                            device.status = DeviceStatus.disconnected
                        }
                    }
                    else if state == .connecting
                    {
                        device.status = DeviceStatus.connecting
                    }
                    else if state == .connected
                    {
                        if device.status != DeviceStatus.transfer
                        {
                            device.status = DeviceStatus.connected
                        }
                    }
                    break;
                }
            }
            
            if thisDevice.senderMode == true && state == .connected
            {
                DispatchQueue.main.async {
                
                    self.broadcastHostMode()
                }
            }
        }
        else
        {
            if state == .notConnected
            {
                if hostDevice != nil && hostDevice.peerId.hash == peerID.hash
                {
                    // we lost hostDevice
                    
                    for obj in recvResources!
                    {
                        let recv = obj as! ResourceObject
                        
                        recv.progress.removeObserver(self, forKeyPath: "fractionCompleted")
                    }
                    
                    recvResources?.removeAllObjects();
                }
            }
/*            if hostDevice != nil && hostDevice.peerId.hash == peerID.hash
            {
                if state == .notConnected
                {
                    session.disconnect()
                }
            }*/
        }
        
        self.delegate?.groupStatusChanged()
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        processRecvData(data: data, peer: peerID);
        
    }


    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
        NSLog("=================>StartReceivingResource:\(resourceName) from:\(peerID.displayName)");
        
        let resObj = ResourceObject()
        resObj.peer = peerID
        resObj.isSending = false
        resObj.name = resourceName;
        resObj.progress = progress
        self.recvResources?.add(resObj)
        
        resObj.progress.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: nil) // Add observer on progress, track the progess and calulate for speed
        
        self.delegate?.recvResourceStart(resourcename: resourceName)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        
//        print("key path:\(keyPath), object:\(object), change:\(change) and context:\(context)")
        if (object is Progress) {
            
            if self.thisDevice.senderMode == true
            {
                let progressObj = object as! Progress
                let predicate: NSPredicate = NSPredicate.init(format: "progress == %@", progressObj)
                let filteredArray = self.sendResources!.filtered(using: predicate)
                
                if (filteredArray.count > 0) { // Should always return 1 object
                    
                    let resObj = filteredArray[0] as! ResourceObject
                    
                    if progressObj.completedUnitCount == progressObj.totalUnitCount
                    {
                        resObj.progress.removeObserver(self, forKeyPath: "fractionCompleted")
                        
                        self.sendResources.remove(resObj)
                    }
                    
                    if self.bAppTerminated == true && self.sendResources!.count == 0
                    {
//                        self.mainSession.disconnect()
  //                      self.stopService()
                    }
                }
            }
            else{
                let progressObj = object as! Progress
                let predicate: NSPredicate = NSPredicate.init(format: "progress == %@", progressObj)
                let filteredArray = self.recvResources!.filtered(using: predicate)
                if (filteredArray.count > 0) { // Should always return 1 object
                let resObj = filteredArray[0] as! ResourceObject

                    
                    //                print("receiving file:\(resObj.name) (\(progressObj.completedUnitCount)/\(progressObj.totalUnitCount))")
                
                self.delegate?.recvResourceDidUpdateProgressInfo?(progress: object as! Progress, for: resObj.name)
                }
            }
        }
        
        
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        print("Finish receiving:\(resourceName) <===================")
        
        if hostDevice.status != DeviceStatus.cancel
        {
        
            let predicate: NSPredicate = NSPredicate.init(format: "name == %@", resourceName)
        
            let filteredArray = self.recvResources!.filtered(using: predicate)
        
            if (filteredArray.count > 0) { // Necessary check, count should always be 1 in filtered array. Because file name is identical
            // Remove the observer added to track the progress
            
                let resObj: ResourceObject = filteredArray[0] as! ResourceObject
            
                resObj.progress.removeObserver(self, forKeyPath: "fractionCompleted", context: nil) // Observer should exist also
                
                
                self.recvResources!.remove(resObj)
            }
            
            recvResource(resourceName: resourceName, localURL: localURL);
        }
        
    }
    
    //  handshaking data handling
    func processRecvData(data:Data, peer:MCPeerID)
    {
        recvData.append(data)
            
        self.delegate?.recvData(data: data, peer: peer)

    }
    
    func recvResource(resourceName:String, localURL:URL)
    {
//        // move resource to document folder
//        // remove temp url
//        print("Receive Resource: \(resourceName)")
//        
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        
//        let documentsDirectory = paths[0]
//        
//        let fileURL = URL.init(fileURLWithPath: documentsDirectory).appendingPathComponent(resourceName)
//        
//        do
//        {
//            let attr = try FileManager.default.attributesOfItem(atPath: localURL.path)
//            
//            
//            let fileSize = attr[FileAttributeKey.size] as! UInt64
//            
//            if FileManager.default.fileExists(atPath: fileURL.path)
//            {
//                try FileManager.default.removeItem(at: fileURL)
//            }
//            
//            
//            try FileManager.default.moveItem(at: localURL, to: fileURL)
//            
//        self.delegate?.recvResource?(resourcename: resourceName, localURL: localURL) // Optional delegate method
//        }
//        catch let error
//        {
//            NSLog("%@", "Error for recvResource: \(error)")
//        }
        
        print("Receive Resource: \(resourceName)")
        self.delegate?.recvResource?(resourcename: resourceName, localURL: localURL)
    }
    
    func RecvStream()
    {
        
    }
}
 */
