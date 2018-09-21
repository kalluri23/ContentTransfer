//
//  VZCTViewController.h
//  myverizon
//
//  Created by Tourani, Sanjay on 3/16/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTMVMViewController.h"
#import "CTMVMButtons.h"
#import "CTMVMAlertAction.h"
#import "VZViewUtility.h"
#import "UIImage+Helper.h"

/*! Battery boundary for content transfer to show the charge warning. Measurement percent.*/
#define VZBatteryLimit 25

/*! Navigation bar mode enumerate.*/
typedef NS_ENUM(NSInteger, CTNavigationControllerMode) {
    /*! Navi bar with title, quit button. For MVM build use.*/
    CTNavigationControllerMode_QuitBack,
    /*! Navi bar with title, back button. For MVM build use.*/
    CTNavigationControllerMode_OnlyBack,
    /*! Navi bar with title, quilt and menu button. For MVM build use.*/
    CTNavigationControllerMode_QuitAndHamburgar,
    /*! Navi bar with title, back and menu buttons. For MVM build use.*/
    CTNavigationControllerMode_BackAndHamburgar,
    /*! Only title in navi bar, no buttons.*/
    CTNavigationControllerMode_None
};

/*! Deprecated name for Adobe analytics observer name.*/
static NSString *const kPageName = @"pageName";
/*! Observer name for changing the navigation bar title for each view controller.*/
static NSString *const kNavigationTitle = @"title";

/*!
 * @brief Root view controller for content transfer app. Every view controller using in content transfer will be inherited fromm this object. This view controller contains basic setup such as navigation title, bar button, and global flow for navigation bar.
 * @discussion This view controller is from MVM view controller.
 */
@interface VZCTViewController: CTMVMViewController <UINavigationControllerDelegate>
/*! BOOL value indicate that if current device is charging or not.*/
@property (assign, nonatomic) BOOL charging;
/*! BOOL value indicate that if current device has warning for low battery.*/
@property (nonatomic, assign) BOOL batteryWarning;
/*! Deprecated use for Adobe analytics.*/
@property (nonatomic, strong) NSString *pageName;
/*! deprecated use for Adobe analytics.*/
@property (nonatomic, strong) NSDictionary *analyticsData;
/*! Search bar button for navigation bar.*/
@property (strong, nonatomic) UIBarButtonItem *searchButton;
/*! Hamburgar bar button for navigation bar.*/
@property (strong, nonatomic) UIBarButtonItem *hamburgarButton;
/*! Back bar button for navigation bar.*/
@property (strong, nonatomic) UIBarButtonItem *backButton;
/*! UUID for current device.*/
@property (strong, nonatomic) NSString *uuid_string;

#pragma mark - Methods
/*!
    @brief Set mode for navigation bar. Different mode will show different navigation bar button items.
    @param navigationControllerMode enum type represents the mode the navigation bar.
    @see CTNavigationControllerMode
 */
- (void)setNavigationControllerMode:(CTNavigationControllerMode)navigationControllerMode;

@end
