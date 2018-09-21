//
//  VZReceiverViewController.h
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/29/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanLAN.h"
#import "Device.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <netdb.h>
#import "GCDAsyncSocket.h"
#import "VZReceiveDataViewController.h"
#import "CTMVMViewController.h"
#import "CTMVMButtons.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "VZContentTransferSingleton.h"
#import "AppDelegate.h"
#import "VZCTViewController.h"
#import "CTVersionManager.h"

extern NSString *const GCD_ALWAYS_READ_QUEUE;

@import SystemConfiguration.CaptiveNetwork;

@interface VZReceiverViewController : VZCTViewController<ScanLANDelegate>{
    
    GCDAsyncSocket *asyncSocket;
    GCDAsyncSocket *listenOnPort;
    
    BOOL connectionIsSucessful;
    
}
//@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *deviceIP;

@property (weak, nonatomic) IBOutlet UILabel *connectingLbl;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) AppDelegate *app;
@property (nonatomic,strong) NSMutableDictionary *pairDict;
@property (nonatomic,weak) NSTimer *changePinAfter30Sec;


@end
