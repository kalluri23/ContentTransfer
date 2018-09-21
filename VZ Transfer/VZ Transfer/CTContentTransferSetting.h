//
//  CTContentTransferSetting.h
//  contenttransfer
//
//  Created by Sun, Xin on 9/7/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//
#include <Foundation/Foundation.h>

#ifndef CTContentTransferSetting_h
#define CTContentTransferSetting_h

#pragma mark - Build version settings
/**
 * Get the build version of current device: x.x.x; This will show on Store_Release
 */
#if STANDALONE == 1 //  If it's stand alone app
    #define BUILD_VERSION (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#else
    // If it's MVM build
    #define BUILD_VERSION (NSString *)[[NSBundle bundleWithIdentifier:FRAMEWORK_BUNDLE_IDENTIFIER] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#endif

/*!
 * Show complete verison number with build number: x.x.x.x; This only work for QA_Release and Debug build.
 */
#if STANDALONE == 1 //  If it's stand alone app
    #define BUILD_VERSION_FULL (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
#else
// If it's MVM build
    #define BUILD_VERSION_FULL (NSString *)[[NSBundle bundleWithIdentifier:FRAMEWORK_BUNDLE_IDENTIFIER] objectForInfoDictionaryKey:@"CFBundleVersion"]
#endif

#if STANDALONE == 1
    #define BUILD_DATE (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CTBuildDate"]
#else
    #define BUILD_DATE (NSString *)[[NSBundle bundleWithIdentifier:FRAMEWORK_BUNDLE_IDENTIFIER] objectForInfoDictionaryKey:@"CTBuildDate"]
#endif

#pragma mark - Minimum build version settings
// 3(Major).0(Minor).0(Build)
#define BUILD_CROSS_PLATFROM_MIN_VERSION @"3.5.6" // 3(Major).0(Minor).0(Build)
#define BUILD_SAME_PLATFORM_MIN_VERSION  @"3.5.10" // 3(Major).0(Minor).0(Build)


#pragma mark - Analytic related settings
#ifndef LOCAL_ANALYTICS
#define LOCAL_ANALYTICS 1 //DISABLE:0 ENABLE:1
#endif

#ifndef CRASH_REPORT
#define CRASH_REPORT 1   //DISABLE:0 ENABLE:1
#endif

#ifndef SITE_CATALYST
#define SITE_CATALYST 0   //DISABLE:0 ENABLE:1
#endif

#pragma mark - Mutiple connection setting
#ifndef ALLOW_MULTICONNECT
    #if STANDALONE == 1
        #define ALLOW_MULTICONNECT 1
    #else
        #define ALLOW_MULTICONNECT 0
    #endif
#endif

#pragma mark - Data type settings
#ifndef NO_LEGAL_ISSUE_WITH_MUSIC
    #define NO_LEGAL_ISSUE_WITH_MUSIC 1 // Disable music option:0; enable:1.
#endif

#pragma mark - System functionality settings
/*! Decide app will use banner on finish page: 1*/
#ifndef USE_BANNER
#define USE_BANNER 0
#endif

#pragma mark - System functionality settings
/*! Decide app will use survey link on finish page: 1;*/
#ifndef USE_SURVEY_LINK
#define USE_SURVEY_LINK 0
#endif

#pragma mark - System functionality settings
/*! Decide app will use BRAND REFRESH design on finish: 1;*/
#ifndef USE_BRAND_REFRESH
#define USE_BRAND_REFRESH 1
#endif

/*! Decide if app will use custom alerts or system styled alert. Value 1 to enable custom alerts, 0 to disable.*/
#ifndef USES_CUSTOM_VERIZON_ALERTS
#define USES_CUSTOM_VERIZON_ALERTS 0
#endif

/*! Decide if app will allow auto connect to hotspot. Value 1 is enable, value 0 is disable.*/
#ifndef APPROVE_TO_USE_HOTSPOT_HELPER
#define APPROVE_TO_USE_HOTSPOT_HELPER 1
#endif

#endif /* CTContentTransferSetting_h */

#pragma mark - Interface for swift reading objective-C define marco
/*!
 * @brief CTContentTransferSetting object contains all the settings. The method implemetation is for swift file to read the define marco in objective-C.
 * @note Only marcos that using in swift will be added the method.
 */
@interface CTContentTransferSetting : NSObject
/*!
 * @brief Read USES_CUSTOM_VERIZON_ALERTS flag for project in swift file.
 * @return BOOL value indicate the result.
 */
+ (BOOL)userCustomVerizonAlert;
/*!
 * @brief Read APPROVE_TO_USE_HOTSPOT_HELPER flag for project in swift file.
 * @return BOOL value indicate the result.
 */
+ (BOOL)useHotspotAutoConnection;

@end
