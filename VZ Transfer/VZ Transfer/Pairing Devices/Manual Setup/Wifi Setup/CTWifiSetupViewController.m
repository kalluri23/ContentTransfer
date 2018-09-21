//
//  CTWifiSetupViewController.m
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTNetworkUtility.h"
#import "CTReceiverPinViewController.h"
#import "CTSenderPinViewController.h"
#import "CTWifiSetupViewController.h"
#import "CTMVMStyler.h"
#import "CTDeviceStatusUtility.h"
#import "GCDAsyncSocket.h"
#import "CTContentTransferSetting.h"
#import "CTVersionManager.h"
#import "CTSettingsUtility.h"
#import "CTSenderTransferViewController.h"
#import "CTStoryboardHelper.h"
#import "CTReceiverReadyViewController.h"
#import "CTAlertCreateFactory.h"
#import "NSString+CTMVMConvenience.h"
#import "CTStartedViewController.h"
#import "CTFrameworkClipboardStatus.h"
#import "CTMVMAlertHandler.h"
#import "CTCustomAlertView.h"
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif
static NSString *kUUIDToSearch = @"27BBB38E-3059-4396-8CAA-44FD175F5C06";

//static float kProgress = .49;

@interface CTWifiSetupViewController()<GCDAsyncSocketDelegate,updateSenderStatDelegate>

@property (nonatomic, strong) GCDAsyncSocket *gcdSocket;
@property (nonatomic, strong) NSString *ipAddress;
@property (nonatomic, assign) BOOL isSoftAccessPointConnectionStarted;
@property (nonatomic, assign) BOOL shouldIgnore;
@property (nonatomic, assign) BOOL paired;

@property (nonatomic, assign) BOOL shouldCheckSSID; // Default value is YES in viewDidLoad, never reset to YES, work for one time

@property (nonatomic, strong) CTCustomAlertView *alertView;

@end

@implementation CTWifiSetupViewController

- (CTCustomAlertView *)alertView {
    if (!_alertView) {
        _alertView = [[CTCustomAlertView alloc] initCustomAlertViewWithText:CTLocalizedString(kConnectingDialogContext, nil) withOritation:CTAlertViewOritation_HORIZONTAL];
    }
    
    return _alertView;
}

- (void)viewDidLoad {
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneWiFiSelect;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.shouldCheckSSID = YES;
    
    self.title = CTLocalizedString(CT_WIFI_SETUP_VC_NAV_TITLE, nil);
    [self.searchAgainButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
//    self.progressView.progress = kProgress;
#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
#endif
    
    [self updateNetworkName];
    [CTMVMStyler styleStandardMediumTitleLabel:self.networkNameStaticLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    self.isSoftAccessPointConnectionStarted = NO;
    [CTUserDevice userDevice].softAccessPoint = @"FALSE";
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod] && [[CTUserDevice userDevice].deviceType isEqualToString:NEW_DEVICE]) {
        self.secondaryLabel.text = CTLocalizedString(CT_WIFI_SETUP_VC_SEC_LABEL, nil);
    }
}

- (void)updateNetworkName {
    NSString *networkName = [CTNetworkUtility connectedNetworkName];
    if (!networkName) {
        self.ssidNameLabel.text = CTLocalizedString(CT_WIFI_NOT_CONNECTED_LABEL, nil);
        self.nextButton.enabled = NO;
    } else {
        self.ssidNameLabel.text = networkName;
        self.nextButton.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma applicationDidBecomeActive:
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateNetworkName];
    });
}

- (IBAction)handleNextTapped:(UIButton *)sender {
    
    if (self.shouldCheckSSID && [self displayAlertWhenInStore]) {
        return;
    }
    
    [self startFlowBasedOnPlatformAndDeviceType];
}

- (IBAction)handleWifiSettingsTapped:(id)sender {
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
//        
//        [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTAlertGeneralTitle context:@"To open WiFi \nPath on Device:Settings>Wi-Fi" btnText:CTAlertGeneralOKTitle handler:nil isGreedy:NO];
//    }else{
//        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]]) {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//        }
//    }
    
    [CTSettingsUtility openWifiSettings];
}


- (void)startFlowBasedOnPlatformAndDeviceType {
    
    switch (self.transferFlow) {
        case CTTransferFlow_Sender: {
            
            if ([CTNetworkUtility isConnectedToHotSpotAccessPoint]) {
                [self initiateConnectionToSoftAccessPoint];
            } else {
                if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                    CTSenderPinViewController *senderPinViewController = [CTSenderPinViewController initialiseFromStoryboard:[CTStoryboardHelper wifiAndP2PStoryboard]];
                    [self.navigationController pushViewController:senderPinViewController animated:YES];
                }else {
                    [self performSegueWithIdentifier:NSStringFromClass([CTSenderPinViewController class]) sender:nil];
                }
            }
        } break;
            
        case CTTransferFlow_Receiver: {
            if ([CTNetworkUtility isConnectedToHotSpotAccessPoint]) {
                [self initiateConnectionToSoftAccessPoint];
            } else {
                if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                    CTReceiverPinViewController *receiverPinViewController = [CTReceiverPinViewController initialiseFromStoryboard:[CTStoryboardHelper wifiAndP2PStoryboard]];
                    [self.navigationController pushViewController:receiverPinViewController animated:YES];
                }else {
                    [self performSegueWithIdentifier:NSStringFromClass([CTReceiverPinViewController class])
                                              sender:nil];
                }
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)initiateConnectionToSoftAccessPoint {
    
    [self.alertView show];
    
    self.ipAddress = [self getHotSpotIpAddress:[CTDeviceStatusUtility findIPSeries]];
    
    if (self.ipAddress) {
        
        if ([self.gcdSocket isConnected]) { // disconnected previous connected connection
            [self.gcdSocket disconnect];
            self.gcdSocket.delegate = nil;
            self.gcdSocket = nil;
        }
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("CTHotSpotManualQueue", 0);
        self.gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:backgroundQueue];
        
        NSError *error = nil;
        
        self.isSoftAccessPointConnectionStarted = YES;
        
        [self.gcdSocket connectToHost:self.ipAddress onPort:REGULAR_PORT withTimeout:20 error:&error];
        
    } else {
        DebugLog(@"HotSpot ip Address is incorrect");
        
        [self.alertView hide:^{
            if (USES_CUSTOM_VERIZON_ALERTS) {
                [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:CTLocalizedString(CT_UNABLE_TO_ACCESS_HOTSPOT_ALERT_CONTEXT, nil) btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil) handler:nil isGreedy:NO from:self];
            } else {
                [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:CTLocalizedString(CT_UNABLE_TO_ACCESS_HOTSPOT_ALERT_CONTEXT, nil) btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil) handler:nil isGreedy:NO];
            }
        }];
    }
}


- (nullable NSString *)getHotSpotIpAddress:(NSString *)ipAdr {
    
    NSMutableArray *listItems = (NSMutableArray *)[ipAdr componentsSeparatedByString:@"."];
    
    if ([listItems count] > 2) {
        
        [listItems replaceObjectAtIndex:3 withObject:@"1"];
    }
    
    NSString *hotSpotAddress = [listItems componentsJoinedByString:@"."];
    
    return hotSpotAddress;
}

- (void) writeDataToSocket :(NSString *)strData {
    
    NSData *requestData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.gcdSocket writeData:requestData withTimeout: -1.0 tag:0];
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
        
        [self.gcdSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];
        [self.gcdSocket readDataWithTimeout:-1.0 tag:0];
    }
    [self.gcdSocket readDataWithTimeout:-1.0 tag:0];
}


#pragma mark GcdAsyncSocketDelegate methods

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@#space%@",BUILD_VERSION,BUILD_CROSS_PLATFROM_MIN_VERSION,[CTUserDevice userDevice].freeSpaceAvaiable];
    [self writeDataToSocket:shareKey];
    
    [CTUserDevice userDevice].softAccessPoint = @"TRUE";
    
    [CTUserDevice userDevice].pairingType = kP2P;
    [self.gcdSocket readDataWithTimeout:-1.0f tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    [self.alertView hide:nil];
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    response = [response formatRequestForXPlatform];
    
    NSRange range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENAND#"];  // total 39
    
    if (range.location != NSNotFound) {
        
        [CTUserDevice userDevice].isAndroidPlatform = @"TRUE";
        
        CTVersionManager *versionManager = [[CTVersionManager alloc] init];
        CTVersionCheckStatus versionCheckStatus = [versionManager identifyOsVersion:response];
        DebugLog(@"Version check result data for manual PIN page %ld",(long)versionCheckStatus);
        switch (versionCheckStatus) {
            case CTVersionCheckStatusMatched:{
                
                [CTUserDefaults sharedInstance].isCancel = NO;
                self.paired = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self gotoSenderOrReceiverViewController];
                });
            }
                break;
            case CTVersionCheckStatusLesser:{
                NSString *message = [NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil), versionManager.supported_version];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self displayAlert:message withTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil) withAction:nil];
                });
                self.shouldIgnore = YES;
            }
                break;
            case CTVersionCheckStatusGreater:{
                NSString *message = [NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_RECEIVER_ALERT_CONTEXT, nil), versionManager.supported_version];
                dispatch_async(dispatch_get_main_queue(), ^{
                    CTMVMAlertAction *upgradeAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CT_UPGRADE_BUTTON_TITLE, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [CTSettingsUtility openAppStoreLink];
                        [self popToRootViewController:[CTStartedViewController class]];
                    }];
                    
                    [self displayAlert:message withTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil) withAction:upgradeAction];
                });
                self.shouldIgnore = YES;
            }
                break;
            default:
                break;
        }
        
    }
    
    [self.gcdSocket readDataWithTimeout:-1.0 tag:10];
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    DebugLog(@"socket:didWriteDataWithTag: %ld",tag);
    
    [self.gcdSocket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    
    if (err.code != 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateNetworkName];
        });
        
        if (self.shouldIgnore) {
            return;
        }
        
        if (self.paired) {
            // should be cancel
            dispatch_async(dispatch_get_main_queue(), ^{
                CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
                
                errorViewController.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, nil);
                errorViewController.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, nil);
                errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_GOT_IT, nil);
                errorViewController.transferStatusAnalytics = CTTransferStatus_Cancelled;
                
                [self.navigationController pushViewController:errorViewController animated:YES];
            });
            
            return;
        }
        
        DebugLog(@"socketDidDisconnect:withError: \"%@(%ld)\"", err.localizedDescription, (long)err.code);
        [self.alertView hide:^{
            if (USES_CUSTOM_VERIZON_ALERTS) {
                [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                                  context:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil)
                                                            cancelBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                           confirmBtnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                           confirmHandler:^(CTVerizonAlertViewController *alertVC) {
                                                               [CTSettingsUtility openWifiSettings];
                                                           }
                                                            cancelHandler:nil
                                                                 isGreedy:NO
                                                                     from: self];
            } else {
                [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                           context:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil)
                                                     cancelBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                    confirmBtnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                    confirmHandler:^(UIAlertAction *action) {
                                                        [CTSettingsUtility openWifiSettings];
                                                    }
                                                     cancelHandler:nil
                                                          isGreedy:NO];
            }
        }];
    }
}

- (void)displayAlert:(NSString *)message withTitle:(NSString*)title withAction:(CTMVMAlertAction*)action{
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTAlertGeneralCancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [self popToRootViewController:[CTStartedViewController class]];
    }];
    if (action) {
        if (USES_CUSTOM_VERIZON_ALERTS){
            [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:title
                                                             context:message
                                                       cancelBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                      confirmBtnText:CTLocalizedString(action.title, nil)
                                                      confirmHandler:^(CTVerizonAlertViewController *alertVC) {
                                                          UIAlertAction *tmpAction = [[UIAlertAction alloc] init];
                                                          action.handler(tmpAction);
                                                      }
                                                       cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                           [self popToRootViewController:[CTStartedViewController class]];
                                                       }
                                                            isGreedy:NO from:self];
            
        }else{
           [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:title message:message cancelAction:cancelAction otherActions:@[action] isGreedy:NO];
        }
        
    }else{
        if (USES_CUSTOM_VERIZON_ALERTS){
            [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:title
                                                                 context:message
                                                                 btnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                                 handler:^(CTVerizonAlertViewController *alertVC) {
                                                                     [self popToRootViewController:[CTStartedViewController class]];
                                                                 }
                                                                isGreedy:NO from:self];
        }else{
           [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:title message:message cancelAction:cancelAction otherActions:nil isGreedy:NO];
        }
    }
}




- (void)gotoSenderOrReceiverViewController{
    
    if (self.transferFlow == CTTransferFlow_Sender) {  // It goes to Sender if iOS is OLd Device
        
        CTSenderTransferViewController *senderTransferViewController =
        [CTSenderTransferViewController initialiseFromStoryboard:[CTStoryboardHelper transferStoryboard]];
        senderTransferViewController.transferFlow = CTTransferFlow_Sender;
        senderTransferViewController.readSocket = self.gcdSocket;
        senderTransferViewController.delegate = self;
        [self.navigationController pushViewController:senderTransferViewController animated:YES];
        
    } else if (self.transferFlow == CTTransferFlow_Receiver) { // It goes to Recevier if iOS is New Device
        
        CTReceiverReadyViewController *recevierReadyController = [CTReceiverReadyViewController initialiseFromStoryboard:[CTStoryboardHelper transferStoryboard]];
        recevierReadyController.transferFlow = CTTransferFlow_Receiver;
        
        recevierReadyController.writeSocket = self.gcdSocket;
        recevierReadyController.writeSocket.delegate = self.gcdSocket.delegate;
        
        [self.navigationController pushViewController:recevierReadyController animated:YES];
    }
    
}

- (void)ignoreSocketClosedSignal {
    self.shouldIgnore = YES;
}

- (BOOL)displayAlertWhenInStore {
    self.shouldCheckSSID = NO;
    //Display alert when in store & connected to guest wifi
    if ([self.ssidNameLabel.text isEqualToString:@"Verizon Guest Wi-Fi"] && [[CTUserDefaults sharedInstance].beaconUUID isEqualToString:kUUIDToSearch]) {
        
        if (USES_CUSTOM_VERIZON_ALERTS){
            [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                                 context:CTLocalizedString(CT_INSTORE_AND_GUEST_WIFI_ALERT_CONTEXT, nil)
                                                                 btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                 handler:nil
                                                                isGreedy:NO from:self];
        }else{
            CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralOKTitle, nil) style:UIAlertActionStyleCancel handler:nil];
            [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil) message:CTLocalizedString(CT_INSTORE_AND_GUEST_WIFI_ALERT_CONTEXT, nil) cancelAction:cancelAction otherActions:nil isGreedy:NO];
        }
        
        return YES;
    } else if([self.ssidNameLabel.text isEqualToString:@"Verizon Guest Wi-Fi"]){
        
        if (USES_CUSTOM_VERIZON_ALERTS){
            [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                                 context:CTLocalizedString(CT_NOT_SURE_IN_STORE_ALERT_CONTEXT, nil)
                                                                 btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                 handler:nil
                                                                isGreedy:NO from:self];
        }else{
            CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralOKTitle, nil) style:UIAlertActionStyleCancel handler:nil];
            [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil) message:CTLocalizedString(CT_NOT_SURE_IN_STORE_ALERT_CONTEXT, nil) cancelAction:cancelAction otherActions:nil isGreedy:NO];
        }
        return YES;
    }
    
    NSString *passcode = @"vztransfer";
    UIPasteboard.generalPasteboard.string = passcode;
    [[CTFrameworkClipboardStatus sharedInstance] pasteBoardDidPastePassword:passcode];
    
    return NO;
}

@end
