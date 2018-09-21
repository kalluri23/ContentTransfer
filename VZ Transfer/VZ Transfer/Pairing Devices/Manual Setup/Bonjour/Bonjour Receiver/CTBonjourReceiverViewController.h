//
//  CTBonjourReceiverViewController.h
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTGenericBonjourViewController.h"
#import "CTCustomLabel.h"
#import "CTProgressHUD.h"

/*! Bonjour receiver page.*/
@interface CTBonjourReceiverViewController : CTGenericBonjourViewController
@property (nonatomic, weak) IBOutlet CTSubheadThreeLabel *phoneStaticLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneNameLabel;
@property (nonatomic, weak) IBOutlet UIView *wifiInfoView;

/*! Activity indicator showing on this page.*/
@property (nonatomic, strong) CTProgressHUD *activityIndicator;
/*! Bool indicate this page has Wi-Fi connection error or not. Yes if Wi-Fi is off.*/
@property (nonatomic, assign) BOOL hasWifiErr;
/*! Bool indicate this page has bluetooth error or not. Yes if bluetooth is off.*/
@property (nonatomic, assign) BOOL hasBlueToothErr;
/*! Bool indicate that after app comes back from background mode, either Wi-Fi or bluetooth setting got changed compare to previous.*/
@property (nonatomic, assign) BOOL somethingChanged;

@end
