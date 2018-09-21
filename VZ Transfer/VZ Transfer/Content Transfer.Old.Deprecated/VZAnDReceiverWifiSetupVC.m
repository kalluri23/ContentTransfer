//
//  VZAnDReceiverWifiSetupVC.m
//  myverizon
//
//  Created by Hadapad, Prakash on 4/4/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "VZAnDReceiverWifiSetupVC.h"
#import "VZAnDBumpActionRecevier.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <netdb.h>
#import "CTMVMFonts.h"
#import "VZContentTrasnferConstant.h"
#import "VZViewUtility.h"
#import "CTContentTransferSetting.h"

@interface VZAnDReceiverWifiSetupVC ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ssidTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifiTopConstaints;
@property (weak, nonatomic) IBOutlet UILabel *currentNetwork;
@property (weak, nonatomic) IBOutlet UILabel *editLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnBottom;
@property(nonatomic,strong) NSString *address;
@property NSString *netMask;
@property (nonatomic,strong) NSString *deviceName;
@property (nonatomic,assign)int pingCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifiHeight;

@property (assign, nonatomic) BOOL firstResponse;
@end

@implementation VZAnDReceiverWifiSetupVC
@synthesize firstResponse;
@synthesize wifiSsidLbl;
@synthesize wifiSetupLbl,connectPhoneToSameWifiLbl,wifiSetupCompletedLbl;
@synthesize yesBtn,cancelBtn;
@synthesize app;
@synthesize softAccessPointLbl;
@synthesize gotoSettingBtn;
@synthesize address;
@synthesize overlayActivity;

- (void)viewDidLoad {
    
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneWiFiSelect;
    [super viewDidLoad];
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (screenHeight <= 480) { // IPhone 4 & 5 UI resolution.
        [self.infoTopConstaints setConstant:self.infoTopConstaints.constant-20];
        [self.wifiTopConstaints setConstant:self.wifiTopConstaints.constant/2-40];
        
        [self.imageTop setConstant:self.imageTop.constant/2];
        [self.subTop setConstant:self.subTop.constant/2];
        [self.ssidTop setConstant:self.ssidTop.constant/2-10];
        
        [self.lblBottom setConstant:self.lblBottom.constant/2];
        self.btnBottom.constant /= 2;
    } else if (screenHeight <= 568) { // iphone 5
        [self.wifiTopConstaints setConstant:self.wifiTopConstaints.constant/2-15];
    }
    
    firstResponse = YES;
    
    overlayActivity.image = [ UIImage getImageFromBundleWithImageName:@"spinner-1.png" ];
    
    overlayActivity.hidden = YES;
    [overlayActivity stopAnimating];
    
    // Do any additional setup after loading the view.
    
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    self.navigationItem.title = @"Content Transfer";
    
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",wifiInfo]];
    [string addAttribute:NSForegroundColorAttributeName value:[CTMVMColor blackColor] range:NSMakeRange(0, wifiInfo.length)];
    
    
    
    if(ssidInfo == nil) {
        [wifiSsidLbl setText:[NSString stringWithFormat:@"WiFi not connected"]];
        
        self.softAccessPointLbl.text = @"";
        
        self.wifiHeight.constant = 0;
    } else {
        [wifiSsidLbl setAttributedText:string];
        
        self.softAccessPointLbl.text = @"This phone is currently connected to the WiFi shown below. Please make sure both phones are on the same WiFi";
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
    [CTMVMButtons primaryRedButton:self.yesBtn constrainHeight:YES];
    [CTMVMButtons primaryGreyButton:self.cancelBtn constrainHeight:YES];
    
#if STANDALONE
    
    self.wifisetupNewLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.wifisetupNewLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
#else
    
    self.wifisetupNewLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.wifisetupNewLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
#endif
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_WIFISETUP_SCREEN_RECEVIER withExtraInfo:@{} isEncryptedExtras:false];
    
    // [self.yesBtn addTarget:self action:@selector(clickeOnYesBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(clickOnnCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [self.gotoSettingBtn addTarget:self action:@selector(gotoSetting:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[userDefault valueForKey:@"SOFTACCESSPOINT"] isEqualToString:@"NO"]) {
        
        self.softAccessPointLbl.hidden = YES;
        self.gotoSettingBtn.hidden = YES;
    } else {
        BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
        if (canOpenSettings) {
            self.gotoSettingBtn.hidden = NO;
        }
    }
    
    _pingCount = 0;
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector( appActivated: )
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) gotoSetting:(id)sender {
    
    [self openSettings];
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self ];
//}


- (void)appActivated:(NSNotification *)note
{
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",wifiInfo]];
    [string addAttribute:NSForegroundColorAttributeName value:[CTMVMColor blackColor] range:NSMakeRange(0, wifiInfo.length)];
    
    
    if(ssidInfo == nil) {
        [wifiSsidLbl setText:[NSString stringWithFormat:@"WiFi not connected"]];
        
        self.softAccessPointLbl.text = @"";
        //        [self.softAccessPointLbl layoutIfNeeded];
        [UIView animateWithDuration:0.3f animations:^{
            self.wifiHeight.constant = 0;
        }];
    } else {
        self.softAccessPointLbl.text = @"This phone is currently connected to the WiFi shown below. Please make sure both phones are on the same WiFi";
        [UIView animateWithDuration:0.3f animations:^{
            self.wifiHeight.constant = 56;
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
    } else {
        
        // Make server Connection
        
        [self displayAlter];
        
          }
    

    
}

- (void)makeconnectionWithAndriodDevice:(int)sender {
    
    [listenOnPort disconnect];
    listenOnPort.delegate = nil;
    
    overlayActivity.hidden = NO;
    [overlayActivity startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    sleep(2);
    
    listenOnPort = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    //    uint16_t port = 8987;
    uint16_t port = sender;
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

- (void)connectToOtherDevice:(int)sender {
    
    NSError *error = nil;
    uint16_t port = sender;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];
    
    NSString *ChkStr;
    
    if (wifiInfo.length > 6) {
        
        ChkStr = [wifiInfo substringWithRange:NSMakeRange(0, 6)];
    }
    
    if ([ChkStr isEqualToString:@"DIRECT"] && (wifiInfo.length > 6)) {
        
        
        NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneWiFiSelect, ANALYTICS_TrackAction_Param_Value_LinkName_YesButtonHotspotWifi);
        [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Param_Value_LinkName_YesButtonHotspotWifi
                                     data:@{ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Param_Value_LinkName_YesButtonHotspotWifi,
                                            ANALYTICS_TrackAction_Param_Key_FlowInitiated:ANALYTICS_TrackAction_Param_Value_FlowInitiated_1,
                                            ANALYTICS_TrackAction_Param_Key_FlowName:ANALYTICS_TrackAction_Param_Value_FlowInitiated_PairingOfSenderAndReceiver,
                                            ANALYTICS_TrackAction_SenderReceiverTransactionId:self.uuid_string,
                                            ANALYTICS_TrackAction_Key_SenderReceiver:ANALYTICS_TrackAction_Value_SenderReceiver_Receiver,
                                            ANALYTICS_TrackAction_Key_PageLink:pageLink}];
        
        
        NSMutableArray *listItems = (NSMutableArray *)[address componentsSeparatedByString:@"."];
        
        if ([listItems count] > 2) {
            
            [listItems replaceObjectAtIndex:3 withObject:@"1"];
            
        }
        
        address = [listItems componentsJoinedByString:@"."];
        
        [userDefaults setObject:address forKey:@"RECEIVERIPADDRESS"];
        
        
        if ([asyncSocket connectToHost:[userDefaults valueForKey:@"RECEIVERIPADDRESS"] onPort:port withTimeout:10 error:&error])
        {
            DebugLog(@"Connecting...");
        } else {
            DebugLog(@"Unable to connect to due to invalid configuration: %@", error);
        }
        
    } else {
        
        NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneWiFiSelect, ANALYTICS_TrackAction_Param_Value_LinkName_YesButtonHotspotWifi);
        [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Param_Value_LinkName_YesButtonHotspotWifi
                                     data:@{ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Param_Value_LinkName_YesButtonHotspotWifi,
                                            ANALYTICS_TrackAction_Key_PageLink:pageLink}];
        
        asyncSocket.delegate = nil;
        [asyncSocket disconnect];
        asyncSocket = nil;
        
        listenOnPort.delegate = nil;
        [listenOnPort disconnect];
        listenOnPort = nil;
        
        overlayActivity.hidden = YES;
        [overlayActivity stopAnimating];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        _pingCount = 0;
        
        [self performSegueWithIdentifier:@"receiver_yes_segue_Hotspot" sender:self];
        
    }
    
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
    
    DebugLog(@"IP address is %@",address);
    
}



- (IBAction)clickOnnCancelBtn:(id)sender {
    // DebugLog(@"navigation stack: %@",self.navigationController.viewControllers);
    //    NSInteger count = self.navigationController.viewControllers.count;
    //    UIViewController *controller = (UIViewController *)[self.navigationController.viewControllers objectAtIndex:count-2];\
    //    if ([controller isKindOfClass:[VZAnDBumpActionRecevier class]]) {
    //        //        ((VZAnDBumpActionRecevier *)controller).goBack =  YES;
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
    if ([segue.identifier isEqualToString:@"AnD_receiver_yes_segue"]) {
        
        //    } else if ([segue.identifier isEqualToString:@"receiver_wifi_back"]) {
        //        VZBumpActionReceiver *controller = (VZBumpActionReceiver *)segue.destinationViewController;
        //        controller.goBack = YES;
        
        VZAnDBumpActionRecevier *controller = (VZAnDBumpActionRecevier *)segue.destinationViewController;
        //        controller.deviceIPaddress = address;
        //        controller.asyncSocket = asyncSocket;
        //        controller.listenOnPort = listenOnPort;
        
        [asyncSocket disconnect];
        [listenOnPort disconnect];
    }
    
    if ([segue.identifier isEqualToString:@"VZReceiveSegueAnD"]) {
        
        //    } else if ([segue.identifier isEqualToString:@"receiver_wifi_back"]) {
        //        VZBumpActionReceiver *controller = (VZBumpActionReceiver *)segue.destinationViewController;
        //        controller.goBack = YES;
        
        VZReceiveDataViewController *controller = (VZReceiveDataViewController *)segue.destinationViewController;
        //        controller.deviceIPaddress = address;
        controller.asyncSocket = asyncSocket;
        controller.listenOnPort = listenOnPort;
        
    }
    
}

- (void)createAlertWithTitle:(NSString *)title andContext:(NSString *)context
{
    
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Turn on" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
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


- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    DebugLog(@"Connected port is %d",port);
    
    NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@",BUILD_VERSION,BUILD_CROSS_PLATFROM_MIN_VERSION];
    
    NSData *requestData = [shareKey dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData:requestData withTimeout: 0.0 tag:0];
    [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:0.0 tag:0];
    
    [asyncSocket readDataWithTimeout:-1.0 tag:10];
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    DebugLog(@"Connection is successful and recevied data from Andriod device : %@",response);
    
    NSRange range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENAND#"];  // total 39
    
    [[NSUserDefaults standardUserDefaults] setValue:@"TRUE" forKey:@"isAndriodPlatform"];
    
    overlayActivity.hidden = YES;
    [overlayActivity stopAnimating];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    if (firstResponse && range.location != NSNotFound) {
        
        CTVersionManager *versionCheck = [[CTVersionManager alloc] init];
        
        CTVersionCheckStatus status = [versionCheck identifyOsVersion:response];
        
        
        if (status != CTVersionCheckStatusMatched) {
            
            if (status == CTVersionCheckStatusLesser) {
                
                CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                }];
                
                [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Version Mismatch" message:[NSString stringWithFormat:@"The Content Transfer app on the other device seems to be out of date. Please update the app on that device to v:%@ or higher",BUILD_CROSS_PLATFROM_MIN_VERSION] cancelAction:okAction otherActions:nil isGreedy:NO];
 				self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:@"invalid pin or pairing failed"};
                self.pageName = ANALYTICS_TrackState_Value_PageName_VersionMismatch;
                
            } else {
                
                // alert to upgrade currnt device
                
                CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                }];
                
                NSArray *actions = nil;
                actions = @[[[CTMVMAlertAction alloc] initWithTitle:@"Upgrade" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    //                        NSString *iTunesLink = @"itms://itunes.apple.com/us/app/my-verizon-mobile/id416023011?mt=8";
                    
                    NSString *iTunesLink = @"itms://itunes.apple.com/us/app/content-transf/id1127930385?mt=8";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                }]];
                
                [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Version Mismatch" message:[NSString stringWithFormat:@"The Content Transfer app on this device seems to be out of date. Please update the app to v:%@",versionCheck.supported_version] cancelAction:okAction otherActions:actions isGreedy:NO];
                self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:@"invalid pin or pairing failed"};
                self.pageName = ANALYTICS_TrackState_Value_PageName_VersionMismatch;
            }
        }
        
        firstResponse = NO;
        
    } else  {
        
        NSRange range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENAND#"];  // total 39
        if (range.location != NSNotFound) {
            [self performSegueWithIdentifier:@"VZReceiveSegueAnD" sender:self];
            
        }
    }
}


- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
    asyncSocket = newSocket;
    asyncSocket.delegate = self;
    
    [asyncSocket readDataWithTimeout:-1 tag:0];
    
    DebugLog(@"%d",[newSocket connectedPort]);
    
    NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMRECIOS#%@#%@",BUILD_VERSION,BUILD_CROSS_PLATFROM_MIN_VERSION];
    
    NSData *requestData = [shareKey dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData:requestData withTimeout: 0.0 tag:0];
    [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:0.0 tag:0];
    
    [asyncSocket readDataWithTimeout:-1.0 tag:10];
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {

    if (err.code != 0) {
        
        if (_pingCount> 0) {
            
            // Go to Pin
            asyncSocket.delegate = nil;
            [asyncSocket disconnect];
            asyncSocket = nil;
            
            listenOnPort.delegate = nil;
            [listenOnPort disconnect];
            listenOnPort = nil;
            
            overlayActivity.hidden = YES;
            [overlayActivity stopAnimating];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            _pingCount = 0;
            
        } else {
            
            [self createAlertWithTitle:@"Content Transfer" andContext:@"Please connect to the same WIFI/hot-spot on both devices"];
            
            overlayActivity.hidden = YES;
            [overlayActivity stopAnimating];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
        }
        
    }
}


- (void)displayAlter {
    
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];
    
    NSString *infoMsg = [NSString stringWithFormat:@"Is the other device connected to \n \"%@\"?",wifiInfo];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",infoMsg]];
    
    [string addAttribute:NSForegroundColorAttributeName value:[CTMVMColor mvmPrimaryRedColor] range:NSMakeRange(33, wifiInfo.length+4)];
    
    if ([UIAlertController class] != nil) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Content Transfer"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert setValue:string forKey:@"attributedMessage"];
        
        __weak typeof(self) weakSelf = self;
        UIAlertAction *okAction = nil;
        
        okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action) {
                                              
                                              [weakSelf makeconnectionWithAndriodDevice:REGULAR_PORT];
                                              [weakSelf connectToOtherDevice:REGULAR_PORT];
                                              
                                          }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 
                                                             }];
        
        if (okAction != nil) {
            [alert addAction:okAction];
        }
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Content Transfer" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        lbl.attributedText = string;
        lbl.textAlignment = NSTextAlignmentCenter;
        [alert setValue:lbl forKey:@"accessoryView"];
        [alert show];
        
        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 1) {
        
        [self makeconnectionWithAndriodDevice:REGULAR_PORT];
        [self connectToOtherDevice:REGULAR_PORT];
        
        
    }
}


@end

