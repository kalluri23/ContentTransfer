//
//  ViewController.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/12/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "VZSenderViewController.h"
#import "Device.h"
#import "VZTransferDataViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <netdb.h>
#import "VZTransferStatusModel.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <netdb.h>
#import "CTMVMFonts.h"
#import "CTMVMColor.h"
#import "CTVersionManager.h"
#import "VZDeviceMarco.h"
#import "CTPinKeyboardAccessoryView.h"
#import "CTContentTransferSetting.h"


@interface VZSenderViewController ()
@property NSString *netMask;
@property(nonatomic,strong) NSString *address;

@property NSMutableArray *connctedDevices;
@property ScanLAN *lanScanner;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top3;
@property (strong, nonatomic) NSString *pressedOnOff;
@property (weak, nonatomic) IBOutlet UILabel *wifiAccessPointLbl;
@property (strong, nonatomic) NSString *connectionStatus;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifissidLblTopConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleWidth;
@property (weak, nonatomic) IBOutlet UILabel *enterPinTitleLbl;
@property (strong, nonatomic) CTPinKeyboardAccessoryView *keyboardAccessoryView;

@property (nonatomic, assign) BOOL firstLayout;
@end

@implementation VZSenderViewController
@synthesize selDeviceInfo;
@synthesize enterIPAddress;
@synthesize address;
@synthesize overlayActivity;
@synthesize keyBoardOffsetConstraints;
@synthesize cancelBtn;
@synthesize connectBtn;
@synthesize app;
@synthesize pressedOnOff;
@synthesize connectionStatus;


- (void)viewDidLoad {
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhonePIN;
    [super viewDidLoad];
    
    self.firstLayout = YES;
    
    // Do any additional setup after loading the view, typically from a nib.
    
    overlayActivity.image = [ UIImage getImageFromBundleWithImageName:@"spinner-1.png" ];

    overlayActivity.hidden = YES;
    
    self.navigationItem.title = @"Content Transfer";
    
    listenOnPort = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    uint16_t port = REGULAR_PORT;
    address = @"error";
    
    if (![listenOnPort acceptOnPort:port error:&error]) {
        DebugLog(@"No i am not able to listen on this port 8988");
    } else {
        DebugLog(@"Yes i am able to listen on this port");
    }
    
    self.selDeviceInfo = [[Device alloc] init];
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.enterIPAddress.delegate = self;
    self.enterIPAddress.font = [CTMVMFonts mvmBoldFontOfSize:20];
    
    @try {
        self.keyboardAccessoryView = [CTPinKeyboardAccessoryView customView];
        [self.keyboardAccessoryView.connectButton addTarget:self action:@selector(handleConnectFromAccessoryView:) forControlEvents:UIControlEventTouchUpInside];
        [self.keyboardAccessoryView.dismissButton addTarget:self action:@selector(handleDismissFromAccessoryView:) forControlEvents:UIControlEventTouchUpInside];
        self.enterIPAddress.inputAccessoryView = self.keyboardAccessoryView;

    } @catch (NSException *exception) {
        NSAssert(false,@"Please check implementation, nib should've been found");
        DebugLog(@"Exception %@ ",[exception description]);
    }
    
    [self findIPSeries];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
#if STANDALONE
    
    self.NetworkConnectionLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.NetworkConnectionLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    self.enterPinTitleLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:15];
#else
    self.NetworkConnectionLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.NetworkConnectionLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    self.enterPinTitleLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:15];
//    self.phoneNameLbl.textColor = [CTMVMColor mvmDarkGrayColor];
//    self.phoneNameLbl.font = [CTMVMFonts mvmBoldFontOfSize:14];
    
#endif
    
    [CTMVMButtons primaryGreyButton:self.cancelBtn constrainHeight:YES];
    [CTMVMButtons primaryRedButton:self.connectBtn constrainHeight:YES];
    
    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackController:self withName:@"VZReceiverViewController" withExtraInfo:@{} isEncryptedExtras:false];
    
    self.connectionStatus = @"NotApplication";
    
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"WiFi Connected to: \n%@",wifiInfo]];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(20, wifiInfo.length)];
    [string addAttribute:NSFontAttributeName value:[CTMVMFonts mvmBoldFontOfSize:20] range:NSMakeRange(20, wifiInfo.length)];
    
    _wifiAccessPointLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
    _wifiAccessPointLbl.textColor = [CTMVMColor mvmDarkGrayColor];
    
    if(ssidInfo == nil) {
        
        [_wifiAccessPointLbl setText:[NSString stringWithFormat:@"WiFi not connected"]];
    }
    
    else
    {
        [_wifiAccessPointLbl setAttributedText:string];
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
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.firstLayout) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) { // UI adaption for iPhones
            CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
            if (screenHeight <= 480) { // IPhone 4 & 5 UI resolution.
                [self.keyBoardOffsetConstraints setConstant:self.keyBoardOffsetConstraints.constant - 20];
                
                self.top1.constant -= 20;
                self.top2.constant /= 4;
                self.top3.constant /= 2;
                
                self.circleWidth.constant = 200;
            }
        }
        
        self.firstLayout = NO;
    }
}

- (void)appActivated:(NSNotification *)note
{
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    
    NSString *wifiInfo = [[NSString alloc] initWithFormat:@"%@",[ssidInfo valueForKey:@"SSID"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"WiFi Connected to: \n%@",wifiInfo]];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(20, wifiInfo.length)];
    [string addAttribute:NSFontAttributeName value:[CTMVMFonts mvmBoldFontOfSize:20] range:NSMakeRange(20, wifiInfo.length)];
    
    if(ssidInfo == nil) {
        [_wifiAccessPointLbl setText:[NSString stringWithFormat:@"WiFi not connected"]];
    }
    
    else
    {
        [_wifiAccessPointLbl setAttributedText:string];
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

- (void)handleConnectFromAccessoryView:(id)sender {
    
    [self dismissKeyboard];
    [self connectToSelDevice:sender];
}

- (void)handleDismissFromAccessoryView:(id)sender {
    
    [self dismissKeyboard];
}

- (IBAction)connectToSelDevice:(id)sender {
    
    self.pressedOnOff = @"Connect";
    
    [self connectToOtherDevice:REGULAR_PORT];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark GCDAsyncSocket delegate methods

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    
    if (port == REGULAR_PORT) {
        
        self.connectionStatus = @"Success";
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#%@#%@",BUILD_VERSION,BUILD_CROSS_PLATFROM_MIN_VERSION];
        
        NSData *requestData = [shareKey dataUsingEncoding:NSUTF8StringEncoding];
        
        [asyncSocket writeData:requestData withTimeout: 0.0 tag:0];
        [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:0.0 tag:0];
        
        [asyncSocket readDataWithTimeout:-1 tag:0];

    }

}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
        
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //    DebugLog(@"NSdata to String2 : %@", response);
        
        NSRange range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMREC"];
        
        overlayActivity.hidden = YES;
        [overlayActivity stopAnimating];
        if (range.location != NSNotFound) {
            
            range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMRECIOS"];
            
            NSUserDefaults *usedeafult = [NSUserDefaults standardUserDefaults];
            
            if (range.location != NSNotFound) {
                
                [usedeafult setValue:@"NO" forKey:@"isIamIOS"];
            } else {
                
                [usedeafult setValue:@"YES" forKey:@"isIamIOS"];
                
            }
            
            CTVersionManager *versionCheck = [[CTVersionManager alloc] init];
            
            CTVersionCheckStatus status = [versionCheck identifyOsVersion:response];
            
            
            if (status == CTVersionCheckStatusMatched) {
                
                [self performSegueWithIdentifier:@"showTransfersegue" sender:self];
                
            } else {
                
                if (status == CTVersionCheckStatusLesser) {
                    
                    // alert to upgrade other device
                    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    }];
                    
                    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Version Mismatch" message:[NSString stringWithFormat:@"The Content Transfer app on the other device seems to be out of date. Please update the app on that device to v:%@ or higher",versionCheck.supported_version] cancelAction:okAction otherActions:nil isGreedy:NO];
                    
                    self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:[@"The Content Transfer app on the other device seems to be out of date." lowercaseString]};
                    self.pageName = ANALYTICS_TrackState_Value_PageName_PairingFailed;
                    
                } else {
                    
                    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        
                    }];
                    
                    NSArray *actions = nil;
                    actions = @[[[CTMVMAlertAction alloc] initWithTitle:@"Upgrade" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        NSString *iTunesLink = @"itms://itunes.apple.com/us/app/content-transf/id1127930385?mt=8";
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                    }]];
                    
                    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Version Mismatch" message:[NSString stringWithFormat:@"The Content Transfer app on this device seems to be out of date. Please update the app to v:%@",versionCheck.supported_version] cancelAction:okAction otherActions:actions isGreedy:NO];
                    
                    self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:[@"The Content Transfer app on this device seems to be out of date." lowercaseString]};
                    self.pageName = ANALYTICS_TrackState_Value_PageName_PairingFailed;
                    
                }
            }
        }
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    DebugLog(@"socket:didWriteDataWithTag: %ld",tag);
    
   
//    [asyncSocket readDataWithTimeout:-1 tag:0];
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    DebugLog(@"socketDidDisconnect:withError: \"%@\"", err.localizedDescription);
    
    self.connectionStatus = @"Failure";

    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    if (err.localizedDescription != nil) {
        
         self.analyticsData = @{ANALYTICS_TrackAction_Key_ErrorMessage:[@"invalid pin" lowercaseString]};
        
        if ([err.localizedDescription isEqualToString:@"Attempt to connect to host timed out"]) {
            
            overlayActivity.hidden = YES;
            [overlayActivity stopAnimating];
            [self
             displayAlter:@"Please check the pin, verify both phones are still connected to same network and retry."];

        } else {
            
            overlayActivity.hidden = YES;
            [overlayActivity stopAnimating];
            if ([err.localizedDescription isEqualToString:@"nodename nor servname provided, or not known"]) {
                
                [self displayAlter:@"Please check the pin, verify both phones are still connected to same network and retry."];
                
            }else {
                
                [self displayAlter:@"Please check the pin, verify both phones are still connected to same network and retry."];

            }
        }
        
        self.pageName = ANALYTICS_TrackState_Value_PageName_PairingFailed;
    }

}


- (void) socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
    asyncSocket = newSocket;
    
    [asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)connectToOtherDevice:(int)portNumber {
    
    NSError *error = nil;
    uint16_t port = portNumber;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //    DebugLog(@"IP address is %@",address);
    
    if ([self validateIpAddress]) {
        
        NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhonePIN, ANALYTICS_TrackAction_Value_LinkName_ConnectUsingPin);
        [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Value_LinkName_ConnectUsingPin
                                     data:@{
                                            ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Value_LinkName_ConnectUsingPin,
                                            ANALYTICS_TrackAction_Key_PageLink:pageLink,
                                            ANALYTICS_TrackAction_Param_Key_FlowInitiated:ANALYTICS_TrackAction_Param_Value_FlowInitiated_1,
                                            ANALYTICS_TrackAction_Param_Key_FlowName:ANALYTICS_TrackAction_Param_Value_FlowInitiated_PairingOfSenderAndReceiver,
                                            ANALYTICS_TrackAction_Key_SenderReceiver:ANALYTICS_TrackAction_Value_SenderReceiver_Sender,
                                            ANALYTICS_TrackAction_Key_TransactionId:self.uuid_string
                                            }];
        
        [asyncSocket disconnect];
        [listenOnPort disconnect];
        
        overlayActivity.hidden = NO;
        [overlayActivity startAnimating];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
            if ([asyncSocket connectToHost:[userDefaults valueForKey:@"RECEIVERIPADDRESS"] onPort:port withTimeout:20 error:&error])
            {
                DebugLog(@"Unable to connect to due to invalid configuration: %@", error);
            } else {
                DebugLog(@"Connecting...");
                
            }
    }
    
    
}

#pragma mark UITextField Delegate methods

//REVIEW: Is this method even used ?
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    NSMutableArray *listItems = (NSMutableArray *)[address componentsSeparatedByString:@"."];
    
    NSString *newpin = [self decode4Digitpin:enterIPAddress.text];
    
    // FIXME : Potential crash
    [listItems replaceObjectAtIndex:3 withObject:newpin];
    
    address = [listItems componentsJoinedByString:@"."];
    
    [self dismissKeyboard];
    
    return [self.view endEditing:YES];
    
}


- (NSString *)decode4Digitpin:(NSString *)enteredpin {
    
    
    int pin = enteredpin.intValue % PINCODE;
    
    return [NSString stringWithFormat:@"%d",pin];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    textField.placeholder = @"";
    
    if ([[UIScreen mainScreen] bounds].size.height <= 480) { // iphone 4
        
        [UIView animateWithDuration:.5
                         animations:^{
                             [self.view setFrame:CGRectMake(0,-100,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
                             [self.view setNeedsLayout];
                         }];
        
        [self.view needsUpdateConstraints];
        [self.view layoutIfNeeded];
    } else if ([[UIScreen mainScreen] bounds].size.height <= 568) { // iphone 5
        
        [UIView animateWithDuration:.5
                         animations:^{
                             [self.view setFrame:CGRectMake(0,-50,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
                             [self.view setNeedsLayout];
                         }];
        
        //        keyBoardOffsetConstraints.constant = -45;
        
        [self.view needsUpdateConstraints];
        [self.view layoutIfNeeded];
        
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.text.length >= 4 && range.length == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField.text.length == 0) {
        
        textField.placeholder = @"Enter PIN";
    }
    
    return YES;
}

- (void)findIPSeries {
    
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

- (BOOL)validateIpAddress {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:address forKey:@"RECEIVERIPADDRESS"];
    
    if (self.enterIPAddress.text.length > 0) {
        
        if (self.enterIPAddress.text.length < 4) {
            [self displayAlter:@"Invalid PIN, please try again."];
            
            return NO;
        }
        
        return YES;
        
    } else {
        
        [self displayAlter:@"Please enter the PIN"];
    }
    
    return NO;
}

-(void)dismissKeyboard {
    
    NSMutableArray *listItems = (NSMutableArray *)[address componentsSeparatedByString:@"."];
    
    if ([listItems count] > 2) {
        
        NSString *newpin = [self decode4Digitpin:enterIPAddress.text];
        
        [listItems replaceObjectAtIndex:3 withObject:newpin];
        
    }
    
    address = [listItems componentsJoinedByString:@"."];
    
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:.5
                     animations:^{
                         [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
                         [self.view setNeedsLayout];
                     }];
}


- (void)displayAlter:(NSString *)str {
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:str cancelAction:cancelAction otherActions:nil isGreedy:NO];
}

- (IBAction)clickedCancelBtn:(id)sender {
    
    self.pressedOnOff = @"Cancel";
    
    [asyncSocket disconnect];
    [listenOnPort disconnect];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showTransfersegue"]) {
        
        VZTransferDataViewController *destination = segue.destinationViewController;
        destination.asyncSocket = asyncSocket;
        destination.listenOnPort = listenOnPort;
    }
}

@end
