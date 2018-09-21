//
//  VZRecevierWifiSetupViewController.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 2/2/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import "VZRecevierWifiSetupViewController.h"
#import "VZBumpActionReceiver.h"
#import "CTMVMColor.h"
#import "CTMVMFonts.h"
#import "VZContentTrasnferConstant.h"


@interface VZRecevierWifiSetupViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifiTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifiBlankHeight;
@property (weak, nonatomic) IBOutlet UILabel *currentNetwork;
@property (weak, nonatomic) IBOutlet UILabel *editLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifiSetupLblHeight;

@end

@implementation VZRecevierWifiSetupViewController
@synthesize wifiSsidLbl;
@synthesize wifiSetupLbl,connectPhoneToSameWifiLbl,wifiSetupCompletedLbl;
@synthesize yesBtn,cancelBtn;
@synthesize app;
@synthesize softAccessPointLbl;
@synthesize gotoSettingBtn;

- (void)viewDidLoad {
    
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneWiFiSelect;
    
    [super viewDidLoad];
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (screenHeight <= 480) { // IPhone 4 & 5 UI resolution.
        [self.infoTopConstaints setConstant:self.infoTopConstaints.constant-15];
        [self.wifiTopConstaints setConstant:self.wifiTopConstaints.constant/2-40];
    } else if (screenHeight <= 568) { // iphone 5
        [self.wifiTopConstaints setConstant:self.wifiTopConstaints.constant/2];
        self.wifiBlankHeight.constant /= 2;
    }
    
    // Do any additional setup after loading the view.
    
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    self.navigationItem.title = @"Content Transfer";
    
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",wifiInfo]];
    [string addAttribute:NSForegroundColorAttributeName value:[CTMVMColor blackColor] range:NSMakeRange(0, wifiInfo.length)];
    
    
    
    if(ssidInfo == nil) {
        [wifiSsidLbl setText:[NSString stringWithFormat:@"WiFi not connected"]];
        self.softAccessPointLbl.text = @"";
//        [self.softAccessPointLbl layoutIfNeeded];
        self.wifiSetupLblHeight.constant = 0;
    } else {
        [wifiSsidLbl setAttributedText:string];
        
        self.softAccessPointLbl.text = @"This phone is currently connected to the WiFi shown below. Please make sure both phones are on the same WiFi.";
        [self.softAccessPointLbl layoutIfNeeded];
    }
    DebugLog(@"SSDI info is %@", ssidInfo);
    
    self.wifiSsidLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
    self.connectToSameWifi.font = [CTMVMFonts mvmBoldFontOfSize:14];
    self.wifiSetupCompletedLbl.font = [CTMVMFonts mvmBookFontOfSize:15];
    self.wifiSetupLbl.font = [CTMVMFonts mvmBookFontOfSize:16];
//    self.wifiSetupLbl.textColor = [CTMVMColor mvmDarkGrayColor];
    self.softAccessPointLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
    [self.softAccessPointLbl setTextColor:[CTMVMColor blackColor]];
    self.currentNetwork.font = [CTMVMFonts mvmBoldFontOfSize:16];
    self.editLbl.font = [CTMVMFonts mvmBoldFontOfSize:14];

//    [MVMButtons primaryRedButton:self.gotoSettingBtn constrainHeight:YES];
    
    
#if STANDALONE
    
    self.wifisetupNewLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.wifisetupNewLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
#else
    
    self.wifisetupNewLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.wifisetupNewLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
#endif
    
    [CTMVMButtons primaryRedButton:self.yesBtn constrainHeight:YES];
    [CTMVMButtons primaryGreyButton:self.cancelBtn constrainHeight:YES];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_WIFISETUP_SCREEN_RECEVIER withExtraInfo:@{} isEncryptedExtras:false];
    
    // [self.yesBtn addTarget:self action:@selector(clickeOnYesBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(clickOnnCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [self.gotoSettingBtn addTarget:self action:@selector(gotoSetting:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[userDefault valueForKey:@"SOFTACCESSPOINT"] isEqualToString:@"NO"]) {
        
//        self.softAccessPointLbl.hidden = YES;
        self.gotoSettingBtn.hidden = NO;
    } else {
        BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
        if (canOpenSettings) {
            self.gotoSettingBtn.hidden = NO;
        }
    }
}

- (void) gotoSetting:(id)sender {
    
    [self openSettings];
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector( appActivated: )
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
}


- (void)appActivated:(NSNotification *)note
{
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",wifiInfo]];
    [string addAttribute:NSForegroundColorAttributeName value:[CTMVMColor blackColor] range:NSMakeRange(0, wifiInfo.length)];
    
    
    if(ssidInfo == nil) {
        [wifiSsidLbl setText:[NSString stringWithFormat:@"WiFi not connected"]];
        self.softAccessPointLbl.text = @"";
        [UIView animateWithDuration:0.3f animations:^{
            self.wifiSetupLblHeight.constant = 0;
        }];
    } else {
        self.softAccessPointLbl.text = @"This phone is currently connected to the WiFi shown below. Please make sure both phones are on the same WiFi.";
        [UIView animateWithDuration:0.3f animations:^{
            self.wifiSetupLblHeight.constant = 56;
        }];
        
        [wifiSsidLbl setAttributedText:string];
    }
    
    DebugLog(@"SSDI info is %@", ssidInfo);
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)yesPressed:(UIButton *)sender {
    if ([self fetchSSIDInfo] == nil) {
        [self createAlertWithTitle:@"Content Transfer" andContext:@"Please connect to the same network/hotspot on both devices."];
        
        return;
    }
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_WIFISETUP_YES_RECEVIER];
    [self performSegueWithIdentifier:@"receiver_yes_segue" sender:self];
    
    NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneWiFiSelect, ANALYTICS_TrackAction_Param_Value_LinkName_YesButtonHotspotWifi);
    [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Param_Value_LinkName_YesButtonHotspotWifi
                                 data:@{ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Param_Value_LinkName_YesButtonHotspotWifi,
                                        ANALYTICS_TrackAction_Key_PageLink:pageLink}];
}

- (IBAction)clickOnnCancelBtn:(id)sender {
    // DebugLog(@"navigation stack: %@",self.navigationController.viewControllers);
//    NSInteger count = self.navigationController.viewControllers.count;
//    UIViewController *controller = (UIViewController *)[self.navigationController.viewControllers objectAtIndex:count-2];\
//    if ([controller isKindOfClass:[VZBumpActionReceiver class]]) {
//        ((VZBumpActionReceiver *)controller).goBack =  YES;
//    }
    
    //[self performSegueWithIdentifier:@"receiver_wifi_back" sender:sender];
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_WIFISETUP_NO_SENDER];
//    [self.navigationController popViewControllerAnimated:YES];
    
    [self backButtonPressed];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"receiver_yes_segue"]) {
        
        //    } else if ([segue.identifier isEqualToString:@"receiver_wifi_back"]) {
        //        VZBumpActionReceiver *controller = (VZBumpActionReceiver *)segue.destinationViewController;
        //        controller.goBack = YES;
    }
}

- (void)createAlertWithTitle:(NSString *)title andContext:(NSString *)context
{
    
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Connect" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self openSettings];
    }];
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:title message:context cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    
    
}

- (void)openSettings

{
    
    //    if (&UIApplicationOpenSettingsURLString != NULL) {
    //    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    //    [[UIApplication sharedApplication] openURL:url];
    //    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
}

@end
