//
//  VZDeviceSelectionVC.h
//  VZTransferSocket
//
//  Created by Prakash Mac on 12/15/15.
//  Copyright © 2015 Testing. All rights reserved.
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
#import <CoreBluetooth/CoreBluetooth.h>

@interface VZDeviceSelectionVC : VZCTViewController <CBCentralManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *OldPhoneLbl;
@property (weak, nonatomic) IBOutlet UILabel *NotOldPhoneLbl;
@property (weak, nonatomic) IBOutlet UILabel *whichPhoneLbl;
@property (weak, nonatomic) IBOutlet UIButton *oldDeviceBtn;
@property (nonatomic,strong) NSString *wifiStatus;
@property (nonatomic,strong) NSString *bluetoothStatus;

@property (weak, nonatomic) IBOutlet UIButton *notOldDeviceBtn;
@property (weak, nonatomic) AppDelegate *app;
@property (nonatomic,strong)CBCentralManager *centralManager;



@end
