//
//  CTSTMContents.swift
//  contenttransfer
//
//  Created by Zhang, Yichun on 3/27/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

/**
 Constants class for one-to-many transfer.
 */
class CTSTMContents: NSObject {
    static let DATAHEADERLENGTH = 10
    
    /**
     @Synchronized block in objective-C in swift implementation. This method will make every input/output will keep order when multiple thread trying to access same object.
     
     Method will try to add lock to specific object and if it failed, method will throw exception for that.
     - parameters:
        - lock: Object that needs to be locked when changing the value.
        - block: Changing implementation provided in block.
     */
    static func synchronized(lock: Any!, block:() throws -> Void) rethrows {
        objc_sync_enter(lock)
        defer {
            objc_sync_exit(lock)
        }
        
        try block()
    }

}
