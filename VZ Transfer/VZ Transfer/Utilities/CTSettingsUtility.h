//
//  CTUtility.h
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/17/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
    @brief This is a utility class related to user settings for device. All the method related to setting will be added in this object.
 */
@interface CTSettingsUtility : NSObject
/*!
    @brief Try to open wifi setting page for user.
 */
+ (void)openWifiSettings;
/*!
    @brief Try to open bluetooth setting page for user.
 */
+ (void)openBluetoothSettings;
/*!
    @brief Try to open root setting page for user.
 */
+ (void)openRootSettings;
/*!
    @brief Try to open app setting page for user.
 */
+ (void)openAppCustomSettings;
/*!
    @brief Try to open app store link for downloading content transfer.
 */
+ (void)openAppStoreLink;
/*!
    @brief Try to open the review page for user.
 
           "action=write-review" has been added for apple store deep link. Method will open the review page directly instead of open the app page and let user click the "review" button.
    @note Everything will happen in AppStore app, so process will be exactly as same as user manually choose. It's better than the new review dialog released by Apple from iOS 10.3.x since unstability for the new API.
 */
+ (void)openAppStoreReviewLink;
/*!
    @brief Open cloud app store page.
 */
+ (void)openCloudAppStoreLink;
@end
