//
//  CTBonjourSenderViewController.m
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTBonjourSenderViewController.h"
#import "CTCustomTableViewCell.h"
#import "CTSenderTransferViewController.h"
#import "CTStoryboardHelper.h"
#import "CTErrorViewController.h"
#import "CTWifiSetupViewController.h"
#import "CTSenderWaitingViewController.h"
#import "CTSenderWaitingViewController.h"

#import "CTVersionManager.h"
#import "CTDeviceStatusUtility.h"
#import "CTNetworkUtility.h"
#import "CTSettingsUtility.h"
#import "CTBonjourManager.h"
#import "CTVersionManager.h"
#import "CTAlertCreateFactory.h"
//#import "VZConstants.h"
#import "CTDeviceMarco.h"
#import "CTContentTransferSetting.h"
//#import "CTStringConstants.h"
#import "CTProgressHUD.h"
#import "CTStartedViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CTSingleLabelCheckboxCell.h"
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif
#define NEXT_VIEW_SHOULD_GO_BACK 0
#define NEXT_VIEW_SHOULD_GO_FORWARD 1
#define NEXT_VIEW_SHOULD_POP_ROOT 2
//#define NEXT_VIEW_SHOULD_SHOW_ALERT 3
#define NEXT_VIEW_SHOULD_HIDE_ALERT 3

typedef void (^BonjourSenderHandler)(int);

@interface CTBonjourSenderViewController () <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate, NSStreamDelegate>

@property (nonatomic, assign) BOOL hasWifiErr;
@property (nonatomic, assign) BOOL hasBlueToothErr;
@property (nonatomic, assign) BOOL invitationSent;
@property (nonatomic, assign) BOOL somethingChanged;
@property (nonatomic, assign) BOOL blockUI;
@property (nonatomic, assign) BOOL versionChecked;
@property (nonatomic, assign) BOOL shouldHideExtraRow;
@property (nonatomic, assign) BOOL shouldIgnoreCheck; // igonore check when user reject the request
@property (nonatomic, assign) BOOL shouldWaitForResponse;

@property (nonatomic, assign) NSInteger checkPassed;
@property (nonatomic, assign) NSInteger extraRowNumber;
@property (nonatomic, strong) NSIndexPath *selectedIndex;

@property (nonatomic, strong) NSMutableArray *removeIndics;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CTProgressHUD *activityIndicator;
@property (nonatomic, strong) BonjourSenderHandler handler;

@end

static float kCellDefaultHeight_iPhone = 120.0;
static float kCellDefaultHeight_iPad = 130.0;

@implementation CTBonjourSenderViewController

- (CTProgressHUD *)activityIndicator {
    if (![[self.view subviews] containsObject:_activityIndicator]) {
        _activityIndicator = [[CTProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_activityIndicator];
        [self.view bringSubviewToFront:_activityIndicator];
    }
    
    return _activityIndicator;
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
    self.transferFlow = CTTransferFlow_Sender;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentViewController" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"lastViewController",nil]]; // Send a notification to save current view controller
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkWifiConnectionAgain) name:UIApplicationDidBecomeActiveNotification object:nil]; // Observer for check wifi status
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllCheck) name:UIApplicationWillResignActiveNotification object:nil]; // Observer for check wifi status
    
    if (![CTNetworkUtility isWiFiEnabled]) { // WiFi is not enabled
        self.hasWifiErr = YES;
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
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil]; // Observer for check wifi status
    } @catch (NSException *exception) {
        DebugLog(@"Error when remove oberser: %@", exception.description);
    }
    
    if (!self.shouldWaitForResponse) {
        [[CTBonjourManager sharedInstance] stopServer]; // stop server, so other device won't find this device
        [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
    }
    
    if (_extraRowNumber > 0) {
        self.extraRowNumber = 0;
        @try {
            [self.devicesTableView beginUpdates];
            [self.devicesTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
            [self.devicesTableView endUpdates];
        } @catch (NSException *exception) {
            [self.devicesTableView reloadData];
        }
    }
    
    self.shouldHideExtraRow = YES;
    self.nextButton.enabled = NO;
    
    self.centralManager = nil;
    self.checkPassed = 0;
    self.somethingChanged = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (IS_IPAD) {
        return kCellDefaultHeight_iPad;
    }
    
    return kCellDefaultHeight_iPhone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [[CTBonjourManager sharedInstance] serviceNumber];
    } else {
        return _extraRowNumber;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CTSingleLabelCheckboxCell *cell = (CTSingleLabelCheckboxCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CTSingleLabelCheckboxCell class]) forIndexPath:indexPath];
    
    [cell highlightCell:NO];
    
    if (indexPath.section == 0) {
        // Prepare data for tableview cell.
        NSNetService *service = [[CTBonjourManager sharedInstance] getServiceAt:indexPath.row];
        cell.cellLabel.text = [[CTBonjourManager sharedInstance] getDispalyNameForService:service];
    } else {
        cell.cellLabel.text = CTLocalizedString(CT_I_DONT_SEE_LABEL, nil);
    }
    
    return (CTSingleLabelCheckboxCell *)cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    CTSingleLabelCheckboxCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectedIndex = indexPath;
    [cell highlightCell:YES];

    if (![self.nextButton isEnabled]) {
        self.nextButton.enabled = YES;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    CTSingleLabelCheckboxCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell highlightCell:NO];
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
        [self checkHandleFunction];
    }
}

#pragma mark - NSNetServiceDelegate
- (void)netServiceDidPublish:(NSNetService *)sender {
    if (_invitationSent) {
        // When service publish with invitation sent already, then means service refresh after receiver reject the invitation
        _invitationSent = NO;
        [self enableUserInteractionWithDelay:0];
    }
    
    // Start the device browser
    if ([[CTBonjourManager sharedInstance] isBrowserValid]) {
        [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
    }
    [[CTBonjourManager sharedInstance] clearServices];
    [[CTBonjourManager sharedInstance] startBrowserNetworkingForTarget:self];
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
bool shouldUpdate = true;
int startIndex = 0;
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    
    // Add the service to our array (unless its our own service)
//    NSLog(@"=> should update information: %d", shouldUpdate);
    if (shouldUpdate) {
        startIndex = (int)[[CTBonjourManager sharedInstance] serviceNumber];
//        NSLog(@"=> start index: %d", startIndex);
    }
    if ([[CTBonjourManager sharedInstance] serviceIsLocalService:service]) {
        [[CTBonjourManager sharedInstance] addService:service];
//        NSLog(@"=> added service: %@, total: %d", service, [[CTBonjourManager sharedInstance] serviceNumber]);
    }
    
    // only update the UI once we get the no-more-coming indication
    if (!moreComing) {
//        NSLog(@"=> sort and reload.");
        shouldUpdate = true;
        [self sortAndReloadTable:YES startIndex:startIndex];
    } else {
//        NSLog(@"=> still coming.");
        shouldUpdate = false;
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    if (!self.removeIndics) {
        self.removeIndics = [[NSMutableArray alloc] init];
    }
    // Remove the service from our array
    if ([[CTBonjourManager sharedInstance] serviceIsLocalService:service]) {
        
        NSInteger index = [[CTBonjourManager sharedInstance] serviceIndex:service];
        if (self.selectedIndex != nil && index == self.selectedIndex.row && self.selectedIndex.section == 0) {
            self.selectedIndex = nil;
            
            if ([self.nextButton isEnabled]) {
                self.nextButton.enabled = NO;
            }
        }
        [[CTBonjourManager sharedInstance] removeService:service];
        
        if (index != NSNotFound) {
            [self.removeIndics addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
    
    // Only update the UI once we get the no-more-coming indication
    if (!moreComing) {
        [self sortAndReloadTable:NO startIndex:0];
    }
    
}

#pragma mark - Other Methods
- (void)disableUserInteraction {
    [self.devicesTableView setUserInteractionEnabled:NO];
    [self.activityIndicator showAnimated:YES];
}

- (void)enableUserInteractionWithDelay:(NSInteger)delay {
    [self.devicesTableView setUserInteractionEnabled:YES];
    [self.activityIndicator hideAnimated:YES afterDelay:delay];
}

- (void)checkHandleFunction
{
    self.somethingChanged = NO;
    
    if (!self.shouldIgnoreCheck && (self.hasBlueToothErr || self.hasWifiErr)) {
        
        self.shouldHideExtraRow = YES;
        
        if ([self.nextButton isEnabled]) { // disable the button
            self.nextButton.enabled = NO;
        }
        [self enableUserInteractionWithDelay:0];
        
        if (_extraRowNumber > 0) {
            self.extraRowNumber = 0;
            @try {
                [self.devicesTableView beginUpdates];
                [self.devicesTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
                [self.devicesTableView endUpdates];
            } @catch (NSException *exception) {
                [self.devicesTableView reloadData];
            }
        }
        
        // Stop server if condition not fit
        [[CTBonjourManager sharedInstance] stopServer];
        [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
        
        [self customizeConditionCheckAlert];
        
        return;
        
    } else if (!self.shouldIgnoreCheck && [CTNetworkUtility connectedNetworkName] != nil) { // Access point not nil
        
        //        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        //
        //            [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTAlertGeneralTitle context:@"For best performance please turn on WiFi, but forget all your networks. Data charge will not apply.\nPath on Device:Settings>Wi-Fi" btnText:CTAlertGeneralOKTitle handler:nil isGreedy:NO];
        //        }else{
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                              context:CTLocalizedString(CT_FORGET_NETWORKS_ALERT_CONTEXT, nil)
                                                        cancelBtnText:CTLocalizedString(CT_WIFI_BUTTON_TITLE, nil)
                                                       confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                       confirmHandler:nil
                                                        cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                                                            [CTSettingsUtility openWifiSettings];
                                                        }
                                                             isGreedy:NO from:self];
        }else {
            [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                       context:CTLocalizedString(CT_FORGET_NETWORKS_ALERT_CONTEXT, nil)
                                                 cancelBtnText:CTLocalizedString(CT_WIFI_BUTTON_TITLE, nil)
                                                confirmBtnText:CTLocalizedString(CTAlertGeneralContinueTitle, nil)
                                                confirmHandler:nil
                                                 cancelHandler:^(UIAlertAction *action) {
                                                     [CTSettingsUtility openWifiSettings];
                                                 }
                                                      isGreedy:NO];
        }
        //        }
        
    }
    
    self.shouldHideExtraRow = NO;
    
    [[CTBonjourManager sharedInstance] createServerForController:self];
    
    [self enableUserInteractionWithDelay:0];
    
    [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(addNotSeeMyDeviceRow:) userInfo:nil repeats:NO];
}

- (void)checkWifiConnectionAgain
{
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

- (void)sortAndReloadTable:(BOOL)add startIndex:(NSInteger)startIndex{
    // Reload if the view is loaded
    if (self.isViewLoaded) {
        NSMutableArray *indics = [[NSMutableArray alloc] init];
        if (add) {
            for (NSInteger i=startIndex; i<[[CTBonjourManager sharedInstance] serviceNumber]; i++) {
                [indics addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            @try {
                [self.devicesTableView beginUpdates];
                [self.devicesTableView insertRowsAtIndexPaths:indics withRowAnimation:UITableViewRowAnimationBottom];
                [self.devicesTableView endUpdates];
            } @catch (NSException *exception) {
                DebugLog(@"error happen when update table");
                [self.devicesTableView reloadData];
            }
        } else {
            @try {
                [self.devicesTableView beginUpdates];
                [self.devicesTableView deleteRowsAtIndexPaths:_removeIndics withRowAnimation:UITableViewRowAnimationTop];
                [self.devicesTableView endUpdates];
            } @catch (NSException *exception) {
                DebugLog(@"error happen when update table");
                [self.devicesTableView reloadData];
            }
            
            self.removeIndics = nil;
        }
    }
}

- (void)removeAllCheck
{
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
        _invitationSent = YES; // sent invitation already
        
        [self performSegueWithIdentifier:@"CTSenderWaitingViewController" sender:self];
    }
}

- (void)addNotSeeMyDeviceRow:(NSTimer *)timer
{
    if (!_shouldHideExtraRow) {
        self.extraRowNumber = 1;
        [self.devicesTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
    }
    
    if ([timer isValid]) {
        [timer invalidate];
    }
    timer = nil;
}

- (void)customizeConditionCheckAlert {
    NSString *btnTitle = CTLocalizedString(CT_SETTINGS_BUTTON_TITLE, nil);
    NSString *string = @"";
    
    if (self.hasWifiErr) {
        string = CTLocalizedString(CT_TURN_ON_WIFI_ALERT_CONTEXT, nil);
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
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
    //        if (self.hasBlueToothErr && self.hasWifiErr) {
    //            string = [string stringByAppendingString:@"Navigate to settings to change."];
    //        }
    //        else if (self.hasBlueToothErr) {
    //            string = [string stringByAppendingString:@"\nPath on Device:Settings>Bluetooth"];
    //        }else if(self.hasWifiErr){
    //            string = [string stringByAppendingString:@"\nPath on Device:Settings>Wi-Fi"];
    //        }
    //
    //        [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTAlertGeneralTitle context:string btnText:CTAlertGeneralOKTitle handler:nil isGreedy:NO];
    //
    //
    //    } else {
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
    //    }
}

#pragma mark - Events
- (IBAction)handleNextButtonTapped:(id)sender {
    // Find the service associated with the cell and start a connection to that
    if (self.selectedIndex.section == 1) {
        //Add logic for moving to WiFi
        CTWifiSetupViewController *wifiSetupViewController = [CTWifiSetupViewController initialiseFromStoryboard:[CTStoryboardHelper wifiAndP2PStoryboard]];
        wifiSetupViewController.transferFlow = self.transferFlow;
        [self.navigationController pushViewController:wifiSetupViewController animated:YES];
    } else { // Click one device to connect, sender side should jump to waiting page
        NSNetService *targetService = [[CTBonjourManager sharedInstance] getServiceAt:self.selectedIndex.row];
        if (targetService) {
            self.shouldWaitForResponse = YES;
            [CTBonjourManager sharedInstance].targetServer = targetService;
            [self createConnectionForService:targetService];
        }
    }
}

- (IBAction)unwindWaitingViewController:(UIStoryboardSegue *)seque {
    DebugLog(@"Add logic to go to next transfer what screen");
}

- (IBAction)seachAgainButtonTapped:(id)sender {
    
    if (self.hasBlueToothErr || self.hasWifiErr) {
        [self customizeConditionCheckAlert];
    } else {
        [self disableUserInteraction];
        
        if (self.selectedIndex!= nil && self.selectedIndex.section == 0) {
            self.nextButton.enabled = NO;
        }
        
        // stop current service
        [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
        [[CTBonjourManager sharedInstance] stopServer];
        
        // restart a new service
        [[CTBonjourManager sharedInstance] createServerForController:self];
        
        [self enableUserInteractionWithDelay:1.f];
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
                    // should go cancel
                    CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
                    
                    errorViewController.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, nil);
                    errorViewController.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, nil);
                    errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_GOT_IT, nil);
                    errorViewController.transferStatusAnalytics = CTTransferStatus_Cancelled;
                    
                    [self.navigationController pushViewController:errorViewController animated:NO];
                    return;
                }
                range = [response rangeOfString:kBonjourBadRequest]; // 502, try to connect to a old phone
                if ((range.location != NSNotFound) && (response.length > 0)) { // receiver is a sender
                    
                    if (USES_CUSTOM_VERIZON_ALERTS){
                        [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CT_INVALID_OPERATION_ALERT_TITLE, nil)
                                                                             context:CTLocalizedString(CT_INVALID_OPERATION_ALERT_CONTEXT, nil)
                                                                             btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                             handler:nil
                                                                            isGreedy:NO
                                                                                from:self
                                                                          completion:^(CTVerizonAlertViewController *alertVC){
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
                                                                      handler:nil
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
                        
                        if (USES_CUSTOM_VERIZON_ALERTS){
                            [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                                                 context:CTLocalizedString(CT_INVITATION_REJECTED_ALERT_CONTEXT, nil)
                                                                                 btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                                 handler:nil
                                                                                isGreedy:NO
                                                                                    from:self
                                                                              completion:^(CTVerizonAlertViewController *alertVC){
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
                                                                          handler:nil
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
                    [self.nextButton setUserInteractionEnabled:YES];
                    
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
                                                                 context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil), BUILD_SAME_PLATFORM_MIN_VERSION]
                                                                 btnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil) handler:^(CTVerizonAlertViewController *alertVC) {
                                                                     [[CTBonjourManager sharedInstance] closeStreams];
                                                                     self.versionChecked = NO;
                                                                     self.handler(NEXT_VIEW_SHOULD_POP_ROOT);
                                                                     
                                                                     [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
                                                                 }
                                                                isGreedy:NO from:self];
        }else {
            [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(ALERT_TITLE_VERSION_MISMATCH, nil)
                                                          context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT, nil), BUILD_SAME_PLATFORM_MIN_VERSION]
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
                                                              context:[NSString stringWithFormat:CTLocalizedString(CT_VERSION_MISMATCH_RECEIVER_ALERT_CONTEXT, nil),  versionCheck.supported_version]
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
        }else {
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
    if ([segue.identifier isEqualToString:@"CTSenderWaitingViewController"]) {
        CTSenderWaitingViewController *targetViewController = (CTSenderWaitingViewController *)segue.destinationViewController;
        
        self.handler = ^(int type) {
            if (type == NEXT_VIEW_SHOULD_GO_BACK) {
                [targetViewController senderWaitingViewShouldGoBack];
            } else if (type == NEXT_VIEW_SHOULD_GO_FORWARD) {
                [targetViewController senderWaitingViewShouldGoForward];
            } else if (type == NEXT_VIEW_SHOULD_POP_ROOT) {
                [targetViewController senderWaitingViewShouldPopToRoot];
//            } else if (type == NEXT_VIEW_SHOULD_SHOW_ALERT) {
//                [targetViewController showConnectingDialog];
            } else if (type == NEXT_VIEW_SHOULD_HIDE_ALERT) {
                [targetViewController dismissConnectingDialog];
            }
        };
    }
}

@end
