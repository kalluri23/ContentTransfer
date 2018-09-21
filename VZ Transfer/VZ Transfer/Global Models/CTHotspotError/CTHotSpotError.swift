//
//  CTHotSpotError.swift
//  contenttransfer
//
//  Created by Sun, Xin on 10/4/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

// MARK: - CTHotSpotError Class
/**
 Error object for hotspot manager. This is the subclass of NSError containing proper information for hotspot connection.
 This is the basic error class.
 */
public class CTHotSpotError: NSError {
    /*! Type of CTHotspotError object.*/
    public enum CTHotSpotErrorType {
        /**
         Error when app configured as not using hotspot auto connection.
         - Important: Change configuration value in CTContentTransferSetting to enable the function.
         - SeeAlso: CTContentTransferSetting
         */
        case appConfigNotSupport
        /** Error when connect failed.*/
        case connection
        /** Error when OS version is below 11 and not supporting HotspotConfiguration.*/
        case OSNotSupport
    }
    
    /** Type of CTHotSpotError.*/
    public var type: CTHotSpotErrorType?
    
    /** Domain of the hotspot error.*/
    private static let CTHotSpotErrorDomain = "CTHotSpotErrorDomain"

    // MARK: - Initializer
    /**
     Init method to received information from API provided NSError.
     - Parameter error: NSError object provided by libarary.
     */
    init(with error: NSError) {
        super.init(domain: CTHotSpotError.CTHotSpotErrorDomain, code: error.code, userInfo: error.userInfo)
    }
    
    /**
     Init method with given error code and userInfo.
     - Parameters:
         - code: Int value represents the error code.
         - userInfo: Dictionary of necessary inforamtion for error. Key is String for NSError Keys, value is Any object.
     */
    init(code: Int, userInfo: [String : Any]?) {
        super.init(domain: CTHotSpotError.CTHotSpotErrorDomain, code: code, userInfo: userInfo)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

// MARK: - CTHotSpotConnectionError Class
/**
 Error object for hotspot manager. This is the subclass of CTHotSpotError containing proper information for hotspot connection failure.
 */
class CTHotSpotConnectionError: CTHotSpotError {
    
    override init(with error: NSError) {
        super.init(with: error)
        
        self.type = .connection
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

// MARK: - CTHotSpotOSNotSupportError class
/**
 Error object for hotspot manager. This is the subclass of CTHotSpotError containing proper information for hotspot os verison too low failure.
 */
class CTHotSpotOSNotSupportError: CTHotSpotError {
    /** Configuration for CTHotSpotOSNotSupportError, contains code and localized descriptions.*/
    struct CTHotSpotOSNotSupportErrorConfig {
        /** Error code for CTHotSpotOSNotSupportError. For now it's 500 for internal error.*/
        static let code            : Int = 500
        /** Localized description for CTHotSpotOSNotSupportError.*/
        static let localDescription: String = "This Api only working on iOS 11(non-simulator) and above, current OS verison is too low."
    }
    
    // MARK: - Initalizer
    /**
     Init method for CTHotSpotOSNotSupportError. This method will create a NSError object using information in CTHotSpotOSNotSupportErrorConfig.
     */
    init() {
        super.init(code: CTHotSpotOSNotSupportErrorConfig.code, userInfo: [NSLocalizedDescriptionKey : CTHotSpotOSNotSupportErrorConfig.localDescription])
        
        self.type = .OSNotSupport
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

// MARK: - CTHotSpotAppNotSupportError
/**
 Error object for hotspot manager. This is the subclass of CTHotSpotError containing proper information for hotspot app configuration not support failure.
 */
class CTHotSpotAppNotSupportError: CTHotSpotError {
    /** Configuration for CTHotSpotAppNotSupportError, contains code and localized descriptions.*/
    struct CTHotSpotAppNotSupportErrorConfig {
        /** Error code for CTHotSpotAppNotSupportError. For now it's 600 for configuration error.*/
        static let code            : Int = 600
        /** Localized description for CTHotSpotAppNotSupportError.*/
        static let localDescription: String = "App configured as not using CTHotspotHelper for hotspot connection. Will directly use manual copy logic."
    }
    
    init() {
        super.init(code: CTHotSpotAppNotSupportErrorConfig.code, userInfo: [NSLocalizedDescriptionKey : CTHotSpotAppNotSupportErrorConfig.localDescription])
        
        self.type = .appConfigNotSupport
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

