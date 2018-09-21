//
//  CTSenderPinViewController.m
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTPinKeyboardAccessoryView.h"
#import "CTSenderPinViewController.h"
#import "CTSenderTransferViewController.h"
#import "CTStoryboardHelper.h"
#import "GCDAsyncSocket.h"
#import "NSData+CTHelper.h"
#import "CTVersionManager.h"
#import "CTSettingsUtility.h"
#import "CTDeviceStatusUtility.h"
#import "CTContentTransferSetting.h"
#import "CTNetworkUtility.h"
#import "CTSenderWaitingViewController.h"
#import "CTUserDevice.h"
#import "NSData+CTHelper.h"
#import "NSString+CTMVMConvenience.h"
#import "CTProgressHUD.h"
#import "CTMVMFonts.h"
#import "CTErrorViewController.h"
#import "CTStartedViewController.h"
#import "CTDeviceMarco.h"
#import "CTCustomAlertView.h"
#import "CTMVMAlertHandler.h"
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

typedef void(^closeAllAsyncOperation)(void);

@interface CTSenderPinViewController ()<GCDAsyncSocketDelegate,UITextFieldDelegate,updateSenderStatDelegate>

@property (nonatomic,strong) GCDAsyncSocket *gcdSocket;
@property (nonatomic,strong) NSString *ipAddress;
@property (nonatomic, strong) CTCustomAlertView *activityIndicator;

@property (nonatomic, assign) BOOL paired;
@property (nonatomic, assign) BOOL shouldIgnore;
@property (nonatomic, strong) closeAllAsyncOperation handle;
@property (nonatomic, assign) int guestWiFiRetryRequired;

@end


@implementation CTSenderPinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dispatch_queue_t backgroundQueue = dispatch_queue_create("CTSenderPINSocketQueue", 0);
    self.gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:backgroundQueue];

    CTPinKeyboardAccessoryView *keyboardView = [CTPinKeyboardAccessoryView customView];

    [self.enterPinTextField1 becomeFirstResponder];
    self.enterPinTextField1.inputAccessoryView = keyboardView;
    self.enterPinTextField2.inputAccessoryView = keyboardView;
    self.enterPinTextField3.inputAccessoryView = keyboardView;
    self.enterPinTextField4.inputAccessoryView = keyboardView;
    [keyboardView.dismissButton addTarget:self
                                  action:@selector(cancelButtonTapped:)
                        forControlEvents:UIControlEventTouchUpInside];
    [keyboardView.connectButton addTarget:self
                                   action:@selector(handleConnectButtonTapped:)
                         forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hideKeyboard)];

    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
        if ([CTDeviceMarco isiPhone4AndBelow]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        }
    } @catch (NSException *exception) {
        DebugLog(@"error");
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.enterPinTextField1.font = [CTMVMFonts mvmBookFontOfSize:20.0];
    self.enterPinTextField2.font = [CTMVMFonts mvmBookFontOfSize:20.0];
    self.enterPinTextField3.font = [CTMVMFonts mvmBookFontOfSize:20.0];
    self.enterPinTextField4.font = [CTMVMFonts mvmBookFontOfSize:20.0];
    [self.enterPinTextField1 becomeFirstResponder];
    if ([self.wifiNameLabel.text isEqualToString:@"Verizon Guest Wi-Fi"]) {
        self.guestWiFiRetryRequired = 1;
    } else{
        self.guestWiFiRetryRequired = 0;
    }
    if ([CTDeviceMarco isiPhone4AndBelow]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if ([CTDeviceMarco isiPhone4AndBelow]) {
        self.primaryLabelTopSpaceConstraint.constant = 0;
    }else {
        self.primaryLabelTopSpaceConstraint.constant = 30;
    }
}

#pragma selectors
- (CTCustomAlertView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[CTCustomAlertView alloc] initCustomAlertViewWithText:CTLocalizedString(CT_CONNECT_DIALOG_CONTEXT, nil) withOritation:CTAlertViewOritation_HORIZONTAL];
    }
    
    return _activityIndicator;
}
-(void) hideKeyboard {
    if ([self.enterPinTextField1 isFirstResponder]) {
        [self.enterPinTextField1 resignFirstResponder];
    }else if ([self.enterPinTextField2 isFirstResponder]) {
        [self.enterPinTextField2 resignFirstResponder];
    }else if ([self.enterPinTextField3 isFirstResponder]) {
        [self.enterPinTextField3 resignFirstResponder];
    }else {
        [self.enterPinTextField4 resignFirstResponder];
    }
}

- (void)cancelButtonTapped:(id)sender {
    [self hideKeyboard];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    self.primaryLabelTopSpaceConstraint.constant = 2;
    self.secondaryLabelTopSpaceConstraint.constant = 2;
    self.seperatorViewTopSpaceConstraint.constant = 2;
    self.codeViewTopSpaceConstraint.constant = 2;
    self.wifiHeaderVerticalAlignmentConstraint.priority = 1;
    self.wifiHeaderTopSpaceConstraint.priority = 999;
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.primaryLabelTopSpaceConstraint.constant = 30;
    self.seperatorViewTopSpaceConstraint.constant = 10;
    self.secondaryLabelTopSpaceConstraint.constant = 10;
    self.codeViewTopSpaceConstraint.constant = 10;
    self.wifiHeaderVerticalAlignmentConstraint.priority = 999;
    self.wifiHeaderTopSpaceConstraint.priority = 1;
    [self.view layoutIfNeeded];
}

- (IBAction)handleNextButtonTapped:(id)sender {
    [self handleConnectButtonTapped:sender];
}

- (IBAction)handleCancelButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString*)addressFromPin{
    
    self.ipAddress = [CTDeviceStatusUtility findIPSeries];
    NSMutableArray *listItems = (NSMutableArray *)[self.ipAddress componentsSeparatedByString:@"."];
    
    if ([listItems count] > 2) {
        NSString *pinString = [NSString stringWithFormat:@"%@%@%@%@", self.enterPinTextField1.text, self.enterPinTextField2.text, self.enterPinTextField3.text, self.enterPinTextField4.text];
         int pin = pinString.intValue % PINCODE;
        NSString *newpin = [NSString stringWithFormat:@"%d",pin];
        [listItems replaceObjectAtIndex:3 withObject:newpin];
    }
    
    return [listItems componentsJoinedByString:@"."];

}

- (void)handleConnectButtonTapped:(id)sender {
    
    [self hideKeyboard];
    if (self.enterPinTextField1.text.length==1 &&
        self.enterPinTextField2.text.length==1 &&
        self.enterPinTextField3.text.length==1 &&
        self.enterPinTextField4.text.length==1) {
        
        uint16_t port = REGULAR_PORT;
        NSError *error = nil;

        NSString *retrievedAddress = [self addressFromPin];
        
//        [self.gcdSocket disconnect];
        [self.gcdSocket connectToHost:retrievedAddress onPort:port withTimeout:20 error:&error];
        if (error) {
            DebugLog(@"Unable to connect to due to invalid configuration: %@", [error localizedDescription]);
        }
        else {
            DebugLog(@"Connecting...");
//            [self.activityIndicator showAnimated:YES];
            [self.activityIndicator show];
        }

    } else {
        [self displayAlert:CTLocalizedString(CT_INVALID_PIN_ALERT_CONTEXT, nil) withTitle:CTLocalizedString(kDefaultAppTitle, nil) withAction:nil];
    }
}

- (void)displayAlert:(NSString *)message withTitle:(NSString*)title withAction:(CTMVMAlertAction*)action{
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralOKTitle, nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [self popToRootViewController:[CTStartedViewController class]];
    }];
    if (action) {
        if (USES_CUSTOM_VERIZON_ALERTS){
            [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:title
                                                              context:message
                                                        cancelBtnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                       confirmBtnText:action.title
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
        
        if ([message rangeOfString:CTLocalizedString(CT_PIN_ERROR_ALERT_CONTEXT, nil)].location != NSNotFound || [message rangeOfString:CTLocalizedString(CT_INVALID_PIN_ALERT_CONTEXT, nil)].location != NSNotFound) {
            if (USES_CUSTOM_VERIZON_ALERTS){
                [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:title
                                                                     context:message
                                                                     btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                     handler:nil
                                                                    isGreedy:NO from:self];
            }else{
                CTMVMAlertAction *OkieAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralOKTitle, nil) style:UIAlertActionStyleCancel handler:nil];
                [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:title message:message cancelAction:OkieAction otherActions:nil isGreedy:NO];
            }
        } else {
            if (USES_CUSTOM_VERIZON_ALERTS){
                [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:title
                                                                     context:message
                                                                     btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                     handler:^(CTVerizonAlertViewController *alertVC) {
                                                                         [self popToRootViewController:[CTStartedViewController class]];
                                                                     }
                                                                    isGreedy:NO from:self];
            }else{
                [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:title message:message cancelAction:cancelAction otherActions:nil isGreedy:NO];
            }

        }

    }
}

# pragma mark GCDAsyncSocket delegate methods

- (void)writeDataToSocket :(NSString *)strData {
    
    DebugLog(@"write 1 %@",strData);
    
    NSData *requestData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.gcdSocket writeData:requestData withTimeout: -1.0f tag:0];
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
        [self.gcdSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0f tag:0];
    }
    
    [self.gcdSocket readDataWithTimeout:-1.0 tag:0];
}


#pragma mark GcdAsyncSocketDelegate methods

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
    if (err.code == GCDAsyncSocketConnectionTimeOut) {
        [self updateWiFiAccessPointLbl];
        if (!self.guestWiFiRetryRequired) {
            [self.activityIndicator hide:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self displayAlert:CTLocalizedString(CT_PIN_ERROR_ALERT_CONTEXT, nil) withTitle:CTLocalizedString(kDefaultAppTitle, nil) withAction:nil];
                });
            }];
        } else {
            [self checkIfDeviceConnectedToVerizonGuestWiFi];
        }
    } else {
        // Other error received
        [self.activityIndicator hide:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (USES_CUSTOM_VERIZON_ALERTS){
                    [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil)
                                                                         context:CTLocalizedString(CT_CHECK_WIFI_CONFIG_ALERT_CONTEXT, nil)
                                                                         btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                         handler:nil
                                                                        isGreedy:NO from:self];
                }else{
                    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) message:CTLocalizedString(CT_CHECK_WIFI_CONFIG_ALERT_CONTEXT, nil) cancelAction:[CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralOKTitle, nil) style:UIAlertActionStyleCancel handler:nil] otherActions:nil isGreedy:NO];
                }
            });
        }];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    [self.activityIndicator hide:nil];
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    response = [response formatRequestForXPlatform];
    
    DebugLog(@"Received data using toString %@",response);
    
    NSRange range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENAND#"];  // For cross verison check
    if (range.location == NSNotFound) {
        range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#"]; // iOS verison check
    }
    
    if (range.location != NSNotFound) {
        
        CTVersionManager *versionManager = [[CTVersionManager alloc] init];
        CTVersionCheckStatus versionCheckStatus = [versionManager identifyOsVersion:response];
        
        DebugLog(@"Version check result data %ld",(long)versionCheckStatus);
        
        switch (versionCheckStatus) {
            case CTVersionCheckStatusMatched:{
                
                [CTUserDefaults sharedInstance].isCancel = NO;
                self.paired = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    CTSenderTransferViewController *senderTransferViewController =
                    [CTSenderTransferViewController initialiseFromStoryboard:[CTStoryboardHelper transferStoryboard]];
                    senderTransferViewController.transferFlow = CTTransferFlow_Sender;
                    senderTransferViewController.readSocket = self.gcdSocket;
                    senderTransferViewController.delegate = self;
                
                    [self.navigationController pushViewController:senderTransferViewController animated:YES];
                });
                
            }
                break;
            case CTVersionCheckStatusLesser:{
                NSString *message = [NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_HIGHER_ALERT_CONTEXT, nil), versionManager.supported_version];
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
    
    [self.gcdSocket readDataWithTimeout:-1.0 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    DebugLog(@"socket:didWriteDataWithTag: %ld",tag);
    
    [self.gcdSocket readDataWithTimeout:-1.0 tag:0];
}


#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= 1 && range.length == 0) {
       return NO;
    }else {
        const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        if (isBackSpace == -8 && range.length == 1) {
            switch (textField.tag) {
                case 10:
                    break;
                case 20:
                    [self.enterPinTextField1 performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
                    break;
                case 30:
                    [self.enterPinTextField2 performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
                    break;
                case 40:
                    [self.enterPinTextField3 performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
                    break;
                default:
                    break;
            }
        } else {
            switch (textField.tag) {
                case 10:
                    [self.enterPinTextField2 performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
                    break;
                case 20:
                    [self.enterPinTextField3 performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
                    break;
                case 30:
                    [self.enterPinTextField4 performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
                    break;
                case 40:
                    [self.enterPinTextField4 performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:1.0];
                    break;
                default:
                    break;
            }
        }
       return YES;
    }
}


- (void) updateWiFiAccessPointLbl {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *connectedNetworkName = [CTNetworkUtility connectedNetworkName];
        
        if (connectedNetworkName) {
            self.wifiNameLabel.text = connectedNetworkName;
        } else {
            self.wifiNameLabel.text = CTLocalizedString(NOT_CONNECTED_WIFI_ACCESS_POINT, nil);
        }
    });
}

#pragma applicationDidBecomeActive:
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    
    [self updateWiFiAccessPointLbl];
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIApplicationWillTerminateNotification]) {
        if ([self viewIfLoaded] && self.view.window) {
            DebugLog(@"Terminate notification received test");
        }
    }
}

- (void)ignoreSocketClosedSignal {
    self.shouldIgnore = YES;
}

- (void)checkIfDeviceConnectedToVerizonGuestWiFi {
    
    if ([self.wifiNameLabel.text isEqualToString:@"Verizon Guest Wi-Fi"]) {
        
        NSString *retrievedAddress = [self addressFromPin];
        
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
            
            [self.activityIndicator hide:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (USES_CUSTOM_VERIZON_ALERTS){
                        [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil)
                                                                             context:[NSString stringWithFormat:CTLocalizedString(CT_SENDER_CONNECTION_ERROR_ALERT_CONTEXT, nil), error.localizedDescription]
                                                                             btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                             handler:nil
                                                                            isGreedy:NO from:self];
                    }else{
                      [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) message:[NSString stringWithFormat:CTLocalizedString(CT_SENDER_CONNECTION_ERROR_ALERT_CONTEXT, nil), error.localizedDescription] cancelAction:[CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralOKTitle, nil) style:UIAlertActionStyleCancel handler:nil] otherActions:nil isGreedy:NO];
                    }
                });
            }];
        } else {
            DebugLog(@"Connecting...");
//            [self.activityIndicator showAnimated:YES];
        }
        
    } else {
        
        [self.activityIndicator hide:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayAlert:CTLocalizedString(CT_PIN_ERROR_ALERT_CONTEXT, nil) withTitle:CTLocalizedString(kDefaultAppTitle, nil) withAction:nil];
            });
        }];
        
        self.guestWiFiRetryRequired = 0;
    }
    
}



@end
