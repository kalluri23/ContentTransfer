//
//  CTCheckAppStatus.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/2/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
    @brief Utility class for device information. All the methods related to device will be implemented here.
    @dicussion This object contains all class method. No initializer is needed.
 */
@interface CTDeviceStatusUtility : NSObject
/*!
    @brief Check the current device battery level, if level is lower than 25%, consider as low battery.
    @return BOOL value indicate the battery for device is low or not.
 */
+ (BOOL)isLowBattery;
/*! 
    @brief Get IP series for current device.
    @return NSString value represents the IP series.
 */
+ (NSString*)findIPSeries;
/*!
    @brief Get IP adress for currently connected hotspot for device.
    @return NSString value that represents the IP address with format "xxx.xxx.xxx.xxx"
 */
+ (NSString *)getHotSpotIpAddress;
/*!
    @brief Get the available space for current device. This method is a class method.
    @return Long long value represents the available space for device in Bytes.
 */
+ (long long)getFreeDiskSpace;
/*!
    @brief Get the available space for current device in MB. This method is a class method.
    @return Double value represents the available space for device in MegaByte.
    @see getFreeDiskSpace
 */
+ (double)getFreeDiskSpaceInMegaBytes;
/*!
 * @brief Check device is currently using Spanish as displayed language or not.
 * @note Only two languages are supported. If it's not Spanish, should handle English.
 */
+ (BOOL)isDeviceUsingSpanish;

@end
