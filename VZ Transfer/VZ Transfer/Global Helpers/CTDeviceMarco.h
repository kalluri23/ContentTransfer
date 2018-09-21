//
//  CTDeviceMarco.h
//  contenttransfer
//
//  Created by Sun, Xin on 9/6/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
    @class      CTDeviceMarco
    @brief      This class is for detecting the device model information
    @discussion This class contains all the methods that use for checking device infomation like devie model.
                
                There is a device model List to identify the current model and return the readable string for it.
                
                Note: Not all the device models included in the list.
 */
@interface CTDeviceMarco : NSObject

/*!
    @brief  Get list of known deviceID to identify the device. This method will get user readable device model for analytics purpose;
    @return User readable device model name, or; if it's known, return deviceID directly.
 */
@property (nonatomic, strong) NSDictionary* models;
/*!
     @brief Check current device is iPhone 4 and below or not.
     @return BOOL value indicate this device is iPhone 4.
     @see getDeviceModel
 */
+ (BOOL)isiPhone4AndBelow;
/*!
     @brief Check if current device is iPhone 5 serial.
     @return BOOL value indicate this device is iPhone 5.
     @see getDeviceModel
 */
+ (BOOL)isiPhone5Serial;
/*!
     @brief Check if current device is iPhone 6 and above model.
     @return BOOL value indicate this device is iPhone 6 and above.
     @see getDeviceModel
 */
+ (BOOL)isiPhone6AndAbove;
/*!
 @brief This method will detect if current device is iPhoneX.
 @discussion Since Apple change the resolution of their screen for iPhone X, not all the general UI rule working for both current version and iPhone X. This method is using when some part of UI only working for iPhone X.
 
             This method will use device model and name to detect device type, not pixel of screen.
 @return BOOL value indicate the result.
 */
+ (BOOL)isiPhoneX;
/*!
    @brief  This method is for getting device model name from the list
    @return If it's known deviceID, then return user readable device model name; 
            Otherwise return deviceID.
 */
- (NSString *)getDeviceModel;


@end
