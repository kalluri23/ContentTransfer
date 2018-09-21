//
//  VZBumpActionReceiver.m
//  VZTransferSocket
//
//  Created by Hadapad, Prakash on 1/29/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import "VZBumpActionReceiver.h"
#import "CDActivityIndicatorView.h"
#import "AudioSessionManager.h"
#import "ShakingAlerts.h"
#import "AMPlayer.h"
#import "VolumeConfiguration.h"
#import <AVFoundation/AVFoundation.h>
#import "CTMVMFonts.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "CTNoInternetViewController.h"

#import "BonjourManager.h"
#import "VZContentTrasnferConstant.h"
#import <ifaddrs.h>
#import <net/if.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CTMVMDataMeterConstants.h"
#import "VZDeviceMarco.h"
#import "CTVersionManager.h"
#import "CTContentTransferSetting.h"

@interface VZBumpActionReceiver () <NSNetServiceDelegate, NSStreamDelegate, CBCentralManagerDelegate>

//@property (nonatomic, assign) BOOL hasHeadset;
//@property (nonatomic, strong) AMPlayer *player;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSTimer *heartbeatTimer;

@property (weak, nonatomic) IBOutlet UILabel *recevierTitleLabel;
@property (weak, nonatomic) IBOutlet CDActivityIndicatorView *activityIndcator;

//@property (nonatomic, assign) BOOL hasMircoPhonePermissionErr;
@property (nonatomic, assign) BOOL hasWifiErr;
@property (nonatomic, assign) BOOL hasBlueToothErr;
@property (nonatomic, assign) NSInteger checkPassed;

@property (weak, nonatomic) IBOutlet UILabel *phoneNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *oldPhoneList;
@property (weak, nonatomic) IBOutlet UILabel *orLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downConstraintsToAnimation;
@property (nonatomic,strong)CBCentralManager *centralManager;
@end

@implementation VZBumpActionReceiver

#define VOLUME @"outputVolume"

@synthesize bumpImageView;
//@synthesize hasHeadset;
@synthesize timer;
@synthesize heartbeatTimer;
@synthesize availablePhoneLbl;
@synthesize app;
@synthesize goBack;
@synthesize methodchoosen;
@synthesize centralManager;
@synthesize versionCheckflag;

typedef enum {
    ConnectionTypeUnknown,
    ConnectionTypeNone,
    ConnectionType3G,
    ConnectionTypeWiFi
} ConnectionType;

//// Init AMPlayer object with Audio Queue Format
//- (AMPlayer *)player
//{
//    if (_player == nil) {
//        _player = [[AMPlayer alloc] initWithFormat];
//    }
//    
//    return _player;
//}

- (void)viewDidLoad {
    
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneWiDiSelect;    
    [super viewDidLoad];

    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (screenHeight <= 480) {
        [self.downConstraintsToAnimation setConstant:self.downConstraintsToAnimation.constant - 70];
    }
    
    self.availablePhoneLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
    self.shakeThisPhone.font = [CTMVMFonts mvmBookFontOfSize:12];
    
    self.oldPhoneList.font = [CTMVMFonts mvmBookFontOfSize:12];
    self.orLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
    
#if STANDALONE
    
    self.phoneNameLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.phoneNameLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
#else
    
    self.phoneNameLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.phoneNameLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
#endif
    
    [CTMVMButtons primaryGreyButton:self.cancelBtn constrainHeight:YES];
    [CTMVMButtons primaryRedButton:self.notFoundBtn constrainHeight:YES];
    
    self.navigationItem.title = @"Content Transfer";
    
    //    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackController:self withName:@"VZBumpActionReceiver" withExtraInfo:@{} isEncryptedExtras:false];
    
//    // Setup image animation
//    [self setupAnimationBumpImageView];
    
    [self.activityIndcator setHidden:NO];
    [self.activityIndcator startAnimating];
    
    versionCheckflag = false;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentViewController" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"lastViewController", nil]]; // post a notification to save current view controller
    
    if (([VZDeviceMarco isiPhone4AndBelow] || ([VZDeviceMarco isiPhone5Serial] && SYSTEM_VERSION_LESS_THAN(@"8.0"))) && !goBack) {
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.activityIndcator setHidden:YES];
            [self.activityIndcator stopAnimating];
        }];
        
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Connect" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self performSegueWithIdentifier:@"receiver_go_to_p2p_segue" sender:self];
        }];
        
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:@"Your device only supports Hotspot method." cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    }
    
    if (!([VZDeviceMarco isiPhone4AndBelow] || ([VZDeviceMarco isiPhone5Serial] && SYSTEM_VERSION_LESS_THAN(@"8.0")))) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkWifiConnectionAgain) name:CTApplicationDidBecomeActive object:nil];
        
        // Test Wifi Connection
        if (![self isWiFiEnabled]) {
            self.hasWifiErr = YES;
            
            self.checkPassed ++;
            if (self.checkPassed == 2) {
                [self performSelector:@selector(checkHandleFunction) withObject:nil];
            }
        } else {
            self.checkPassed ++;
            if (self.checkPassed == 2) {
                [self performSelector:@selector(checkHandleFunction) withObject:nil];
            }
        }
        
        // Test Bluetooth status
        centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                              queue:nil
                                                            options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                                                                forKey:CBCentralManagerOptionShowPowerAlertKey]];
    }
}

- (void)checkWifiConnectionAgain
{
    if ([self isWiFiEnabled] && [self fetchSSIDInfo] != nil && self.hasWifiErr) {
        self.hasWifiErr = NO;
        
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:nil];
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"WiFi Settings" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [weakSelf openWifiSettings];
        }];
        CTMVMAlertObject* alertObject = [[CTMVMAlertObject alloc] initWithTitle:@"Content Transfer"
                                                                    message:@"For best performance please turn on WiFi, but forget all your networks. Data charge will not apply."
                                                               cancelAction:okAction
                                                               otherActions:@[cancelAction]
                                                                   isGreedy:YES];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
    }
}

- (NSDictionary *)fetchSSIDInfo
{
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

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        self.hasBlueToothErr = YES;
        
        self.checkPassed ++;
        if (self.checkPassed == 2) {
            [self performSelector:@selector(checkHandleFunction) withObject:nil];
        }
    } else {
        self.checkPassed ++;
        if (self.checkPassed == 2) {
            [self performSelector:@selector(checkHandleFunction) withObject:nil];
        }
    }
}

- (void)checkHandleFunction
{
    if (self.hasBlueToothErr || self.hasWifiErr) {
        
        NSString *string = @"";
        if (self.hasWifiErr) {
            string = @"Please turn on Wifi";
        }
        
        if (self.hasBlueToothErr) {
            if (string.length == 0) {
                string = @"Please turn off bluetooth";
            } else {
                string = [NSString stringWithFormat:@"%@and turn off bluetooth", string];
            }
        }
        
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Turn on" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            if (self.hasBlueToothErr && self.hasWifiErr) {
                [weakSelf openRootSettings];
            } else if (self.hasBlueToothErr) {
                [weakSelf openBluetoothSettings];
            } else {
                [weakSelf openWifiSettings];
            }
        }];
        
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        CTMVMAlertObject* alertObject = [[CTMVMAlertObject alloc] initWithTitle:@"Content Transfer"
                                                                    message:string
                                                               cancelAction:okAction
                                                               otherActions:@[cancelAction]
                                                                   isGreedy:NO];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
    } else if ([self fetchSSIDInfo] != nil) { // Access point not nil
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:nil];
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"WiFi Settings" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [weakSelf openWifiSettings];
        }];
        CTMVMAlertObject* alertObject = [[CTMVMAlertObject alloc] initWithTitle:@"Content Transfer"
                                                                    message:@"For best performance please turn on WiFi, but forget all your networks. Data charge will not apply."
                                                               cancelAction:okAction
                                                               otherActions:@[cancelAction]
                                                                   isGreedy:NO];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
    }
    
//    // Enable shake support for current controller
//    [self enableShakeDectectSupport];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChanged:) name:AVAudioSessionRouteChangeNotification object:nil]; // observer for detecting headset plug in status
//    [AudioSessionManager enableTrackingSystemVolumeChangeForController:self]; // add observer tracking the volume
    
//    hasHeadset = NO;
//    if ((hasHeadset = [AudioSessionManager isHeadsetPluggedIn]) == YES) {
//        [ShakingAlerts showHeadsetAlerts:self withHandler:^{
//            // Bonjour service setup for current view
//            [[BonjourManager sharedInstance] createServerForController:self];
//        }];
//        
//        [self.player updateRelativeVolumeForPlayer:0.0f]; // if headset attached, set voice volume to 0
//    } else {
//        float initVol = 0;
//        if (currentVolumeForReceiver < 0) {
//            // Detect the current system volume
//            initVol = [AudioSessionManager getCurrentSystemVolume];
//            currentVolumeForReceiver = initVol;
//        } else {
//            initVol = currentVolumeForReceiver;
//        }
//        if (initVol == 0) {
//            [ShakingAlerts showVolumeAlerts:self];
//        } else {
//            [self.player updateRelativeVolumeForPlayer:[self getRelativeVolume:initVol]]; // set relative volume based on current system volume.
//        }
    
        // Bonjour service setup for current view
        [[BonjourManager sharedInstance] createServerForController:self];
//    }
    
    [self.activityIndcator setHidden:NO];
    [self.activityIndcator startAnimating];
}

- (void)openWifiSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
}

- (void)openBluetoothSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
}

- (void)openRootSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Settings"]];
}

- (BOOL)isWiFiEnabled {
    
    NSCountedSet * cset = [NSCountedSet new];
    
    struct ifaddrs *interfaces;
    
    if(!getifaddrs(&interfaces)) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ((interface->ifa_flags & IFF_UP) == IFF_UP) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    
    BOOL result = [cset countForObject:@"awdl0"] > 1 ? YES : NO;
    freeifaddrs(interfaces);
    
    return result;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([timer isValid]) {
        [timer invalidate]; // if timer still runing, disable it.
    }
    
    if ([heartbeatTimer isValid]) {
        [heartbeatTimer invalidate];
    }
    
//    // shutdown any play or record queue..
//    if ([self.player isRunning]) {
//        [self.player stop];
//    }
    
    if (!([VZDeviceMarco isiPhone4AndBelow] || ([VZDeviceMarco isiPhone5Serial] && SYSTEM_VERSION_LESS_THAN(@"8.0")))) {
        
//        @try{
//            [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume"]; }
//        @catch(id anException) {
//            DebugLog(@"Exception Thrown for remove observer");
//        }
        
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CTApplicationDidBecomeActive object:nil];
        
        [[BonjourManager sharedInstance] stopServer]; // stop server, so other device won't find this device
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentViewController" object:nil userInfo:nil]; // post a notification to save current view controller
    
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
    
    [infoDict setValue:self.methodchoosen forKey:@"PairType"];
    [infoDict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
    [infoDict setValue:@"Bonjour" forKey:@"ConnectionType"];
    
    self.centralManager = nil;
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"PairingScreen" withExtraInfo:infoDict isEncryptedExtras:false];
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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

- (IBAction)clickedCancelBtn:(id)sender {
    // Close stream once this view
    
    //    [[self navigationController] popViewControllerAnimated:YES];
    
    //    [self backButtonPressedForBump];
    
    [self backButtonPressed];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_CLICKED_CANCEL];
}

- (void)backButtonPressedForBump
{
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        [[BonjourManager sharedInstance] closeStreamForController:self];
        
        [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
        
        if([[[[self navigationController]viewControllers]objectAtIndex:0] isKindOfClass:[CTNoInternetViewController class]]) {
            [self.navigationController setNavigationBarHidden:YES animated:NO];
        }
        
        if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
        
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        
        
        
        //        UIApplication *app = [UIApplication sharedApplication];
        //        NSArray *eventArray = [app scheduledLocalNotifications];
        //        for (int i=0; i<[eventArray count]; i++)
        //        {
        //            UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        //            NSDictionary *userInfoCurrent = oneEvent.userInfo;
        //            NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"uid"]];
        //            if ([uid isEqualToString:NSProcessInfoPowerStateDidChangeNotification])
        //            {
        //                //Cancelling local notification
        //                [app cancelLocalNotification:oneEvent];
        //                break;
        //            }
        //        }
        
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
        //        [appDelegate.window makeKeyAndVisible];
        
        
        
    }];
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:@"Are you sure you want to go back to the home page?" cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
}

- (IBAction)clickedNotFoundBtn:(id)sender {
    // Close stream once this view
    [[BonjourManager sharedInstance] closeStreamForController:self];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_NOTFOUND];
    
    self.methodchoosen = @"HotSpot";
    
    NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneWiDiSelect, ANALYTICS_TrackAction_Param_Value_LinkName_HotspotSelected);
    [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Param_Value_LinkName_HotspotSelected
                                 data:@{ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Param_Value_LinkName_HotspotSelected,
                                        ANALYTICS_TrackAction_Key_PageLink:pageLink,
                                        }];
}


- (void) setupAnimationBumpImageView {
    
    self.bumpImageView.animationImages = [NSArray arrayWithObjects:
                                    [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_00" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_01" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_02" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_03" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_04" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_05" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_06" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_07" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_08" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_09" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_10" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_11" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_12" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_13" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_14" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_15" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_16" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_17" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_18" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_18" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_20" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_21" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_22" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_23" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_24" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_25" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_26" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_27" ],nil];
    
    // all frames will execute in 1.75 seconds
    self.bumpImageView.animationDuration = 1.75;
    // repeat the animation forever
    self.bumpImageView.animationRepeatCount = 0;
}

- (void)stopAnimation {
    [self.bumpImageView stopAnimating];
    
    self.methodchoosen = @"Shake";
}

- (void)startAnimation {
    [self.bumpImageView startAnimating];
}

#pragma mark - Shaking detect methods

// Enable Shaking support for current controller
- (void)enableShakeDectectSupport {
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    [self becomeFirstResponder];
}

//// Dectect motion begins
//static int countdown = 5;
//- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
//    if (self.registeredName == nil) { // if not registered, motion won't work...
//        return;
//    }
//    
//    countdown = 5;
//    
//    if (![self.player isRunning]) { // while sound is playing, disable the shake detect, simply do nothing.
//        [self.player play]; // start playing audio
//        
//        [self setupTimer];
//        [self timerStart];
//        
//        [self.activityIndcator setHidden:NO];
//        [self.activityIndcator startAnimating];
//        
//        [self stopAnimation];
//    }
//}

//// Stop playing message
//- (void)stopPlayMessage
//{
//    if ([self.player isRunning]) {
//        [self.player stop];
//        
//        [self.activityIndcator setHidden:YES];
//        [self.activityIndcator stopAnimating];
//        
//        [self startAnimation];
//    }
//}

#pragma mark - Timer methods

//// Setup timer for keep playing message for 5 seconds
//- (void)setupTimer
//{
//    timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(timerHandler) userInfo:nil repeats:YES];
//    [self performSelector:@selector(stopPlayMessage) withObject:nil afterDelay:5.0f];
//}
//
//- (void)timerStart
//{
//    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//}
//
//- (void)timerHandler {
//    //    DebugLog(@"timer:%d",countdown--);
//    if (--countdown == 0) {
//        [timer invalidate];
//    }
//}

#pragma mark - Volume Setting

//// Detect the headset plugged method
//- (void)routeChanged:(NSNotification *)notificaiton
//{
//    NSDictionary *info = notificaiton.userInfo;
//    NSInteger changeReason = [info[@"AVAudioSessionRouteChangeReasonKey"] integerValue];
//    if (changeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) { // plugged
//        hasHeadset = YES;
//        [ShakingAlerts showHeadsetAlerts:self withHandler:nil];
//        [self.player updateRelativeVolumeForPlayer:0.0f]; // if headset attached, set voice volume to 0
//    } else if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) { // unplugged
//        hasHeadset = NO;
//        
//        // Recheck volume for headset unplugged status
//        float initVol = [AudioSessionManager getCurrentSystemVolume];
//        if (initVol == 0) {
//            [ShakingAlerts showVolumeAlerts:self];
//        } else {
//            [self.player updateRelativeVolumeForPlayer:[self getRelativeVolume:initVol]]; // set relative volume based on current system volume.
//        }
//    }
//}

#pragma mark - Volume Setting
//// KvO for volume settings
//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary<NSString *,id> *)change
//                       context:(void *)context
//{
//    if ([keyPath isEqualToString:VOLUME] && !hasHeadset) { // kvO for volume change
//        float newVol = [change[@"new"] floatValue];
//        currentVolumeForReceiver = newVol;
//        if (newVol == 0) {
//            [ShakingAlerts showVolumeAlerts:self];
//        } else {
//            // set relative volume when user try to change the system vol.
//            [self.player updateRelativeVolumeForPlayer:[self getRelativeVolume:[change[@"new"] floatValue]]];
//        }
//        
//    }
//}
//
//// Set relative volume based on the system volume that user set for device
//- (float)getRelativeVolume:(float)sysVol
//{
//    int idx = sysVol / FRACTION - 1; // Only 16 level of sys. vol. user could set for playing sound.
//    return volumes[idx];
//}

#pragma mark - NSNetDelegate

// Server published its service
- (void)netServiceDidPublish:(NSNetService *)sender
{
    // Register service name
    self.registeredName = [[BonjourManager sharedInstance] getServerName];
    self.recevierTitleLabel.text = self.registeredName;
    
    // Set audio property once service registered
//    [self.player setupPlayInfo:[NSString stringWithFormat:@"%d", [self getNumberIDForPeer:sender.name]]];
    
    if (![self.activityIndcator isHidden]) {
        [self.activityIndcator setHidden:YES];
        [self.activityIndcator stopAnimating];
    }
    
//    // Start animation
//    [self startAnimation];
}

// Server accepted a device connection
typedef void (^createAlertDialog)(bool);
- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
    if ([timer isValid]) { // invalid the background timer
        [timer invalidate];
//        [self.player stop]; // stop playing audio
    }
    
//    if ([self.bumpImageView isAnimating]) {
//        [self stopAnimation];
//    }
    
    __weak typeof(self) weakSelf = self;
    
    [self createConnectionDialogWithSender:sender withHandler:^(bool response) {
        if (response == YES) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                // already connected to a device?
                if ([BonjourManager sharedInstance].inputStream != nil) {
                    
                    // Yes, so reject this new one
                    [inputStream open];
                    [inputStream close];
                    [outputStream open];
                    [outputStream close];
                } else {
                    // create a new device connection
                    [[BonjourManager sharedInstance] stopServer]; // stop server
                    [BonjourManager sharedInstance].isServerStarted = NO;
                    self.registeredName = nil;
                    
                    // we accepted connection to another device so open in/out connection streams
                    [BonjourManager sharedInstance].inputStream  = inputStream;
                    [BonjourManager sharedInstance].outputStream = outputStream;
                    [BonjourManager sharedInstance].streamOpenCount = 0;
                    [[BonjourManager sharedInstance] openStreamsForController:self withHandler:^{
                        // create timer for heart beat, keep sending back information from receiver to sender
                        //                        DebugLog(@"devices connected start heartbeats");
                        
                        // start keep alive heartbeat
                        if (heartbeatTimer != nil) {
                            [heartbeatTimer invalidate];
                            heartbeatTimer = nil;
                        }
                        
                        heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                                          target:self
                                                                        selector:@selector(sendHeartbeat)
                                                                        userInfo:nil
                                                                         repeats:NO];
                    }];
                }
            }];
            
            NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneWiDiSelect, ANALYTICS_TrackAction_Param_Value_LinkName_WifiDirectSelected);
            
            [weakSelf.sharedAnalytics trackAction:ANALYTICS_TrackAction_Param_Value_LinkName_WifiDirectSelected
                                         data:@{ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Param_Value_LinkName_WifiDirectSelected,
                                                ANALYTICS_TrackAction_Key_PageLink:pageLink,
                                                ANALYTICS_TrackAction_Param_Key_FlowInitiated:ANALYTICS_TrackAction_Param_Value_FlowInitiated_1,
                                                ANALYTICS_TrackAction_Param_Key_FlowName:ANALYTICS_TrackAction_Param_Value_FlowInitiated_PairingOfSenderAndReceiver,
                                                ANALYTICS_TrackAction_Key_TransactionId:weakSelf.uuid_string,
                                                ANALYTICS_TrackAction_Key_SenderReceiver:ANALYTICS_TrackAction_Value_SenderReceiver_Receiver
                                                }];
            
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // First create connection for sending respond back
                [[BonjourManager sharedInstance] stopServer]; // stop server
                [BonjourManager sharedInstance].isServerStarted = NO;
                self.registeredName = nil;
                
                // we accepted connection to another device so open in/out connection streams
                [BonjourManager sharedInstance].inputStream  = inputStream;
                [BonjourManager sharedInstance].outputStream = outputStream;
                [BonjourManager sharedInstance].streamOpenCount = 0;
                [[BonjourManager sharedInstance] openStreamsForController:self withHandler:^{
                    // create timer for heart beat, keep sending back information from receiver to sender
                    //                    DebugLog(@"devices connected start heartbeats");
                    
                    // start keep alive heartbeat
                    if (heartbeatTimer != nil) {
                        [heartbeatTimer invalidate];
                        heartbeatTimer = nil;
                    }
                    
                    heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                                      target:self
                                                                    selector:@selector(sendRejectResponse)
                                                                    userInfo:nil
                                                                     repeats:NO];
                }];
            }];
        }
    }];
}

// Send keep alive heartbeat
- (void)sendHeartbeat {
    // send some data to keep connection alive
    NSMutableDictionary *dataDict = [NSMutableDictionary new];
    [dataDict setObject:self.uuid_string forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
    [dataDict setObject:[UIDevice currentDevice].model forKey:USER_DEFAULTS_PAIRING_MODEL];
    [dataDict setObject:[UIDevice currentDevice].systemVersion forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
    [dataDict setObject:@"iOS" forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
    [dataDict setObject:@"Bonjour" forKey:USER_DEFAULTS_PAIRING_TYPE];


    NSString * str = [NSString stringWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@",BUILD_VERSION,BUILD_CROSS_PLATFROM_MIN_VERSION];
    [dataDict setObject:str forKey:USER_DEFAULTS_VERSION_CHECK];

    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:dataDict
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:&error];
    //NSData * data =[str dataUsingEncoding:NSUTF8StringEncoding];
    
    [[BonjourManager sharedInstance] sendStream:requestData]; // Send bits heart beats
    
    //    [self moveToBonjourReceiverScreen];
}

// Send reject response
- (void)sendRejectResponse {
    // send some data to keep connection alive
    NSString * str = @"503";
    NSData * data =[str dataUsingEncoding:NSUTF8StringEncoding];
    
    [[BonjourManager sharedInstance] sendStream:data]; // Send bits heart beats
    
    // Then reject the connection
    [[BonjourManager sharedInstance] setupStream];
}


- (void) moveToBonjourReceiverScreen {
    
    heartbeatTimer = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        //        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
        //                                    @"VZContentTransfer" bundle:[NSBundle mainBundle]];
        //        UIViewController *myController = [storyboard instantiateViewControllerWithIdentifier:@"bonjourReceiverID"];
        //        [self presentViewController:myController animated:YES completion:nil];
        //    });
        
        [self performSegueWithIdentifier:@"GoToBonjourReceive" sender:self];
        
    });
}


- (void)createConnectionDialogWithSender:(NSNetService *)sender withHandler:(createAlertDialog)handler
{
    
    
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler(YES);
        //        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        handler(NO);
    }];
    
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:@"A device wants to connect with you" cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    
    if (![self.methodchoosen isEqualToString:@"Shake"]) {
        
        self.methodchoosen = @"Manual";
    }
    
}
#define SERVER_OK @"200"
#define GATEWAY_ERR @"502"
#define SERVICE_UNAVAILABLE @"503"

#pragma mark - NSStreamDelegate
// Stream connection event
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) { // streams opened
        case NSStreamEventOpenCompleted: {
            [BonjourManager sharedInstance].streamOpenCount += 1;
            //            DebugLog(@"--->connected:%d",[BonjourManager sharedInstance].streamOpenCount);
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
            //            DebugLog(@"ActionReceiver...");
            // stream has data
            // (in a real app you have gather up multiple data packets into the sent data)
            NSUInteger bsize = 1024;
            uint8_t buf[bsize];
            NSInteger bytesRead = 0;
            bytesRead = [[BonjourManager sharedInstance].inputStream read:buf maxLength:bsize];
            if (bytesRead <= 0) {
                // handle EOF and error in NSStreamEventEndEncountered and NSStreamEventErrorOccurred cases
            } else {
                NSData *data = [NSData dataWithBytes:buf length:bytesRead];
                NSError *errorJson=nil;
                NSDictionary* myDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
                NSString *receivedStr = [myDictionary objectForKey:USER_DEFAULTS_VERSION_CHECK];
                //NSString *receivedStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[myDictionary objectForKey:USER_DEFAULTS_PAIRING_DEVICE_ID] forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
                [userDefaults setObject:[myDictionary objectForKey:USER_DEFAULTS_PAIRING_OS_VERSION] forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
                [userDefaults setObject:[myDictionary objectForKey:USER_DEFAULTS_PAIRING_MODEL] forKey:USER_DEFAULTS_PAIRING_MODEL];
                [userDefaults setObject:[myDictionary objectForKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE] forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
                
                [userDefaults synchronize];

                
                NSRange range = [receivedStr rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS"];
                if ((range.location != NSNotFound) && (receivedStr.length > 0)) { // receiver accept connection
                    
                    if (!versionCheckflag) {
                        [self checkVersionoftheApp:receivedStr];
                    }
                    
                    //                    NSRange range = [receivedStr rangeOfString:SERVER_OK];
                    
                    //                    [self movetoBonjuorTransferScreen];
                    
                } else {
                    // received remote data
                    //                DebugLog(@"received data: %ld bytes\n\n",(long)bytesRead);
                    
                    
                }
            }
            break;
        }
            // all others cases
        case NSStreamEventEndEncountered:
            //            DebugLog(@"receiving end test");
            break;
        case NSStreamEventNone:
            break;
        case NSStreamEventErrorOccurred:
            // fall through
            break;
        default: {
            // setup stream
            //            [[BonjourManager sharedInstance] setupStream];
        } break;
    }
}

- (void) checkVersionoftheApp:(NSString *)str {
    CTVersionManager *versionCheck = [[CTVersionManager alloc] init];
    
    self.versionCheckflag = true;
    
    CTVersionCheckStatus status = [versionCheck identifyOsVersion:str];
    
    if ( status == CTVersionCheckStatusMatched) {
        
        [self moveToBonjourReceiverScreen];
        
    } else {
        
        if (status == CTVersionCheckStatusLesser) {
            
            // alert to upgrade other device
            
            CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                
                [[BonjourManager sharedInstance] setupStream];
                
                versionCheckflag = false;
            }];
            
            [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Version Mismatch" message:[NSString stringWithFormat:@"The Content Transfer app on the other device seems to be out of date. Please update the app on that device to v:%@ or higher" ,BUILD_VERSION] cancelAction:okAction otherActions:nil isGreedy:NO];
             self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:@"invalid pin or pairing failed"};
            self.pageName = ANALYTICS_TrackState_Value_PageName_VersionMismatch;
            
            
        } else {
            
            // alert to upgrade currnt device
            
            CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                
                [[BonjourManager sharedInstance] setupStream];
                
                versionCheckflag = false;
            }];
            
            NSArray *actions = nil;
            actions = @[[[CTMVMAlertAction alloc] initWithTitle:@"Upgrade" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                //                NSString *iTunesLink = @"itms://itunes.apple.com/us/app/my-verizon-mobile/id416023011?mt=8";
                
                NSString *iTunesLink = @"itms://itunes.apple.com/us/app/content-transf/id1127930385?mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
            }]];
            
            [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Version Mismatch" message:[NSString stringWithFormat:@"The Content Transfer app on this device seems to be out of date. Please update the app to v:%@",versionCheck.supported_version] cancelAction:okAction otherActions:actions isGreedy:NO];
            self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:@"invalid pin or pairing failed"};
            self.pageName = ANALYTICS_TrackState_Value_PageName_VersionMismatch;
            
        }
        
        NSMutableDictionary *dataDict = [NSMutableDictionary new];
        [dataDict setObject:self.uuid_string forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
        [dataDict setObject:[UIDevice currentDevice].model forKey:USER_DEFAULTS_PAIRING_MODEL];
        [dataDict setObject:[UIDevice currentDevice].systemVersion forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
        [dataDict setObject:@"iOS" forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
        [dataDict setObject:@"Bonjour" forKey:USER_DEFAULTS_PAIRING_TYPE];
        
        
        NSString * str = [NSString stringWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@",BUILD_VERSION,BUILD_CROSS_PLATFROM_MIN_VERSION];
        [dataDict setObject:str forKey:USER_DEFAULTS_VERSION_CHECK];
        NSError *errorJson=nil;

        NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
                                                              options:NSJSONWritingPrettyPrinted
                                                                error:&errorJson];
        

        [[BonjourManager sharedInstance] sendStream:data];
        
    }
    
}

#pragma mark - Helper Methods

// Helper function: help turn the long string into numbers
- (int)getNumberIDForPeer:(NSString *)name
{
    int numberID = 0;
    for (int i=0; i<name.length; i++) {
        numberID += (int)[name characterAtIndex:i];
    }
    
    return numberID;
}

@end
