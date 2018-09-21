//
//  CTReceiverReadyViewController.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/26/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTReceiverReadyViewController.h"
#import "CTDeviceSelectionViewController.h"
#import "CTReceiverProgressViewController.h"
#import "CTErrorViewController.h"
#import "CTStartedViewController.h"
#import "CTReceiverProgressManager.h"
#import "CTStoryboardHelper.h"
#import "CTBundle.h"
//#import "CTStringConstants.h"
#import "CTAlertCreateFactory.h"
#import "CTSettingsUtility.h"
#import "CTBonjourManager.h"
#import "CTLocalAnalysticsManager.h"
#import "CTAlertCreateFactory.h"
#import "CTUserDevice.h"
#import "CTSTMService2.h"
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

@interface CTReceiverReadyViewController () <CTReceiverProgressManagerDelegate, CTSTMServiceDelegate2>
/*!Receiver progress manager*/
@property (nonatomic, strong) CTReceiverProgressManager *manager;

// On-to-Many option
@property (nonatomic, strong) CTSTMRecvProcessor *recvProcessor;

@end

@implementation CTReceiverReadyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2M]) { // This is only indicate one-to-many for iOS to iOS using multipeer connectivity.
        // If this ready view controller is for one-to-many option
        // Start the on-to-many service, then waiting for sender side to transfer content.
        [CTSTMService2 sharedInstance].delegate = self;
        
        // Init recv processor
        self.recvProcessor = [[CTSTMRecvProcessor alloc] init];
        self.recvProcessor.transferService = [CTSTMService2 sharedInstance];
        
        // Publish the service to make the connection happen.
        [[CTSTMService2 sharedInstance] startService:NO serviceType:_serviceName];
    } else {
        self.manager = [[CTReceiverProgressManager alloc] initWithDelegate:self];
        
        if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P]) {
            [self.manager setwriteAsyncSocket:self.writeSocket];
        }
    }
    
#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
#endif

    if (IS_IPAD) {
        self.imageViewRightMargin.constant = 150.0;
        self.imageViewLeftMargin.constant = 150.0;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendTransferCancelDuetoPermissionChange) name:@"BONJOUR_PERMISSION_NOTIFICATION" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitContentTransfer:) name:CT_NOTIFICATION_EXIT_CONTENT_TRANSFER object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BONJOUR_PERMISSION_NOTIFICATION" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CT_NOTIFICATION_EXIT_CONTENT_TRANSFER object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Try to connect commport socket after view controller showed up.
    [self.manager createClientCommportSocket];
}

#pragma mark - Receiver progress delegate
- (void)viewShouldGotoNextView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CTReceiverProgressViewController *receiverProgressViewController = [[CTReceiverProgressViewController alloc] initWithNibName:NSStringFromClass([CTTransferInProgressViewController class]) bundle:[CTBundle resourceBundle]];
        receiverProgressViewController.manager = self.manager;
        [self.navigationController pushViewController:receiverProgressViewController animated:YES];
    });
}

- (void)viewShouldCancel {
    dispatch_async(dispatch_get_main_queue(), ^{
        CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
        
        errorViewController.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, nil);
        errorViewController.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, nil);
        errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_TRY_AGAIN, nil);
        errorViewController.leftButtonTitle = CTLocalizedString(BUTTON_TITLE_RECAP, nil);
        errorViewController.transferStatusAnalytics = CTTransferStatus_Cancelled;
        errorViewController.cancelInTransferWhatPage = YES;
        
        [self.navigationController pushViewController:errorViewController animated:YES];
    });
}

- (void)viewShouldInterrupt { //For transfer failure cases
    dispatch_async(dispatch_get_main_queue(), ^{
        CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
        
        errorViewController.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, nil);
        errorViewController.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, nil);
        errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_TRY_AGAIN, nil);
        errorViewController.leftButtonTitle = CTLocalizedString(BUTTON_TITLE_RECAP, nil);
        errorViewController.transferStatusAnalytics = CTTransferStatus_Interrupted;
        
        [self.navigationController pushViewController:errorViewController animated:YES];
    });
}

// going to root view controller after change permission request
- (void)goToRootViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self popToRootViewController:[CTStartedViewController class]];
    });
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    if (self.navigationController.topViewController == self) {
        DebugLog(@"Terminate notification received test");
        [self.manager cancelTransfer:CTTransferCancelMode_UserForceExit];
    }
}

- (void)sendTransferCancelDuetoPermissionChange {
    [self popToRootViewController:[CTStartedViewController class]];
    if ([[CTUserDevice userDevice].pairingType isEqualToString:kBonjour]) {
        [self.manager receiverPermissionCancelRequestForBonjour];
    }
}

-(void)exitContentTransfer:(NSNotification*)notification{
    
    NSString *descMsg = [NSString stringWithFormat:@"MF back button,CT app exit-%@",[self class]];
    [[CTLocalAnalysticsManager sharedInstance] localAnalyticsData:@"Transfer Cancelled - Not Started"
                                              andNumberOfContacts:0
                                                andNumberOfPhotos:0
                                                andNumberOfVideos:0
                                             andNumberOfCalendars:0
                                             andNumberOfReminders:0
                                                  andNumberOfApps:0
                                                andNumberOfAudios:0
                                                  totalDownloaded:0
                                                 totalTimeElapsed:0
                                                     averageSpeed:0 description:descMsg];
    [self.manager cancelTransfer:CTTransferCancelMode_Cancel];
}

- (void)tansferFailedBeforeStarted {
    if (USES_CUSTOM_VERIZON_ALERTS) {
        [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                             context:CTLocalizedString(CT_TRANSFER_FAILED_ALERT_CONTEXT, nil)
                                                             btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                             handler:^(CTVerizonAlertViewController *alertVC) {
                                                                 [self viewShouldInterruptWithFailed];
                                                             }
                                                            isGreedy:YES from:self];
    } else {
        [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                      context:CTLocalizedString(CT_TRANSFER_FAILED_ALERT_CONTEXT, nil)
                                                      btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                      handler:^(UIAlertAction *action) {
                                                          [self viewShouldInterruptWithFailed];
                                                      }
                                                     isGreedy:YES];
    }
}

- (void)viewShouldInterruptWithFailed { //For transfer failure cases
    dispatch_async(dispatch_get_main_queue(), ^{
        CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
        
        errorViewController.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, nil);
        errorViewController.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, nil);
        errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_TRY_AGAIN, nil);
        errorViewController.leftButtonTitle = CTLocalizedString(BUTTON_TITLE_RECAP, nil);
        errorViewController.transferStatusAnalytics = CTTransferStatus_Cancelled;
        
        [self.navigationController pushViewController:errorViewController animated:YES];
    });
}

#pragma mark - CTSTMServiceDelegate2

- (void) startBrowseError:(CTSTMService2 *)service error:(NSError *)error
{
    
}

- (void) startServiceError:(CTSTMService2 *)service error:(NSError *)error
{
    
}


- (void) connectRequest:(NSString *) host confirmation:(void (^)(Boolean success))confirmHandler
{
    confirmHandler(YES);
}

- (void)groupStatusChanged {
    NSLog(@"->Connection status changed. Do nothing?");
}



- (void)recvResourceStart:(NSString *)resourcename {
    NSLog(@"->Start receiving resouces. Should we jump to the next screen?");
}


- (void)recvData:(NSData *)data withPeer:(MCPeerID *)peer {
    
    if (data.length >= CT_SEND_FILE_HOST_HEADER.length) {
        NSData *headerData = [data subdataWithRange:NSMakeRange(0, CT_SEND_FILE_HOST_HEADER.length)];
        NSString *headerStr = [[NSString alloc] initWithData:headerData encoding:NSUTF8StringEncoding];
        if (headerStr.length > 0) {
            if ([headerStr containsString:CT_SEND_FILE_HOST_HEADER]) {
                [[CTSTMService2 sharedInstance] setupHost:peer];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.recvProcessor sendFreeSpaceToHost];
                });
                return;
            }
        }
    }
    
    // Recevied any package besides the host clarification, should go to progress view to do receiving logic
    [self performSelectorOnMainThread:@selector(progressShouldJumpToRecvProgressView) withObject:nil waitUntilDone:NO];
    [self.recvProcessor processDataWithData:data];
}

- (void)progressShouldJumpToRecvProgressView {
    CTSTMRecvViewController *targetViewController = [[CTSTMRecvViewController alloc] initWithNibName:@"CTTransferInProgressViewController" bundle:[CTBundle resourceBundle]];
    targetViewController.recvProcessor = self.recvProcessor;
    
    [self.navigationController pushViewController:targetViewController animated:YES];
}

- (void) recvLostHost
{
    // host lost in here
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
        
        errorViewController.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, nil);
        errorViewController.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, nil);
        errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_TRY_AGAIN, nil);
        errorViewController.leftButtonTitle = CTLocalizedString(BUTTON_TITLE_RECAP, nil);
        errorViewController.transferStatusAnalytics = CTTransferStatus_Cancelled;
        errorViewController.cancelInTransferWhatPage = YES;
        
        [self.navigationController pushViewController:errorViewController animated:YES];
    });
}

//- (void)test2 {
//    [CTAlertCreateFactory showSingleButtonsAlertWithTitle:@"test" context:@"disconnected!" btnText:@"OK" handler:nil isGreedy:NO];
//}

@end
