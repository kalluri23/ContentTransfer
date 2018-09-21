//
//  CTBonjourSenderScannerViewController.m
//  contenttransfer
//
//  Created by Pena, Ricardo on 2/3/17.
//  Rewrote by Xin , Sun     on 2/22/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//
//
//  - This class is the combined class for QR code functionality.
//  - Disable QR code scanner by switch flag AllowQRScan to 0 in content transfer constant settings.
//  - If QR code is disabled, transfer will go through old flow, which allow user to pick device
//  name in the list manually.
//

#import "CTSenderScannerViewController.h"
#import "CTCustomTableViewCell.h"
#import "CTSenderTransferViewController.h"
#import "CTStoryboardHelper.h"
#import "CTErrorViewController.h"
#import "CTWifiSetupViewController.h"
#import "CTSenderWaitingViewController.h"
#import "CTMVMColor.h"
#import "CTQRCode.h"
#import "NSString+CTMVMConvenience.h"
#import "CTVersionManager.h"
#import "CTDeviceStatusUtility.h"
#import "CTNetworkUtility.h"
#import "CTSettingsUtility.h"
#import "CTBonjourManager.h"
#import "CTVersionManager.h"
#import "CTAlertCreateFactory.h"
#import "CTDeviceMarco.h"
#import "CTContentTransferSetting.h"
#import "CTQRScanner.h"
#import "CTProgressHUD.h"
#import "CTStartedViewController.h"
#import "CTWifiSetupViewController.h"
#import "CTAlertCreateFactory.h"
#import "CTReceiverReadyViewController.h"
#import "CTCustomAlertView.h"
#import "CTQRCodeViewController.h"
#import "CTBonjourSenderViewController.h"
#import "CTQRCodeSwitch.h"
#import "CTFrameworkClipboardStatus.h"
#import "CTMVMAlertHandler.h"
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif
#import <CoreBluetooth/CoreBluetooth.h>

#define NEXT_VIEW_SHOULD_GO_BACK 0
#define NEXT_VIEW_SHOULD_GO_FORWARD 1
#define NEXT_VIEW_SHOULD_POP_ROOT 2
#define NEXT_VIEW_SHOULD_HIDE_ALERT 3
#define NEXT_VIEW_SHOULD_CANCEL 4

static int CTButtonTypeTryAnotherWay = 0;
static int CTButtonTypeRescan        = 1;
static NSUInteger CTFindIPAddressMaxRetryTime = 10; // measurement is second.

typedef void(^closeAllAsyncOperation)(void);
typedef void(^pushCancelFlowBlock)(void);

@interface CTSenderScannerViewController () <CBCentralManagerDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate, NSStreamDelegate, UIAlertViewDelegate, updateSenderStatDelegate, CTQRScannerDelegate>

@property (nonatomic, assign) BOOL hasWifiErr;
@property (nonatomic, assign) BOOL hasBlueToothErr;
@property (nonatomic, assign) BOOL somethingChanged;
@property (nonatomic, assign) BOOL blockUI;
@property (nonatomic, assign) BOOL versionChecked;
@property (nonatomic, assign) BOOL shouldIgnoreCheck; // igonore check when user reject the request
@property (nonatomic, assign) BOOL paired;
@property (nonatomic, assign) BOOL shouldIgnore;
@property (nonatomic, assign) BOOL bonjourEnabled;

@property (nonatomic, assign) int guestWiFiRetryRequired;

@property (nonatomic, assign) NSInteger checkPassed;
@property (nonatomic, assign) NSInteger extraRowNumber;

@property (nonatomic, strong) NSMutableArray *removeIndics;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) UIView * highlightView;
/*! Global spinner parameter.*/
@property (nonatomic, strong) CTProgressHUD *activityIndicator;
@property (nonatomic, strong) GCDAsyncSocket *gcdSocket;
@property (nonatomic, strong) closeAllAsyncOperation handle;
@property (nonatomic, strong) CTCustomAlertView *alertView;

@property (nonatomic, strong) NSString *targetService;
@property (nonatomic, strong) NSString *targetIP;
@property (nonatomic, strong) NSString *targetSSID;
@property (nonatomic, strong) NSString *targetPasscode;
@property (nonatomic, strong) NSString *localSSID;
@property (nonatomic, strong) NSString *securityType;
@property (nonatomic, strong) NSString *transferType;
@property (nonatomic, strong) NSString *targetSetupType;

@property (nonatomic, strong) pushCancelFlowBlock pushCancelBlock;

@property (nonatomic, assign) BOOL needSameWifiCheck; // After user scan the QR code, if SSID doesn't match, show alert, keep checking wifi until both connect to same one and continue connection. Default value is NO. Change to YES only after scan the QR code without same SSID. Change back to NO, when connection failed or established.
@property (nonatomic, assign) BOOL requestToConnectWiFi; // This one will be assigned to YES when device try to ask user to join network;

@property (nonatomic, strong) CTQRScanner *scanner;
@end

@implementation CTSenderScannerViewController

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

#pragma mark - UIViewController delegate
- (void)viewDidLoad {
    
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneWiDiSelect;
    
    [super viewDidLoad];
    _somethingChanged = YES;
    
    [self disableUserInteraction];
    
#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
#endif
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
        self.transferFlow = CTTransferFlow_Sender;
    }
    
    [self.manualSetupButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.tryAnotherWayBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.manualSetupCenterButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    if (self.transferFlow == CTTransferFlow_Receiver && !self.isForSTM) { // Receiver side for cross platform, should open camera first
        self.tryAnotherWayBtn.hidden  = NO;
        self.manualSetupButton.hidden = NO;
        self.manualSetupCenterButton.hidden = YES;
        
        [self.tryAnotherWayBtn setTitle:CTLocalizedString(CT_TRY_ANOTHER_WAY_BUTTON_TITLE, nil) forState:UIControlStateNormal];
        
        self.tryAnotherWayBtn.tag = CTButtonTypeTryAnotherWay; // differicate the "try another way button" and "rescan" button.
    } else { // only show manual setup at the beginning
        self.tryAnotherWayBtn.hidden  = YES;
        self.manualSetupButton.hidden = YES;
        self.manualSetupCenterButton.hidden = NO;
        
        if (self.isForSTM) { // one to many, need centered button with try another way text and recan function
            [self.manualSetupCenterButton setTitle:CTLocalizedString(CT_TRY_ANOTHER_WAY_BUTTON_TITLE, nil) forState:UIControlStateNormal]; // use try another way as title text
            [self.manualSetupCenterButton simulateCommonBlackButton]; // change black boardered button to common black button
        } else {
            [self.tryAnotherWayBtn setTitle:CTLocalizedString(CT_RESCAN_BUTTON_TITLE, nil) forState:UIControlStateNormal];
        }
        self.tryAnotherWayBtn.tag = CTButtonTypeRescan; // differicate the "try another way button" and "rescan" button.
    }
    
    // Hide all elements until condition check passed.
    self.viewPreview.hidden = YES;
    self.secondaryLabel.hidden = YES;
    
    [CTUserDevice userDevice].softAccessPoint = @"FALSE";
    
    // Setup QR code scanner
    self.scanner = [CTQRScanner shared];
    [self.scanner enableScannerforTarget:self.viewPreview];
    self.scanner.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([CTDeviceMarco isiPhone4AndBelow]) {//Adapt camera view position to iphone 4
        self.cameraViewTopSpace.constant /= 2;
        self.secondaryTop.constant /= 2;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentViewController" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"lastViewController",nil]]; // Send a notification to save current view controller
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkWifiConnectionAgain) name:UIApplicationDidBecomeActiveNotification object:nil]; // Observer for check wifi status
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllCheck) name:UIApplicationWillResignActiveNotification object:nil]; // Observer for check wifi status
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
    if ([CTDeviceMarco isiPhone4AndBelow]) {
        self.hasWifiErr = NO;
    } else {
        if (![CTNetworkUtility isWiFiEnabled]) { // WiFi is not enabled
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
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification    object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification  object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil]; // Observer for check wifi status
    } @catch (NSException *exception) {
        DebugLog(@"Error when remove oberser: %@", exception.description);
    }
    
    if (!self.shouldWaitForResponse) {
        [[CTBonjourManager sharedInstance] stopServer]; // stop server, so other device won't find this device
        [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
    }
    
    self.centralManager = nil;
    self.checkPassed = 0;
    self.somethingChanged = YES;
    
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
        self.backgroundMode = NO;
        self.needSameWifiCheck = NO;
        
        [self checkHandleFunction];
    } else if (self.backgroundMode) {
        if (!self.hasBlueToothErr && !self.hasWifiErr) {
            if (self.needSameWifiCheck) {
                // Should check wifi again
                [self scanCurrentNetwork];
            } else if (![CTDeviceMarco isiPhone4AndBelow] && [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // support Bonjour
                [[CTBonjourManager sharedInstance] createServerForController:self];
            } else { // not supporting Bonjour
                [self enableUserInteractionWithDelay:0];
            }
        } else {
            self.needSameWifiCheck = NO;
            [self enableUserInteractionWithDelay:0];
        }
    } else {
        if (self.needSameWifiCheck) {
            [self scanCurrentNetwork];
        } else {
            [self enableUserInteractionWithDelay:0];
        }
    }
}

#pragma mark - NSNetServiceDelegate
- (void)netServiceDidPublish:(NSNetService *)sender {
    _bonjourEnabled = YES;
    [self enableUserInteractionWithDelay:0];
    
    if (self.backgroundMode) {
        self.backgroundMode = NO;
    } else if (self.scanner.isScannerEnabled) {
        self.secondaryLabel.hidden = YES;
        self.viewPreview.hidden = NO;
        [self.scanner attachScanner];
        [self.scanner startScanner];
    } else {
        NSLog(@"Scanner failed: %@", self.scanner.scannerError.localizedDescription);
        // camer disabled, add button to go back to manual one on both side. ask camera permission at the beginning.
        self.secondaryLabel.text = CTLocalizedString(CT_BACK_CAMERA_ERROR_MESSAGE_LABEL, nil);
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                              context:CTLocalizedString(CT_BACK_CAMERA_ALERT_CONTEXT, nil)
                                                        cancelBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil)
                                                       confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                       confirmHandler:nil
                                                        cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                            [CTSettingsUtility openAppCustomSettings]; // Go to permission page, supported by all iOS versions
                                                        }
                                                             isGreedy:NO from:self];
        } else {
            [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                       context:CTLocalizedString(CT_BACK_CAMERA_ALERT_CONTEXT, nil)
                                                 cancelBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil)
                                                confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                confirmHandler:nil
                                                 cancelHandler:^(UIAlertAction *action) {
                                                     [CTSettingsUtility openAppCustomSettings]; // Go to permission page, supported by all iOS versions
                                                 }
                                                      isGreedy:NO];
        }
    }
    
    if (_invitationSent) {
        // When service publish with invitation sent already, then means service refresh after receiver reject the invitation
        _invitationSent = NO;
    }
    
    // Start the device browser
    if ([[CTBonjourManager sharedInstance] isBrowserValid]) {
        [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
    }
    [[CTBonjourManager sharedInstance] clearServices];
    [[CTBonjourManager sharedInstance] startBrowserNetworkingForTarget:self];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    NSLog(@"service not published:%@", errorDict);
    _bonjourEnabled = NO;
    [self enableUserInteractionWithDelay:0];
    
    if (self.backgroundMode) {
        self.backgroundMode = NO;
    } else if (self.scanner.isScannerEnabled) { // Only P2P left
        self.secondaryLabel.hidden = YES;
        self.viewPreview.hidden = NO;
        [self.scanner attachScanner];
        [self.scanner startScanner];
    } else {
        NSLog(@"Scanner failed: %@", self.scanner.scannerError.localizedDescription);
        // camer disabled, add button to go back to manual one on both side. ask camera permission at the beginning.
        self.secondaryLabel.text = CTLocalizedString(CT_BACK_CAMERA_ERROR_MESSAGE_LABEL, nil);
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                              context:CTLocalizedString(CT_BACK_CAMERA_ALERT_CONTEXT, nil)
                                                        cancelBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil)
                                                       confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                       confirmHandler:nil
                                                        cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                            [CTSettingsUtility openAppCustomSettings]; // Go to permission page, supported by all iOS versions
                                                        }
                                                             isGreedy:NO from:self];
        } else {
            [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                       context:CTLocalizedString(CT_BACK_CAMERA_ALERT_CONTEXT, nil)
                                                 cancelBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil)
                                                confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                confirmHandler:nil
                                                 cancelHandler:^(UIAlertAction *action) {
                                                     [CTSettingsUtility openAppCustomSettings]; // Go to permission page, supported by all iOS versions
                                                 }
                                                      isGreedy:NO];
        }
    }
}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    // Everything try to connect sender will be reject
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // create a new device connection
        [[CTBonjourManager sharedInstance] stopServer]; // stop server
        [CTBonjourManager sharedInstance].isServerStarted = NO;
        
        // we accepted connection to another device so open in/out connection streams
        [CTBonjourManager sharedInstance].inputStream = inputStream;
        [CTBonjourManager sharedInstance].outputStream = outputStream;
        [CTBonjourManager sharedInstance].streamOpenCount = 0;
        [[CTBonjourManager sharedInstance] openStreamsForController:self withHandler:^{
            // Send response after 1.5s
            [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(sendResponse:) userInfo:nil repeats:NO];
        }];
    }];
}

#pragma mark - NSNetServiceBrowserDelegate
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    
    if ([[CTBonjourManager sharedInstance] serviceIsLocalService:service]) {
        [[CTBonjourManager sharedInstance] addService:service];
    }
    
    // only update the UI once we get the no-more-coming indication
    if (!moreComing) {
        [self checkService];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    
    // Remove the service from our array
    if ([[CTBonjourManager sharedInstance] serviceIsLocalService:service]) {
        [[CTBonjourManager sharedInstance] removeService:service];
    }
    
    // Only update the UI once we get the no-more-coming indication
    if (!moreComing) {
        NSLog(@"No more removed");
    }
}

#pragma mark - Other Methods
- (void)disableUserInteraction {
    [self.activityIndicator showAnimated:YES];
}

- (void)enableUserInteractionWithDelay:(NSInteger)delay {
    [self.activityIndicator hideAnimated:YES afterDelay:delay];
}

- (void)checkHandleFunction {
    self.somethingChanged = NO;
    
    if (/*!self.shouldIgnoreCheck && */(self.hasBlueToothErr || self.hasWifiErr)) {
        [self enableUserInteractionWithDelay:0];
        
        // Stop server if condition not fit
        [[CTBonjourManager sharedInstance] stopServer];
        [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
        
        // Show alert information on secondary label
        if (self.scanner.scannerStarted) {
            [self.scanner stopScanner];
            [self.scanner detachScanner];
            self.viewPreview.hidden = YES;
        }
        self.secondaryLabel.hidden = NO;
        self.secondaryLabel.alpha = 0;
        [UIView animateWithDuration:0.5f animations:^{
            self.secondaryLabel.alpha = 1;
            [self.secondaryLabel setTextAlignment:NSTextAlignmentCenter];
        }];
        
        [self customizeConditionCheckAlert];
        
        return;
        
    }
    
    if (self.isForSTM) { // if it's one to many, use try another way as title
        [self.manualSetupCenterButton setTitle:CTLocalizedString(CT_TRY_ANOTHER_WAY_BUTTON_TITLE, nil) forState:UIControlStateNormal];
    } else {
        [self.manualSetupCenterButton setTitle:CTLocalizedString(CT_MANUAL_SETUP_BUTTON_TITLE, nil) forState:UIControlStateNormal];
    }
    
    // Hide the info label and open the camera
    [self disableUserInteraction];
    if (self.secondaryLabel.isHidden) {
        self.secondaryLabel.hidden = NO;
        [self.secondaryLabel setTextAlignment:NSTextAlignmentCenter];
    }
    self.secondaryLabel.text = CTLocalizedString(CT_OPENING_CAMERA_LABEL, nil);
    
    if (![CTDeviceMarco isiPhone4AndBelow] && [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // support Bonjour
        [[CTBonjourManager sharedInstance] createServerForController:self];
    } else { // not supporting Bonjour
        if (self.scanner.isScannerEnabled) {
            self.secondaryLabel.hidden = YES;
            self.viewPreview.hidden = NO;
            [self.scanner attachScanner];
            [self.scanner startScanner];
        } else {
            NSLog(@"Scanner failed: %@", self.scanner.scannerError.localizedDescription);
            // camer disabled, add button to go back to manual one on both side. ask camera permission at the beginning.
            self.secondaryLabel.text = CTLocalizedString(CT_BACK_CAMERA_ERROR_MESSAGE_LABEL, nil);
            if (USES_CUSTOM_VERIZON_ALERTS) {
                [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                                  context:CTLocalizedString(CT_BACK_CAMERA_ALERT_CONTEXT, nil)
                                                            cancelBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil)
                                                           confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                           confirmHandler:nil
                                                            cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                                [CTSettingsUtility openAppCustomSettings]; // Go to permission page, supported by all iOS versions
                                                            }
                                                                 isGreedy:NO from:self];
            } else {
                [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                           context:CTLocalizedString(CT_BACK_CAMERA_ALERT_CONTEXT, nil)
                                                     cancelBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil)
                                                    confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                    confirmHandler:nil
                                                     cancelHandler:^(UIAlertAction *action) {
                                                         [CTSettingsUtility openAppCustomSettings]; // Go to permission page, supported by all iOS versions
                                                     }
                                                          isGreedy:NO];
            }
        }
        [self enableUserInteractionWithDelay:0];
    }
}

- (void)checkWifiConnectionAgain {
    if (self.requestToConnectWiFi) { // If call this method during the system dialog for asking to connect hotspot, then ignore.
        return;
    }
    
    [self disableUserInteraction];
    
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

// Send response
- (void)sendResponse:(NSTimer *)timer {
    // send some data to keep connection alive
    NSString *str = kBonjourBadRequest; // bad request
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [[CTBonjourManager sharedInstance] sendStream:data]; // Send bad request response
    
    timer = nil;
    
    [[CTBonjourManager sharedInstance] setupStream];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CT_INVALID_OPERATION_ALERT_TITLE, nil)
                                                                 context:CTLocalizedString(CT_INVALID_OPERATION_ALERT_CONTEXT, nil)
                                                                 btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                 handler:nil
                                                                isGreedy:NO from:self];
        } else {
            [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CT_INVALID_OPERATION_ALERT_TITLE, nil)
                                                          context:CTLocalizedString(CT_INVALID_OPERATION_ALERT_CONTEXT, nil)
                                                          btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                          handler:nil
                                                         isGreedy:NO];
        }
    });
}

- (void)removeAllCheck {
    if (self.centralManager) {
        self.centralManager = nil;
        self.checkPassed = 0;
    }
}

- (void)createConnectionForService:(NSNetService *)service {
    BOOL success = NO;
    NSInputStream *inStream = nil;
    NSOutputStream *outStream = nil;
    
    // device was chosen by user in picker view
    success = [service getInputStream:&inStream outputStream:&outStream];
    if (!success) {
        // failed, so allow user to choose device
        [[CTBonjourManager sharedInstance] setupStream];
    } else {
        // user tapped device: so create and open streams with that devices
        [CTBonjourManager sharedInstance].inputStream = inStream;
        [CTBonjourManager sharedInstance].outputStream = outStream;
        [CTBonjourManager sharedInstance].streamOpenCount = 0;
        [[CTBonjourManager sharedInstance] openStreamsForController:self withHandler:nil];
        
        // prevent user click multiple times
        self.invitationSent = YES; // sent invitation already
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"CTScanningToCTSenderWaitingViewController" sender:self];
        });
        
    }
}

- (void)customizeConditionCheckAlert {
    NSString *btnTitle = CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, nil);
    NSString *string = @"";
    
    if (self.hasWifiErr) {
        string = CTLocalizedString(ALERT_MESSAGE_PLEASE_TURN_ON_WIFI, nil);
    }
    
    if (self.hasBlueToothErr) {
        if (string.length == 0) {
            string = CTLocalizedString(CT_TURN_OFF_BT_ALERT_CONTEXT, nil);
        } else {
            string = [NSString stringWithFormat:CTLocalizedString(CT_FORMATTED_TURN_OFF_BT_ALERT_CONTEXT, nil), string];
        }
    }
    
    string = [string stringByAppendingString:CTLocalizedString(CT_START_SEARCHING_STRING, nil)];
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
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // iOS to iOS only has one manual setup button
        if (self.hasWifiErr && self.hasBlueToothErr) {
            [self.manualSetupCenterButton setTitle:CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, nil) forState:UIControlStateNormal];
        } else if (self.hasWifiErr) {
            [self.manualSetupCenterButton setTitle:CTLocalizedString(CT_WIFI_BUTTON_TITLE, nil) forState:UIControlStateNormal];
        } else {
            [self.manualSetupCenterButton setTitle:CTLocalizedString(CT_BT_SETTINGS_BUTTON_TITLE, nil) forState:UIControlStateNormal];
        }
    }
    
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

- (void)alertUser:(NSString *)context withSettingGuild:(BOOL)needSetting withSettingButtonTitle:(NSString *)title withConfirmHandler:(void (^)(UIAlertAction *action))handler andCancelHandler:(void (^)(UIAlertAction *action))cancelHandler {
    if (needSetting) {
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                              context:context
                                                        cancelBtnText:CTLocalizedString(title, nil)
                                                       confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                       confirmHandler:^(CTVerizonAlertViewController *alertVC) {
                                                           UIAlertAction *action = [[UIAlertAction alloc]init];
                                                           handler(action);
                                                       }
                                                        cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                            UIAlertAction *action = [[UIAlertAction alloc]init];
                                                            cancelHandler(action);
                                                        }
                                                             isGreedy:NO from:self];
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
                                                                     UIAlertAction *action = [[UIAlertAction alloc]init];
                                                                     handler(action);
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

#pragma mark - NSStreamDelegate
// Stream connection event
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) { // streams opened
        case NSStreamEventOpenCompleted: {
            [CTBonjourManager sharedInstance].streamOpenCount += 1;
            DebugLog(@"opened:%@", stream);
            @try {
                NSAssert([CTBonjourManager sharedInstance].streamOpenCount <= 2, @"StreamCountException");
            } @catch(NSException *exception) {
                DebugLog(@"Error when open stream, count wrong:%@", exception.description);
            }
            // once both streams are open we hide the picker
            if ([CTBonjourManager sharedInstance].streamOpenCount == 2) {
                [[CTBonjourManager sharedInstance] stopServer];
                self.shouldWaitForResponse = NO;
            }
        }
            break;
            
        case NSStreamEventHasBytesAvailable: {
            // stream has data (in a real app you have gather up multiple data packets into the sent data)
            NSUInteger bsize = 1024;
            uint8_t buf[bsize];
            NSInteger bytesRead = 0;
            bytesRead = [[CTBonjourManager sharedInstance].inputStream read:buf maxLength:bsize];
            if (bytesRead > 0) {
                self.handler(NEXT_VIEW_SHOULD_HIDE_ALERT);
                
                NSData *receivedData = [NSData dataWithBytes:buf length:bytesRead];
                //                DebugLog(@"debug mode:received data on pairing page:%lu", (unsigned long)receivedData.length);
                NSString *response = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
                
                if ([response rangeOfString:CT_REQUEST_FILE_CANCEL_PERMISSION].location != NSNotFound) {
                    [[CTBonjourManager sharedInstance] closeStreams];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CANCEL_ALL_OPERATION" object:nil];
                    [self popToRootViewController:[CTStartedViewController class]];
                    
                    return;
                }
                
                NSRange range = [response rangeOfString:CT_REQUEST_FILE_CANCEL];
                if ((range.location != NSNotFound) && (response.length > 0)) { // receiver is a sender
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // should go cancel
                        self.handler(NEXT_VIEW_SHOULD_CANCEL);
                    });
                    return;
                }
                range = [response rangeOfString:kBonjourBadRequest]; // 502, try to connect to a old phone
                if ((range.location != NSNotFound) && (response.length > 0)) { // receiver is a sender
                    [self.scanner scannerShouldIgnoreFutherReadForAlert];
                    if (USES_CUSTOM_VERIZON_ALERTS){
                        [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CT_INVALID_OPERATION_ALERT_TITLE, nil)
                                                                             context:CTLocalizedString(CT_INVALID_OPERATION_ALERT_CONTEXT, nil)
                                                                             btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                             handler:^(CTVerizonAlertViewController *alertVC) {
                                                                                 [self.scanner scannerShouldstartReading];
                                                                             }
                                                                            isGreedy:NO
                                                                                from:self
                                                                          completion:^(CTVerizonAlertViewController *alertVC) {
                                                                              [[CTBonjourManager sharedInstance] closeStreams];
                                                                              
                                                                              self.shouldIgnoreCheck = YES;
                                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                                  self.handler(NEXT_VIEW_SHOULD_GO_BACK);
                                                                              });
                                                                          }];
                    }else{
                        [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CT_INVALID_OPERATION_ALERT_TITLE, nil)
                                                                      context:CTLocalizedString(CT_INVALID_OPERATION_ALERT_CONTEXT, nil)
                                                                      btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                      handler:^(UIAlertAction *action) {
                                                                          [self.scanner scannerShouldstartReading];
                                                                      }
                                                                     isGreedy:NO];
                        [[CTBonjourManager sharedInstance] closeStreams];
                        
                        self.shouldIgnoreCheck = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.handler(NEXT_VIEW_SHOULD_GO_BACK);
                        });
                    }
                    
                } else { // receiver reject this connection
                    range = [response rangeOfString:kBonjourServiceUnavailable];
                    if ((range.location != NSNotFound) && (response.length > 0)) {
                        [self.scanner scannerShouldIgnoreFutherReadForAlert];
                        if (USES_CUSTOM_VERIZON_ALERTS){
                            [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                                                 context:CTLocalizedString(CT_INVITATION_REJECTED_ALERT_CONTEXT, nil)
                                                                                 btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                                 handler:^(CTVerizonAlertViewController *alertVC) {
                                                                                     [self.scanner scannerShouldstartReading];
                                                                                 }
                                                                                isGreedy:NO
                                                                                    from:self
                                                                              completion:^(CTVerizonAlertViewController *alertVC) {
                                                                                  [[CTBonjourManager sharedInstance] closeStreams];
                                                                                  
                                                                                  self.shouldIgnoreCheck = YES;
                                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                                      self.handler(NEXT_VIEW_SHOULD_GO_BACK);
                                                                                  });
                                                                              }];
                        }else{
                            [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                                          context:CTLocalizedString(CT_INVITATION_REJECTED_ALERT_CONTEXT, nil)
                                                                          btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                          handler:^(UIAlertAction *action) {
                                                                              [self.scanner scannerShouldstartReading];
                                                                          }
                                                                         isGreedy:NO];
                            
                            [[CTBonjourManager sharedInstance] closeStreams];
                            
                            self.shouldIgnoreCheck = YES;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.handler(NEXT_VIEW_SHOULD_GO_BACK);
                            });
                        }
                        
                    } else {
                        NSError *errorJson = nil;
                        NSDictionary *myDictionary = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions error:&errorJson];
                        if (myDictionary.count > 0) {
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
                }
                
                if (self.blockUI) { // only dismiss UI block when this view will not dismiss
                    [self enableUserInteractionWithDelay:0];
                    
                    self.blockUI = NO;
                }
            }
        }
            break;
        case NSStreamEventEndEncountered: {
            DebugLog(@"event end");
        }
            break;
        case NSStreamEventNone: {
            DebugLog(@"event none");
        }
            break;
        case NSStreamEventErrorOccurred:{
            DebugLog(@"error");
            
        }
            break;
        default:
            break;
    }
}

- (void)checkVersionoftheApp:(NSString *)verison {
    CTVersionManager *versionCheck = [[CTVersionManager alloc] init];
    self.versionChecked = YES;
    
    NSString *str1 = [NSString stringWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@#%@", BUILD_VERSION, BUILD_SAME_PLATFORM_MIN_VERSION,[CTUserDevice userDevice].freeSpaceAvaiable];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:str1 forKey:USER_DEFAULTS_VERSION_CHECK];
    [dict setValue:[NSString stringWithFormat:@"Device ID: %@",self.uuid_string] forKey:USER_DEFAULTS_DB_PARING_DEVICE_INFO];
    
    CTDeviceMarco *deviceMacro = [[CTDeviceMarco alloc] init];
    NSString *modelCode = [deviceMacro getDeviceModel];
    NSString *model = [deviceMacro.models objectForKey:modelCode];
    if (model.length == 0) {
        model = modelCode;
    }
    
    [dict setValue:model forKey:USER_DEFAULTS_PAIRING_MODEL];
    [dict setValue:[[UIDevice currentDevice] systemVersion] forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
    [dict setValue:@"iOS" forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
    [dict setValue:[CTUserDevice userDevice].deviceUDID forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
    [dict setObject:kBonjour forKey:USER_DEFAULTS_PAIRING_TYPE];
    
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    [[CTBonjourManager sharedInstance] sendStream:requestData];
    
    // Check the current version with other side version
    CTVersionCheckStatus status = [versionCheck identifyOsVersion:verison];
    if (status == CTVersionCheckStatusMatched) {
        [CTUserDefaults sharedInstance].isCancel = NO;
        self.handler(NEXT_VIEW_SHOULD_GO_FORWARD);
        [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
    } else if (status == CTVersionCheckStatusLesser) {
        // alert to upgrade other device
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                                 context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil), versionCheck.supported_version]
                                                                 btnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil) handler:^(CTVerizonAlertViewController *alertVC) {
                                                                     [[CTBonjourManager sharedInstance] closeStreams];
                                                                     self.versionChecked = NO;
                                                                     self.handler(NEXT_VIEW_SHOULD_POP_ROOT);
                                                                     
                                                                     [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
                                                                 }
                                                                isGreedy:NO from:self];
        }else {
            [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                          context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil),  versionCheck.supported_version]
                                                          btnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil) handler:^(UIAlertAction *action) {
                                                              [[CTBonjourManager sharedInstance] closeStreams];
                                                              self.versionChecked = NO;
                                                              self.handler(NEXT_VIEW_SHOULD_POP_ROOT);
                                                              
                                                              [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
                                                          }
                                                         isGreedy:NO];
  
        }
    } else {
        // alert to upgrade currnt device
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                              context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_RECEIVER_ALERT_CONTEXT, nil), versionCheck.supported_version]
                                                        cancelBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                       confirmBtnText:CTLocalizedString(CT_UPGRADE_BUTTON_TITLE, nil)
                                                       confirmHandler:^(CTVerizonAlertViewController *alertVC) {
                                                           [[CTBonjourManager sharedInstance] closeStreams];
                                                           [CTSettingsUtility openAppStoreLink];
                                                           self.handler(NEXT_VIEW_SHOULD_POP_ROOT);
                                                           
                                                           [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
                                                       }
                                                        cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                            [[CTBonjourManager sharedInstance] closeStreams];
                                                            self.versionChecked = NO;
                                                            self.handler(NEXT_VIEW_SHOULD_POP_ROOT);
                                                            
                                                            [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
                                                        }
                                                             isGreedy:NO from:self];
        } else {
            [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                       context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_RECEIVER_ALERT_CONTEXT, nil), versionCheck.supported_version]
                                                 cancelBtnText:CTLocalizedString(CT_UPGRADE_BUTTON_TITLE, nil)
                                                confirmBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                confirmHandler:^(UIAlertAction *action) {
                                                    [[CTBonjourManager sharedInstance] closeStreams];
                                                    self.versionChecked = NO;
                                                    self.handler(NEXT_VIEW_SHOULD_POP_ROOT);
                                                    
                                                    [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
                                                }
                                                 cancelHandler:^(UIAlertAction *action) {
                                                     [[CTBonjourManager sharedInstance] closeStreams];
                                                     [CTSettingsUtility openAppStoreLink];
                                                     self.handler(NEXT_VIEW_SHOULD_POP_ROOT);
                                                     
                                                     [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
                                                 }
                                                      isGreedy:NO];
  
        }
    }
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CTScanningToCTSenderWaitingViewController"]) {
        CTSenderWaitingViewController *targetViewController = (CTSenderWaitingViewController *)segue.destinationViewController;
        
        self.handler = ^(int type) {
            if (type == NEXT_VIEW_SHOULD_GO_BACK) {
                [targetViewController senderWaitingViewShouldGoBack];
            } else if (type == NEXT_VIEW_SHOULD_GO_FORWARD) {
                [targetViewController senderWaitingViewShouldGoForward];
            } else if (type == NEXT_VIEW_SHOULD_POP_ROOT) {
                [targetViewController senderWaitingViewShouldPopToRoot];
            } else if (type == NEXT_VIEW_SHOULD_HIDE_ALERT) {
                [targetViewController dismissConnectingDialog];
            } else if (type == NEXT_VIEW_SHOULD_CANCEL) {
                [targetViewController senderShouldPushCancel];
            }
        };
    }
}

#pragma mark - QRScanner delegate
- (void)QRScanner:(CTQRScanner *)scanner didFailedScannedQRCode:(NSString *)reason handler:(void (^)(void))handler {
    // Display whatever the error information
    [self alertUser:reason withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
        handler();
    } andCancelHandler:nil];

}

- (void)QRScanner:(CTQRScanner *)scanner didSuccessfullyScannedQRCode:(NSString *)qrCodeString {
    NSArray *connectInfo = [CTQRCode parseQRCodeString:qrCodeString];
    NSLog(@"Connected infomation:\n%@", connectInfo);
    [self analysisConnectionInfo:connectInfo];
}

#pragma mark - QR Code Reading Logic
- (void)analysisConnectionInfo:(NSArray *)connectInfo {
    
    if (connectInfo.count == CTQRCodeTypeNormal || connectInfo.count == CTQRCodeTypeCross) {
        NSString *firstSection = connectInfo[0];
        if (firstSection.length < 5 || ![[firstSection substringToIndex:5] isEqualToString:@"VZWCT"]) {
            // invalid code text
            [self.scanner scannerShouldIgnoreFutherReadForAlert];
            [self alertUser:CTLocalizedString(CT_ERROR_READING_CODE_ALERT_CONTEXT, nil) withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
                [self.scanner scannerShouldstartReading];
            } andCancelHandler:nil];
            
            [self.scanner attachScanner];
            [self.scanner startScanner];
            
            return;
        }
        
        if (connectInfo.count == CTQRCodeTypeNormal) {
            self.targetService  = connectInfo[CTQRInfoService];
            
        } else if (connectInfo.count == CTQRCodeTypeCross) {
            // Do nothing
        }
    } else {
        // invalid code text
        [self.scanner scannerShouldIgnoreFutherReadForAlert];
        [self alertUser:CTLocalizedString(CT_ERROR_READING_CODE_ALERT_CONTEXT, nil) withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
            [self.scanner scannerShouldstartReading];
        } andCancelHandler:nil];
        
        [self.scanner attachScanner];
        [self.scanner startScanner];
        
        return;
    }
    
    self.targetIP        = connectInfo[CTQRInfoIpAddress];
    self.targetSSID      = connectInfo[CTQRInfoSSID];
    self.targetPasscode  = connectInfo[CTQRInfoPasscode];
    self.transferType    = connectInfo[CTQRInfoCombinationType];
    self.securityType    = connectInfo[CTQRInfoSecurityType];
    self.targetSetupType = connectInfo[CTQRInfoSetupType];
    
    if ([connectInfo[CTQRInfoConnectionType] isEqualToString:@"multipeer"]) { // scan ios to ios one-to-many code
        [self.scanner scannerShouldIgnoreFutherReadForAlert];
        NSString *context = CTLocalizedString(CT_ERROR_READING_CODE_ALERT_CONTEXT_MULTIPEER, nil);
        __weak typeof(self) weakSelf = self;
        [self alertUser:context withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
            [weakSelf popToRootViewController:[CTStartedViewController class]];
        } andCancelHandler:nil];
        
        return;
    }
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod] && ([self.transferType isEqualToString:@"same platform"] || [self.transferType isEqualToString:@"ios to ios"])) { // cross platform setting
        [self.scanner scannerShouldIgnoreFutherReadForAlert];
        NSString *context = @"";
        if (self.transferFlow == CTTransferFlow_Sender) {
            context = CTLocalizedString(CT_ERROR_SCANNING_CODE_ALERT_CONTEXT_IPHONE_TO_OTHER, nil);
        } else {
            context = CTLocalizedString(CT_ERROR_SCANNING_CODE_ALERT_CONTEXT_OTHER_TO_IPHONE, nil);
        }
        __weak typeof(self) weakSelf = self;
        [self alertUser:context withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
            [weakSelf popToRootViewController:[CTStartedViewController class]];
        } andCancelHandler:nil];
        
        return;
    }
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod] && [self.transferType isEqualToString:@"cross platform"] && ((self.transferFlow == CTTransferFlow_Sender && [self.targetSetupType isEqualToString:@"Sender"]) || (self.transferFlow == CTTransferFlow_Receiver && [self.targetSetupType isEqualToString:@"Receiver"]))) { // cross platform setting with same flow
        [self.scanner scannerShouldIgnoreFutherReadForAlert];
        NSString *context = @"";
        if (self.transferFlow == CTTransferFlow_Sender) {
            context = CTLocalizedString(CT_ERROR_SCANNING_CODE_ALERT_CONTEXT_IPHONE_TO_OTHER, nil);
        } else {
            context = CTLocalizedString(CT_ERROR_SCANNING_CODE_ALERT_CONTEXT_OTHER_TO_IPHONE, nil);
        }
        __weak typeof(self) weakSelf = self;
        [self alertUser:context withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
            [weakSelf popToRootViewController:[CTStartedViewController class]];
        } andCancelHandler:nil];
        
        return;
    }
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS] && ([self.transferType isEqualToString:@"cross platform"] || [self.transferType isEqualToString:@"same platform"])) { // ios to ios setting
        [self.scanner scannerShouldIgnoreFutherReadForAlert];
        NSString *context = CTLocalizedString(CT_ERROR_SCANNING_CODE_ALERT_CONTEXT_IPHONE_TO_IPHONE, nil);
        __weak typeof(self) weakSelf = self;
        [self alertUser:context withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
            [weakSelf popToRootViewController:[CTStartedViewController class]];
        } andCancelHandler:nil];
        
        return;
    }
    
    // Check one to many cross code setting
    if (self.isForSTM && ![self.transferType isEqualToString:@"one to many"]) {
        [self.scanner scannerShouldIgnoreFutherReadForAlert];
        NSString *context = CTLocalizedString(CT_ERROR_SCANNING_CODE_ALERT_CONTEXT_ONE_TO_MANY, nil);
        __weak typeof(self) weakSelf = self;
        [self alertUser:context withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
            [weakSelf popToRootViewController:[CTStartedViewController class]];
        } andCancelHandler:nil];
        
        return;
    }
    
    if (!self.isForSTM && [self.transferType isEqualToString:@"one to many"]) {
        [self.scanner scannerShouldIgnoreFutherReadForAlert];
        NSString *context = CTLocalizedString(CT_ERROR_SCANNINED_CODE_ALERT_CONTEXT_IS_ONE_TO_MANY, nil);
        __weak typeof(self) weakSelf = self;
        [self alertUser:context withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
            [weakSelf popToRootViewController:[CTStartedViewController class]];
        } andCancelHandler:nil];
        
        return;
    }
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod] && [self.transferType isEqualToString:@"one to many"] && ((self.transferFlow == CTTransferFlow_Sender && [self.targetSetupType isEqualToString:@"Sender"]) || (self.transferFlow == CTTransferFlow_Receiver && [self.targetSetupType isEqualToString:@"Receiver"]))) { // one to many cross platform setting with same flow
        [self.scanner scannerShouldIgnoreFutherReadForAlert];
        NSString *context = @"";
        if (self.transferFlow == CTTransferFlow_Sender) {
            context = CTLocalizedString(CT_ERROR_SCANNING_CODE_ALERT_CONTEXT_IPHONE_TO_OTHER, nil);
        } else {
            context = CTLocalizedString(CT_ERROR_SCANNING_CODE_ALERT_CONTEXT_OTHER_TO_IPHONE, nil);
        }
        __weak typeof(self) weakSelf = self;
        [self alertUser:context withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
            [weakSelf popToRootViewController:[CTStartedViewController class]];
        } andCancelHandler:nil];
        
        return;
    }
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS] && connectInfo.count == CTQRCodeTypeNormal) {
        if (![CTDeviceMarco isiPhone4AndBelow] && _bonjourEnabled) { // Bonjour
            if (self.targetService == nil || self.targetService.length == 0) {
                [self prepareP2PConnection];
            } else {
                [self disableUserInteraction];
                [self checkService];
            }
        } else { // Not supporting Bonjour
            [self prepareP2PConnection];
        }
    } else if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod] && connectInfo.count == CTQRCodeTypeCross) {
        self.targetIP       = connectInfo[CTQRInfoIpAddress];
        self.targetSSID     = connectInfo[CTQRInfoSSID];
        self.targetPasscode = connectInfo[CTQRInfoPasscode];
        self.securityType   = connectInfo[CTQRInfoSecurityType];
        
        [self prepareP2PConnection];
    }
}

- (void)checkService {
    if ([CTBonjourManager sharedInstance].serviceNumber <= 0) {
        return;
    }
    
    if (self.targetService == nil) {
        return;
    }
    
    [self enableUserInteractionWithDelay:0.f];
    [[CTBonjourManager sharedInstance] seachingForService:self.targetService InListWithHandler:^(bool found, long count, id target) {
        self.targetService = nil;
        if (found) {
            NSNetService *rightSerivce = [((NSArray *)target) objectAtIndex:0];
            _shouldWaitForResponse = YES;
            [CTBonjourManager sharedInstance].targetServer = rightSerivce;
            [self createConnectionForService:rightSerivce];
        } else {
            // go to P2P process automatically.
            [self prepareP2PConnection];
        }
    }];
}

#pragma mark - GCDAsyncSocket
- (void)prepareP2PConnection {
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod] && [CTNetworkUtility isConnectedToHotSpotAccessPoint:self.targetSSID]) {
        // Using hotspot for cross platform
        [CTUserDevice userDevice].softAccessPoint = @"TRUE";
    } else {
        [CTUserDevice userDevice].softAccessPoint = @"FALSE";
    }
    
    self.localSSID = [CTNetworkUtility connectedNetworkName];
    if ([_localSSID isEqualToString:@"Verizon Guest Wi-Fi"]) {
        self.guestWiFiRetryRequired = 1;
    } else {
        self.guestWiFiRetryRequired = 0;
    }
    
    // Check SSID
    if (self.targetSSID.length <= 0 || self.targetSSID == nil) { // No target SSID Found
        [self.scanner scannerShouldIgnoreFutherReadForAlert];
        NSString * alertContext = [NSString stringWithFormat:@"%@", CTLocalizedString(CT_RESCAN_ALERT_CONTEXT, nil)];
        
        [self alertUser:alertContext withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
            [self.scanner scannerShouldstartReading];
        } andCancelHandler:nil];
        
        [self.scanner attachScanner];
        [self.scanner startScanner];
        
        return;
    } else if (self.targetIP == nil || self.targetIP.length <= 0) { // IP not exist
        [self.scanner scannerShouldIgnoreFutherReadForAlert];
        NSString * alertContext = [NSString stringWithFormat:@"%@", CTLocalizedString(CT_RESCAN_AND_MANUAL_SETUP_ALERT_CONTEXT, nil)];
        
        [self alertUser:alertContext withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
            [self.scanner scannerShouldstartReading];
        } andCancelHandler:nil];
        
        [self.scanner attachScanner];
        [self.scanner startScanner];
        
        return;
    } else if (![self.targetSSID isEqualToString:_localSSID]) { // Not connect to same Wi-Fi network
#if TARGET_OS_SIMULATOR
        // Fail to connect, log the error message, and use old fashion way.
        NSLog(@"Simulator is not compilable for NENetworkConfiguration.");
        [self showConnectToSameWiFiPrompt];
        [self showConnectToSameWiFiInformation];
#else
        self.requestToConnectWiFi = YES;
        // Disable user interaction
        [self disableUserInteraction];
        // Try to connect to target Wi-Fi programmatically
        [[CTHotSpotHelper shared] connectToPersonalHotspot:self.targetSSID passphrase:self.targetPasscode completion:^(CTHotSpotError * _Nullable error) {
            self.requestToConnectWiFi = NO;
            if (error) {
                // Enable user interaction
                [self enableUserInteractionWithDelay:0];
                // Fail to connect, log the error message, and use old fashion way.
                NSLog(@"Connect to hotspot failed. Reason(%ld): %@", (long)error.code, error.localizedDescription);
                
                [self showConnectToSameWiFiPrompt];
                [self showConnectToSameWiFiInformation];
            } else {
                // Successfully connect to hotspot, proceed
                // During test, block will return after the device switch the network to the new network completely. So if device is able to join target network, then SSID will be the same and proceed the socket connection; Otherwise ssid will not be equal, and one system prompt with "Unable to join" will show, at same time, app will show the copied information(prompt + label)
                NSLog(@"Connected to target hotspot network.");
                if (![self scanCurrentNetwork]) {
                    [self showConnectToSameWiFiPrompt];
                    [self showConnectToSameWiFiInformation];
                }
            }
        }];
#endif
        
        return;
    }
    
    [self disableUserInteraction];
    [self tryP2PConnection];
}

- (void)showConnectToSameWiFiPrompt {
    if (self.targetPasscode.length > 0) { // has password
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Copy password into clipboard
            UIPasteboard.generalPasteboard.string = self.targetPasscode;
            [[CTFrameworkClipboardStatus sharedInstance] pasteBoardDidPastePassword:self.targetPasscode];
            
            // Alert title
            NSAttributedString *alertTitle = [[NSAttributedString alloc] initWithString:CTLocalizedString(CT_CONNECT_TO_DEVICE_HOTSPOT_ALERT_TITLE, nil) attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17.f], NSForegroundColorAttributeName:[CTMVMColor mvmPrimaryRedColor]}];
            
            // Alert body
            NSMutableAttributedString *alertBody = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:CTLocalizedString(CT_CONNECT_TO_DEVICE_HOTSPOT_ALERT_BODY_PART1, nil), self.targetSSID] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}];
            [alertBody setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]} range:NSMakeRange(alertBody.length - self.targetSSID.length - 1, self.targetSSID.length)];
            [alertBody appendAttributedString:[[NSAttributedString alloc] initWithString:CTLocalizedString(CT_CONNECT_TO_DEVICE_HOTSPOT_ALERT_BODY_PART2, nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}]];
            [alertBody appendAttributedString:[[NSAttributedString alloc] initWithString:CTLocalizedString(CT_CONNECT_TO_DEVICE_HOTSPOT_ALERT_BODY_PART3, nil) attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}]];
            if (USES_CUSTOM_VERIZON_ALERTS) {
                [CTVerizonAlertCreateFactory showTwoButtonsAlertWithAttributedTitle:alertTitle attributedContext:alertBody cancelBtnText:CTLocalizedString(CT_DISMISS_BUTTON_TITLE, nil) confirmBtnText:CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, nil) confirmHandler:^(CTVerizonAlertViewController *alertVC){
                    [CTSettingsUtility openWifiSettings];
                } cancelHandler:nil isGreedy:NO from:self];
            } else {
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okBtn = [UIAlertAction actionWithTitle:CTLocalizedString(CT_DISMISS_BUTTON_TITLE, nil) style:UIAlertActionStyleDefault handler:nil];
                UIAlertAction *settingBtn = [UIAlertAction actionWithTitle:CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [CTSettingsUtility openWifiSettings];
                }];
                [controller addAction:okBtn];
                [controller addAction:settingBtn];
                [controller setValue:alertTitle forKey:@"attributedTitle"];
                [controller setValue:alertBody forKey:@"attributedMessage"];
                [self presentViewController:controller animated:YES completion:nil];
            }
        });
    } else {
        NSString * alertContext = [NSString stringWithFormat:CTLocalizedString(CT_CONNECT_DEVICE_TO_NETWORK_ALERT_CONTEXT, nil), self.targetSSID];
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                              context:alertContext
                                                        cancelBtnText:CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, nil)
                                                       confirmBtnText:CTLocalizedString(CT_DISMISS_BUTTON_TITLE, nil)
                                                       confirmHandler:nil
                                                        cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                            [CTSettingsUtility openWifiSettings];
                                                        } isGreedy:NO from:self];
        } else {
            [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                       context:alertContext
                                                 cancelBtnText:CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, nil)
                                                confirmBtnText:CTLocalizedString(CT_DISMISS_BUTTON_TITLE, nil)
                                                confirmHandler:nil
                                                 cancelHandler:^(UIAlertAction *action) {
                                                     [CTSettingsUtility openWifiSettings];
                                                 } isGreedy:NO];
        }
    }
}

- (void)showConnectToSameWiFiInformation {
    self.viewPreview.hidden = YES;
    self.secondaryLabel.hidden = NO;
    
    self.titleLbl.text = CTLocalizedString(CT_CONNECT_TO_NETWORK_INFO_LABEL, nil);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", CTLocalizedString(CT_CONNECT_TO_NETWORK_SEC_INFO_LABEL_PART1, nil)]];
    if ([CTDeviceStatusUtility isDeviceUsingSpanish]) {
        [attributedString setAttributes:@{NSFontAttributeName:[CTMVMFonts mvmBoldFontOfSize:13.f]}
                                  range:NSMakeRange(attributedString.length - 45, 21)];
    } else {
        [attributedString setAttributes:@{NSFontAttributeName:[CTMVMFonts mvmBoldFontOfSize:13.f]}
                              range:NSMakeRange(attributedString.length - 35, 15)];
    }
    
    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:CTLocalizedString(CT_CONNECT_TO_NETWORK_SEC_INFO_LABEL_PART2, nil), self.targetSSID]];
    NSInteger titleLen = 13;
    if ([CTDeviceStatusUtility isDeviceUsingSpanish]) {
        titleLen = 14;
    }
    [attributedString2 setAttributes:@{NSFontAttributeName:[CTMVMFonts mvmBoldFontOfSize:13.f]}
                               range:NSMakeRange(0, titleLen)];
    [attributedString2 setAttributes:@{NSFontAttributeName:[CTMVMFonts mvmBookFontOfSize:13.f], NSForegroundColorAttributeName:[CTMVMColor mvmPrimaryRedColor]}
                               range:NSMakeRange(titleLen, attributedString2.length - titleLen)];
    
    [attributedString appendAttributedString:attributedString2];
    if (self.targetPasscode.length > 0) {
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:CTLocalizedString(CT_CONNECT_TO_NETWORK_SEC_INFO_LABEL_PART3, nil), self.targetPasscode]]];
        
        if ([CTDeviceStatusUtility isDeviceUsingSpanish]) {
            [attributedString setAttributes:@{NSFontAttributeName:[CTMVMFonts mvmBoldFontOfSize:13.f]}
                                      range:NSMakeRange(attributedString.length-self.targetPasscode.length-12, 12)];
        } else {
            [attributedString setAttributes:@{NSFontAttributeName:[CTMVMFonts mvmBoldFontOfSize:13.f]}
                                  range:NSMakeRange(attributedString.length-self.targetPasscode.length-10, 10)];
        }
    }
    self.secondaryLabel.attributedText = attributedString;
    [self.secondaryLabel setTextAlignment:NSTextAlignmentLeft];
    
    self.needSameWifiCheck = YES;
    
    if (self.transferFlow == CTTransferFlow_Sender) {
        self.manualSetupCenterButton.hidden = YES;
        self.manualSetupButton.hidden = NO;
        self.tryAnotherWayBtn.hidden = NO;
    }
}

- (void)tryP2PConnection {
    dispatch_queue_t backgroundQueue = dispatch_queue_create("CTScannerSocketQueue", 0);
    self.gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:backgroundQueue];
    
    __weak typeof(self) weakSelf = self;
    // Fetch the IP address from background thread.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger retryTimes = 0;
        if ([[CTUserDevice userDevice].softAccessPoint isEqualToString:@"TRUE"]) { // If it's wifi-direct hotspot
            do { // It may take sometime for system to get IP from newly connected wifi network.
                weakSelf.targetIP = [CTDeviceStatusUtility getHotSpotIpAddress];
                NSLog(@"Target IP: %@", weakSelf.targetIP);
                retryTimes += 1; // Add retry time by one.
                // Delay 1 second to continue
                [NSThread sleepForTimeInterval:1.0f];
            } while((!weakSelf.targetIP || weakSelf.targetIP.length == 0) && retryTimes < CTFindIPAddressMaxRetryTime);
        }
        
        NSLog(@"IP found: %@", self.targetIP);
        
        // Try to connect
        dispatch_async(dispatch_get_main_queue(), ^{
            [self enableUserInteractionWithDelay:0];
            NSError *error = nil;
            [self.gcdSocket connectToHost:self.targetIP onPort:REGULAR_PORT withTimeout:20 error:&error];
            if (error) {
                DebugLog(@"Unable to connect to due to invalid configuration: %@", [error localizedDescription]);
                // Show alert information
                [self.scanner scannerShouldIgnoreFutherReadForAlert];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self alertUser:CTLocalizedString(CT_PIN_ERROR_ALERT_CONTEXT, nil) withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
                        [self.scanner scannerShouldstartReading];
                    } andCancelHandler:nil];
                    
                    [self.scanner attachScanner];
                    [self.scanner startScanner];
                });
            } else {
                DebugLog(@"Connecting...");
                [self.alertView show];
            }
        });
    });
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    NSString *shareKey = nil;
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
        shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@#space%@",BUILD_VERSION,BUILD_SAME_PLATFORM_MIN_VERSION,[CTUserDevice userDevice].freeSpaceAvaiable];
    } else {
        shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@#space%@",BUILD_VERSION,BUILD_CROSS_PLATFROM_MIN_VERSION,[CTUserDevice userDevice].freeSpaceAvaiable];
    }
    
    [self writeDataToSocket:shareKey];
    [CTUserDevice userDevice].pairingType = kP2P;
    [self.gcdSocket readDataWithTimeout:-1.0f tag:0];
}

- (void)writeDataToSocket :(NSString *)strData {
    
    DebugLog(@"write 1 %@",strData);
    NSData *requestData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.gcdSocket writeData:requestData withTimeout: -1.0f tag:0];
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
        [self.gcdSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0f tag:0];
    }
    
    [self.gcdSocket readDataWithTimeout:-1.0 tag:0];
}

#define GCDAsyncSocketConnectionTimeOut 3
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (err.code == 0) {
        return;
    }
    
    if (self.shouldIgnore) {
        return;
    }
    
    if (self.paired) {
        // should be cancel
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pushCancelBlock();
        });
        
        return;
    }
    
    DebugLog(@"socketDidDisconnect:withError: \"%@(%ld)\"", err.localizedDescription, (long)err.code);
    if (err.code == GCDAsyncSocketConnectionTimeOut) {
        if (!self.guestWiFiRetryRequired) {
            [self.scanner scannerShouldIgnoreFutherReadForAlert];
            [self.alertView hide:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self alertUser:CTLocalizedString(CT_PIN_ERROR_ALERT_CONTEXT, nil) withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
                        [self.scanner scannerShouldstartReading];
                    } andCancelHandler:nil];
                    
                    [self.scanner attachScanner];
                    [self.scanner startScanner];
                });
            }];
        } else {
            [self checkIfDeviceConnectedToVerizonGuestWiFi];
        }
    } else {
        // Other error received
        [self.scanner scannerShouldIgnoreFutherReadForAlert];
        [self.alertView hide:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertUser:CTLocalizedString(CT_RESCAN_AND_MANUAL_SETUP_ALERT_CONTEXT, nil) withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
                    [self.scanner scannerShouldstartReading];
                } andCancelHandler:nil];
                
                [self.scanner attachScanner];
                [self.scanner startScanner];
            });
        }];
    }
}

- (void)checkIfDeviceConnectedToVerizonGuestWiFi {
    NSString *retrievedAddress = self.targetIP;
    
    NSMutableArray *listItems = (NSMutableArray *)[retrievedAddress componentsSeparatedByString:@"."];
    
    int thirdIndex = (int)[[listItems objectAtIndex:2] integerValue];
    
    if (thirdIndex == 98) {
        thirdIndex++;
    } else {
        thirdIndex--;
    }
    NSString *newpin = [NSString stringWithFormat:@"%d",thirdIndex];
    [listItems replaceObjectAtIndex:2 withObject:newpin];
    
    newpin = [listItems componentsJoinedByString:@"."];
    
    uint16_t port = REGULAR_PORT;
    NSError *error = nil;
    
    self.guestWiFiRetryRequired = 0;
    
    [self.gcdSocket connectToHost:newpin onPort:port withTimeout:20 error:&error];
    if (error) {
        DebugLog(@"Unable to connect to due to invalid configuration: %@", [error localizedDescription]);
        
        [self.scanner scannerShouldIgnoreFutherReadForAlert];
        [self.alertView hide:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertUser:CTLocalizedString(CT_RESCAN_AND_MANUAL_SETUP_ALERT_CONTEXT, nil) withSettingGuild:NO withSettingButtonTitle:nil withConfirmHandler:^(UIAlertAction *action) {
                    [self.scanner scannerShouldstartReading];
                } andCancelHandler:nil];
                
                [self.scanner attachScanner];
                [self.scanner startScanner];
            });
        }];
    } else {
        DebugLog(@"Connecting...");
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    [self.alertView hide:nil];
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    response = [response formatRequestForXPlatform];
    
    NSRange range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENAND#"];  // For cross verison check
    if (range.location == NSNotFound) {
        range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#"]; // iOS verison check
        
        [CTUserDevice userDevice].isAndroidPlatform = @"FALSE";
    } else {
        [CTUserDevice userDevice].isAndroidPlatform = @"TRUE";
    }
    
    if (range.location != NSNotFound) {
        
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
                NSString *message = [NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil),versionManager.supported_version];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (USES_CUSTOM_VERIZON_ALERTS){
                        [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                                             context:message
                                                                             btnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil)
                                                                             handler:^(CTVerizonAlertViewController *alertVC) {
                                                                                 [self popToRootViewController:[CTStartedViewController class]];
                                                                             }
                                                                            isGreedy:NO from:self];
                    }else{
                        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTAlertGeneralCancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                            [self popToRootViewController:[CTStartedViewController class]];
                        }];
                        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(CTAlertGeneralCancelTitle, nil) message:message cancelAction:cancelAction otherActions:nil isGreedy:NO];
                    }
                });
                
                self.shouldIgnore = YES;
            }
                break;
            case CTVersionCheckStatusGreater:{
                NSString *message = [NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_RECEIVER_ALERT_CONTEXT, nil),versionManager.supported_version];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (USES_CUSTOM_VERIZON_ALERTS){
                        [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                                          context:message
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
                        CTMVMAlertAction *upgradeAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CT_UPGRADE_BUTTON_TITLE, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                            [CTSettingsUtility openAppStoreLink];
                            [self popToRootViewController:[CTStartedViewController class]];
                        }];
                        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralCancelTitle, nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                            [self popToRootViewController:[CTStartedViewController class]];
                        }];
                        
                        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil) message:message cancelAction:cancelAction otherActions:@[upgradeAction] isGreedy:NO];
                    }
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

- (void)gotoSenderOrReceiverViewController{
    
    if (self.transferFlow == CTTransferFlow_Sender) {  // It goes to Sender if iOS is OLd Device
        
        CTSenderTransferViewController *senderTransferViewController =
        [CTSenderTransferViewController initialiseFromStoryboard:[CTStoryboardHelper transferStoryboard]];
        senderTransferViewController.transferFlow = CTTransferFlow_Sender;
        senderTransferViewController.readSocket = self.gcdSocket;
        senderTransferViewController.delegate = self;
        
        self.pushCancelBlock = ^{
            [senderTransferViewController viewShouldGoToCancelPage]; // block implementation
        };
        
        [self.navigationController pushViewController:senderTransferViewController animated:YES];
        
    } else if (self.transferFlow == CTTransferFlow_Receiver) { // It goes to Recevier if iOS is New Device
        
        CTReceiverReadyViewController *recevierReadyController = [CTReceiverReadyViewController initialiseFromStoryboard:[CTStoryboardHelper transferStoryboard]];
        recevierReadyController.transferFlow = CTTransferFlow_Receiver;
        
        recevierReadyController.writeSocket = self.gcdSocket;
        recevierReadyController.writeSocket.delegate = self.gcdSocket.delegate;
        
        [self.navigationController pushViewController:recevierReadyController animated:YES];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    DebugLog(@"socket:didWriteDataWithTag: %ld",tag);
    
    [self.gcdSocket readDataWithTimeout:-1.0 tag:0];
}

- (BOOL)scanCurrentNetwork {
    if ([[CTNetworkUtility connectedNetworkName] isEqualToString:self.targetSSID]) {
        NSLog(@"Connected SSID: %@", self.targetSSID);
        [self tryP2PConnection];
        return YES;
    } else {
        [self enableUserInteractionWithDelay:0];
        return NO;
    }
}

#pragma mark - updateSenderStatDelegate
- (void)ignoreSocketClosedSignal {
    self.shouldIgnore = YES;
}

#pragma mark - Observers
- (void)applicationWillTerminate:(NSNotification *)notification {
    if ([notification.name isEqualToString:UIApplicationWillTerminateNotification]) {
        if ([self viewIfLoaded] && self.view.window) {
            DebugLog(@"Terminate notification received test");
        }
    }
}

#pragma mark - IBActions
- (IBAction)tryAnotherWayClicked:(UIButton *)sender {
    if (sender.tag == CTButtonTypeTryAnotherWay) { // Try another way button
        if (self.scanner.scannerStarted) {
            [self.scanner stopScanner];
            [self.scanner detachScanner];
        }
        
        if (self.gcdSocket) {
            self.gcdSocket = nil;
        }
        
        if (self.transferFlow == CTTransferFlow_Sender) {
            // When sender side, go to wifi setting page to let user change the proper network
            [CTSettingsUtility openWifiSettings];
        } else {
            // When receiver side, switch camera to QR Code
            CTQRCodeViewController *ctQRCodeViewController = [CTQRCodeViewController initialiseFromStoryboard:[CTStoryboardHelper qrCodeAndScannerStoryboard]];
            ctQRCodeViewController.transferFlow = self.transferFlow;
            [self.navigationController pushViewController:ctQRCodeViewController animated:YES];
        }
    } else { // Rescan
        self.tryAnotherWayBtn.hidden  = YES;
        self.manualSetupButton.hidden = YES;
        self.manualSetupCenterButton.hidden = NO;
        
        self.viewPreview.hidden = NO;
        self.secondaryLabel.hidden = YES;
        
        self.needSameWifiCheck = NO;
        
        if (self.scanner.scannerStarted) {
            [self.scanner stopScanner];
            [self.scanner detachScanner];
        }
        
        [self disableUserInteraction];
        if (self.scanner.isScannerEnabled) {
            [self.scanner attachScanner];
            [self.scanner startScanner];
        } else {
            // camer disabled, add button to go back to manual one on both side. ask camera permission at the beginning.
            self.viewPreview.hidden = YES;
            self.secondaryLabel.hidden = NO;
            self.secondaryLabel.text = CTLocalizedString(CT_BACK_CAMERA_ERROR_MESSAGE_LABEL, nil);
            if (USES_CUSTOM_VERIZON_ALERTS) {
                [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                                  context:CTLocalizedString(CT_BACK_CAMERA_ALERT_CONTEXT, nil)
                                                            cancelBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil)
                                                           confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                           confirmHandler:nil
                                                            cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                                [CTSettingsUtility openAppCustomSettings]; // Go to permission page, supported by all iOS versions
                                                            }
                                                                 isGreedy:NO from:self];
            } else {
                [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                           context:CTLocalizedString(CT_BACK_CAMERA_ALERT_CONTEXT, nil)
                                                     cancelBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil)
                                                    confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                    confirmHandler:nil
                                                     cancelHandler:^(UIAlertAction *action) {
                                                         [CTSettingsUtility openAppCustomSettings]; // Go to permission page, supported by all iOS versions
                                                     }
                                                          isGreedy:NO];
            }
        }
        [self enableUserInteractionWithDelay:0];
    }
}

- (IBAction)manualSetupClicked:(id)sender {
    if (self.isForSTM) { // if it's one to many, simulate try another way operation using manual setup button
        [self tryAnotherWayClicked:self.tryAnotherWayBtn];
        return;
    }
    if (self.hasBlueToothErr && self.hasWifiErr) {
        [CTSettingsUtility openRootSettings];
    } else if (self.hasBlueToothErr) {
        [CTSettingsUtility openBluetoothSettings];
    } else if (self.hasWifiErr) {
        [CTSettingsUtility openWifiSettings];
    } else {
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
    }
}

@end

