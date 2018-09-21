//
//  CTQRCodeViewController.m
//  contenttransfer
//
//  Created by Pena, Ricardo on 1/30/17.
//  Rewrote by Xin , Sun     on 2/22/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//
//
//  - This class is the combined class for QR code functionality.
//  - Disable QR code scanner by switch flag AllowQRScan to 0 in content transfer constant settings.
//  - If QR code is disabled, transfer will go through old flow, which allow user to pick device
//  name in the list manually.
//

#import "CTQRCodeViewController.h"
#import "CTVersionManager.h"
#import "CTReceiverReadyViewController.h"
#import "CTStartedViewController.h"
#import "CTAlertCreateFactory.h"
#import "CTStoryboardHelper.h"
#import "CTSettingsUtility.h"
#import "CTContentTransferSetting.h"
#import "CTBonjourManager.h"
#import "CTNetworkUtility.h"
#import "CTCustomAlertView.h"
#import "CTDeviceMarco.h"
#import "CTDeviceStatusUtility.h"
#import "CTWifiSetupViewController.h"
#import "CTBonjourReceiverViewController.h"
#import "CTAlertCreateFactory.h"
#import "CTDeviceSelectionViewController.h"
#import "CTQRCodeSwitch.h"
#import "CTFrameworkClipboardStatus.h"
#import "CTMVMAlertHandler.h"
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif
#import <SystemConfiguration/CaptiveNetwork.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define kInvitationTimeLimit 30 // seconds

static NSString *kUUIDToSearch = @"27BBB38E-3059-4396-8CAA-44FD175F5C06"; // store Beacon

@interface CTQRCodeViewController () <CBCentralManagerDelegate, NSNetServiceDelegate, NSStreamDelegate,GCDAsyncSocketDelegate>

@property (strong, nonatomic) NSNetService *service;
@property (strong, nonatomic) GCDAsyncSocket *receiverSocket;
@property (nonatomic, strong) CTProgressHUD *activityIndicator;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, weak) NSInputStream *inputStream;
@property (nonatomic, weak) NSOutputStream *outputStream;
@property (nonatomic, strong) NSTimer *invitationTimer;
@property (nonatomic, strong) CTCustomAlertView *alertView;
@property (weak, nonatomic) IBOutlet CTBoldFontLabel *ssidLbl;

@property (assign, nonatomic) BOOL isP2PFlow;
@property (assign, nonatomic) BOOL somethingChanged;
@property (nonatomic, assign) BOOL hasWifiErr;
@property (nonatomic, assign) BOOL hasBlueToothErr;
@property (nonatomic, assign) BOOL accepted;
@property (nonatomic, assign) BOOL responseSent;
@property (nonatomic, assign) BOOL versionChecked;
@property (nonatomic, assign) BOOL connectionIsSucessful;
@property (nonatomic, assign) BOOL paired;
@property (nonatomic, assign) BOOL shouldCheckSSID; // Default value is YES in viewDidLoad, never reset to YES, work for one time
@property (nonatomic, assign) BOOL socketOpened;
@property (nonatomic, assign) BOOL servicePublished;

@property (nonatomic, strong) NSString *pairingStatus;

@property (nonatomic, assign) NSInteger checkPassed;
@property (nonatomic, assign) int invitationCount;

@property (nonatomic, weak) id targetAlert;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *QRImgLeading;


@end

@implementation CTQRCodeViewController

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
    _shouldCheckSSID  = YES;
    
#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
#endif
    
//    self.transferFlow = CTTransferFlow_Receiver;

    self.qrCodeImageView.hidden = YES;
    self.secondaryLabel.hidden = YES;
    
    [CTUserDevice userDevice].softAccessPoint = @"FALSE";
    
    [self.manualSetupBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.settingButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    if ([CTDeviceStatusUtility isDeviceUsingSpanish]) {
        // If it's using spanish, then add 3 extra pixel smaller than system auto adjustment.
        self.settingButton.titleLabel.font = [UIFont fontWithName:self.settingButton.titleLabel.font.fontName size:self.settingButton.titleLabel.font.pointSize - 3];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (IS_IPAD || IS_IPAD_PRO) {
        self.QRImgLeading.constant *= 3;
    } else if ([CTDeviceMarco isiPhone4AndBelow]) { // adapte the small screen size
        self.ssidLblTop.constant /= 3;
        self.qrCodeImageViewLeadingSpace.constant = 60.0;
    }
    
    if ([CTDeviceMarco isiPhone6AndAbove]) { //Adapt QR code image size to iphone 5
        self.qrCodeImageTopSpace.constant = 40.0;
        self.qrCodeImageViewLeadingSpace.constant = 60.0;
    }else {
        self.qrCodeImageTopSpace.constant = 20.0;
    }
    
    if ([self.receiverSocket isConnected]) { // if still connect, disconnect it.
        [self.receiverSocket disconnect];
        self.receiverSocket = nil;
        DebugLog(@"receiverSocket was connected and now disconnected");
    }
    
    [self startScan];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentViewController" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"lastViewController", nil]]; // post a notification to save current view controller
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkWifiConnectionAgain) name:UIApplicationDidBecomeActiveNotification object:nil]; // Observer for check wifi
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllCheck) name:UIApplicationWillResignActiveNotification object:nil]; // Observer for clear status
    
    [self.activityIndicator showAnimated:YES];
    
    // Test Wifi Connection
    if ([CTDeviceMarco isiPhone4AndBelow]) {
        self.hasWifiErr = NO;
    } else {
        if (![CTNetworkUtility isWiFiEnabled]) {
            self.hasWifiErr = YES;
        }
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
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    } @catch (NSException *exception) {
        DebugLog(@"Error when remove oberser: %@", exception.description);
    }
    
    [[CTBonjourManager sharedInstance] stopServer];
    
    self.centralManager = nil;
    self.checkPassed = 0;
    self.somethingChanged = YES;
}

#pragma mark - Selectors
- (void)checkWifiConnectionAgain {
    
    [self startScan];
    
    [self.activityIndicator showAnimated:YES];
    
    if (![CTDeviceMarco isiPhone4AndBelow]) {
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
    } else {
        _hasWifiErr = NO;
    }
    
    self.checkPassed ++;
    DebugLog(@"WiFi error:%ld", (long)self.hasWifiErr);
    
    // Test Bluetooth status
    if (!self.centralManager) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:CBCentralManagerOptionShowPowerAlertKey]];
    }
}

- (void)removeAllCheck
{
    if (self.centralManager) {
        self.centralManager = nil;
        self.checkPassed = 0;
    }
}

- (void)generateQRCode:(NSString *)serviceName {
    // Show qr image view
    self.secondaryLabel.hidden = YES;
    self.qrCodeImageView.hidden = NO;
    
    [self updateQRCode:serviceName andPort:@""];
    
    [self.activityIndicator hideAnimated:YES];
}

// Create request alert for Bonjour connection
- (void)createConnectionDialogWithSender:(NSNetService *)sender
                             withHandler:(void(^)(bool response))handler {
    
    if (USES_CUSTOM_VERIZON_ALERTS){
        [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CT_BONJOUR_CONNECTTION_ALERT_TITLE, nil)
                                                   context:[NSString stringWithFormat:CTLocalizedString(CT_BONJOUR_CONNECTTION_ALERT_CONTEXT, nil), kInvitationTimeLimit]
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

// Send reject response
- (void)sendRejectResponse:(NSTimer *)timer {
    // send some data to keep connection alive
    NSString * str = kBonjourServiceUnavailable;
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [[CTBonjourManager sharedInstance] sendStream:data]; // Send bits heart beats
    
    // Then reject the connection
    [[CTBonjourManager sharedInstance] setupStream];
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

- (void)checkHandleFunction {
    if (self.hasBlueToothErr || self.hasWifiErr) {
        
        [self.activityIndicator hideAnimated:YES];
        
        // Stop server if condition not fit
        if (self.socket) {
            self.socket = nil;
        }
        [[CTBonjourManager sharedInstance] stopServer];
        
        self.qrCodeImageView.hidden = YES;
        self.secondaryLabel.hidden = NO;
        self.secondaryLabel.alpha = 0;
        [UIView animateWithDuration:0.5f animations:^{
            self.secondaryLabel.alpha = 1;
        }];
        
        [self customizeConditionCheckAlert];
        
        return;
        
    } else if (_shouldCheckSSID && [self.ssidLbl.text isEqualToString:@"Verizon Guest Wi-Fi"]) {
        _shouldCheckSSID = NO;
        [self displayAlertWhenInStore];
    }
    
    // Default is wi-fi setting page.
    [self.settingButton setTitle:CTLocalizedString(CT_WIFI_BUTTON_TITLE, nil) forState:UIControlStateNormal];
    
    [self.activityIndicator showAnimated:YES];
    [self startBroadcast];
    self.somethingChanged = NO;
}

- (void)customizeConditionCheckAlert {
    NSString *string = @"";
    NSString *btnTitle = CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, nil);
    if (self.hasWifiErr && self.hasBlueToothErr) {
        [self.settingButton setTitle:CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, nil) forState:UIControlStateNormal];
    } else if (self.hasWifiErr) {
        [self.settingButton setTitle:CTLocalizedString(CT_WIFI_BUTTON_TITLE, nil) forState:UIControlStateNormal];
    } else {
        [self.settingButton setTitle:CTLocalizedString(CT_BT_SETTINGS_BUTTON_TITLE, nil) forState:UIControlStateNormal];
    }
    
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
    self.secondaryLabel.text = string;
    
    self.somethingChanged = NO;
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
    } else {
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
}

- (void)checkVersionoftheApp:(NSString *)verison {
    CTVersionManager *versionCheck = [[CTVersionManager alloc] init];
    self.versionChecked = YES;
    
    CTVersionCheckStatus status = [versionCheck identifyOsVersion:verison];
    if (status == CTVersionCheckStatusMatched) {
        [CTUserDefaults sharedInstance].isCancel = NO;
        [self pushReadyView];
    } else if (status == CTVersionCheckStatusLesser) {
        // alert to upgrade other device
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                                 context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil), BUILD_SAME_PLATFORM_MIN_VERSION]
                                                                 btnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil) handler:^(CTVerizonAlertViewController *alertVC) {
                                                                     [[CTBonjourManager sharedInstance] setupStream];
                                                                     self.versionChecked = NO;
                                                                     
                                                                     [self popToRootViewContorller];
                                                                 }
                                                                isGreedy:NO from:self];
        }else {
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
        } else {
            [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                       context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_RECEIVER_ALERT_CONTEXT, nil), versionCheck.supported_version]
                                                 cancelBtnText:CTLocalizedString(CT_UPGRADE_BUTTON_TITLE, nil)
                                                confirmBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                confirmHandler:^(UIAlertAction *action) {
                                                    [CTSettingsUtility openAppStoreLink];
                                                    [self popToRootViewContorller];
                                                }
                                                 cancelHandler:^(UIAlertAction *action) {
                                                     [[CTBonjourManager sharedInstance] setupStream];
                                                     self.versionChecked = NO;
                                                     [self popToRootViewContorller];
                                                 }
                                                      isGreedy:NO];
  
        }
        
        self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:@"invalid pin or pairing failed"};
        self.pageName = ANALYTICS_TrackState_Value_PageName_VersionMismatch;
    }
}

- (void)startScan {
    NSString *ssid = [CTNetworkUtility connectedNetworkName];
    
    if (ssid) {
        self.ssidLbl.text = ssid;
    } else {
        self.ssidLbl.text = @"----";
    }
}

- (void)displayAlertWhenInStore {
    //Display alert when in store & connected to guest wifi
    if ([[CTUserDefaults sharedInstance].beaconUUID isEqualToString:kUUIDToSearch]) { // in store
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil)
                                                                 context:CTLocalizedString(CT_INSTORE_AND_GUEST_WIFI_ALERT_CONTEXT, nil)
                                                                 btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                 handler:nil
                                                                isGreedy:NO from:self];
        }else{
            CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralOKTitle, nil) style:UIAlertActionStyleCancel handler:nil];
            [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) message:CTLocalizedString(CT_INSTORE_AND_GUEST_WIFI_ALERT_CONTEXT, nil) cancelAction:cancelAction otherActions:nil isGreedy:NO];
        }
    } else { // not sure in store
        if (USES_CUSTOM_VERIZON_ALERTS){
            [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil)
                                                                 context:CTLocalizedString(CT_NOT_SURE_IN_STORE_ALERT_CONTEXT, nil)
                                                                 btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                 handler:nil
                                                                isGreedy:NO from:self];
        }else{
            CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralOKTitle, nil) style:UIAlertActionStyleCancel handler:nil];
            [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) message:CTLocalizedString(CT_NOT_SURE_IN_STORE_ALERT_CONTEXT, nil) cancelAction:cancelAction otherActions:nil isGreedy:NO];
        }
    }
    
    NSString *passcode = @"vztransfer";
    UIPasteboard.generalPasteboard.string = passcode;
    [[CTFrameworkClipboardStatus sharedInstance] pasteBoardDidPastePassword:passcode];
}

#pragma mark - Central Manager Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
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
    
    if (++self.checkPassed == 2 && self.somethingChanged) {
        self.backgroundMode = NO;
        [self checkHandleFunction];
    } else if (self.backgroundMode) {
        self.backgroundMode = NO;
        if (!self.hasBlueToothErr && !self.hasWifiErr) {
            [self startBroadcast];
        } else {
            [self.activityIndicator hideAnimated:YES];
        }
    } else {
        [self.activityIndicator hideAnimated:YES];
    }
}

#pragma mark - QR Code related
- (void)updateQRCode:(NSString *)serviceName andPort:(NSString *)port {
    
    NSString *ssid = [CTNetworkUtility connectedNetworkName];
    NSString *ipAddress = [CTDeviceStatusUtility findIPSeries];
    NSString *platfrom = [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS] ? @"ios to ios" : @"cross platform";
    
    self.ctQRCode = [[CTQRCode alloc] initWithPlattform:platfrom
                                                andSSID:ssid?ssid:@""
                                          andIPAddreess:ipAddress
                                                andPort:port
                                            andPasscode:@""
                                             andService:serviceName
                                           andSetupType:self.transferFlow == CTTransferFlow_Sender?@"Sender":@"Receiver"];
    
    self.qrCodeImageView.image = [self.ctQRCode toUIImageFromLayer:self.qrCodeImageView.layer];
    
}

- (void)startBroadcast {
    
    NSLog(@"startBroadcast");
    
    if ([self.ssidLbl.text isEqualToString:@"----"] && [CTDeviceMarco isiPhone4AndBelow]) { // No Wifi network connected, alert user to connect
        self.qrCodeImageView.hidden = YES;
        self.secondaryLabel.hidden = NO;
        self.secondaryLabel.text = CTLocalizedString(CT_OPEN_WIFI_AND_CONNECT_TO_NW_CONTEXT, nil);
        [self.activityIndicator hideAnimated:YES];
        
        if (_somethingChanged) {
            NSString * alertContext = CTLocalizedString(CT_OPEN_WIFI_AND_CONNECT_TO_NW_CONTEXT, nil);
            [self alertUser:alertContext withSettingGuild:YES withSettingButtonTitle:CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, nil) withConfirmHandler:nil andCancelHandler:^(UIAlertAction *action) {
                [CTSettingsUtility openWifiSettings];
            }];
        }
        
        return;
    }
    
    self.isP2PFlow = NO;
    
    // Initialize GCDAsyncSoc ket
    dispatch_queue_t backgroundQueue = dispatch_queue_create("CTQRCodeSocketQueue", 0);
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:backgroundQueue];
//    self.socket = nil;
    
    // Start Listening for Incoming Connections
    NSError *error = nil;
    if ([self.socket acceptOnPort:REGULAR_PORT error:&error]) { // If unable to listen on port (P2P)
        self.socketOpened = YES;
        NSLog(@"Yes i am able to listen on this port");
        
        if (![CTDeviceMarco isiPhone4AndBelow]) { // On device support both Bonjour and P2P
            [[CTBonjourManager sharedInstance] createServerForController:self]; // Start bonjour service
        } else { // On device only support P2P
            [self generateQRCode:@""];
        }
    } else { // If fail to listen on port (P2P), same as SSID empty case actually
        self.socketOpened = NO;
        NSLog(@"Unable to listen socket. Error:%@", error.localizedDescription);
        if (![CTDeviceMarco isiPhone4AndBelow]) {// On device support both Bonjour and P2P
            [[CTBonjourManager sharedInstance] createServerForController:self]; // Start bonjour service
        } else { // If this device only support P2P, then let user change other network to try
            self.qrCodeImageView.hidden = YES;
            self.secondaryLabel.hidden = NO;
            NSString *text = CTLocalizedString(CT_PAIRING_PROBLEM_CONTEXT, nil);
            self.secondaryLabel.text = text;
            [self.activityIndicator hideAnimated:YES];
            [self alertUser:text withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:nil andCancelHandler:nil];
        }
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

#pragma mark - Navigation

- (void)pushReadyView {
    // push the ready view controller
    CTReceiverReadyViewController *receiverReadyViewController = [CTReceiverReadyViewController initialiseFromStoryboard:[CTStoryboardHelper transferStoryboard]];
    receiverReadyViewController.transferFlow = self.transferFlow;
    [self.navigationController pushViewController:receiverReadyViewController animated:YES];
}

- (void)popToRootViewContorller {
    NSArray *viewStacks = self.navigationController.viewControllers;
    for (int i=0; i<viewStacks.count; i++) { // find to root view controller in the view stack, in case of adding more views in stack and change the index of the view
        UIViewController *controller = (UIViewController *)[viewStacks objectAtIndex:i];
        if ([controller isKindOfClass:[CTStartedViewController class]]) { // pop to root
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

#pragma mark - NetService delegate
- (void)netServiceDidPublish:(NSNetService *)service {
    NSString *serviceName = [CTBonjourManager sharedInstance].getServerIdentifier;
    NSLog(@"Service published:%@", serviceName);
    
    [self generateQRCode:serviceName];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    NSLog(@"service not published:%@", errorDict);
    if (self.socketOpened) { // If listen on socket, then generate code only contain socket information
        if ([self.ssidLbl.text isEqualToString:@"----"]) {
            self.qrCodeImageView.hidden = YES;
            self.secondaryLabel.hidden = NO;
            NSString *alertContext = CTLocalizedString(CT_OPEN_WIFI_AND_CONNECT_TO_NW_CONTEXT, nil);
            self.secondaryLabel.text = alertContext;
            
            if (_somethingChanged) {
//                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
//                    alertContext = [alertContext stringByAppendingString:@"\nPath on device:Settings>Wi-Fi"];
//                }
                [self alertUser:alertContext withSettingGuild:YES withSettingButtonTitle:CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, nil) withConfirmHandler:nil andCancelHandler:^(UIAlertAction *action) {
                    [CTSettingsUtility openWifiSettings];
                }];
            }
        } else {
            [self generateQRCode:@""];
        }
    } else { // Otherwise alert user nothing works
        self.secondaryLabel.hidden = NO;
        self.qrCodeImageView.hidden = YES;
        NSString *alertText = CTLocalizedString(CT_PAIRING_PROBLEM_CONTEXT, nil);
        self.secondaryLabel.text = alertText;
        
//        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
//            alertText = [alertText stringByAppendingString:@"\nPath on device:Settings>Wi-Fi"];
//        }
        [self alertUser:alertText withSettingGuild:YES withSettingButtonTitle:CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, nil) withConfirmHandler:nil andCancelHandler:^(UIAlertAction *action) {
            [CTSettingsUtility openWifiSettings];
        }];
    }
    
    [self.activityIndicator hideAnimated:YES];
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

#pragma mark - GCDAsyncSockets delegate methods
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
            
        } else if (status == CTVersionCheckStatusLesser) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (USES_CUSTOM_VERIZON_ALERTS) {
                    [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                                         context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil),versionCheck.supported_version]
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
                                                               confirmBtnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
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

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
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

- (IBAction)manualSetupClicked:(id)sender {
    if (USES_CUSTOM_VERIZON_ALERTS) {
        [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                          context:CTLocalizedString(CT_MANUAL_PAIRING_ALERT_CONTEXT, nil)
                                                    cancelBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                   confirmBtnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                   confirmHandler:^(CTVerizonAlertViewController *alertVC) {
                                                       if ([[CTQRCodeSwitch uniqueSwitch] isOn]) {
                                                           [[CTQRCodeSwitch uniqueSwitch] off];
                                                       }
                                                       
                                                       [self popToRootViewController:[CTStartedViewController class]];
                                                   }
                                                    cancelHandler:nil isGreedy:NO from:self];
    } else {
        [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                   context:CTLocalizedString(CT_MANUAL_PAIRING_ALERT_CONTEXT, nil)
                                             cancelBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                            confirmBtnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                            confirmHandler:^(UIAlertAction *action) {
                                                if ([[CTQRCodeSwitch uniqueSwitch] isOn]) {
                                                    [[CTQRCodeSwitch uniqueSwitch] off];
                                                }
                                                
                                                [self popToRootViewController:[CTStartedViewController class]];
                                            }
                                             cancelHandler:nil isGreedy:NO];
    }
//    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
//        if ([CTDeviceMarco isiPhone4AndBelow]) {
//            CTWifiSetupViewController *wifiSetupViewController = [CTWifiSetupViewController initialiseFromStoryboard:[CTStoryboardHelper wifiAndP2PStoryboard]];
//            wifiSetupViewController.transferFlow = self.transferFlow;
//            
//            [self.navigationController pushViewController:wifiSetupViewController animated:YES];
//        } else {
//            CTBonjourReceiverViewController *bonjourReceiverViewController = [CTBonjourReceiverViewController initialiseFromStoryboard:[CTStoryboardHelper bonjourStoryboard]];
//            bonjourReceiverViewController.transferFlow = self.transferFlow;
//            [self.navigationController pushViewController:bonjourReceiverViewController animated:YES];
//        }
//    } else {
//        CTWifiSetupViewController *wifiSetupViewController = [CTWifiSetupViewController initialiseFromStoryboard:[CTStoryboardHelper wifiAndP2PStoryboard]];
//        wifiSetupViewController.transferFlow = self.transferFlow;
//        
//        [self.navigationController pushViewController:wifiSetupViewController animated:YES];
//    }
}

- (void)alertUser:(NSString *)context withSettingGuild:(BOOL)needSetting withSettingButtonTitle:(NSString *)title withConfirmHandler:(void (^)(UIAlertAction *action))handler andCancelHandler:(void (^)(UIAlertAction *action))cancelHandler {
    if (needSetting) {
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                              context:context
                                                        cancelBtnText:title
                                                       confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                       confirmHandler:^(CTVerizonAlertViewController * alertVC) {
                                                           if (handler) {
                                                               handler(nil);
                                                           }
                                                       }  cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                           if (cancelHandler) {
                                                               cancelHandler(nil);
                                                           }
                                                       }
                                                             isGreedy:NO
                                                                 from:self];
        } else {
            [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                       context:context
                                                 cancelBtnText:title
                                                confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                confirmHandler:handler
                                                 cancelHandler:cancelHandler
                                                      isGreedy:NO];
        }
    } else {
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                                 context:context
                                                                 btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                 handler:^(CTVerizonAlertViewController *alertVC) {
                                                                     if (handler) {
                                                                         handler(nil);
                                                                     }
                                                                 }
                                                                isGreedy:NO from:self];
        } else {
            [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                          context:context
                                                          btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                          handler:handler
                                                         isGreedy:NO];
        }
    }
}

- (IBAction)wifiSettingBtnClicked:(id)sender {
    if (self.hasBlueToothErr && self.hasWifiErr) {
        [CTSettingsUtility openRootSettings];
    } else if (self.hasBlueToothErr) {
        [CTSettingsUtility openBluetoothSettings];
    } else {
        [CTSettingsUtility openWifiSettings];
    }
}
@end
