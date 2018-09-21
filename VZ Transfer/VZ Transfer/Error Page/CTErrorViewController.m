//
//  CTErrorViewController.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/1/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTErrorViewController.h"
#import "CTStartedViewController.h"
#import "CTSummaryViewController.h"
#import "CTStoryboardHelper.h"
#import "CTLocalAnalysticsManager.h"
#import "NSNumber+CTHelper.h"
#import "NSString+CTHelper.h"
#import "NSString+CTMVMConvenience.h"

@interface CTErrorViewController ()


@end

@implementation CTErrorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //if (self.transferStatusAnalytics) {
        [self prepareLocalAnalyticsData];

    //}
    NSAssert(self.primaryErrorText, @"primaryErrorText can't be nil");
    NSAssert(self.secondaryErrorText, @"secondaryErrorText can't be nil");

    if (self.navigationController) {
        self.title = CTLocalizedString(CT_ERROR_VC_NAV_TITLE, nil);
    }
    
    self.primaryLabel.text = self.primaryErrorText;
    self.secondaryLabel.text = self.secondaryErrorText;
    
    [self.rightButton setTitle:self.rightButtonTitle  forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(handleRightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    if (self.leftButtonTitle) {
        [self.leftButton setTitle:self.leftButtonTitle forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(handleLeftButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    }else {
        self.leftButton.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
    
    [CTUserDefaults sharedInstance].transferFinished = @"YES";
    
    [self alignButtonsInContainer];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.bottomspace) {
       self.bottomSpaceConstraint.constant = 30.0;
    }else {
        self.bottomSpaceConstraint.constant = self.bottomspace;
    }
}

- (void)prepareLocalAnalyticsData {
    // Remove failure number
    [self adjustNumberForAnalytics];
    
    NSString *transferStatus = nil;
    switch (self.transferStatusAnalytics) {
        case CTTransferStatus_Success:
            transferStatus = @"Transfer Success";
            break;
        case CTTransferStatus_Failed:
            transferStatus = @"Transfer Failed";
            break;
        case CTTransferStatus_Interrupted:
            if (![CTUserDefaults sharedInstance].transferStarted) {
                transferStatus = @"Transfer Cancelled - Not Started";
            } else {
                transferStatus = @"Transfer Interrupted";
            }
            
            break;
        case CTTransferStatus_Force_Close:
            transferStatus = @"Transfer Force Closed On Other Side.";
            break;
            
        case CTTransferStatus_Insufficient_Storage:
            transferStatus = @"Transfer Cancelled(Insufficient Storage)";
            break;
        case CTTransferStatus_Cancelled:
            if (![CTUserDefaults sharedInstance].transferStarted) {
                transferStatus = @"Transfer Cancelled - Not Started";
            } else {
                transferStatus = @"Transfer Cancelled";
            }
            break;
        case CTTransferStatus_Battery_Check:
            transferStatus = nil;
            break;
        default:
            transferStatus = nil;
            break;
    }
    
    NSString *dataTransferred = [self adjustSizeForAnalytics];
    
    if (transferStatus != nil) {
        [[CTLocalAnalysticsManager sharedInstance] localAnalyticsData:transferStatus
                                                  andNumberOfContacts:self.numberOfContacts
                                                    andNumberOfPhotos:self.numberOfPhotos
                                                    andNumberOfVideos:self.numberOfVideos
                                                 andNumberOfCalendars:self.numberOfCalendar
                                                 andNumberOfReminders:self.numberOfReminder
                                                      andNumberOfApps:self.numberOfApps
                                                    andNumberOfAudios:self.numberOfAudios
                                                      totalDownloaded:dataTransferred
                                                     totalTimeElapsed:[NSString stringWithFormat:@"%.0f",[self.transferTime floatValue] *1000]
                                                         averageSpeed:self.transferSpeed description:@""];
    }
}
/*!
    @brief Adjust the count for each of data type transferred.
 */
- (void)adjustNumberForAnalytics {
    NSArray *transferFailureCounts = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"transferFailureCounts"];
    if (transferFailureCounts) {
        self.numberOfContacts -= [transferFailureCounts[0] integerValue];
        self.numberOfCalendar -= [transferFailureCounts[1] integerValue];
        self.numberOfReminder -= [transferFailureCounts[2] integerValue];
        self.numberOfPhotos   -= [transferFailureCounts[3] integerValue];
        self.numberOfVideos   -= [transferFailureCounts[4] integerValue];
        self.numberOfApps     -= [transferFailureCounts[5] integerValue];
    }
}
/*!
    @brief Generate size string with measurment.
    @discussion This method will check if there is failure during the transfer, size will reduce the failure size. If no failure, orignal size will be used for calculation.
    @return NSString value represents the total transfer size with MB.
 */
- (NSString *)adjustSizeForAnalytics {
    NSString *transferredAmnt = nil;
    if ([[CTUserDevice userDevice].deviceType isEqualToString:OLD_DEVICE]) { // Sender
        long long failureSize = [[[NSUserDefaults standardUserDefaults] objectForKey:@"totalFailureSize"] longLongValue];
        transferredAmnt = [NSNumber formattedDataSizeText:[NSNumber numberWithLongLong:[[[NSUserDefaults standardUserDefaults] objectForKey:@"NonDuplicateDataSize"] longLongValue] - failureSize]];
    } else {
        NSArray *transferFailureSize = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"transferFailureSize"];
        if (transferFailureSize) { // need to reduce the size
            transferredAmnt = [NSString stringWithFormat:@"%.1f MB", [NSNumber toMB:[[[NSUserDefaults standardUserDefaults] objectForKey:@"NonDuplicateDataSize"] longLongValue] - [self calculateTotalFailureSize:transferFailureSize]]];
        } else { // no need to reduce the size
            transferredAmnt = [NSString stringWithFormat:@"%.1f MB", [NSNumber toMB:[[[NSUserDefaults standardUserDefaults] objectForKey:@"NonDuplicateDataSize"] longLongValue]]];
        }
    }
    
    return transferredAmnt;
}
/*!
    @brief Calculate the total size of all failure files.
    @return Long long value represents the size in Bytes.
 */
- (long long)calculateTotalFailureSize:(NSArray *)transferFailureSize {
    long long totalFailureSize = 0;
    for (NSNumber *size in transferFailureSize) { // zero item should be fine
        totalFailureSize += [size longLongValue];
    }
    
    return totalFailureSize;
}

- (void)alignButtonsInContainer {
    
    if (self.leftButton.hidden == YES) {
        self.trailingConstraint.constant = self.buttonContainer.frame.size.width/2 - self.rightButton.frame.size.width/2;
        [self.buttonContainer layoutIfNeeded];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleRightButtonTapped:(id)sender {
    
    [self popToRootViewController:[CTStartedViewController class]];
}

- (void)handleLeftButtonTapped:(id)sender {
    
    //Only "Recap" button is using this
    CTSummaryViewController *summaryViewController = [CTSummaryViewController initialiseFromStoryboard:[CTStoryboardHelper transferStoryboard]];
    summaryViewController.totalDataSentUntillInterrupted = self.totalDataSentUntillInterrupted;
    summaryViewController.totalDataAmount = self.totalDataAmount;
    
    summaryViewController.dataInterruptedItemsList = self.dataInterruptedItemsList;
    
    summaryViewController.transferSpeed = self.transferSpeed;
    
    summaryViewController.totalTimeTaken = self.transferTime;
    
    summaryViewController.cancelFromTransferWhatPage = self.cancelInTransferWhatPage;
    
    summaryViewController.photoFailedList = self.photoFailedList;
    
    summaryViewController.videoFailedList = self.videoFailedList;
    
    
 
    [self.navigationController pushViewController:summaryViewController animated:YES];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}


@end
