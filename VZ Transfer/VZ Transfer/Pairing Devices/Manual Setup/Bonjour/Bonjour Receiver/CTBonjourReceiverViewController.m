//
//  CTBonjourReceiverViewController.m
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTBonjourReceiverViewController.h"
#import "CTWifiSetupViewController.h"
#import "CTStartedViewController.h"
#import "CTReceiverReadyViewController.h"

#import "CTMVMStyler.h"
#import "CTStoryboardHelper.h"
#import "CTNetworkUtility.h"
#import "CTBonjourManager.h"
#import "CTAlertCreateFactory.h"
#import "CTSettingsUtility.h"
#import "CTContentTransferSetting.h"
#import "CTUserDefaults.h"
#import "CTVersionManager.h"
#import "CTDeviceMarco.h"
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif
#import "CTCustomAlertView.h"

#import <CoreBluetooth/CoreBluetooth.h>

typedef void (^BonjourReceiverHandler)(void);

#define kInvitationTimeLimit 30 // seconds

@interface CTBonjourReceiverViewController() <CBCentralManagerDelegate, NSNetServiceDelegate, NSStreamDelegate>

@property (nonatomic, assign) BOOL versionChecked;

@property (nonatomic, assign) NSInteger checkPassed;

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, assign) int invitationCount;

@property (nonatomic, weak) NSInputStream *inputStream;
@property (nonatomic, weak) NSOutputStream *outputStream;
@property (nonatomic, strong) NSTimer *invitationTimer;

@property (nonatomic, weak) id targetAlert;
@property (nonatomic, assign) BOOL accepted;
@property (nonatomic, assign) BOOL responseSent;

@property (nonatomic, strong) CTCustomAlertView *alertView;

@end

@implementation CTBonjourReceiverViewController

- (CTProgressHUD *)activityIndicator {
    if (![[self.view subviews] containsObject:_activityIndicator]) {
        _activityIndicator = [[CTProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_activityIndicator];
        [self.view bringSubviewToFront:_activityIndicator];
    }
    
    return _activityIndicator;
}


- (CTCustomAlertView *)alertView {
    if (!_alertView) {
        _alertView = [[CTCustomAlertView alloc] initCustomAlertViewWithText:CTLocalizedString(kConnectingDialogContext, nil) withOritation:CTAlertViewOritation_HORIZONTAL];
    }
    
    return _alertView;
}

#pragma mark - UIViewController Delegate
- (void)viewDidLoad {
    
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneWiDiSelect;
    [super viewDidLoad];
    _somethingChanged = YES;
    
#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
#endif
    
    [CTMVMStyler styleStandardMediumTitleLabel:self.phoneStaticLabel];
    [CTMVMStyler styleStandardSmallMessageLabel:self.phoneNameLabel];
    
    self.transferFlow = CTTransferFlow_Receiver;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentViewController" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"lastViewController", nil]]; // post a notification to save current view controller
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkWifiConnectionAgain) name:UIApplicationDidBecomeActiveNotification object:nil]; // Observer for check wifi
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllCheck) name:UIApplicationWillResignActiveNotification object:nil]; // Observer for clear status
    
    [self.activityIndicator showAnimated:YES];
    
    // Test Wifi Connection
    if (![CTNetworkUtility isWiFiEnabled]) {
        self.hasWifiErr = YES;
    }
    self.checkPassed ++;
    
    // Test Bluetooth status
    if (!self.centralManager) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:CBCentralManagerOptionShowPowerAlertKey]];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentViewController" object:nil userInfo:nil]; // post a notification to save current view controller
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    } @catch (NSException *exception) {
        DebugLog(@"Error when remove oberser: %@", exception.description);
    }
    
    [[CTBonjourManager sharedInstance] stopServer];
    
    self.centralManager = nil;
    self.checkPassed = 0;
    self.somethingChanged = YES;
    
    self.wifiInfoView.alpha = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Central Manager Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) { // Bluetooth On
        if (!self.hasBlueToothErr) {
            self.somethingChanged = YES;
        }
        self.hasBlueToothErr = YES;
    } else {
        if (self.hasBlueToothErr) {
            self.somethingChanged = YES;
        }
        self.hasBlueToothErr = NO;
    }
    DebugLog(@"Bluetooth error:%ld", (long)self.hasBlueToothErr);
    
    if (++self.checkPassed == 2 && _somethingChanged) {
        [self checkHandleFunction];
    } else {
        [self.activityIndicator hideAnimated:YES];
    }
}

#pragma mark - NSNetDelegate
// Server published its service
- (void)netServiceDidPublish:(NSNetService *)sender
{
    // Register service name
    dispatch_async(dispatch_get_main_queue(), ^{
        self.phoneNameLabel.text = [[CTBonjourManager sharedInstance] getServerName];
    });
}

// Server accepted a device connection
- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
    self.accepted = NO;
    self.responseSent = NO;
    
    // First create connection for sending respond back
    _inputStream = inputStream;
    _outputStream = outputStream;
    _invitationTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(checkInvitationTimeout:) userInfo:nil repeats:YES];
    [self createConnectionDialogWithSender:sender withHandler:^(bool response) {
        if (response == YES) { // ACCEPTED
            
            [self.alertView show:^{
                if ([_invitationTimer isValid]) {
                    _invitationCount = 0;
                    [_invitationTimer invalidate];
                    _invitationTimer = nil;
                }
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // already connected to a device?
                    if ([CTBonjourManager sharedInstance].inputStream != nil) {
                        // Yes, so reject this new one
                        [inputStream open];
                        [inputStream close];
                        [outputStream open];
                        [outputStream close];
                    } else {
                        // create a new device connection
                        [[CTBonjourManager sharedInstance] stopServer]; // stop server
                        [CTBonjourManager sharedInstance].isServerStarted = NO;
                        
                        // we accepted connection to another device so open in/out connection streams
                        [CTBonjourManager sharedInstance].streamOpenCount = 0;
                        [CTBonjourManager sharedInstance].inputStream = inputStream;
                        [CTBonjourManager sharedInstance].outputStream = outputStream;
                        [[CTBonjourManager sharedInstance] openStreamsForController:self withHandler:^{
                            [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(sendAcceptedReponse:) userInfo:nil repeats:NO];
                        }];
                    }
                }];
            }];
            
        } else {
            
            if ([_invitationTimer isValid]) {
                _invitationCount = 0;
                [_invitationTimer invalidate];
                _invitationTimer = nil;
            }
            
            // First create connection for sending respond back
            [[CTBonjourManager sharedInstance] stopServer]; // stop server
            [CTBonjourManager sharedInstance].isServerStarted = NO;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{ // REJECTED
                // we accepted connection to another device so open in/out connection streams
                [CTBonjourManager sharedInstance].streamOpenCount = 0;
                [CTBonjourManager sharedInstance].inputStream = inputStream;
                [CTBonjourManager sharedInstance].outputStream = outputStream;
                [[CTBonjourManager sharedInstance] openStreamsForController:self withHandler:^{
                    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(sendRejectResponse:) userInfo:nil repeats:NO];
                }];
            }];
        }
    }];
}

- (void)checkInvitationTimeout:(NSTimer *)timer {
    if (++_invitationCount == kInvitationTimeLimit) {
        _invitationCount = 0;
        [timer invalidate];
        timer = nil;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{ // REJECTED
            // we accepted connection to another device so open in/out connection streams
            [CTBonjourManager sharedInstance].streamOpenCount = 0;
            [CTBonjourManager sharedInstance].inputStream = _inputStream;
            [CTBonjourManager sharedInstance].outputStream = _outputStream;
            [[CTBonjourManager sharedInstance] openStreamsForController:self withHandler:^{
                [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(sendRejectResponse:) userInfo:nil repeats:NO];
            }];
        }];
        
        if (USES_CUSTOM_VERIZON_ALERTS){
            [CTVerizonAlertManager dismissVerizonAlertViewController:self.targetAlert completion:nil];
        }else{
            if ([self.targetAlert isKindOfClass:[UIAlertView class]]) {
                UIAlertView *temp = (UIAlertView *)self.targetAlert;
                [temp dismissWithClickedButtonIndex:-1 animated:YES];
            } else if ([self.targetAlert isKindOfClass:[UIAlertController class]]) {
                UIAlertController *temp = (UIAlertController *)self.targetAlert;
                [temp dismissViewControllerAnimated:YES completion:nil];
            }
        }
        
        return;
    }
    DebugLog(@"invitation count:%d", _invitationCount);
    if (USES_CUSTOM_VERIZON_ALERTS){
        if ([self.targetAlert isKindOfClass:[CTVerizonAlertViewController class]]) {
            CTVerizonAlertViewController *alertVC = (CTVerizonAlertViewController *)self.targetAlert;
            [CTVerizonAlertManager updateAlertBodyOf:alertVC withText:[NSString stringWithFormat:CTLocalizedString(CT_BONJOUR_CONNECTTION_ALERT_CONTEXT, nil), kInvitationTimeLimit-_invitationCount]];
        }
    }else{
        if ([self.targetAlert isKindOfClass:[UIAlertView class]]) {
            UIAlertView *temp = (UIAlertView *)self.targetAlert;
            [temp setMessage:[NSString stringWithFormat:CTLocalizedString(CT_BONJOUR_CONNECTTION_ALERT_CONTEXT, nil), kInvitationTimeLimit-_invitationCount]];
        } else if ([self.targetAlert isKindOfClass:[UIAlertController class]]) {
            UIAlertController *temp = (UIAlertController *)self.targetAlert;
            [temp setMessage:[NSString stringWithFormat:CTLocalizedString(CT_BONJOUR_CONNECTTION_ALERT_CONTEXT, nil), kInvitationTimeLimit-_invitationCount]];
        }
    }
}

// Send accepted response
- (void)sendAcceptedReponse:(NSTimer *)timer {
    
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    [dataDict setObject:[CTUserDevice userDevice].deviceUDID forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
    
    CTDeviceMarco *deviceMacro = [[CTDeviceMarco alloc] init];
    NSString *modelCode = [deviceMacro getDeviceModel];
    NSString *model = [deviceMacro.models objectForKey:modelCode];
    if (model.length == 0) {
        model = modelCode;
    }

    [dataDict setObject:model forKey:USER_DEFAULTS_PAIRING_MODEL];
    [dataDict setObject:[UIDevice currentDevice].systemVersion forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
    [dataDict setObject:@"iOS" forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
    [dataDict setObject:@"Bonjour" forKey:USER_DEFAULTS_PAIRING_TYPE];
    
    // Version check request
    NSString * str = [NSString stringWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@#space%@", BUILD_VERSION,BUILD_SAME_PLATFORM_MIN_VERSION,[CTUserDevice userDevice].freeSpaceAvaiable];
    [dataDict setObject:str forKey:USER_DEFAULTS_VERSION_CHECK];
    
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:dataDict options:NSJSONWritingPrettyPrinted error:&error];
    
    [[CTBonjourManager sharedInstance] sendStream:requestData]; // Send bits heart beats
}

// Send reject response
- (void)sendRejectResponse:(NSTimer *)timer {
    // send some data to keep connection alive
    NSString * str = kBonjourServiceUnavailable;
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [[CTBonjourManager sharedInstance] sendStream:data]; // Send bits heart beats
    
    // Then reject the connection
    [[CTBonjourManager sharedInstance] setupStream];
}

// Create request alert for Bonjour connection
- (void)createConnectionDialogWithSender:(NSNetService *)sender
                             withHandler:(void(^)(bool response))handler {
    
    if (USES_CUSTOM_VERIZON_ALERTS){
        [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CT_BONJOUR_CONNECTTION_ALERT_TITLE, nil)
                                                          context:[NSString stringWithFormat:CTLocalizedString(CT_BONJOUR_CONNECTTION_ALERT_CONTEXT, nil),kInvitationTimeLimit]
                                                    cancelBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                   confirmBtnText:CTLocalizedString(CT_CONFIRM_ALERT_BUTTON_TITLE, nil)
                                                   confirmHandler:^(CTVerizonAlertViewController *alertVC) {
                                                       handler(YES);
                                                   }
                                                    cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                        handler(NO);
                                                    }
                                                         isGreedy:YES
                                                             from:self
                                                       completion:^(CTVerizonAlertViewController *alertVC) {
                                                           self.targetAlert = alertVC;
                                                       }];
    }else{
        [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CT_BONJOUR_CONNECTTION_ALERT_TITLE, nil)
                                                   context:[NSString stringWithFormat:CTLocalizedString(CT_BONJOUR_CONNECTTION_ALERT_CONTEXT, nil), kInvitationTimeLimit]
                                             cancelBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                            confirmBtnText:CTLocalizedString(CT_CONFIRM_ALERT_BUTTON_TITLE, nil)
                                            confirmHandler:^(UIAlertAction *action) {
                                                handler(YES);
                                            }
                                             cancelHandler:^(UIAlertAction *action) {
                                                 handler(NO);
                                             }
                                                  isGreedy:YES
                                                 withAlert:^(id alert) {
                                                     self.targetAlert = alert;
                                                 }];
    }
}


#pragma mark - Other Methods
- (void)removeAllCheck
{
    if (self.centralManager) {
        self.centralManager = nil;
        self.checkPassed = 0;
    }
}

- (void)checkWifiConnectionAgain
{
    if ([CTDeviceMarco isiPhone4AndBelow]) {
        return;
    }
    
    [self.activityIndicator showAnimated:YES];
    if (![CTNetworkUtility isWiFiEnabled]) {
        if (!_hasWifiErr) {
            self.somethingChanged = YES;
        }
        _hasWifiErr = YES;
    } else {
        if (_hasWifiErr) {
            self.somethingChanged = YES;
        }
        _hasWifiErr = NO;
    }
    self.checkPassed ++;
    DebugLog(@"WiFi error:%ld", (long)self.hasWifiErr);
    
    // Test Bluetooth status
    if (!self.centralManager) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:CBCentralManagerOptionShowPowerAlertKey]];
    }
}

- (void)checkHandleFunction {
    self.somethingChanged = NO;
    [self.activityIndicator hideAnimated:YES];
    
    if (self.hasBlueToothErr || self.hasWifiErr) {
        
        // Stop server if condition not fit
        [[CTBonjourManager sharedInstance] stopServer];
        
        [self customizeConditionCheckAlert];
        
        [UIView animateWithDuration:0.5f animations:^{
            self.wifiInfoView.alpha = 0;
        }];
        
        return;
        
    } else if ([CTNetworkUtility connectedNetworkName] != nil) { // Access point not nil
        
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
//            
//            [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTAlertGeneralTitle context:@"For best performance please turn on WiFi, but forget all your networks. Data charge will not apply.\nPath on device:Settings>Wi-Fi" btnText:CTAlertGeneralOKTitle handler:nil isGreedy:NO];
//            
//        }else{
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                              context:CTLocalizedString(CT_FORGET_NETWORKS_ALERT_CONTEXT, nil)
                                                        cancelBtnText:CTLocalizedString(CT_WIFI_BUTTON_TITLE, nil)
                                                       confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                       confirmHandler:nil
                                                        cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                            [CTSettingsUtility openWifiSettings];
                                                        }
                                                             isGreedy:NO from:self];
        }else {
            [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                       context:CTLocalizedString(CT_FORGET_NETWORKS_ALERT_CONTEXT, nil)
                                                 cancelBtnText:CTLocalizedString(CT_WIFI_BUTTON_TITLE, nil)
                                                confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                confirmHandler:nil
                                                 cancelHandler:^(UIAlertAction *action) {
                                                     [CTSettingsUtility openWifiSettings];
                                                 }
                                                      isGreedy:NO];
        }
        
//        }
        
    }
    [[CTBonjourManager sharedInstance] createServerForController:self];
    
    [UIView animateWithDuration:1.0f animations:^{
        self.wifiInfoView.alpha = 1;
    }];
}

- (void)customizeConditionCheckAlert {
    NSString *string = @"";
    NSString *btnTitle = CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, nil);
    
    if (self.hasWifiErr) {
        string = CTLocalizedString(CT_TURN_ON_WIFI_ALERT_CONTEXT, nil);
    }
    
    if (self.hasBlueToothErr) {
        if (string.length == 0) {
            string = CTLocalizedString(CT_TURN_OFF_BT_ALERT_CONTEXT, nil);
        } else {
            string = [NSString stringWithFormat:CTLocalizedString(CT_FORMATTED_TURN_OFF_BT_ALERT_CONTEXT, nil), string];
        }
    }
    
    string = [string stringByAppendingString:CTLocalizedString(CT_PUBLISH_SERVICE_STRING, nil)];
    
    if (self.hasWifiErr && !self.hasBlueToothErr) {
        string = [string stringByAppendingString:CTLocalizedString(CT_WIFI_PATH, nil)];
    }
    if (self.hasBlueToothErr && !self.hasWifiErr) {
        string = [string stringByAppendingString:CTLocalizedString(CT_BT_PATH, nil)];
    }
    if (self.hasWifiErr && self.hasBlueToothErr) {
        string = [string stringByAppendingString:CTLocalizedString(CT_WIFI_AND_BT_PATH, nil)];
    }
    
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
    //        if (self.hasBlueToothErr && self.hasWifiErr) {
    //            string = [string stringByAppendingString:@"Navigate to settings"];
    //        }
    //        else if (self.hasBlueToothErr) {
    //            string = [string stringByAppendingString:@"\nPath on Device:Settings>Bluetooth"];
    //        }else if(self.hasWifiErr){
    //            string = [string stringByAppendingString:@"\nPath on Device:Settings>Wi-Fi"];
    //        }
    //
    //        [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTAlertGeneralTitle context:string btnText:CTAlertGeneralOKTitle handler:nil isGreedy:NO];
    //
    //
    //    }else{
    if (USES_CUSTOM_VERIZON_ALERTS) {
        [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                          context:string
                                                    cancelBtnText:btnTitle
                                                   confirmBtnText:CTLocalizedString(CTAlertGeneralIgnoreTitle, nil)
                                                   confirmHandler:nil
                                                    cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                        if (self.hasBlueToothErr && self.hasWifiErr) {
                                                            [CTSettingsUtility openRootSettings];
                                                        } else if (self.hasBlueToothErr) {
                                                            [CTSettingsUtility openBluetoothSettings];
                                                        } else {
                                                            [CTSettingsUtility openWifiSettings];
                                                        }
                                                    }
                                                         isGreedy:NO from:self];
    }else {
        [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                   context:string
                                             cancelBtnText:btnTitle
                                            confirmBtnText:CTLocalizedString(CTAlertGeneralIgnoreTitle, nil)
                                            confirmHandler:nil
                                             cancelHandler:^(UIAlertAction *action) {
                                                 if (self.hasBlueToothErr && self.hasWifiErr) {
                                                     [CTSettingsUtility openRootSettings];
                                                 } else if (self.hasBlueToothErr) {
                                                     [CTSettingsUtility openBluetoothSettings];
                                                 } else {
                                                     [CTSettingsUtility openWifiSettings];
                                                 }
                                             }
                                                  isGreedy:NO];
        
    }
    //    }
}

#pragma mark - Events
- (IBAction)notSeeMyPhoneButtonTapped:(UIButton *)sender {
    if (self.hasBlueToothErr || self.hasWifiErr) {
        [self customizeConditionCheckAlert];
    } else {
        // Add logic for moving to WiFi
        CTWifiSetupViewController *wifiSetupViewController = [CTWifiSetupViewController initialiseFromStoryboard:[CTStoryboardHelper wifiAndP2PStoryboard]];
        wifiSetupViewController.transferFlow = self.transferFlow;
        [self.navigationController pushViewController:wifiSetupViewController animated:YES];
    }
}

#pragma mark - NSStreamDelegate
// Stream connection event
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) { // streams opened
        case NSStreamEventOpenCompleted: {
            [CTBonjourManager sharedInstance].streamOpenCount += 1;
            DebugLog(@"opened stream:%@", stream);
            @try {
                NSAssert([CTBonjourManager sharedInstance].streamOpenCount <= 2, @"streamCountException");
            } @catch(NSException *exception) {
                DebugLog(@"Error when open stream, count wrong:%@", exception.description);
            }
            
            // once both streams are open we hide the picker
            if ([CTBonjourManager sharedInstance].streamOpenCount == 2) {
                [[CTBonjourManager sharedInstance] stopServer];
            }
        }
            break;
            
        case NSStreamEventHasSpaceAvailable: { // stream has space
            @try {
                NSAssert(stream == [CTBonjourManager sharedInstance].outputStream, @"stream type wrong");
            } @catch(NSException *exception) {
                DebugLog(@"Error when open stream, count wrong:%@", exception.description);
            }
        }
            break;
            
        case NSStreamEventHasBytesAvailable: {
            
            NSUInteger bsize = 1024;
            uint8_t buf[bsize];
            NSInteger bytesRead = 0;
            bytesRead = [[CTBonjourManager sharedInstance].inputStream read:buf maxLength:bsize];
            if (bytesRead > 0) {
                [self.alertView hide:nil];
                NSData *data = [NSData dataWithBytes:buf length:bytesRead];
                NSError *errorJson = nil;
                NSDictionary* myDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
                [CTUserDefaults sharedInstance].pairingInfo = myDictionary;
                
                NSString *receivedStr = [myDictionary objectForKey:USER_DEFAULTS_VERSION_CHECK];
                NSRange range = [receivedStr rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS"];
                if ((range.location != NSNotFound) && (receivedStr.length > 0)) { // receiver accept connection
                    if (!_versionChecked) {
                        [self checkVersionoftheApp:receivedStr];
                    }
                }
            }
        }
            break;
        
        // all others cases
        case NSStreamEventEndEncountered:
        case NSStreamEventNone:
        case NSStreamEventErrorOccurred:
        default:
            break;
    }
}

- (void)checkVersionoftheApp:(NSString *)verison {
    CTVersionManager *versionCheck = [[CTVersionManager alloc] init];
    self.versionChecked = YES;
    
    CTVersionCheckStatus status = [versionCheck identifyOsVersion:verison];
    if (status == CTVersionCheckStatusMatched) {
        [CTUserDefaults sharedInstance].isCancel = NO;
        [self pushReadyView];
        
        NSMutableArray *dataTypes = [[NSMutableArray alloc] init];
        if ([CTUserDefaults sharedInstance].hasVcardPermissionError) {
            [dataTypes addObject:CTLocalizedString(CT_CONTACTS_STRING, nil)];
        }
        
        if ([CTUserDefaults sharedInstance].hasPhotoPermissionError) {
            [dataTypes addObject:CTLocalizedString(CT_PHOTOS_STRING, nil)];
            [dataTypes addObject:CTLocalizedString(CT_VIDEOS_STRING, nil)];
        }
        
        if ([CTUserDefaults sharedInstance].hasCalendarPermissionError) {
            [dataTypes addObject:CTLocalizedString(CT_CALANDERS_STRING, nil)];
        }
        
        if ([CTUserDefaults sharedInstance].hasReminderPermissionError) {
            [dataTypes addObject:CTLocalizedString(CT_REMINDERS_STRING, nil)];
        }
        
        if ([dataTypes count]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *commaSeperatedMsg = [dataTypes componentsJoinedByString:@", "];
                commaSeperatedMsg = [commaSeperatedMsg stringByReplacingCharactersInRange:[commaSeperatedMsg rangeOfString:@"," options:NSBackwardsSearch] withString:[NSString stringWithFormat:@" %@", CTLocalizedString(CT_AND, nil)]];
                NSString *allowAccessMessage = [NSString stringWithFormat:@"%@ %@", CTLocalizedString(ALERT_MESSAGE_THIS_APP_REQUIRES_PERMISSION_TO_ACCESS, nil), commaSeperatedMsg];
                if (USES_CUSTOM_VERIZON_ALERTS) {
                    [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:allowAccessMessage cancelBtnText:CTLocalizedString(CT_DECLINE_ALERT_BUTTON_TITLE, nil) confirmBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil) confirmHandler:^(CTVerizonAlertViewController *alertVC) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"BONJOUR_PERMISSION_NOTIFICATION" object:nil];
                        
                        [CTSettingsUtility openAppCustomSettings];
                        
                    } cancelHandler:nil isGreedy:NO from:self];
                } else {
                    [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:allowAccessMessage cancelBtnText:CTLocalizedString(CT_DECLINE_ALERT_BUTTON_TITLE, nil) confirmBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil) confirmHandler:^(UIAlertAction *action) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"BONJOUR_PERMISSION_NOTIFICATION" object:nil];
                        
                        [CTSettingsUtility openAppCustomSettings];
                        
                    } cancelHandler:nil isGreedy:NO];
                }
            });
        }
    } else if (status == CTVersionCheckStatusLesser) {
        // alert to upgrade other device
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                                 context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil),  BUILD_SAME_PLATFORM_MIN_VERSION]
                                                                 btnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil) handler:^(CTVerizonAlertViewController *alertVC) {
                                                                     [[CTBonjourManager sharedInstance] setupStream];
                                                                     self.versionChecked = NO;
                                                                     
                                                                     [self popToRootViewContorller];
                                                                 }
                                                                isGreedy:NO from:self];
        }else{
            [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                          context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil), BUILD_SAME_PLATFORM_MIN_VERSION]
                                                          btnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil) handler:^(UIAlertAction *action) {
                                                              [[CTBonjourManager sharedInstance] setupStream];
                                                              self.versionChecked = NO;
                                                              
                                                              [self popToRootViewContorller];
                                                          }
                                                         isGreedy:NO];
        }

        self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:@"invalid pin or pairing failed"};
        self.pageName = ANALYTICS_TrackState_Value_PageName_VersionMismatch;
        
    } else {
        // alert to upgrade currnt device
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                              context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_RECEIVER_ALERT_CONTEXT, nil), versionCheck.supported_version]
                                                        cancelBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                       confirmBtnText:CTLocalizedString(CT_UPGRADE_BUTTON_TITLE, nil)
                                                       confirmHandler:^(CTVerizonAlertViewController *alertVC) {
                                                           [CTSettingsUtility openAppStoreLink];
                                                           [self popToRootViewContorller];
                                                       }
                                                        cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                            [[CTBonjourManager sharedInstance] setupStream];
                                                            self.versionChecked = NO;
                                                            [self popToRootViewContorller];
                                                        }
                                                             isGreedy:NO from:self];
        }else{
            [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                       context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_RECEIVER_ALERT_CONTEXT, nil),  versionCheck.supported_version]
                                                 cancelBtnText:CTLocalizedString(CT_UPGRADE_BUTTON_TITLE, nil)
                                                confirmBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                confirmHandler:^(UIAlertAction *action) {
                                                    [[CTBonjourManager sharedInstance] setupStream];
                                                    self.versionChecked = NO;
                                                    
                                                    [self popToRootViewContorller];
                                                }
                                                 cancelHandler:^(UIAlertAction *action) {
                                                     [CTSettingsUtility openAppStoreLink];
                                                     [self popToRootViewContorller];
                                                 }
                                                      isGreedy:NO];
  
        }
        self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:@"invalid pin or pairing failed"};
        self.pageName = ANALYTICS_TrackState_Value_PageName_VersionMismatch;
    }
}

- (void)popToRootViewContorller
{
    NSArray *viewStacks = self.navigationController.viewControllers;
    for (int i=0; i<viewStacks.count; i++) { // find to root view controller in the view stack, in case of adding more views in stack and change the index of the view
        UIViewController *controller = (UIViewController *)[viewStacks objectAtIndex:i];
        if ([controller isKindOfClass:[CTStartedViewController class]]) { // pop to root
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (void)pushReadyView {
    // push the ready view controller
    CTReceiverReadyViewController *receiverReadyViewController = [CTReceiverReadyViewController initialiseFromStoryboard:[CTStoryboardHelper transferStoryboard]];
    receiverReadyViewController.transferFlow = self.transferFlow;
    [self.navigationController pushViewController:receiverReadyViewController animated:YES];
}

@end
