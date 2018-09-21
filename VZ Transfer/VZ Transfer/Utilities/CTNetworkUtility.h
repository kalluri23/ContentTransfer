//
//  CTNetworkUtility.h
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 @brief Utility object relate to network operations. Use this utility to check the network connection or fetch related information.
 @disscussion All the methods inside this utility will be implemented as class methods, so init is not necessary to use the methods.
 */
@interface CTNetworkUtility : NSObject
/*!
 @brief Get connected network SSID for current device.
 @return NSString value represent the connected network SSID.
 */
+ (NSString *)connectedNetworkName;
/*!
 @brief Check current device is conecting to WiFi or not.
 @warning This method will detect device is connecting to Wi-Fi or not, not sure if Wi-Fi without Internet access will pass the check or not.
 @return BOOL value indicate the result.
 */
+ (BOOL)isConnectedToWifi;
/*!
 @brief Checks if wifi is turned on (Doesn't consider if internet is accessible or not)
 @return BOOL value indicate the result.
 */
+ (BOOL)isWiFiEnabled;
/*!
 @brief Check if current connected network is WiFi-Direct Hotspot or not.
 @return BOOL value indicate the result.
 */
+ (BOOL)isConnectedToHotSpotAccessPoint;
/*!
 @brief Check if specific network with given SSID is a WiFi-Direct Hotspot or not.
 @return BOOL indicate the result.
 */
+ (BOOL)isConnectedToHotSpotAccessPoint:(NSString *)ssid;
/*!
 @brief Read the network configuration information for current connecting WiFi network.
 @return NSDictionary object contains necessary information for network.
 */
+ (NSDictionary *)fetchSSIDInfo;

@end
