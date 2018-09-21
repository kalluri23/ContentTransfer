//
//  CTHotSpotHelper.swift
//  contenttransfer
//
//  Created by Sun, Xin on 10/4/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

import UIKit
import NetworkExtension

// MARK: - CTHotSpotHelper object

/**
 Hotspot helper object for Content Transfer app, this object help app connect to known network SSID with/without password.
 - Important:
 The API using in this object is working only above iOS 11. Methods calling below iOS 11 is safe, won't cause crash, basically they will do nothing at all.
 
 Project entitlement setting support is required.
 
 This object is a singlton, will hold the status of hotspot connection for each time app runs.
 */
public class CTHotSpotHelper: NSObject {
    
    // MARK: - Properties
    
    /**
     Hotspot connection status, to indicate that current API already connect the specific network or not.
     - Important:
     This property is designed to work with method:
     ````
     CodeBlockdisconnectPersonHotspot:
     ````
     But since we need to keep the configuration of hotspot on local device, so joinOnce property no longer be true, and method is not using anymore, so this property is useless. Decision may change, so deprecate it instead of remove it.
     - SeeAlso:
     disconnectPersonHotspot:
     */
    @available(*, deprecated, message: "This flag is working with disconnectPersonHotspot: method which is deprecated, so this property is useless.")
    var hotspotConfigApplied: Bool = false
    
    // MARK: - Initializer
    
    /** Singlton initializer for CTHotspotHelper object.*/
    @objc public static let shared = CTHotSpotHelper()
    private override init() {
        super.init()
        print("CTHotspotHelper init. Should only call once, since it's a singlton.")
//        hotspotConfigApplied = false
    }
    
    // MARK: - Public API
    
    /**
     Try to connect to personal hotspot with given SSID and given password. Connect result will be returned in block.
     - Parameters:
         - ssid: String represents the SSID of target hotspot.
         - passphrase: String represents the password setup for target hotspot.
         - completion: Completion handler for process.
         - error: CTHotSpotError error property inside closure. If anything wrong, property error will be assigned, otherwise nil will be returned.
     */
    @objc public func connectToPersonalHotspot(_ ssid: String, passphrase: String? = nil, completion:@escaping (_ error: CTHotSpotError?)->()) {
        // Disconnect first
//        disconnectPersonHotspot(ssid)
        // If app configuration is not supporting hotspot helper
        if (!CTContentTransferSetting.useHotspotAutoConnection()) {
            completion(CTHotSpotAppNotSupportError())
            return
        }
        #if arch(i386) || arch(x86_64)
            completion(CTHotSpotOSNotSupportError())
        #else
            // Try to connect to hotspot
            if #available(iOS 11.0, *) {
                // This feature only support on iOS 11
                var config: NEHotspotConfiguration?
                if passphrase != nil {
                    // There is password, try WPA/WP2 type.
                    config = NEHotspotConfiguration.configHotSpot(.WPAOrWPA2, ssid: ssid, passphrase: passphrase!)
                } else {
                    // There is no password, try Open type
                    config = NEHotspotConfiguration.configHotSpot(ssid: ssid)
                }
                guard config != nil else {
                    fatalError("Hotspot configuration should not be empty when reaching to this point.")
                }
                config!.joinOnce = false
                // Try to connect to the hotspot using config.
                NEHotspotConfigurationManager.shared.apply(config!, completionHandler: { (error) in
                    if error != nil {
                        //                    self.hotspotConfigApplied = false
                        completion(CTHotSpotConnectionError(with: error! as NSError))
                    } else {
                        //                    self.hotspotConfigApplied = true
                        completion(nil)
                    }
                })
            } else {
                // Fallback on earlier versions
                //            self.hotspotConfigApplied = false
                completion(CTHotSpotOSNotSupportError())
            }
        #endif
    }
    
    /**
     Try to disconnect the hotspot created by library. This method only work when joinOnce change to true.
     - Important:
     Since joinOnce is no longer be true, this method is deprecated.
     - Parameter ssid: String value represents the SSID of target hotspot.
     */
    @available(*, deprecated, message: "For now, no need to remove the configuration for user. Android side will disconnect the host. Next time user is able to join same network without input password.")
    @objc public func disconnectPersonHotspot(_ ssid: String) {
        #if arch(i386) || arch(x86_64)
            print("Simulator not working for hotspot configuration.")
        #else
        if #available(iOS 11.0, *) {
            if (self.hotspotConfigApplied) {
                NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
                self.hotspotConfigApplied = false
            }
        } else {
            // Fallback on earlier versions
            print("iOS 11 and above support hotspot configuration, here will do nothing, because non iOS 11 will not be able to run apply()")
        }
        #endif
    }
    
}

// MARK: - NEHotspotConfiguration extension
#if !arch(i386) && !arch(x86_64)
@available(iOS 11.0, *)
extension NEHotspotConfiguration {
    /**
     Supported hotspot type for NEHotspotConfiguration.
     - Warning:
     Only Open/WPAOrWPA2/WEP are supported right now. Assign any other type into the method will expect crash.
     */
    enum CTHotspotType: UInt {
        /** Hotspot without any password when joining.*/
        case Open
        /** Hotspot with WPA/WPA2 Person type.*/
        case WPAOrWPA2
        /** Hotspot with WEP type.*/
        case WEP
        /** Hotspot with WPA/WPA2 Enterprice type.*/
        case WPAOrWPA2Enterprice
        /** Hotspot with Hotspot 2.0 configuration.*/
        case Hotspot2
    }
    /**
     Try to return the proper configuration for hotspot manager. Need to provide right type and password combination.
     - Parameters:
         - type: CTHotspotType value. Optional. Default value is Open. **Only Open/WPAOrWPA2/WEP are acceptable.**
         - ssid: String value represents the SSID of target hotspot.
         - passphrase: String value represents the password of target hotspot. Optional, default value is nil. **Provide password using Open type or using WPAOrWPA2/WEP type without provide passphrase parameter will cause app to crash.**
     - Important:
     Only Open/WPAOrWPA2/WEP are supported right now. Assign any other type into the method will expect crash.
     */
    static func configHotSpot(_ type: CTHotspotType? = .Open , ssid: String, passphrase: String? = nil) -> NEHotspotConfiguration {
        switch type! {
        case .Open:
            guard passphrase == nil else {
                fatalError("Given passphrase is not allowed for this type, should specify hotspot type.")
            }
            return self.init(ssid: ssid)
        case .WPAOrWPA2:
            guard passphrase != nil else {
                fatalError("No passphrase is specified, should give password or change type to Open.")
            }
            return self.init(ssid: ssid, passphrase: passphrase!, isWEP: false)
        case .WEP:
            guard passphrase != nil else {
                fatalError("No passphrase is specified, should give password or change type to Open.")
            }
            return self.init(ssid: ssid, passphrase: passphrase!, isWEP: true)
        default:
            // TODO: In future we may need to implement other type of hotspot support based on requirement. Now leave the protocol.
            fatalError("Unsupported hotspot type yet.")
            break
        }
    }
}
#endif
