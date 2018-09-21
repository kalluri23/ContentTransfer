//
//  CTUtility.m
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/17/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTSettingsUtility.h"
/*! Setting navigation type value.*/
typedef NS_ENUM(NSUInteger, CTSettingNavigationType) {
    /*! Navigate to root setting page.*/
    CTRootSettingNavigationType,
    /*! Navigate to Wi-Fi setting page.*/
    CTWiFiSettingNavigationType,
    /*! Navigate to bluetooth setting page.*/
    CTBluetoothSettingNavigationType
};

@implementation CTSettingsUtility

+ (void)openWifiSettings {
    [CTSettingsUtility _openSettingURL];
}

+ (void)openBluetoothSettings {
    [CTSettingsUtility _openSettingURL];
}

+ (void)openRootSettings {
    [CTSettingsUtility _openSettingURL];
}
/*!
    @brief Try to open settings URL.
 
           This is private method, will not be called directly by other class.
    @note App binary gets rejected if we use non-public API like prefs and App-prefs
 */
+ (void)_openSettingURL {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

+ (void)openAppCustomSettings{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (void)openAppStoreLink{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreURL]];
}

+ (void)openAppStoreReviewLink {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreReviewURL]];
}

+ (void)openCloudAppStoreLink {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kCloudAppStoreURL]];
}

@end
