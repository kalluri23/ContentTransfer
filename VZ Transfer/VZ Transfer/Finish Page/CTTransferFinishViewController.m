//
//  CTTransferFinishViewController.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/22/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTTransferFinishViewController.h"
#import "CTSummaryViewController.h"
#import "CTLocalAnalysticsManager.h"
#import "CTStartedViewController.h"
#import "CTStoryboardHelper.h"
#import "CTSurveyOverlay.h"
#import "CTDeviceMarco.h"
#import "NSNumber+CTHelper.h"
#import "NSString+CTHelper.h"
#import "CTMVMAlertController.h"
#import "CTMVMAlertView.h"
#import "CTSettingsUtility.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "NSNumber+CTHelper.h"
#import "CTAppReviewManager.h"
#import "CTContentTransferSetting.h"

#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

@interface CTTransferFinishViewController() <CTBannerOverlayDelegate>
{
    BOOL bItuneReviewDisplayed;
    /*! Manager class to control the review dialog.*/
    CTAppReviewManager *_reviewManager;
}

@end

//static float kProgress = 1.0;

@implementation CTTransferFinishViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = CTLocalizedString(CT_TRANSFER_FINISH_VC_NAV_TITLE, nil);
//    self.progressView.progress = kProgress;
    
#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
    
    if (self.transferFlow == CTTransferFlow_Receiver) {
        #if USE_BANNER == 1
            [self addBannerOverlay];
        #endif
        
        #if USE_SURVEY_LINK == 1
            [self addSurveyLink];
        #endif
        
        #if USE_BRAND_REFRESH == 1
        [self.cloudBannerView setHidden:NO];
        #endif
    }
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
    
    if (self.transferFlow == CTTransferFlow_Receiver) {
        #if USE_BANNER == 1
            [self addBannerOverlay];
        #endif
        
        #if USE_BRAND_REFRESH == 1
        [self.cloudBannerView setHidden:NO];
        #endif
    }
    
#endif
    
    self.backButton.target = self;
    self.backButton.action = @selector(handleBackButtonTapped:);
    /*!Uncomment below code to support banner overlay*/
//    if (IS_STANDARD_IPHONE_4_OR_LESS) {
//        self.imageTopMargin.constant = 0;
//        self.imageBottomMargin.constant = 0;
//        self.labelBottomMarginConstraint.constant = 10;
//    } else if (IS_STANDARD_IPHONE_6_PLUS == 1 || IS_STANDARD_IPHONE_6 == 1) {
//        self.imageTopMargin.constant = 50.0;
//        self.imageBottomMargin.constant = 50.0;
//    } else if ([CTDeviceMarco isiPhoneX]) {
//        // iPhone X UI adaption
//        self.imageTopMargin.constant = 50.0;
//        self.imageBottomMargin.constant = 50.0;
//        self.labelBottomMarginConstraint.constant *= 5;
//    } else if (IS_IPAD == 1) {
//        self.imageTopMargin.constant = 150.0;
//        self.imageBottomMargin.constant = 150.0;
//    }
    
    [CTUserDefaults sharedInstance].transferFinished = @"YES";
    
    [self prepareLocalAnalyticsData];
    
    _reviewManager = [[CTAppReviewManager alloc] initManagerFor:self.transferFlow withResult:self.transferStatusAnalytics];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceBatteryStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceBatteryLevelDidChangeNotification
                                                  object:nil];
    
    [_reviewManager showReviewDialogIfUserNeedToReviewTheAppForTarget:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Survey link setup
- (void)addSurveyLink {
    CTSurveyOverlay *surveyOverlay = [CTSurveyOverlay customView];
    surveyOverlay.frame = CGRectZero;
    surveyOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0")) { // fix label size issue for iOS 8
        surveyOverlay.surveyHeader.font = [CTMVMFonts mvmBoldFontOfSize:18.0];
        surveyOverlay.surveySubText.font = [CTMVMFonts mvmBoldFontOfSize:12.0];
        surveyOverlay.surveyBody.font = [CTMVMFonts mvmBookFontOfSize:9.0];
    }
    [self.view addSubview:surveyOverlay];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:surveyOverlay
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.primaryMessageLabel
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:surveyOverlay
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:surveyOverlay
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.buttonsContainer
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:surveyOverlay
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:0.0]];
        
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSurveyLinkTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [surveyOverlay.surveyContainer addGestureRecognizer:tapGestureRecognizer];
}

- (void)handleSurveyLinkTapped:(UIGestureRecognizer *)gesture {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kSurveyURL]];
}

#pragma mark - Banner overlay setup
/*!
    @brief Create banner overlay on finish view
 */
- (void)addBannerOverlay {
    CTBannerOverlay *bannerOverlay = [CTBannerOverlay loadBannerView];
    bannerOverlay.delegate = self;
    // Change the banner
    bannerOverlay.showBannerNumber = 1;
    [bannerOverlay assignBanner];
    // Setup the size of overlay
    [bannerOverlay attachOverlay:self.view topTo:self.primaryMessageLabel withSize:0.0 bottomTo:self.buttonsContainer withSize:0.0 leftTo:self.view withSize:0.0 rightTo:self.view withSize:0.0];
}

#pragma mark - CTBannerOverlayDelegate
- (void)bannerDidClicked:(UIButton * _Nonnull)sender {
    [CTSettingsUtility openCloudAppStoreLink];
    [[CTLocalAnalysticsManager sharedInstance] uploadBannerAnalyticsJSONDictionary:[self prepareAnalyticsJSON]];
}


#pragma mark - Local analytics
- (void)prepareLocalAnalyticsData {
    if (self.resultItemList) { // Only have this on sender success case.
        [self prepareFilesTransferredList];
    }
    
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
        default:
            transferStatus = nil;
            break;
    }
    
    if (transferStatus != nil) {
        
        NSString *transferredAmnt = [self adjustSizeForAnalytics];
        
        [[CTLocalAnalysticsManager sharedInstance] localAnalyticsData:transferStatus
                                                  andNumberOfContacts:self.numberOfContacts
                                                    andNumberOfPhotos:self.numberOfPhotos
                                                    andNumberOfVideos:self.numberOfVideos
                                                 andNumberOfCalendars:self.numberOfCalendar
                                                 andNumberOfReminders:self.numberOfReminder
                                                      andNumberOfApps:self.numberOfApps
                                                    andNumberOfAudios:self.numberOfAudios
                                                      totalDownloaded:transferredAmnt
                                                     totalTimeElapsed:[NSString stringWithFormat:@"%.0f",[self.transferTime floatValue] * 1000]
                                                         averageSpeed:self.transferSpeed description:@""];
    }
}


/**
 This function creates JSON dictionary that has to be posted to analytics server

 @return NSMutableDictionary containing key value pairs of analytic tags
 */
- (NSMutableDictionary *)prepareAnalyticsJSON {
    NSMutableDictionary *localDict = [[NSMutableDictionary alloc] init];
    [localDict setValue:[CTUserDevice userDevice].deviceUDID forKey:@"deviceId"];
    [localDict setValue:[CTUserDevice userDevice].globalUDID forKey:@"globalUUID"];
    [localDict setObject:[NSNumber numberWithInt:1] forKey:@"didClickImage"];
    [localDict setObject:@"VZcloud" forKey:@"description"];
    [localDict setObject:BUILD_VERSION forKey:@"buildVersion"];
    return localDict;
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
    if (self.transferFlow == CTTransferFlow_Sender) {
        long long failureSize = [[[NSUserDefaults standardUserDefaults] objectForKey:@"totalFailureSize"] longLongValue];
        transferredAmnt = [NSNumber formattedDataSizeText:[NSNumber numberWithLongLong:[[[NSUserDefaults standardUserDefaults] objectForKey:@"NonDuplicateDataSize"] longLongValue] - failureSize]];
    } else {
//        NSArray *transferFailureSize = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"transferFailureSize"];
//        if (transferFailureSize) { // need to reduce the size
//            transferredAmnt = [NSString stringWithFormat:@"%.1f MB", [NSNumber toMB:[[[NSUserDefaults standardUserDefaults] objectForKey:@"NonDuplicateDataSize"] longLongValue] - [self calculateTotalFailureSize:transferFailureSize]]];
//        } else { // no need to reduce the size
            transferredAmnt = [NSString stringWithFormat:@"%.1f MB", [NSNumber toMB:[[[NSUserDefaults standardUserDefaults] objectForKey:@"NonDuplicateDataSize"] longLongValue]]];
//        }
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

- (void)prepareFilesTransferredList {
    [self.resultItemList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *eachDict = (NSDictionary*)obj;
        [eachDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            //            NSDictionary *tempDict = (NSDictionary*)obj;
            
            if ([key isEqualToString:@"Photos"]) {
                self.numberOfPhotos = [[obj objectForKey:@"successTransferred"] integerValue];
            } else if ([key isEqualToString:@"Videos"]){
                self.numberOfVideos = [[obj objectForKey:@"successTransferred"] integerValue];
            } else if ([key isEqualToString:@"Contacts"]){
                self.numberOfContacts = [[obj objectForKey:@"successTransferred"] integerValue];
            } else if ([key isEqualToString:@"Calendars"]){
                self.numberOfCalendar = [[obj objectForKey:@"successTransferred"] integerValue];
            } else if ([key isEqualToString:@"Reminders"]){
                self.numberOfReminder = [[obj objectForKey:@"successTransferred"] integerValue];
            } else if ([key isEqualToString:@"Audios"]){
                self.numberOfAudios = [[obj objectForKey:@"successTransferred"] integerValue];
            }
        }];
        
    }];
}

#pragma mark - Actions
- (IBAction)handleRecapTapped:(id)sender {
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        if( _bMultiDevices) {
            CTSTMSenderRecapViewController * vc = [[CTSTMSenderRecapViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            CTSummaryViewController *summaryViewController = [CTSummaryViewController initialiseFromStoryboard:[CTStoryboardHelper transferStoryboard]];
        
//            summaryViewController.transferredItemsList = self.transferredItemsList;
            summaryViewController.fileList                       = self.fileList;
            summaryViewController.savedItemsList                 = self.savedItemsList;
            summaryViewController.transferSpeed                  = self.transferSpeed;
            summaryViewController.totalTimeTaken                 = self.transferTime;
            summaryViewController.totalDataAmount                = self.totalDataTransferred;
            summaryViewController.dataInterruptedItemsList       = self.resultItemList;
            summaryViewController.totalDataSentUntillInterrupted = self.dataTransferred;
            summaryViewController.photoFailedList                = self.photoFailedList;
            summaryViewController.videoFailedList                = self.videoFailedList;
            summaryViewController.transferFlow                   = self.transferFlow;
        
            [self.navigationController pushViewController:summaryViewController animated:YES];
        }
    } else {
        if( _bMultiDevices) {
            CTSTMSenderRecapViewController * vc = [[CTSTMSenderRecapViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self performSegueWithIdentifier:NSStringFromClass([CTSummaryViewController class]) sender:nil];
        }
    }
}

- (IBAction)handleDoneTapped:(id)sender {
#if STANDALONE
     [self showLandingScreen];
#else
    [self exitContentTransfer];
#endif
}

- (void)handleBackButtonTapped:(id)sender {
    
#if STANDALONE
    [self showLandingScreen];
#else
    [self exitContentTransfer];
#endif
}

- (IBAction)learnMoreTapped:(UIButton *)sender {
    [CTSettingsUtility openCloudAppStoreLink];
    [[CTLocalAnalysticsManager sharedInstance] uploadBannerAnalyticsJSONDictionary:[self prepareAnalyticsJSON]];
}

- (void)showLandingScreen {
    
    [self popToRootViewController:[CTStartedViewController class]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:NSStringFromClass([CTSummaryViewController class])]) {
        CTSummaryViewController *summaryVC = [segue destinationViewController];
//        summaryVC.transferredItemsList = self.transferredItemsList;
        summaryVC.fileList                       = self.fileList;
        summaryVC.savedItemsList                 = self.savedItemsList;
        summaryVC.transferSpeed                  = self.transferSpeed;
        summaryVC.totalTimeTaken                 = self.transferTime;
        summaryVC.totalDataAmount                = self.totalDataTransferred;
        summaryVC.dataInterruptedItemsList       = self.resultItemList;
        summaryVC.totalDataSentUntillInterrupted = self.dataTransferred;
        summaryVC.photoFailedList                = self.photoFailedList;
        summaryVC.videoFailedList                = self.videoFailedList;
        summaryVC.photoFailedList                = self.photoFailedList;
        summaryVC.videoFailedList                = self.videoFailedList;
        summaryVC.transferFlow                   = self.transferFlow;
    }
 }

- (void)exitContentTransfer {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitContentTransfer" object:self.navigationController];
}

@end
