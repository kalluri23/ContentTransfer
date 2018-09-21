//
//  ViewController.h
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/12/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanLAN.h"
#import "GCDAsyncSocket.h"
#import "Device.h"
#import "CDActivityIndicatorView.h"
#import "CTMVMViewController.h"
#import "CTMVMButtons.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "VZContentTransferSingleton.h"
#import "AppDelegate.h"
#import "VZCTViewController.h"

extern NSString *const GCD_ALWAYS_READ_QUEUE;

@import SystemConfiguration.CaptiveNetwork;

@interface VZSenderViewController : VZCTViewController<ScanLANDelegate,UITextFieldDelegate> {
    
    GCDAsyncSocket *asyncSocket;
    GCDAsyncSocket *listenOnPort;
//    GCDAsyncSocket *asyncSocketCommPort;
//    GCDAsyncSocket *listenOnPortCommPort;
}

@property(strong,nonatomic) Device *selDeviceInfo;

@property(nonatomic,strong) IBOutlet UITextField *enterIPAddress;//FIXME : This is not ip address, its pin - assign meaningful name
@property (weak, nonatomic) IBOutlet CDActivityIndicatorView *overlayActivity;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyBoardOffsetConstraints;
@property (weak, nonatomic) IBOutlet UILabel *NetworkConnectionLbl;

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) AppDelegate *app;

@end

