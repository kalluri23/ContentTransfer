//
//  CTSTMDataUpdateObject.swift
//  contenttransfer
//
//  Created by Sun, Xin on 4/11/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

class CTSTMDataUpdateObject: NSObject {
    
    /** Received data size in MB*/
    public var receviedDataSize:      Double = 0.0
    /** Total data size need to be received in MB*/
    public var totalDataSize:         Double = 0.0
    /** Double value for updating the progress bar; To actual percentage, times 100*/
    public var percentage:            Double = 0.0
    /** Current transfer speed in Mbps*/
    public var transferSpeed:         Double = 0.0
    
    public var timeLeft:              String?
    
    public var currentType:           String?
    public var currentTypeCount:      Int = 0
    public var totalCurrentTypeCount: Int = 0
    
    public init(receviedSize: Double, and totalSize: Double, and speed: Double, and timeLeft: String?, and type:String?, and count: Int, and maxCount: Int) {
        super.init()
        self.receviedDataSize      = receviedSize
        self.totalDataSize         = totalSize
        self.transferSpeed         = speed
        self.timeLeft              = timeLeft
        self.currentType           = type
        self.currentTypeCount      = count
        self.totalCurrentTypeCount = maxCount
        
        // Get percentage
        self.percentage = self.receviedDataSize / self.totalDataSize
    }
}
