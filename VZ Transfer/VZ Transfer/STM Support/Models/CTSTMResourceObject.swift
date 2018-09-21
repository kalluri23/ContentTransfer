//
//  CTSTMResourceObject.swift
//  contenttransfer
//
//  Created by Zhang, Yichun on 3/20/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit
import MultipeerConnectivity

@objc public class CTSTMResourceObject:NSObject
{
    @objc public var progress:Progress?
    @objc public var resourceUrl:URL?
    @objc public var isSending:Bool
    @objc public var peer:MCPeerID?
    @objc public var name:String = ""
    
    override public init()
    {
        progress = Progress()
        
        isSending = false;
        
        name = ""
        
        super.init()
    }
    
    public func resourceSize()->UInt64
    {
        var fileSize : UInt64 = 0
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: resourceUrl!.path)
            
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
