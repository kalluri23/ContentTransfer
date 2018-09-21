//
//  CTLocalizationHelper.swift
//  contenttransfer
//
//  Created by Sun, Xin on 10/10/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit

/**
 Helper class for localization.
 */
public class CTLocalizationHelper: NSObject {
    
    // MARK: - Static for locale type
    /**English US.*/
    @objc public static let EN: String = "en"
    /**Spanish US.*/
    @objc public static let ES: String = "es"

    // MARK: - Public API
    /**
     Get the localized setting for device in string format. Only read the language part.
     - returns: String value represents the language setting of device.
     */
    @objc public static func getDeviceLocalizedSetting() -> String {
        let locale = NSLocale.preferredLanguages.first
        guard locale != nil else {
            return EN
        }
        let components = (locale! as NSString).components(separatedBy: "-")
        return components.first!
    }
    
    /**
     Compare the setting is given language or not.
     - parameter setting: String of current device setting.
     - parameter type: String of target type.
     - returns: Bool value indicate the result.
     */
    @objc public static func compareDeviceLocale(_ setting: String, with type: String) -> Bool {
        return setting == type
    }
    
}
