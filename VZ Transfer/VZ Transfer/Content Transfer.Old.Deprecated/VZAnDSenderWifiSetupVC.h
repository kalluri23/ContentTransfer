//
//  VZAnDSenderWifiSetupVC.h
//  myverizon
//
//  Created by Hadapad, Prakash on 4/1/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
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
#import "ScanLAN.h"
#import "GCDAsyncSocket.h"
#import "Device.h"
#import "CDActivityIndicatorView.h"

@import SystemConfiguration.CaptiveNetwork;


@interface VZAnDSenderWifiSetupVC : VZCTViewController {
    
    GCDAsyncSocket *asyncSocket;
    GCDAsyncSocket *listenOnPort;
    GCDAsyncSocket *asyncSocketCommPort;
    GCDAsyncSocket *listenOnPortCommPort;
}

@property (weak, nonatomic) IBOutlet UILabel *wifissidLbl;
- (IBAction)cancelBtnPressed:(id)sender;
- (IBAction)YesBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *wifiSetupLbl;
@property (weak, nonatomic) IBOutlet UILabel *connectToSameWifi;
@property (weak, nonatomic) IBOutlet UILabel *wifiSetupCompleted;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (weak, nonatomic) IBOutlet UIButton *yesBtn;
@property (weak, nonatomic) AppDelegate *app;
@property (weak, nonatomic) IBOutlet UIButton *gotoSettingBtn;
@property (weak, nonatomic) IBOutlet UILabel *softAccessPointLbl;
@property(strong,nonatomic) Device *selDeviceInfo;
@property (weak, nonatomic) IBOutlet CDActivityIndicatorView *overlayActivity;
@property (weak, nonatomic) IBOutlet UILabel *wifisetupNewLbl;

@end
