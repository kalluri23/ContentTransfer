//
//  VZAnDSenderWifiSetupVC.m
//  myverizon
//
//  Created by Hadapad, Prakash on 4/1/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "VZAnDSenderWifiSetupVC.h"
#import "VZAnDBumpActionSender.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <netdb.h>
#import "VZSenderViewController.h"
#import "CTMVMColor.h"
#import "CTMVMFonts.h"
#import "VZContentTrasnferConstant.h"
#import "CTVersionManager.h"
#import "CTContentTransferSetting.h"


@interface VZAnDSenderWifiSetupVC ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnTopConstaints;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifiConnectTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subLblTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnBottom;
@property(nonatomic,strong) NSString *address;
@property NSString *netMask;
@property (nonatomic,strong) NSString *deviceName;
@property (nonatomic,assign) int pingCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ssidTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblBottom;
@property (weak, nonatomic) IBOutlet UILabel *currentNetwork;
@property (weak, nonatomic) IBOutlet UILabel *editLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifiLblHeight;
@end

@implementation VZAnDSenderWifiSetupVC

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
@synthesize wifisetupNewLbl;




- (void)viewDidLoad {
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneWiFiSelect;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (screenHeight <= 480) { // IPhone 4 UI resolution.
        [self.titleTop setConstant:self.titleTop.constant/2];
        [self.imageTop setConstant:self.imageTop.constant/2];
        [self.subLblTop setConstant:self.subLblTop.constant/2];
        [self.ssidTop setConstant:self.ssidTop.constant/2];
        self.btnBottom.constant /= 2;
        
        [self.lblBottom setConstant:self.lblBottom.constant/2];
    } else if (screenHeight <= 568) { // iphone 5
        
    
    }
    overlayActivity.image = [ UIImage getImageFromBundleWithImageName:@"spinner-1.png" ];

    overlayActivity.hidden = YES;
    [overlayActivity stopAnimating];
    
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];

    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",wifiInfo]];
    [string addAttribute:NSForegroundColorAttributeName value:[CTMVMColor blackColor] range:NSMakeRange(0, wifiInfo.length)];
    
    
    if(ssidInfo == nil) {
        [wifissidLbl setText:[NSString stringWithFormat:@"WiFi not connected"]];
        
        self.softAccessPointLbl.text = @"";
        self.wifiLblHeight.constant = 0;
    } else {
        self.softAccessPointLbl.text = @"This phone is currently connected to the WiFi shown below. Please make sure both phones are on the same WiFi";
        self.wifiLblHeight.constant = 56;
        
        [wifissidLbl setAttributedText:string];
    }
    
    DebugLog(@"SSDI info is %@", ssidInfo);
    
    self.wifissidLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
    self.connectToSameWifi.font = [CTMVMFonts mvmBoldFontOfSize:14];
    self.wifiSetupCompleted.font = [CTMVMFonts mvmBookFontOfSize:15];
    self.wifiSetupLbl.font = [CTMVMFonts mvmBookFontOfSize:16];
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
    
    self.navigationItem.title = @"Content Transfer";
    
    [CTMVMButtons primaryGreyButton:self.cancelBtn constrainHeight:YES];
    [CTMVMButtons primaryRedButton:self.yesBtn constrainHeight:YES];
    
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_WIFISETUP_SCREEN_SENDER withExtraInfo:@{} isEncryptedExtras:false];
    
    
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


- (IBAction)cancelBtnPressed:(id)sender {
    
    //    NSInteger count = self.navigationController.viewControllers.count;
    //    UIViewController *controller = (UIViewController *)[self.navigationController.viewControllers objectAtIndex:count-2];\
    //    if ([controller isKindOfClass:[VZAnDBumpActionSender class]]) {
    //        ((VZAnDBumpActionSender *)controller).goBack =  YES;
    //    }
    //
    //    [app.VZCTAppAnalytics trackEvent:self.view withTrackTag:CONTENT_TRANSFER_WIFISETUP_NO_SENDER];
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
        
        [self displayAlter];
        
    }
    
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_WIFISETUP_YES_SENDER];    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"showTransfersegueAnD"]) {
        
        VZTransferDataViewController *controller = (VZTransferDataViewController *)segue.destinationViewController;
        controller.asyncSocket = asyncSocket;
        controller.listenOnPort = listenOnPort;
    }
    
}

- (void)  makeconnectionWithAndriodDevice:(int)portnumber {
    
    listenOnPort = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    uint16_t port = portnumber;
    address = @"error";
    
    if (![listenOnPort acceptOnPort:port error:&error]) {
        DebugLog(@"No i am not able to listen on this port");
    } else {
        DebugLog(@"Yes i am able to listen on this port");
    }
    
    self.selDeviceInfo = [[Device alloc] init];
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
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
        
        NSMutableArray *listItems = (NSMutableArray *)[address componentsSeparatedByString:@"."];
        
        if ([listItems count] > 2) {
            
            [listItems replaceObjectAtIndex:3 withObject:@"1"];
        }
        
        address = [listItems componentsJoinedByString:@"."];
        
        [userDefaults setObject:address forKey:@"RECEIVERIPADDRESS"];
        
        overlayActivity.hidden = NO;
        [overlayActivity startAnimating];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        if ([asyncSocket connectToHost:[userDefaults valueForKey:@"RECEIVERIPADDRESS"] onPort:port withTimeout:10 error:&error])
        {
            DebugLog(@"Unable to connect to due to invalid configuration: %@", error);
        } else {
            DebugLog(@"Connecting...");
            
        }
    }else {
        
        // Go to pin screen
        
        asyncSocket.delegate = nil;
        [asyncSocket disconnect];
        asyncSocket = nil;
        
        listenOnPort.delegate = nil;
        [listenOnPort disconnect];
        listenOnPort = nil;
        
        overlayActivity.hidden = YES;
        [overlayActivity stopAnimating];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"TRUE" forKey:@"isAndriodPlatform"];
        
        _pingCount = 0;
        
        [self performSegueWithIdentifier:@"sender_yes_segue_Hotspot" sender:self];
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
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

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@",BUILD_VERSION,BUILD_CROSS_PLATFROM_MIN_VERSION];
    
    NSData *requestData = [shareKey dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData:requestData withTimeout: 0.0 tag:0];
    [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:0.0 tag:0];
    
    [asyncSocket readDataWithTimeout:-1.0 tag:10];
    
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRange range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENAND#"];  // total 39
    
    
    if (response.length > 0) {
        
        DebugLog(@"Resposne from Andriod is : %@",response);
    }
    
    overlayActivity.hidden = YES;
    [overlayActivity stopAnimating];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    
    [[NSUserDefaults standardUserDefaults] setValue:@"TRUE" forKey:@"isAndriodPlatform"];
    
    if (range.location != NSNotFound) {
        
        _pingCount++;
        
        
        NSData *tempdata = [data subdataWithRange:NSMakeRange(39, data.length - 39)];
        _deviceName = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
        
        NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@",BUILD_VERSION,BUILD_CROSS_PLATFROM_MIN_VERSION];
        
        NSData *requestData = [shareKey dataUsingEncoding:NSUTF8StringEncoding];
        
        [asyncSocket writeData:requestData withTimeout: 0.0 tag:0];
        [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:0.0 tag:0];
        
        [asyncSocket readDataWithTimeout:-1.0 tag:10];
        
        
        CTVersionManager *versionCheck = [[CTVersionManager alloc] init];
        
        CTVersionCheckStatus status = [versionCheck identifyOsVersion:response];
        
        
        if (status == CTVersionCheckStatusMatched) {
            
            [self performSegueWithIdentifier:@"showTransfersegueAnD" sender:self];
            
        } else {
            
            if (status == CTVersionCheckStatusLesser) {
                
                CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                }];
                
                [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Version Mismatch" message:[NSString stringWithFormat:@"The Content Transfer app on the other device seems to be out of date. Please update the app on that device to v:%@ or higher",BUILD_CROSS_PLATFROM_MIN_VERSION] cancelAction:okAction otherActions:nil isGreedy:NO];
                
            } else {
                
                // alert to upgrade currnt device
                
                CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                }];
                
                NSArray *actions = nil;
                actions = @[[[CTMVMAlertAction alloc] initWithTitle:@"Upgrade" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    NSString *iTunesLink = @"itms://itunes.apple.com/us/app/content-transf/id1127930385?mt=8";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                }]];
                
                [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Version Mismatch" message:[NSString stringWithFormat:@"The Content Transfer app on this device seems to be out of date. Please update the app to v:%@",versionCheck.supported_version] cancelAction:okAction otherActions:actions isGreedy:NO];
            }
        }
        
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    
    
    if (err.code != 0) {
        
        if (_pingCount > 0) {
            
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
            
            [[NSUserDefaults standardUserDefaults] setValue:@"TRUE" forKey:@"isAndriodPlatform"];
            
            _pingCount = 0;
            
        }else {
            
            [self createAlertWithTitle:@"Content Transfer" andContext:@"Please connect to the same WIFI/hot-spot on both devices"];
            
            overlayActivity.hidden = YES;
            [overlayActivity stopAnimating];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
        }
        
    }
}

- (void)appActivated:(NSNotification *)note
{
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];

    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",wifiInfo]];
    [string addAttribute:NSForegroundColorAttributeName value:[CTMVMColor blackColor] range:NSMakeRange(0, wifiInfo.length)];
    
    if(ssidInfo == nil) {
        [wifissidLbl setText:[NSString stringWithFormat:@"WiFi not connected"]];
        self.softAccessPointLbl.text = @"";
        [UIView animateWithDuration:0.3 animations:^{
            self.wifiLblHeight.constant = 0;
        }];
    } else {
        
        self.softAccessPointLbl.text = @"This phone is currently connected to the WiFi shown below. Please make sure both phones are on the same WiFi";
        [UIView animateWithDuration:0.3 animations:^{
            self.wifiLblHeight.constant = 56;
        }];
        [wifissidLbl setAttributedText:string];
    }
    
    DebugLog(@"SSDI info is %@", ssidInfo);
    
}

- (void) gotoSetting:(id)sender {
    
    [self openSettings];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
    asyncSocket = newSocket;
    asyncSocket.delegate = self;
    
    [asyncSocket readDataWithTimeout:-1 tag:0];
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
        
        [alert setValue:[self getLabelWithMessage:string] forKey:@"accessoryView"];
        [alert show];
    }
    
}

- (UILabel *)getLabelWithMessage:(NSAttributedString *)message {
    
    UILabel *label = [[UILabel alloc] init];
    [label setAttributedText:message];
    [label setNumberOfLines:0];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    
    label.frame = CGRectMake(20, 0, label.frame.size.width-10, 0);
    [label sizeToFit];
    
    return label;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 1) {
        
        [self makeconnectionWithAndriodDevice:REGULAR_PORT];
        [self connectToOtherDevice:REGULAR_PORT];
        
        
    }
}



@end
