//
//  Apps.swift
//  test
//
//  Created by Sun, Xin on 4/4/17.
//  Copyright © 2017 Sun, Xin. All rights reserved.
//

import UIKit

/**
 Content transfer entity object for app. This object contains all the information need for app.
 */
class CTApp: NSObject {
    /** App name. We use this to run search program.*/
    var name             : String?
    /** App path. This read from file list, but meaningless in iOS side.*/
    var path             : String?
    /** Track URL returned from Apple Store search.*/
    var trackURL         : String?
    /** App size. This read from file list, but meaningless in iOS side.*/
    var size             : UInt64 = 0
    /** App search cont returned using current app name. Default is 0.*/
    var searchResSetCount: Int    = 0
    /** App is clicked by user or not. Default value is false.*/
    var isClicked        : Bool   = false
    
    /**
     Initializer for CTApp object. Save name/path/size information from file list.
     - parameters:
        - appInfo: NSDictionary object contains all the information for app.
     */
    init(_ appInfo: NSDictionary) {
        self.name = appInfo.object(forKey: "name") as? String
        self.path = appInfo.object(forKey: "Path") as? String
        self.size = UInt64(appInfo["Size"] as! String)!
    }
    /**
     Call this method when one app get clicked. Use to track the user interaction.
     */
    func didChecked() {
        self.isClicked = true // Never reset to false until next time relaunch the app
    }
    
}
