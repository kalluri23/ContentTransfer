//
//  VZMacros.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 7/27/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#ifndef VZMacros_h
#define VZMacros_h

// Get Page link string
#define pageLink(x,y) [NSString stringWithFormat:@"%@|%@",x,y]

// Check if device is iPad
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define debugAlert(format, ...)  {UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n line: %d ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:format, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil]; [alert show];}


// Bonjour request define
#define kBonjourBadRequest @"VZTRANSFER_BAD_REQUEST" // 503
#define kBonjourServerOK @"VZTRANSFER_SERVER_OK" // 200
#define kBonjourServiceUnavailable @"VZTRANSFER_SERVICE_UNAVAILABLE" // 403

#define IS_OS_8_OR_LATER          ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IPAD                   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPAD_PRO               ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [UIScreen mainScreen].bounds.size.height == 1366)
#define IS_IPHONE                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_STANDARD_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
#define IS_STANDARD_IPHONE_6      (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0  && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale)
#define IS_STANDARD_IPHONE_5      (IS_IPHONE && MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) == 568.0)
#define IS_STANDARD_IPHONE_4_OR_LESS (IS_IPHONE && MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) < 568.0)

/*
 *  System Versioning Preprocessor Macros
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/*
 *  String Localization Macros
 */
#if STANDALONE
#define CTLocalizedString(key, comment) [[NSBundle mainBundle] localizedStringForKey:(key) value:(comment) table:@"Localizable"]
#else
#define CTLocalizedString(key, comment) [[NSBundle bundleWithIdentifier: @"com.vzw.contentTransfer.framework.bundle"] localizedStringForKey:(key) value:(comment) table:@"Localizable"]
#endif

#endif /* VZMacros_h */
