//
//  VZWifiSetupViewController.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 2/2/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import "VZSenderWifiSetupViewController.h"
#import "VZBumpActionSender.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <netdb.h>


#import "CTMVMFonts.h"
#import "CTMVMColor.h"
#import "CTContentTransferSetting.h"

@interface VZSenderWifiSetupViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnBottomConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifiConnectTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleBlankHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelBottom;
@property(nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSMutableDictionary *infodict;
@property (nonatomic,strong) NSString *buttonSelection;
@property NSString *netMask;
@property (weak, nonatomic) IBOutlet UILabel *currentNetwork;
@property (weak, nonatomic) IBOutlet UILabel *editLbl;
@property (weak, nonatomic) IBOutlet UIImageView *wifiIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifisetupLblHeight;
@end

@implementation VZSenderWifiSetupViewController
@synthesize wifissidLbl;
@synthesize wifiSetupCompleted;
@synthesize wifiSetupLbl;
@synthesize connectToSameWifi;
@synthesize cancelBtn;
@synthesize yesBtn;
@synthesize app;
@synthesize address;
@synthesize selDeviceInfo;
@synthesize overlayActivity;


- (void)viewDidLoad {
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneWiFiSelect;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (screenHeight <= 480) { // IPhone 4 UI resolution.
//        [self.titleTop setConstant:self.titleTop.constant-15];
        [self.wifiConnectTopConstaints setConstant:self.wifiConnectTopConstaints.constant/2];
        self.titleBlankHeight.constant /= 4;
        self.labelBottom.constant /= 2;
        self.btnBottomConstaints.constant /= 2;
    } else if (screenHeight <= 568) { // iphone 5
        [self.wifiConnectTopConstaints setConstant:self.wifiConnectTopConstaints.constant/2];
        [self.titleBlankHeight setConstant:self.titleBlankHeight.constant/2];
    }
    
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",wifiInfo]];
    [string addAttribute:NSForegroundColorAttributeName value:[CTMVMColor blackColor] range:NSMakeRange(0, wifiInfo.length)];
    
    
    if(ssidInfo == nil) {
        [wifissidLbl setText:[NSString stringWithFormat:@"WiFi not connected"]];
        self.softAccessPointLbl.text = @"";
        self.wifisetupLblHeight.constant = 0;
    } else {
        
        [self.softAccessPointLbl layoutIfNeeded];
        self.softAccessPointLbl.text = @"This phone is currently connected to the WiFi shown below. Please make sure both phones are on the same WiFi";
        
        [wifissidLbl setAttributedText:string];
    }
    
    DebugLog(@"SSDI info is %@", ssidInfo);
    
    self.wifissidLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
    self.connectToSameWifi.font = [CTMVMFonts mvmBoldFontOfSize:14];
    self.wifiSetupCompleted.font = [CTMVMFonts mvmBookFontOfSize:15];
    self.wifiSetupLbl.font = [CTMVMFonts mvmBookFontOfSize:16];
//    self.wifiSetupLbl.textColor = [CTMVMColor mvmDarkGrayColor];
    self.softAccessPointLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
    [self.softAccessPointLbl setTextColor:[CTMVMColor blackColor]];
    self.currentNetwork.font = [CTMVMFonts mvmBoldFontOfSize:16];
    self.editLbl.font = [CTMVMFonts mvmBoldFontOfSize:14];
    
#if STANDALONE
    
    self.wifisetupNewLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.wifisetupNewLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
#else
    
    self.wifisetupNewLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.wifisetupNewLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
#endif
//    [MVMButtons primaryRedButton:self.gotoSettingBtn constrainHeight:YES];
    
    
    self.navigationItem.title = @"Content Transfer";
    
    [CTMVMButtons primaryGreyButton:self.cancelBtn constrainHeight:YES];
    [CTMVMButtons primaryRedButton:self.yesBtn constrainHeight:YES];
        
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_WIFISETUP_SCREEN_SENDER withExtraInfo:@{} isEncryptedExtras:false];
    
    
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
    
    self.infodict = [[NSMutableDictionary alloc] init];
    
    [self.infodict setValue:@"UNKNOWN" forKey:@"WiFiSignalStrength"];
    [self.infodict setValue:@"UNKNOWN" forKey:@"WiFiLinkSpeed"];
    [self.infodict setValue:@"UNKNOWN" forKey:@"WifiStatus"];
    [self.infodict setValue:@"UNKNOWN" forKey:@"WiFiSSID"];
    [self.infodict setValue:@"UNKNOWN" forKey:@"WiFiFrequency"];
    
    self.buttonSelection = @"NO";
}


- (void)viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector( appActivated: )
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) gotoSetting:(id)sender {
    
    [self openSettings];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
    
    [self.infodict setValue:self.buttonSelection forKey:@"ButtonSelection"];
    [self.infodict setValue:wifissidLbl.text forKey:@"WiFiSSID"];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"WiFiSetupScreen" withExtraInfo:self.infodict isEncryptedExtras:false];

}


- (void)appActivated:(NSNotification *)note
{
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",wifiInfo]];
    [string addAttribute:NSForegroundColorAttributeName value:[CTMVMColor blackColor] range:NSMakeRange(0, wifiInfo.length)];
    

    if(ssidInfo == nil) {
        [wifissidLbl setText:[NSString stringWithFormat:@"WiFi not connected"]];
//        self.softAccessPointLbl.hidden = YES;
        self.softAccessPointLbl.text = @"";
        
        [UIView animateWithDuration:0.3f animations:^{
            self.wifisetupLblHeight.constant = 0;
        }];
        
    } else {
        self.softAccessPointLbl.text = @"This phone is currently connected to the WiFi shown below. Please make sure both phones are on the same WiFi";
        [UIView animateWithDuration:0.3f animations:^{
            self.wifisetupLblHeight.constant = 63;
        }];
        
        [wifissidLbl setAttributedText:string];
    }
    
    DebugLog(@"SSDI info is %@", ssidInfo);
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

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


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (IBAction)cancelBtnPressed:(id)sender {
    
//    NSInteger count = self.navigationController.viewControllers.count;
//    UIViewController *controller = (UIViewController *)[self.navigationController.viewControllers objectAtIndex:count-2];\
//    if ([controller isKindOfClass:[VZBumpActionSender class]]) {
//        ((VZBumpActionSender *)controller).goBack =  YES;
//    }
//    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_WIFISETUP_NO_SENDER];
//    [self.navigationController popViewControllerAnimated:YES];
    
    [self backButtonPressed];
}

- (IBAction)YesBtnPressed:(id)sender {
    
    if ([self fetchSSIDInfo] == nil) {
        [self createAlertWithTitle:@"Content Transfer" andContext:@"Please connect to the same WIFI/hot-spot on both devices."];
        
        return;
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if ([[userDefault valueForKey:@"SOFTACCESSPOINT"] isEqualToString:@"NO"]) {
        
        [self performSegueWithIdentifier:@"sender_yes_segue" sender:self];
        
    } else {
        
        // Make server Connection
        
        //        [self makeconnectionWithAndriodDevice];
        
        //        [self connectToOtherDevice:nil];
    }
    
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_WIFISETUP_YES_SENDER];
    
    
    self.buttonSelection = @"YES";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"sender_yes_segue"]) {
        
        //    } else if ([segue.identifier isEqualToString:@"sender_wifi_goback"]) {
        //        VZBumpActionSender *controller = (VZBumpActionSender *)segue.destinationViewController;
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
    //    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    //    [[UIApplication sharedApplication] openURL:url];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
}

- (void)  makeconnectionWithAndriodDevice {
    
    listenOnPort = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    uint16_t port = REGULAR_PORT;
    address = @"error";
    
    if (![listenOnPort acceptOnPort:port error:&error]) {
        DebugLog(@"No i am not able to listen on this port");
    } else {
        DebugLog(@"Yes i am able to listen on this port");
    }
    
    self.selDeviceInfo = [[Device alloc] init];
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //    self.enterIPAddress.delegate = self;
    
    [self findIPSeries];
}

- (void) findIPSeries {
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    
    if (success == 0)
    {
        temp_addr = interfaces;
        
        while(temp_addr != NULL)
        {
            // check if interface is en0 which is the wifi connection on the iPhone
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    self.netMask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    //    DebugLog(@"IP address is %@",address);
    
}

- (void)connectToOtherDevice:(id)sender {
    
    NSError *error = nil;
    uint16_t port = REGULAR_PORT;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //    DebugLog(@"IP address is %@",address);
    
    //    if ([self validateIpAddress]) {
    
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *listItems = (NSMutableArray *)[address componentsSeparatedByString:@"."];
    
    if ([listItems count] > 2) {
        
        [listItems replaceObjectAtIndex:3 withObject:@"1"];
    }
    
    
    
    address = [listItems componentsJoinedByString:@"."];
    
    [userDefaults setObject:address forKey:@"RECEIVERIPADDRESS"];
    
    overlayActivity.image = [ UIImage getImageFromBundleWithImageName:@"spinner-1.png" ];

    overlayActivity.hidden = NO;
    [overlayActivity startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    if ([asyncSocket connectToHost:[userDefaults valueForKey:@"RECEIVERIPADDRESS"] onPort:port withTimeout:20 error:&error])
    {
        DebugLog(@"Unable to connect to due to invalid configuration: %@", error);
    } else {
        DebugLog(@"Connecting...");
        
    }
    //    }
    
}

- (void) displayAlter:(NSString *)str {
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:str cancelAction:cancelAction otherActions:nil isGreedy:NO];
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    NSString *mydeviceName = [[UIDevice currentDevice] name];
    
    NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@",BUILD_VERSION,BUILD_CROSS_PLATFROM_MIN_VERSION];
    
    NSData *requestData = [shareKey dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData:requestData withTimeout: 0.0 tag:0];
    [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:0.0 tag:0];
    
    //    [self performSegueWithIdentifier:@"showTransfersegue" sender:self];
    
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRange range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENAND"];
    
    overlayActivity.hidden = YES;
    [overlayActivity stopAnimating];
    
    if (range.location != NSNotFound) {
        
        [self performSegueWithIdentifier:@"showTransfersegue" sender:self];
    }
}

@end
