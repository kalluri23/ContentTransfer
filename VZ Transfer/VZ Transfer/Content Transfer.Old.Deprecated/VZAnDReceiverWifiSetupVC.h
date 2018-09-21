//
//  VZAnDReceiverWifiSetupVC.h
//  myverizon
//
//  Created by Hadapad, Prakash on 4/4/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZCTViewController.h"
#import "VZAnDBumpActionRecevier.h"
#import "Device.h"
#import "CDActivityIndicatorView.h"

@import SystemConfiguration.CaptiveNetwork;

@interface VZAnDReceiverWifiSetupVC : VZCTViewController {
    
    GCDAsyncSocket *asyncSocket;
    GCDAsyncSocket *listenOnPort;
}

@property (weak, nonatomic) IBOutlet UILabel *wifiSsidLbl;
@property (weak, nonatomic) IBOutlet UILabel *wifiSetupLbl;
@property (weak, nonatomic) IBOutlet UILabel *connectPhoneToSameWifiLbl;
@property (weak, nonatomic) IBOutlet UILabel *wifiSetupCompletedLbl;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *yesBtn;
@property (weak, nonatomic) IBOutlet UILabel *connectToSameWifi;
@property (weak, nonatomic) AppDelegate *app;
@property(strong,nonatomic) Device *selDeviceInfo;

@property (weak, nonatomic) IBOutlet UIButton *gotoSettingBtn;
@property (weak, nonatomic) IBOutlet UILabel *softAccessPointLbl;
@property (weak, nonatomic) IBOutlet CDActivityIndicatorView *overlayActivity;
@property (weak, nonatomic) IBOutlet UILabel *wifisetupNewLbl;
//@property(nonatomic,strong) GCDAsyncSocket *asyncSocket;
//@property(nonatomic,strong) GCDAsyncSocket *listenOnPort;


@end
