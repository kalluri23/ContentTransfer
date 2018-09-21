//
//  VZReceiverViewController.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/29/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "VZReceiverViewController.h"
#import "VZContactsImport.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <netdb.h>
#import "CTMVMFonts.h"
#import "VZContentTrasnferConstant.h"
#import "VZDeviceMarco.h"
#import "CTContentTransferSetting.h"

@interface VZReceiverViewController ()

@property ScanLAN *lanScanner;
@property NSString *netMask;

@property (nonatomic, assign) BOOL accepted;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circularTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numberTop;
@property (weak, nonatomic) IBOutlet UILabel *wifiSsidLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifissidLblTopConstraints;
@property (strong, nonatomic) NSString *PairingStatus;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstaints;
@property (weak, nonatomic) IBOutlet UILabel *pinTitleLbl;

@property (nonatomic, assign) BOOL firstLayout;
@end


@implementation VZReceiverViewController

@synthesize deviceIP;
@synthesize cancelBtn;
@synthesize app;
@synthesize PairingStatus;
@synthesize pairDict;
@synthesize changePinAfter30Sec;




- (void)viewDidLoad {
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhonePIN;
    [super viewDidLoad];
    
    self.firstLayout = YES;
    
    self.accepted = NO;
    
    listenOnPort = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    uint16_t port = REGULAR_PORT;
    
    if (![listenOnPort acceptOnPort:port error:&error]) {
        
        DebugLog(@"Yes i am able to listen on this port");
    } else {
        
        DebugLog(@"No i am not able to listen on this port");
    }
    

    // Do any additional setup after loading the view.
    
    connectionIsSucessful = FALSE;
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self startScan];
    
    self.pinTitleLbl.font = [CTMVMFonts mvmBoldFontOfSize:15];
    self.deviceIP.font = [CTMVMFonts mvmBoldFontOfSize:22];
    
#if STANDALONE
    
    self.connectingLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.connectingLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
    self.pinTitleLbl.font = [CTMVMFonts mvmBookFontOfSize:15];
    self.deviceIP.font = [CTMVMFonts mvmBoldFontOfSize:22];
    
#else
    
    self.connectingLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.connectingLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
    self.pinTitleLbl.font = [CTMVMFonts mvmBookFontOfSize:15];
    self.deviceIP.font = [CTMVMFonts mvmBoldFontOfSize:22];
    
#endif
    
    self.navigationItem.title = @"Content Transfer";
    
    [CTMVMButtons primaryRedButton:self.cancelBtn constrainHeight:YES];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackController:self withName:@"VZReceiverViewController" withExtraInfo:@{} isEncryptedExtras:false];
    
    self.PairingStatus = @"unknown";
    
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"WiFi Connected to: \n%@",wifiInfo]];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(20, wifiInfo.length)];
    [string addAttribute:NSFontAttributeName value:[CTMVMFonts mvmBoldFontOfSize:20] range:NSMakeRange(20, wifiInfo.length)];
    
    _wifiSsidLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
    _wifiSsidLbl.textColor = [CTMVMColor mvmDarkGrayColor];
    
    if(ssidInfo == nil) {
        
        [_wifiSsidLbl setText:[NSString stringWithFormat:@"Wifi not connected"]];
    }
    
    else
    {
        [_wifiSsidLbl setAttributedText:string];
        
    }
    
    
    self.pairDict = [[NSMutableDictionary alloc] init];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.firstLayout) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) { // UI adaption for iPhones
            
            // Build selection list UI adaption
            CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
            if (screenHeight <= 480) { // IPhone 4 UI resolution.
                self.circularTop.constant /= 4;
                self.wifissidLblTopConstraints.constant /= 3;
                self.circleWidth.constant = 200;
                
                self.titleTopConstaints.constant -= 20;
            }
            
            self.firstLayout = NO;
        }
    }
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
    
    [self.changePinAfter30Sec invalidate];
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackController:self withName:@"DisplayPinScreen" withExtraInfo:self.pairDict isEncryptedExtras:false];
    
}


- (void)appActivated:(NSNotification *)note
{
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"WiFi Connected to: \n%@",wifiInfo]];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(20, wifiInfo.length)];
    [string addAttribute:NSFontAttributeName value:[CTMVMFonts mvmBoldFontOfSize:20] range:NSMakeRange(20, wifiInfo.length)];
    
    
    if(ssidInfo == nil) {
        [_wifiSsidLbl setText:[NSString stringWithFormat:@"WiFi not connected"]];
    } else {
        [_wifiSsidLbl setAttributedText:string];
        [self startScan];
    }
    
    DebugLog(@"SSDI info is %@", ssidInfo);
    
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


- (void) viewDidAppear {
    
    [super viewDidAppear:YES];
    
    [asyncSocket disconnect];
    [listenOnPort disconnect];
}

- (void) uploadCapture{
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:self.PairingStatus forKey:@"PairingStatus"];
    [dict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
    
    self.pairDict = dict;
}



- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void)startScan {
    
    
    NSString *address = @"error";
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
    
    NSArray *listItems = [address componentsSeparatedByString:@"."];
    
    if ([listItems count] > 2) {
        
        deviceIP.text = [self get4DigitPIN:[listItems objectAtIndex:3]];
        
        self.changePinAfter30Sec = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                                    target:self
                                                                  selector:@selector(startScan)
                                                                  userInfo:nil
                                                                   repeats:NO];
        
    } else {
        
        [self displayAlter:@"Please check your mobile wifi connection"];
    }
    
    
}


- (NSString *) get4DigitPIN:(NSString*)pinStr {
    
    
    int pin = pinStr.intValue + PINCODE * (arc4random_uniform(34) + 4);
    
    return [NSString stringWithFormat:@"%d",pin];
}


#pragma mark GCDAsyncSockets delegate methods

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    DebugLog(@"Connected to Host : %@",host);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {

//    if (sock == asyncSocketCommPort) {
//        
//         NSError *errorJson;
//         NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
//        
//        if (responseDict )
//        {
//        
//            DebugLog(@"read comm port information : %@",responseDict);
//            
//            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//            
//            [dict setValue:[NSString stringWithFormat:@"Device ID: %@",self.uuid_string] forKey:DB_PARING_DEVICE_INFO];
//            
//            VZDeviceMarco *deviceMacro = [[VZDeviceMarco alloc] init];
//            NSString *modelCode = [deviceMacro getDeviceModel];
//            NSString *model = [deviceMacro.models objectForKey:modelCode];
//            if (model.length == 0) {
//                model = modelCode;
//            }
//            
//            [dict setValue:model forKey:PAIRING_MODEL];
//            [dict setValue:[[UIDevice currentDevice] systemVersion] forKey:PAIRING_OS_VERSION];
//            [dict setValue:@"iOS" forKey:PAIRING_DEVICE_TYPE];
//            [dict setValue:self.uuid_string forKey:PAIRING_DEVICE_ID];
//            
//            NSError *error;
//            NSData *requestData = [NSJSONSerialization dataWithJSONObject:dict
//                                                                  options:NSJSONWritingPrettyPrinted
//                                                                    error:&error];
//            
//            [asyncSocketCommPort writeData:requestData withTimeout: 0.0 tag:100];
//            [asyncSocketCommPort writeData:[GCDAsyncSocket CRLFData] withTimeout:0.0 tag:100];
//            
//            [asyncSocketCommPort readDataWithTimeout:-1 tag:0];
//            
//            [self performSegueWithIdentifier:@"VZReceiveSegue" sender:self];
//        
//        }
//         
//        return;
//    }
    
    if (data.length > 5) {
        
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //    DebugLog(@"NSdata to String1 : %@", response);
        
        NSRange range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSEN"];
        
        if (range.location != NSNotFound) {
            
            connectionIsSucessful = TRUE;
        }
        
        
        range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENAND"];
        
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        
        if (range.location != NSNotFound) {
            
            [userdefault setValue:@"TRUE" forKey:@"isAndriodPlatform"];
            
        } else {
            
            [userdefault setValue:@"FALSE" forKey:@"isAndriodPlatform"];
        }
        
        [self authenticatedConnectionMade:nil];
        
        CTVersionManager *versionCheck = [[CTVersionManager alloc] init];
        
        CTVersionCheckStatus status = [versionCheck identifyOsVersion:response];
        
        
        if (status == CTVersionCheckStatusMatched) {
            
//            NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhonePIN, ANALYTICS_TrackAction_Value_LinkName_ConnectUsingPin);
//            [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Value_LinkName_ConnectUsingPin
//                                         data:@{
//                                                ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Value_LinkName_ConnectUsingPin,
//                                                ANALYTICS_TrackAction_Key_PageLink:pageLink,
//                                                ANALYTICS_TrackAction_Param_Key_FlowInitiated:ANALYTICS_TrackAction_Param_Value_FlowInitiated_1,
//                                                ANALYTICS_TrackAction_Param_Key_FlowName:ANALYTICS_TrackAction_Param_Value_FlowInitiated_PairingOfSenderAndReceiver
//                                                }];
            [self performSegueWithIdentifier:@"VZReceiveSegue" sender:self];
            
        } else {
            
            if (status == CTVersionCheckStatusLesser) {
                
                CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                }];
                
                [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Version Mismatch" message:[NSString stringWithFormat:@"The Content Transfer app on the other device seems to be out of date. Please update the app on that device to v:%@ or higher",versionCheck.supported_version] cancelAction:okAction otherActions:nil isGreedy:NO];
                
            self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:@"invalid pin or pairing failed"};
            self.pageName = ANALYTICS_TrackState_Value_PageName_VersionMismatch;                
            } else {
                
                // alert to upgrade currnt device
                
                CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                }];
                
                NSArray *actions = nil;
                actions = @[[[CTMVMAlertAction alloc] initWithTitle:@"Upgrade" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    //                NSString *iTunesLink = @"itms://itunes.apple.com/us/app/my-verizon-mobile/id416023011?mt=8";
                    NSString *iTunesLink = @"itms://itunes.apple.com/us/app/content-transf/id1127930385?mt=8";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                }]];
                
                [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Version Mismatch" message:[NSString stringWithFormat:@"The Content Transfer app on this device seems to be out of date. Please update the app to v:%@",versionCheck.supported_version] cancelAction:okAction otherActions:actions isGreedy:NO];
                
                    self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:@"invalid pin or pairing failed" };
                self.pageName = ANALYTICS_TrackState_Value_PageName_VersionMismatch;
            }
        }
        
        [asyncSocket readDataWithTimeout:-1 tag:0];
        
    }
}

- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    DebugLog(@"socket:didWriteDataWithTag: %ld",tag);
    
    [asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    
    self.PairingStatus = @"fail";
    
    [self uploadCapture];
}

- (void) socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
        [self.changePinAfter30Sec invalidate];
    
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    
    if ([[[userdefault dictionaryRepresentation] allKeys] containsObject:@"RECEIVERIPADDRESS"]) {
        
         [userdefault removeObjectForKey:@"RECEIVERIPADDRESS"];
    }
    
    if ([newSocket connectedHost]) {
        
        [userdefault setObject:[newSocket connectedHost] forKey:@"RECEIVERIPADDRESS"];
    }
    

        asyncSocket = newSocket;
        asyncSocket.delegate = self;
        
        [asyncSocket readDataWithTimeout:-1 tag:0];
        
        self.PairingStatus = @"Successful";
        
        [self uploadCapture];

        [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_CONNECTION_IS_SUCCESSFUL_RECEIVER];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) authenticatedConnectionMade:(id)sender {
    
    NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMRECIOS#%@#%@",BUILD_VERSION,BUILD_CROSS_PLATFROM_MIN_VERSION];
    
    NSData *requestData = [shareKey dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData:requestData withTimeout: -1.0 tag:0];
    [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:30];
    
    
}

- (void)readSocketRepeated {
    
    dispatch_queue_t alwaysReadQueue = dispatch_queue_create([GCD_ALWAYS_READ_QUEUE UTF8String], NULL);
    
    dispatch_async(alwaysReadQueue, ^{
        while(![asyncSocket isDisconnected]) {
            [NSThread sleepForTimeInterval:1];
            [asyncSocket readDataWithTimeout:-1 tag:0];
        }
    });
    
}


- (IBAction)clickedCancelBtn:(id)sender {
    
    [asyncSocket disconnect];
    [listenOnPort disconnect];
    
    self.PairingStatus = @"Cancel";
    
    [self uploadCapture];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_CLICKED_CANCEL];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) displayAlter:(NSString *)str {
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:str cancelAction:cancelAction otherActions:nil isGreedy:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"VZReceiveSegue"]) {
        
        VZReceiveDataViewController *destination = segue.destinationViewController;
        
        destination.asyncSocket = asyncSocket;
        destination.listenOnPort = listenOnPort;
    }
}


@end
