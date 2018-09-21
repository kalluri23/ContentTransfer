//
//  VZBumpActionSender.m
//  VZTransferSocket
//
//  Created by Hadapad, Prakash on 1/29/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import "CDActivityIndicatorView.h"
#import "CTMVMFonts.h"
#import "VZBumpActionSender.h"
#import "VZContentTrasnferConstant.h"
#import <SystemConfiguration/CaptiveNetwork.h>

// Header for audio
#import "AMRecorder.h"
#import "AudioSessionManager.h"
#import "CTNoInternetViewController.h"
#import "ShakingAlerts.h"
#import <AVFoundation/AVFoundation.h>

// Bonjour header
#import "BonjourManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <ifaddrs.h>
#import <net/if.h>

// Device detect header
#import "CTMVMDataMeterConstants.h"
#import "VZDeviceMarco.h"
#import "CTVersionManager.h"
#import "VZConstants.h"
#import "CTContentTransferSetting.h"

@interface VZBumpActionSender () <NSNetServiceDelegate, NSNetServiceBrowserDelegate,
UITableViewDataSource, UITableViewDelegate, NSStreamDelegate,
UIAlertViewDelegate, CBCentralManagerDelegate>

// Audio parameters
//@property(nonatomic, strong) AMRecorder *recorder;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSTimer *heartbeatTimer;

@property(nonatomic, assign) BOOL invitationSent;
@property(nonatomic, assign) BOOL blockUI;

@property(weak, nonatomic) IBOutlet CDActivityIndicatorView *activityIndicator;

//@property(nonatomic, assign) BOOL hasMircoPhonePermissionErr;
@property(nonatomic, assign) BOOL hasWifiErr;
@property(nonatomic, assign) BOOL hasBlueToothErr;

@property(nonatomic, assign) NSInteger checkPassed;

@property(nonatomic, strong) CBCentralManager *centralManager;
@end

@implementation VZBumpActionSender
@synthesize bumpAnimationImgView;
@synthesize timer;
@synthesize invitationSent;
@synthesize heartbeatTimer;
@synthesize orLbl;
@synthesize availablePhoneLbl;
@synthesize shakeThisPhoneLbl;
@synthesize chooseNewPhone;
@synthesize cancelBtn, notFoundBtn;
@synthesize goBack;
@synthesize app;
@synthesize centralManager;
@synthesize versionCheckflag;

typedef enum {
    ConnectionTypeUnknown,
    ConnectionTypeNone,
    ConnectionType3G,
    ConnectionTypeWiFi
} ConnectionType;

- (void)viewDidLoad {
    
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneWiDiSelect;
    [super viewDidLoad];
    
    self.deviceListView.delegate = self;
    self.deviceListView.dataSource = self;
    
    self.deviceListView.layer.borderWidth = 0.75f;
    self.deviceListView.layer.cornerRadius = 15.0f;
    self.deviceListView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [CTMVMButtons primaryGreyButton:self.cancelBtn constrainHeight:YES];
    [CTMVMButtons primaryRedButton:self.notFoundBtn constrainHeight:YES];
    
//    // Setup image animation
//    [self setupAnimationBumpImageView];
    
    versionCheckflag = false;
    
#if STANDALONE
    
    self.availablePhoneLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.availablePhoneLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
#else
    
    self.availablePhoneLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.availablePhoneLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
#endif
    
    self.orLbl.font = self.shakeThisPhoneLbl.font = self.chooseNewPhone.font =
    [CTMVMFonts mvmBookFontOfSize:14];
    
    self.navigationItem.title = @"Content Transfer";
    //    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackController:self withName:@"VZBumpActionSender"withExtraInfo:@{} isEncryptedExtras:false];
    
    [self.deviceListView setUserInteractionEnabled:NO];
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"CurrentViewController"
     object:nil
     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
               self, @"lastViewController",
               nil]]; // send a notification to
    // save current view
    // controller
    
    if (([VZDeviceMarco isiPhone4AndBelow] ||
         ([VZDeviceMarco isiPhone5Serial] && SYSTEM_VERSION_LESS_THAN(@"8.0"))) &&
        !goBack) {
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction
                                        actionWithTitle:@"Cancel"
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction *action) {
                                            [self.deviceListView setUserInteractionEnabled:YES];
                                            [self.activityIndicator setHidden:YES];
                                            [self.activityIndicator stopAnimating];
                                        }];
        
        CTMVMAlertAction *okAction = [CTMVMAlertAction
                                    actionWithTitle:@"Connect"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action) {
                                        [self performSegueWithIdentifier:@"receiver_go_to_p2p_segue"
                                                                  sender:self];
                                    }];
        
        [[CTMVMAlertHandler sharedAlertHandler]
         showAlertWithTitle:@"Content Transfer"
         message:@"Your device only supports Hotspot method."
         cancelAction:cancelAction
         otherActions:@[ okAction ]
         isGreedy:NO];
    }
    
    if (!([VZDeviceMarco isiPhone4AndBelow] ||
          ([VZDeviceMarco isiPhone5Serial] &&
           SYSTEM_VERSION_LESS_THAN(@"8.0")))) {
              
              [[NSNotificationCenter defaultCenter]
               addObserver:self
               selector:@selector(checkWifiConnectionAgain)
               name:CTApplicationDidBecomeActive
               object:nil];
              
              // Test Wifi Connection
              if (![self isWiFiEnabled]) {
                  self.hasWifiErr = YES;
                  
                  self.checkPassed++;
                  if (self.checkPassed == 2) {
                      [self performSelector:@selector(checkHandleFunction) withObject:nil];
                  }
              } else {
                  self.checkPassed++;
                  if (self.checkPassed == 2) {
                      [self performSelector:@selector(checkHandleFunction) withObject:nil];
                  }
              }
              
              // Test Bluetooth status
              centralManager = [[CBCentralManager alloc]
                                initWithDelegate:self
                                queue:nil
                                options:
                                [NSDictionary
                                 dictionaryWithObject:[NSNumber numberWithInt:0]
                                 forKey:
                                 CBCentralManagerOptionShowPowerAlertKey]];
          }
}

- (void)checkWifiConnectionAgain {
    if ([self isWiFiEnabled] && [self fetchSSIDInfo] != nil && self.hasWifiErr) {
        self.hasWifiErr = NO;
        
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction =
        [CTMVMAlertAction actionWithTitle:@"Continue"
                                  style:UIAlertActionStyleDefault
                                handler:nil];
        CTMVMAlertAction *cancelAction =
        [CTMVMAlertAction actionWithTitle:@"WiFi Settings"
                                  style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction *action) {
                                    [weakSelf openWifiSettings];
                                }];
        CTMVMAlertObject *alertObject = [[CTMVMAlertObject alloc]
                                       initWithTitle:@"Content Transfer"
                                       message:@"For best performance please turn on WiFi, but forget "
                                       @"all your networks. Data charge will not apply."
                                       cancelAction:okAction
                                       otherActions:@[ cancelAction ]
                                       isGreedy:YES];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        self.hasBlueToothErr = YES;
        
        self.checkPassed++;
        if (self.checkPassed == 2) {
            [self performSelector:@selector(checkHandleFunction) withObject:nil];
        }
    } else {
        self.checkPassed++;
        if (self.checkPassed == 2) {
            [self performSelector:@selector(checkHandleFunction) withObject:nil];
        }
    }
    
//    // Setup image animation
//    [self setupAnimationBumpImageView];
    
    // self.availablePhoneLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
    
    self.orLbl.font = self.shakeThisPhoneLbl.font = self.chooseNewPhone.font =
    [CTMVMFonts mvmBookFontOfSize:14];
    
    self.navigationItem.title = @"Content Transfer";
    //    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[CTMVMSessionSingleton sharedGlobal]
     .vzctAnalyticsObject trackController:self
     withName:@"VZBumpActionSender"
     withExtraInfo:@{}
     isEncryptedExtras:false];
}

- (void)checkHandleFunction {
    if (self.hasBlueToothErr || self.hasWifiErr) {
        
        NSString *string = @"";
        if (self.hasWifiErr) {
            string = @"Please turn on Wifi";
        }
        
        if (self.hasBlueToothErr) {
            if (string.length == 0) {
                string = @"Please turn off bluetooth";
            } else {
                string =
                [NSString stringWithFormat:@"%@and turn off bluetooth", string];
            }
        }
        
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction =
        [CTMVMAlertAction actionWithTitle:@"Go to Setting"
                                  style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    if (self.hasBlueToothErr && self.hasWifiErr) {
                                        [weakSelf openRootSettings];
                                    } else if (self.hasBlueToothErr) {
                                        [weakSelf openBluetoothSettings];
                                    } else {
                                        [weakSelf openWifiSettings];
                                    }
                                }];
        CTMVMAlertAction *cancelAction =
        [CTMVMAlertAction actionWithTitle:@"OK"
                                  style:UIAlertActionStyleCancel
                                handler:nil];
        CTMVMAlertObject *alertObject =
        [[CTMVMAlertObject alloc] initWithTitle:@"Content Transfer"
                                      message:string
                                 cancelAction:okAction
                                 otherActions:@[ cancelAction ]
                                     isGreedy:YES];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
    } else if ([self fetchSSIDInfo] != nil) { // Access point not nil
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction =
        [CTMVMAlertAction actionWithTitle:@"Continue"
                                  style:UIAlertActionStyleDefault
                                handler:nil];
        CTMVMAlertAction *cancelAction =
        [CTMVMAlertAction actionWithTitle:@"WiFi Settings"
                                  style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction *action) {
                                    [weakSelf openWifiSettings];
                                }];
        CTMVMAlertObject *alertObject = [[CTMVMAlertObject alloc]
                                       initWithTitle:@"Content Transfer"
                                       message:@"For best performance please turn on WiFi, but forget "
                                       @"all your networks. Data charge will not apply."
                                       cancelAction:okAction
                                       otherActions:@[ cancelAction ]
                                       isGreedy:YES];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
    }
    
//    // Enable shake support for current controller
//    [self enableShakeDectectSupport];
    
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(routeChanged:)
//     name:AVAudioSessionRouteChangeNotification
//     object:nil];
    
//    if ([AudioSessionManager isHeadsetPluggedIn] == YES) {
//        [ShakingAlerts showHeadsetAlerts:self withHandler:nil];
//    }
    
//    self.recorder = [[AMRecorder alloc] initWithFormat]; // prepare the recorder
//    self.recorder.delegate = self;
    
    // Bonjour service setup for current view
    [[BonjourManager sharedInstance] createServerForController:self];
    
    [self.deviceListView setUserInteractionEnabled:YES];
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
}

- (NSDictionary *)fetchSSIDInfo {
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    DebugLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        DebugLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

- (void)openWifiSettings {
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
}

- (void)openBluetoothSettings {
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
}

- (void)openRootSettings {
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:@"prefs:root=Settings"]];
}

- (BOOL)isWiFiEnabled {
    
    NSCountedSet *cset = [NSCountedSet new];
    
    struct ifaddrs *interfaces;
    
    if (!getifaddrs(&interfaces)) {
        for (struct ifaddrs *interface = interfaces; interface;
             interface = interface->ifa_next) {
            if ((interface->ifa_flags & IFF_UP) == IFF_UP) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    
    BOOL result = [cset countForObject:@"awdl0"] > 1 ? YES : NO;
    freeifaddrs(interfaces);
    
    return result;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([timer isValid]) {
        [timer invalidate]; // if timer still runing, disable it.
    }
    
    if ([heartbeatTimer isValid]) {
        [heartbeatTimer invalidate];
    }
    
//    // shutdown any play or record queue..
//    if ([self.recorder isRunning]) {
//        [self.recorder stop];
//    }
    
    if (!([VZDeviceMarco isiPhone4AndBelow] || ([VZDeviceMarco isiPhone5Serial] && SYSTEM_VERSION_LESS_THAN(@"8.0")))) {
        
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CTApplicationDidBecomeActive object:nil];
        
        [[BonjourManager sharedInstance] stopServer]; // stop server, so other device won't find this device
        [[BonjourManager sharedInstance] stopBrowserNetworking:self];
    }
    
    self.centralManager = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentViewController" object:nil userInfo:nil]; // post a notification to save current view
    // controller
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///**
// * Enable Shaking support for current controller
// */
//- (void)enableShakeDectectSupport {
//    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
//    [self becomeFirstResponder];
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little
 preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)clickedOnCancelBtn:(id)sender {
    // Close stream once this view
    
    //    [[self navigationController] popViewControllerAnimated:YES];
    
    [self backButtonPressed];
    
    [[CTMVMSessionSingleton sharedGlobal]
     .vzctAnalyticsObject trackEvent:self.view
     withTrackTag:CONTENT_TRANSFER_CLICKED_CANCEL];
}

- (void)backButtonPressedForBump {
    CTMVMAlertAction *okAction = [CTMVMAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    
                                    [[BonjourManager sharedInstance] closeStreamForController:self];
                                    
                                    [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
                                    
                                    if ([[[[self navigationController] viewControllers]
                                          objectAtIndex:0]
                                         isKindOfClass:[CTNoInternetViewController class]]) {
                                        [self.navigationController setNavigationBarHidden:YES
                                                                                 animated:NO];
                                    }
                                    
                                    if ([self.navigationController
                                         respondsToSelector:
                                         @selector(interactivePopGestureRecognizer)]) {
                                        self.navigationController.interactivePopGestureRecognizer
                                        .enabled = YES;
                                    }
                                    
                                    [UIApplication sharedApplication].idleTimerDisabled = NO;
                                    
                                    //        UIApplication *app = [UIApplication
                                    //        sharedApplication];
                                    //        NSArray *eventArray = [app
                                    //        scheduledLocalNotifications];
                                    //        for (int i=0; i<[eventArray count]; i++)
                                    //        {
                                    //            UILocalNotification* oneEvent = [eventArray
                                    //            objectAtIndex:i];
                                    //            NSDictionary *userInfoCurrent = oneEvent.userInfo;
                                    //            NSString *uid=[NSString
                                    //            stringWithFormat:@"%@",[userInfoCurrent
                                    //            valueForKey:@"uid"]];
                                    //            if ([uid
                                    //            isEqualToString:NSProcessInfoPowerStateDidChangeNotification])
                                    //            {
                                    //                //Cancelling local notification
                                    //                [app cancelLocalNotification:oneEvent];
                                    //                break;
                                    //            }
                                    //        }
                                    
                                    AppDelegate *appDelegate =
                                    (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                    [appDelegate.window.rootViewController
                                     dismissViewControllerAnimated:NO
                                     completion:nil];
                                    //        [appDelegate.window makeKeyAndVisible];
                                    
                                }];
    
    CTMVMAlertAction *cancelAction =
    [CTMVMAlertAction actionWithTitle:@"No"
                              style:UIAlertActionStyleCancel
                            handler:nil];
    
    [[CTMVMAlertHandler sharedAlertHandler]
     showAlertWithTitle:@"Content Transfer"
     message:@"Are you sure you want to go back to the home page?"
     cancelAction:cancelAction
     otherActions:@[ okAction ]
     isGreedy:NO];
}

- (IBAction)notFoundBtn:(id)sender {
    // Close stream once this view
    [[BonjourManager sharedInstance] closeStreamForController:self];
    
    [[CTMVMSessionSingleton sharedGlobal]
     .vzctAnalyticsObject trackEvent:self.view
     withTrackTag:CONTENT_TRANSFER_NOTFOUND];
}

//- (void)setupAnimationBumpImageView {
//    
//    self.bumpAnimationImgView.animationImages =
//    [NSArray arrayWithObjects:[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_00"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_01"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_02"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_03"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_04"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_05"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_06"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_07"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_08"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_09"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_10"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_11"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_12"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_13"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_14"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_15"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_16"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_17"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_18"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_18"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_20"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_21"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_22"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_23"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_24"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_25"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_26"],
//     [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_27"], nil];
//    
//    // all frames will execute in 1.75 seconds
//    self.bumpAnimationImgView.animationDuration = 1.75;
//    // repeat the animation forever
//    self.bumpAnimationImgView.animationRepeatCount = 0;
//}

//- (void)startAnimation {
//    [self.bumpAnimationImgView startAnimating];
//}
//
//- (void)stopAnimation {
//    [self.bumpAnimationImgView stopAnimating];
//}

#pragma mark - Motion detect methods

//// Dectect motion begins
//static int countdown = 5;
//- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
//    
//    [self.deviceListView setUserInteractionEnabled:NO];
//    [self.activityIndicator setHidden:NO];
//    [self.activityIndicator startAnimating];
//    
//    // Test permission of mircophone
//    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
//        if (!granted) {
//            DebugLog(@"Permission denied");
//            
//            [self.deviceListView setUserInteractionEnabled:YES];
//            [self.activityIndicator setHidden:YES];
//            [self.activityIndicator stopAnimating];
//            
//            MVMAlertAction *cancelAction =
//            [MVMAlertAction actionWithTitle:@"Choose Device"
//                                      style:UIAlertActionStyleDefault
//                                    handler:nil];
//            
//            MVMAlertAction *goToSettingAction =
//            [MVMAlertAction actionWithTitle:@"Go to Setting"
//                                      style:UIAlertActionStyleCancel
//                                    handler:^(UIAlertAction *action) {
//                                        [self goToAppSetting];
//                                    }];
//            
//            MVMAlertObject *alertObject = [[MVMAlertObject alloc]
//                                           initWithTitle:@"Content Transfer"
//                                           message:@"Microphone permission is not granted. Please give "
//                                           @"permission and retry or choose device from pair "
//                                           @"phone list."
//                                           cancelAction:goToSettingAction
//                                           otherActions:@[ cancelAction ]
//                                           isGreedy:NO];
//            
//            [[AlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
//        } else {
//            
//            [self.deviceListView setUserInteractionEnabled:YES];
//            [self.activityIndicator setHidden:YES];
//            [self.activityIndicator stopAnimating];
//            
//            countdown = 5;
//            
//            if (![self.recorder isRunning]) {
//                [self.deviceListView setUserInteractionEnabled:NO];
//                [self.activityIndicator setHidden:NO];
//                [self.activityIndicator startAnimating];
//                
//                [self.recorder startRecording];
//                
//                [self setupTimer];
//                [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//                
//                [self stopAnimation];
//            }
//        }
//    }];
//}

- (void)goToAppSetting {
    if (&UIApplicationOpenSettingsURLString != NULL) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

//// Setup a timer for recording, temp for 5 seconds
//- (void)setupTimer {
//    
//    timer = [NSTimer timerWithTimeInterval:1.0f
//                                    target:self
//                                  selector:@selector(timerCountdown)
//                                  userInfo:nil
//                                   repeats:YES];
//    [self performSelector:@selector(stopRecording)
//               withObject:nil
//               afterDelay:5.0f];
//}

//// Stop record selector
//- (void)stopRecording {
//    
//    if ([self.recorder isRunning]) {
//        [self.recorder stop];
//        
//        [self.deviceListView setUserInteractionEnabled:YES];
//        [self.activityIndicator setHidden:YES];
//        [self.activityIndicator stopAnimating];
//        
//        [self startAnimation];
//    }
//}

//// Countdown timer selector
//- (void)timerCountdown {
//    
//    if ([self.recorder isRunning]) {
//        //        DebugLog(@"%d", countdown--);
//        if (--countdown == 0) {
//            [timer invalidate];
//        }
//    } else if (![self.recorder isRunning]) {
//        [timer invalidate];
//    }
//}

#pragma mark - Headset plug in detect
//- (void)routeChanged:(NSNotification *)notificaiton {
//    
//    NSDictionary *info = notificaiton.userInfo;
//    NSInteger changeReason =
//    [info[@"AVAudioSessionRouteChangeReasonKey"] integerValue];
//    if (changeReason ==
//        AVAudioSessionRouteChangeReasonNewDeviceAvailable) { // plugged
//        [ShakingAlerts showHeadsetAlerts:self withHandler:nil];
//    }
//}

#pragma mark - Record Delegate
//- (void)recorderDidFinishRecording {
//    [self.deviceListView setUserInteractionEnabled:YES];
//    [self.activityIndicator stopAnimating];
//    [self.activityIndicator setHidden:YES];
//    
//    DebugLog(@"found: %@", self.recorder.result);
//    
//    [[BonjourManager sharedInstance]
//     seachingForService:self.recorder.result
//     InListWithHandler:^(bool found, long count, id target) {
//         if (found && count == 1) {
//             [self stopRecording];
//             
//             NSArray *resultArray = (NSArray *)target;
//             [[BonjourManager sharedInstance]
//              setTargetServer:(NSNetService *)[resultArray objectAtIndex:0]];
//             [self createConnectionForService:[[BonjourManager sharedInstance]
//                                               targetServer]];
//         } else {
//             // Not matched, don't need to handler, just stay in the same view
//             //[ShakingAlerts showDeviceNotFoundAlerts:self];
//             //[self startAnimation];
//         }
//     }];
//}

#pragma mark - NSNetServiceDelegate
- (void)netServiceDidPublish:(NSNetService *)sender {
    if (invitationSent) {
        // When service publish with invitation sent already, then means service
        // refresh after receiver reject the invitation
        invitationSent = NO;
        [self.deviceListView setUserInteractionEnabled:YES];
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
    }
    
    // Register service name
    self.registeredName = [[BonjourManager sharedInstance] getServerName];
    
    // Start the device browser
    if ([[BonjourManager sharedInstance] isBrowserValid]) {
        [[BonjourManager sharedInstance] stopBrowserNetworking:self];
    }
    [[BonjourManager sharedInstance] startBrowserNetworkingForTarget:self];
    
//    // Start Animation
//    [self startAnimation];
}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    // Everything try to connect sender will be reject
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // create a new device connection
        [[BonjourManager sharedInstance] stopServer]; // stop server
        [BonjourManager sharedInstance].isServerStarted = NO;
        self.registeredName = nil;
        
        // we accepted connection to another device so open in/out connection
        // streams
        [BonjourManager sharedInstance].inputStream = inputStream;
        [BonjourManager sharedInstance].outputStream = outputStream;
        [BonjourManager sharedInstance].streamOpenCount = 0;
        [[BonjourManager sharedInstance] openStreamsForController:self withHandler:^{
             // create timer for heart beat, keep sending back
             // information from receiver to sender
             //            DebugLog(@"devices connected start
             //            heartbeats");
             
             // start keep alive heartbeat
             if (heartbeatTimer != nil) {
                 [heartbeatTimer invalidate];
                 heartbeatTimer = nil;
             }
             
             // Send response after 1.5s
             heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                               target:self
                                                             selector:@selector(sendResponse)
                                                             userInfo:nil
                                                              repeats:NO];
         }];
    }];
}

// Send response
- (void)sendResponse {
    // send some data to keep connection alive
    NSString *str = @"502"; // bad request
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [[BonjourManager sharedInstance] sendStream:data]; // Send 9 bits heart beats
    
    heartbeatTimer = nil;
    
    [[BonjourManager sharedInstance] setupStream];
}

#pragma mark - NSNetServiceBrowserDelegate
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    //    DebugLog(@"%@", service.name);
    // Add the service to our array (unless its our own service)
    if ([[BonjourManager sharedInstance] serviceIsLocalService:service]) {
        [[BonjourManager sharedInstance] addService:service];
    }
    
    // only update the UI once we get the no-more-coming indication
    if (!moreComing) {
        [self sortAndReloadTable];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    // Remove the service from our array
    if ([[BonjourManager sharedInstance] serviceIsLocalService:service]) {
        [[BonjourManager sharedInstance] removeService:service];
    }
    
    // Only update the UI once we get the no-more-coming indication
    if (!moreComing) {
        [self sortAndReloadTable];
    }
}

- (void)sortAndReloadTable {
    [[BonjourManager sharedInstance] sortService];
    
    // Reload if the view is loaded
    if (self.isViewLoaded) {
        [self.deviceListView reloadData];
    }
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [[BonjourManager sharedInstance] serviceNumber];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"device_name_cell"
                                    forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    // Prepare data for tableview cell.
    NSNetService *service =
    [[BonjourManager sharedInstance] getServiceAt:indexPath.row];
    //    DebugLog(@"%@", service.name);
    
    cell.textLabel.text =
    [[BonjourManager sharedInstance] getDispalyNameForService:service];
    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    cell.textLabel.font = [CTMVMFonts mvmBookFontOfSize:14];
    
    return cell;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Find the service associated with the cell and start a connection to that
    [BonjourManager sharedInstance].targetServer =
    [[BonjourManager sharedInstance] getServiceAt:indexPath.row];
    [self createConnectionForService:[BonjourManager sharedInstance].targetServer];
    [[CTMVMSessionSingleton sharedGlobal]
     .vzctAnalyticsObject trackEvent:self.view
     withTrackTag:CONTENT_TRANSFER_BONJOUR_LIST];
    
    /*
     Link Name
     PageName|LinkName
     Flow Initiated
     Flow Name
     Transaction Id
     Sender/Receiver
     */
    
//    NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneWiDiSelect, ANALYTICS_TrackAction_Param_Value_LinkName_WifiDirectSelected);
//    [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Name_Phone_Selected
//                                 data:@{ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Param_Value_LinkName_WifiDirectSelected,
//                                        ANALYTICS_TrackAction_Key_PageLink:pageLink,
//                                        ANALYTICS_TrackAction_Param_Key_FlowInitiated:ANALYTICS_TrackAction_Param_Value_FlowInitiated_1,
//                                        ANALYTICS_TrackAction_Param_Key_FlowName:ANALYTICS_TrackAction_Param_Value_FlowInitiated_PairingOfSenderAndReceiver,
//                                        ANALYTICS_TrackAction_Key_TransactionId:self.uuid_string,
//                                        ANALYTICS_TrackAction_Key_SenderReceiver:ANALYTICS_TrackAction_Value_SenderReceiver_Sender
//                                        }];
}

- (void)createConnectionForService:(NSNetService *)service {
    BOOL success = NO;
    NSInputStream *inStream = nil;
    NSOutputStream *outStream = nil;
    
    // device was chosen by user in picker view
    success = [service getInputStream:&inStream outputStream:&outStream];
    if (!success) {
        // failed, so allow user to choose device
        [[BonjourManager sharedInstance] setupStream];
    } else {
        // user tapped device: so create and open streams with that devices
        [BonjourManager sharedInstance].inputStream = inStream;
        [BonjourManager sharedInstance].outputStream = outStream;
        [BonjourManager sharedInstance].streamOpenCount = 0;
        [[BonjourManager sharedInstance] openStreamsForController:self withHandler:nil];
        
        // prevent user click multiple times
        invitationSent = YES; // sent invitation already
        [self.deviceListView setUserInteractionEnabled:NO];
        [self.activityIndicator startAnimating];
        [self.activityIndicator setHidden:NO];
        
//        [self stopAnimation];
        
        self.blockUI = YES;
    }
}

#pragma mark - NSStreamDelegate
#define SERVER_OK @"200"
#define GATEWAY_ERR @"502"
#define SERVICE_UNAVAILABLE @"503"
// Stream connection event
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) { // streams opened
        case NSStreamEventOpenCompleted: {
            [BonjourManager sharedInstance].streamOpenCount += 1;
            //            DebugLog(@"--->connected:%d",[BonjourManager
            //            sharedInstance].streamOpenCount);
            assert([BonjourManager sharedInstance].streamOpenCount <= 2);
            // once both streams are open we hide the picker
            if ([BonjourManager sharedInstance].streamOpenCount == 2) {
                //                DebugLog(@"Close server");
                [[BonjourManager sharedInstance] stopServer];
                [BonjourManager sharedInstance].isServerStarted = NO;
                self.registeredName = nil;
            }
            break;
        }
            
        case NSStreamEventHasSpaceAvailable: { // stream has space
            assert(stream == [BonjourManager sharedInstance].outputStream);
            break;
        }
            
        case NSStreamEventHasBytesAvailable: {
            // stream has data
            // (in a real app you have gather up multiple data packets into the sent
            // data)
            NSUInteger bsize = 1024;
            uint8_t buf[bsize];
            NSInteger bytesRead = 0;
            bytesRead = [[BonjourManager sharedInstance].inputStream read:buf maxLength:bsize];
            if (bytesRead <= 0) {
                // handle EOF and error in NSStreamEventEndEncountered and
                // NSStreamEventErrorOccurred cases
            } else {
                NSData *receivedData = [NSData dataWithBytes:buf length:bytesRead];
                //DebugLog(@"Data from dict %@",[NSString stringWithUTF8String:[receivedData bytes]]);

                NSError *errorJson=nil;
                NSDictionary* myDictionary = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions error:&errorJson];
                NSString *receivedStr = [myDictionary objectForKey:USER_DEFAULTS_VERSION_CHECK];
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[myDictionary objectForKey:USER_DEFAULTS_PAIRING_DEVICE_ID] forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
                [userDefaults setObject:[myDictionary objectForKey:USER_DEFAULTS_PAIRING_OS_VERSION] forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
                [userDefaults setObject:[myDictionary objectForKey:USER_DEFAULTS_PAIRING_MODEL] forKey:USER_DEFAULTS_PAIRING_MODEL];
                [userDefaults setObject:[myDictionary objectForKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE] forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
                [userDefaults setObject:[myDictionary objectForKey:USER_DEFAULTS_PAIRING_TYPE] forKey:USER_DEFAULTS_PAIRING_TYPE];


                [userDefaults synchronize];

                NSRange range = [receivedStr rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS"];
                if ((range.location != NSNotFound) && (receivedStr.length > 0)) { // receiver accept connection
                    
                    if (!versionCheckflag) {
                        [self checkVersionoftheApp:receivedStr];
                    }
                    
                } else {
                    range = [receivedStr rangeOfString:GATEWAY_ERR];
                    
                    if ((range.location != NSNotFound) &&
                        (receivedStr.length > 0)) {          // receiver is a sender
                        [ShakingAlerts showDeviceAlerts:self]; // show device alert;
                        [[BonjourManager sharedInstance] setupStream];
                    } else { // receiver reject this connection
                        range = [receivedStr rangeOfString:SERVICE_UNAVAILABLE];
                        
                        CTMVMAlertAction *okAction =
                        [CTMVMAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil];
                        
                        [[CTMVMAlertHandler sharedAlertHandler]
                         showAlertWithTitle:@"Content Transfer"
                         message:@"The invitation is rejected by new device, "
                         @"please try again."
                         cancelAction:okAction
                         otherActions:nil
                         isGreedy:NO];
                        
                        [[BonjourManager sharedInstance] setupStream];
                    }
                    
                    if (self.blockUI) { // only dismiss UI block when this view will not
                        // dismiss
                        [self.activityIndicator setHidden:YES];
                        [self.activityIndicator stopAnimating];
                        [self.deviceListView setUserInteractionEnabled:YES];
                        
//                        [self startAnimation];
                        
                        self.blockUI = NO;
                    }
                }
            }
            break;
        }
            // all others cases
        case NSStreamEventEndEncountered:
        case NSStreamEventNone:
        case NSStreamEventErrorOccurred:
            // fall through
        default: {
            // setup stream
            //[[BonjourManager sharedInstance] setupStream];
        } break;
    }
}

- (void)movetoBonjuorTransferScreen {
    
    [self performSegueWithIdentifier:@"GoToBonjourTransfer" sender:self];
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
    //                                    @"VZContentTransfer" bundle:[NSBundle
    //                                    mainBundle]];
    //        UIViewController *myController = [storyboard
    //        instantiateViewControllerWithIdentifier:@"bonjourTransferID"];
    //        [self presentViewController:myController animated:YES
    //        completion:nil];
    //    });
}

- (void)checkVersionoftheApp:(NSString *)str {
    CTVersionManager *versionCheck = [[CTVersionManager alloc] init];
    
    versionCheckflag = true;
    
    NSString *str1 = [NSString
                      stringWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@",
                      BUILD_VERSION, BUILD_CROSS_PLATFROM_MIN_VERSION];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:str1 forKey:USER_DEFAULTS_VERSION_CHECK];
    [dict setValue:[NSString stringWithFormat:@"Device ID: %@",self.uuid_string] forKey:USER_DEFAULTS_DB_PARING_DEVICE_INFO];
    
    VZDeviceMarco *deviceMacro = [[VZDeviceMarco alloc] init];
    NSString *modelCode = [deviceMacro getDeviceModel];
    NSString *model = [deviceMacro.models objectForKey:modelCode];
    if (model.length == 0) {
        model = modelCode;
    }
    
    [dict setValue:model forKey:USER_DEFAULTS_PAIRING_MODEL];
    [dict setValue:[[UIDevice currentDevice] systemVersion] forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
    [dict setValue:@"iOS" forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
    [dict setValue:self.uuid_string forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];

    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:dict
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:&error];

    [[BonjourManager sharedInstance] sendStream:requestData];
    
    CTVersionCheckStatus status = [versionCheck identifyOsVersion:str];
    
    if (status == CTVersionCheckStatusMatched) {
        
        [self movetoBonjuorTransferScreen];
        
    } else {
        
        if (status == CTVersionCheckStatusLesser) {
            
            // alert to upgrade other device
            
            CTMVMAlertAction *okAction = [CTMVMAlertAction
                                        actionWithTitle:@"Cancel"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                                            
                                            [[BonjourManager sharedInstance] setupStream];
                                            
                                            versionCheckflag = false;
                                        }];
            
            [[CTMVMAlertHandler sharedAlertHandler]
             showAlertWithTitle:@"Content Transfer"
             message:[NSString stringWithFormat:@"The Content Transfer "
                      @"app on the other "
                      @"device seems to be "
                      @"out of date. Please "
                      @"update the app on "
                      @"that device to v:%@",
                      BUILD_VERSION]
             cancelAction:okAction
             otherActions:nil
             isGreedy:NO];
            
        } else {
            
            // alert to upgrade currnt device
            
            CTMVMAlertAction *okAction = [CTMVMAlertAction
                                        actionWithTitle:@"Cancel"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                                            
                                            [[BonjourManager sharedInstance] setupStream];
                                            versionCheckflag = false;
                                        }];
            
            NSArray *actions = nil;
            actions = @[
                        [[CTMVMAlertAction alloc]
                         initWithTitle:@"Upgrade"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             
                             NSString *iTunesLink = @"itms://itunes.apple.com/us/app/content-transf/id1127930385?mt=8";
                             [[UIApplication sharedApplication]
                              openURL:[NSURL URLWithString:iTunesLink]];
                         }]
                        ];
            
            [[CTMVMAlertHandler sharedAlertHandler]
             showAlertWithTitle:@"Content Transfer"
             message:[NSString stringWithFormat:@"The Content Transfer "
                      @"app on this device "
                      @"seems to be out of "
                      @"date. Please update "
                      @"the app to v:%@",
                      versionCheck
                      .supported_version]
             cancelAction:okAction
             otherActions:actions
             isGreedy:NO];
        }
    }
}

@end
