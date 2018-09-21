//
//  VZRecevierWifiSetupViewController.h
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 2/2/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTMVMViewController.h"
#import "CTMVMButtons.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "VZContentTransferSingleton.h"
#import "AppDelegate.h"
#import "VZCTViewController.h"

@import SystemConfiguration.CaptiveNetwork;

@interface VZRecevierWifiSetupViewController : VZCTViewController
@property (weak, nonatomic) IBOutlet UILabel *wifiSsidLbl;
@property (weak, nonatomic) IBOutlet UILabel *wifiSetupLbl;
@property (weak, nonatomic) IBOutlet UILabel *connectPhoneToSameWifiLbl;
@property (weak, nonatomic) IBOutlet UILabel *wifiSetupCompletedLbl;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *yesBtn;
@property (weak, nonatomic) AppDelegate *app;

@property (weak, nonatomic) IBOutlet UIButton *gotoSettingBtn;
@property (weak, nonatomic) IBOutlet UILabel *softAccessPointLbl;
@property (weak, nonatomic) IBOutlet UILabel *wifisetupNewLbl;
@property (weak, nonatomic) IBOutlet UILabel *connectToSameWifi;

@end
