//
//  CTReceiverPinViewController.m
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTReceiverPinViewController.h"
#import "CTReceiverReadyViewController.h"
#import "CTMVMStyler.h"
#import "CTBundle.h"
#import "CTStoryboardHelper.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "CTNetworkUtility.h"
#import "GCDAsyncSocket.h"
#import "CTVersionManager.h"
#import "CTContentTransferSetting.h"
#import "CTDeviceStatusUtility.h"
#import "CTDeviceMarco.h"
#import "CTAlertCreateFactory.h"
#import "CTSettingsUtility.h"
#import "CTErrorViewController.h"
#import "CTStartedViewController.h"
#import "CTMVMAlertHandler.h"
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif
@interface CTReceiverPinViewController () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) NSString *netMask;
@property (nonatomic, strong) NSTimer *pinChangingTimer;
@property (nonatomic, strong) GCDAsyncSocket *receiverSocket;
@property (nonatomic, strong) NSMutableDictionary *pairDict;
@property (nonatomic, assign) BOOL connectionIsSucessful;
@property (nonatomic, strong) NSString *pairingStatus;
@property (nonatomic, assign) BOOL paired;

@end

@implementation CTReceiverPinViewController

- (void)viewDidLoad {
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhonePIN;
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [CTMVMStyler styleStandardBoldTitleLabel:self.generatedPinLabel];

    dispatch_queue_t backgroundQueue = dispatch_queue_create("CTReceiverPINSocketQueue", 0);
    self.receiverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:backgroundQueue];
    
    NSError *error = nil;
    uint16_t port = REGULAR_PORT;
    
    if ([self.receiverSocket acceptOnPort:port error:&error]) {
        DebugLog(@"Yes i am able to listen on this port");
    }
    
    if ([CTDeviceMarco isiPhone4AndBelow]) {
        self.imageHeight.constant = 150.0;
        self.pinWidth.constant = 50.0;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.receiverSocket isConnected]) {
        [self.receiverSocket isConnected];
        DebugLog(@"receiverSocket was connected and now disconnected");
    }
    
    [self startScan];
}

- (void)startScan {
    
    NSString *ipaddres = [CTDeviceStatusUtility findIPSeries];
    
    if (ipaddres.length > 0) {
        
        NSArray *listItems = [ipaddres componentsSeparatedByString:@"."];
        
        if ([listItems count] > 2) {
            self.generatedPinLabel.text = [self get4DigitPIN:[listItems objectAtIndex:3]];
            self.pinChangingTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                                     target:self
                                                                   selector:@selector(startScan)
                                                                   userInfo:nil
                                                                    repeats:NO];
        } else {
            
            [self displayAlert:CTLocalizedString(CT_CHECK_WIFI_ALERT_CONTEXT, nil)];
            
            self.generatedPinLabel.text = @"----";
        }
    } else {
        
        [self displayAlert:CTLocalizedString(CT_CHECK_WIFI_ALERT_CONTEXT, nil)];
        
        self.generatedPinLabel.text = @"----";
    }
}

- (NSString *)get4DigitPIN:(NSString*)pinStr {
    
    int pin = pinStr.intValue + PINCODE * (arc4random_uniform(34) + 4);
    return [NSString stringWithFormat:@"%d",pin];
}

#pragma mark GCDAsyncSockets delegate methods

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    DebugLog(@"Connected to Host : %@",host);
    
    [CTUserDevice userDevice].pairingType = kP2P;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    if (data.length > 5) {
        
        [self authenticatedConnectionMade];
        
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSRange range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSEN"];
        
        if (range.location != NSNotFound) {
            self.connectionIsSucessful = TRUE;
        }
        
        range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENAND"];
        
        if (range.location != NSNotFound) {
            [CTUserDevice userDevice].isAndroidPlatform = @"TRUE";
        } else {
            [CTUserDevice userDevice].isAndroidPlatform = @"FALSE";
        }
        
        CTVersionManager *versionCheck = [[CTVersionManager alloc] init];
        CTVersionCheckStatus status = [versionCheck identifyOsVersion:response];
        
        if (status == CTVersionCheckStatusMatched) {
            [CTUserDefaults sharedInstance].isCancel = NO;
            
            self.paired = YES;
            
            [CTUserDevice userDevice].pairingType = kP2P;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CTReceiverReadyViewController *recevierReadyController = [CTReceiverReadyViewController initialiseFromStoryboard:[CTStoryboardHelper transferStoryboard]];
                recevierReadyController.transferFlow = CTTransferFlow_Receiver;
                recevierReadyController.writeSocket = self.receiverSocket;
                recevierReadyController.writeSocket.delegate = self.receiverSocket.delegate;
                [self.navigationController pushViewController:recevierReadyController animated:YES];
            });
            
        } else if ( status == CTVersionCheckStatusLesser) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (USES_CUSTOM_VERIZON_ALERTS){
                    [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                                         context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil), versionCheck.supported_version]
                                                                         btnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                                         handler:^(CTVerizonAlertViewController *alertVC) {
                                                                             [self popToRootViewController:[CTStartedViewController class]];
                                                                         }
                                                                        isGreedy:NO from:self];
                }else{
                    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralCancelTitle, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        [self popToRootViewController:[CTStartedViewController class]];
                    }];
                    
                    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil) message:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil), versionCheck.supported_version] cancelAction:okAction otherActions:nil isGreedy:NO];
                }
            });
            
            self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:@"invalid pin or pairing failed"};
            self.pageName = ANALYTICS_TrackState_Value_PageName_VersionMismatch;
            
        } else {
            // alert to upgrade currnt device
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (USES_CUSTOM_VERIZON_ALERTS){
                    [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                                      context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_RECEIVER_ALERT_CONTEXT, nil), versionCheck.supported_version]
                                                                cancelBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                               confirmBtnText:CTLocalizedString(CT_UPGRADE_BUTTON_TITLE, nil)
                                                               confirmHandler:^(CTVerizonAlertViewController *alertVC) {
                                                                   [CTSettingsUtility openAppStoreLink];
                                                                   [self popToRootViewController:[CTStartedViewController class]];
                                                               }
                                                                cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                                    [self popToRootViewController:[CTStartedViewController class]];
                                                                }
                                                                     isGreedy:NO from:self];
                }else{
                    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralCancelTitle, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        [self popToRootViewController:[CTStartedViewController class]];
                    }];
                    
                    NSArray *actions = nil;
                    actions = @[[[CTMVMAlertAction alloc] initWithTitle:CTLocalizedString(CT_UPGRADE_BUTTON_TITLE, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [CTSettingsUtility openAppStoreLink];
                        [self popToRootViewController:[CTStartedViewController class]];
                    }]];
                    
                    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil) message:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_RECEIVER_ALERT_CONTEXT, nil), versionCheck.supported_version] cancelAction:okAction otherActions:actions isGreedy:NO];
                }
            });
            
            self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:@"invalid pin or pairing failed" };
            self.pageName = ANALYTICS_TrackState_Value_PageName_VersionMismatch;
        }
        
        [self.receiverSocket readDataWithTimeout:-1.0f tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    DebugLog(@"socket:didWriteDataWithTag: %ld",tag);
    
    [self.receiverSocket readDataWithTimeout:-1.0f tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"disconnect happened");
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
    [self.pinChangingTimer invalidate];
    DebugLog(@"socket connection accepted succefully");
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    
    if ([[[userdefault dictionaryRepresentation] allKeys] containsObject:@"RECEIVERIPADDRESS"]) {
        [CTUserDevice userDevice].receiverIPAddress = nil;
    }
    
    if ([newSocket connectedHost]) {
        [CTUserDevice userDevice].receiverIPAddress = [newSocket connectedHost];
    }
    
    self.receiverSocket = newSocket;
    self.receiverSocket.delegate = self;
    [self.receiverSocket readDataWithTimeout:-1.0f tag:0];
    self.pairingStatus = @"Successful";
    
}

- (void)authenticatedConnectionMade {
    NSString *shareKey = nil;
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
        shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@#space%@",BUILD_VERSION,BUILD_SAME_PLATFORM_MIN_VERSION,[CTUserDevice userDevice].freeSpaceAvaiable];
    } else {
        shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@#space%@",BUILD_VERSION,BUILD_CROSS_PLATFROM_MIN_VERSION,[CTUserDevice userDevice].freeSpaceAvaiable];
    }
    
    DebugLog(@"Data written to socket %@",shareKey);
    NSData *requestData = [shareKey dataUsingEncoding:NSUTF8StringEncoding];
    [self.receiverSocket writeData:requestData withTimeout:-1.0f tag:10];
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
        [self.receiverSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0f tag:30];
    }
}

//REVIEW: Later this method will be used to common place
- (void)displayAlert:(NSString *)message {
    
    if (USES_CUSTOM_VERIZON_ALERTS){
        [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil)
                                                             context:message
                                                             btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                             handler:nil
                                                            isGreedy:NO from:self];
    }else{
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralOKTitle, nil) style:UIAlertActionStyleCancel handler:nil];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) message:message cancelAction:cancelAction otherActions:nil isGreedy:NO];
    }
}

#pragma applicationDidBecomeActive:
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    NSString *connectedNetworkName = [CTNetworkUtility connectedNetworkName];
    
    if (connectedNetworkName) {
        [self startScan];
        
        self.wifiNameLabel.text = connectedNetworkName;
        
    }else {
        self.wifiNameLabel.text = CTLocalizedString(NOT_CONNECTED_WIFI_ACCESS_POINT, nil);
        self.generatedPinLabel.text = @"----";
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.pinChangingTimer invalidate];
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    } @catch (NSException *exception) {
        DebugLog(@"error");
    }
}

- (void)dealloc {
    [self.pinChangingTimer invalidate];
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIApplicationWillTerminateNotification]) {
        if ([self viewIfLoaded] && self.view.window) {
            DebugLog(@"Terminate notification received test");
        }
    }
}

@end
