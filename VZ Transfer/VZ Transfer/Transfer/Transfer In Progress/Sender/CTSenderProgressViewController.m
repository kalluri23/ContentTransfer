//
//  CTSenderProgressViewController.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/17/16.
//  Copyright © 2016 Verizon. All rights reserved.
//
#import "CTSenderProgressViewController.h"
#import "CTBundle.h"
#import "CTColor.h"
#import "CTProgressViewTableCell.h"
#import "CTTransferInProgressTableCell.h"
#import "CTProgressInfo.h"
#import "CTTransferFinishViewController.h"
#import "CTStoryboardHelper.h"
#import "CTErrorViewController.h"
#import "NSString+CTMVMConvenience.h"
#import "CTErrorViewController.h"
#import "NSNumber+CTHelper.h"
#import "NSString+CTHelper.h"
#import "CTCustomAlertView.h"
#import "CTAlertCreateFactory.h"
#import "CTLocalAnalysticsManager.h"
#import "CTStartedViewController.h"
#import "CTMVMAlertHandler.h"
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

typedef NS_ENUM(NSInteger, CTSenderTransferInProgressTableBreakDown) {
    CTSenderTransferInProgressTableBreakDown_CurrentTransferringContent,
    CTSenderTransferInProgressTableBreakDown_TransferredAmount,
    CTSenderTransferInProgressTableBreakDown_Speed,
    CTSenderTransferInProgressTableBreakDown_Total
};

@interface CTSenderProgressViewController ()
<UITableViewDataSource,
UITableViewDelegate,
CTSenderProgressManagerDelegate>{
    NSInteger filesCount;//For each mediatype eg:Contacts its always 1
}
@property (nonatomic, strong) NSDate *startTime;
/*! Last package information when sending.*/
@property (atomic, strong) CTProgressInfo *currentProgressInfo;
@property (nonatomic, assign) long long currentSectionSize;

@property (nonatomic, weak) UILabel *sentLbl;
@property (nonatomic, weak) UILabel *speedLbl;
@property (nonatomic, weak) UILabel *sendingTitleLbl;
@property (nonatomic, weak) UILabel *sendingFileCountLbl;

@property (nonatomic, strong, nonnull) CTCustomAlertView *connectionAlert;

@property (nonatomic, assign) double averageSpeed;
@property (nonatomic, copy) NSDate *lastPackageSendingDate;
@property (nonatomic, assign) NSTimeInterval acutalSendingTime;

@end

@implementation CTSenderProgressViewController
@synthesize currentProgressInfo;

static CGFloat kProgressViewTableCellHeight_iPhone = 102.0f;
static CGFloat kDefaultTableViewCellheight_iPhone = 67.0f;
static CGFloat kProgressViewTableCellHeight_iPad = 110.0f;
static CGFloat kDefaultTableViewCellheight_iPad = 80.0f;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.startTime = [NSDate date];
    self.currentProgressInfo = [[CTProgressInfo alloc] initWithMediaType:@"file list"];
    
    filesCount = 1;
    
    self.cancelButton.hidden = YES;
    self.currentSectionSize = 0;
    self.transferInProgressTableView.dataSource = self;
    self.transferInProgressTableView.delegate = self;

    [self.transferInProgressTableView
     registerNib:[UINib nibWithNibName:NSStringFromClass([CTTransferInProgressTableCell class])
                                bundle:[CTBundle resourceBundle]]
     forCellReuseIdentifier:NSStringFromClass([CTTransferInProgressTableCell class])];
    [self.transferInProgressTableView
     registerNib:[UINib nibWithNibName:NSStringFromClass([CTProgressViewTableCell class])
                                bundle:[CTBundle resourceBundle]]
     forCellReuseIdentifier:NSStringFromClass([CTProgressViewTableCell class])];

    self.senderProgressManager = [[CTSenderProgressManager alloc] initWithFileList:self.fileList andSocket:self.readSocket commSocket:self.commSocket andPhotoManager:self.mediaManager andVideoManager:self.mediaManager andDelegate:self];
    
    NSAssert(self.senderProgressManager.receiverProgressManagerDelegate, @"receiverProgressManagerDelegate should've been sent to self");
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitContentTransfer:) name:CT_NOTIFICATION_EXIT_CONTENT_TRANSFER object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
    @brief      This method will calculate the speed for current transfer.
    @discussion Speed will use Mbps. Use 
    @code ((Data in MB)/time) * 8 @endcode
                to get proper speed data.
    @warning    Duplicate file speed will force to 1Mbps; and any speed lower than 1Mbps will consider as 1Mbps.
    @return     double value represents the current transfer speed in Mbps.
 */
- (double)calculateSpeed {
#warning TODO: Need to change the one-to-many part for this.
    if (self.currentProgressInfo.isDuplicate) {
        return 1.0f;
    }
    
    //Following old logic
    long long totalDownloadedData = [self.currentProgressInfo.totalDataAmount longLongValue]; // Not a single file transferred.
    if (totalDownloadedData == 0) {
        return 0;
    }
//    double totalDownloadedDataInMB = totalDownloadedData/(1024.f * 1024.f); // to MBs
    
    NSDate *currentTime = [NSDate date];
    NSTimeInterval secondsBetween = [currentTime timeIntervalSinceDate:self.startTime];;
    if (!self.currentProgressInfo.isDuplicate) { // If it's not duplicate
        if (!self.lastPackageSendingDate) {
            self.acutalSendingTime = secondsBetween;
        } else {
            // Get time diff between current time and the time received last package, and add them all.
            self.acutalSendingTime += [currentTime timeIntervalSinceDate:self.lastPackageSendingDate];
        }
    }
    self.lastPackageSendingDate = currentTime;


    self.averageSpeed = ([self.currentProgressInfo.acutalTransferredAmount longLongValue] / (1024.f * 1024.f)) / (double)self.acutalSendingTime * 8;
    
    return (self.averageSpeed < 1.0f) ? 1.0f : self.averageSpeed;
}

- (NSInteger)calculateFilesCountInMediaType:(NSString*)mediaType{
    
    if ([mediaType isEqualToString:@"contacts"] || [mediaType isEqualToString:@"reminder"]) {
        return 1;
    } else if ([mediaType isEqualToString:@"photos"]) {
        return self.fileList.numberOfPhotos;
    } else if ([mediaType isEqualToString:@"videos"]) {
        return self.fileList.numberOfVideos;
    } else if ([mediaType isEqualToString:@"calendar"]) {
        return self.fileList.numberOfCalendar;
    } else if ([mediaType isEqualToString:@"audios"]) {
        return self.fileList.numberOfAudios;
    }
    
    return 0;
}

#pragma UITableView datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (IS_IPAD) {
        if (indexPath.row == CTSenderTransferInProgressTableBreakDown_CurrentTransferringContent) {
            return kProgressViewTableCellHeight_iPad;
        }
        return kDefaultTableViewCellheight_iPad;
    }else {
        if (indexPath.row == CTSenderTransferInProgressTableBreakDown_CurrentTransferringContent) {
            return kProgressViewTableCellHeight_iPhone;
        }

        if ([CTDeviceMarco isiPhone4AndBelow]) {
            return 40.0;
        } else {
            return kDefaultTableViewCellheight_iPhone;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CTSenderTransferInProgressTableBreakDown_Total;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
            
        case CTSenderTransferInProgressTableBreakDown_TransferredAmount: {
            CTTransferInProgressTableCell *cell = (CTTransferInProgressTableCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CTTransferInProgressTableCell class]) forIndexPath:indexPath];
            cell.keyLabel.text = CTLocalizedString(CT_SENT, nil);
            NSString *totalData = [NSString formattedDataSizeText:self.totalDataSize];
            NSString *transferredAmnt = [NSNumber toMBs:self.currentProgressInfo.totalDataAmount];
            
            cell.widthOfValueLabel.constant = 180.0;

            cell.valueLabel.text = [NSString stringWithFormat:@"%@ of %@",transferredAmnt,totalData];
            self.sentLbl = cell.valueLabel;


            return cell;
        } break;
        case CTSenderTransferInProgressTableBreakDown_Speed: {
            CTTransferInProgressTableCell *cell = (CTTransferInProgressTableCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CTTransferInProgressTableCell class]) forIndexPath:indexPath];
            cell.keyLabel.text = CTLocalizedString(CT_SPEED, nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%.1f Mbps",[self calculateSpeed]];
            self.speedLbl = cell.valueLabel;

            return cell;
        } break;
        case CTSenderTransferInProgressTableBreakDown_CurrentTransferringContent: {
            CTProgressViewTableCell *cell = (CTProgressViewTableCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CTProgressViewTableCell class]) forIndexPath:indexPath];

            [cell setNeedsLayout];
            [cell layoutIfNeeded];
            
            cell.keyLabel.text = [NSString stringWithFormat:CTLocalizedString(CT_SENDING_AMOUNT, nil), [self.currentProgressInfo.mediaType pluralMediaType]];
            self.sendingTitleLbl = cell.keyLabel;
            
            cell.valueLabel.text = [NSString stringWithFormat:@"%@/%lu",self.currentProgressInfo.transferredCount, (long)filesCount];
            self.sendingFileCountLbl = cell.valueLabel;
  
            if (_currentSectionSize <= 0) {
                cell.customProgressView.progress = 0.f;
            } else {
                cell.customProgressView.progress = [self.currentProgressInfo.totalDataAmount floatValue]/self.totalDataSize;
            }
            
            //cell.customProgressView.progress = [self.currentProgressInfo.transferredCount floatValue]/filesCount;

            return cell;
        } break;
            
        default:
            NSAssert(false, @"Unknown type should've been handled, please check implementation");
            break;
    }
    
    NSAssert(false, @"Execution should not reach to this point");
    return nil;
}

#pragma CTReceiverProgressManagerDelegate updateUIWithProgressInfo
- (void)updateUIWithProgressInfo:(CTProgressInfo *)progressInfo {
    @synchronized (self) {
        self.currentProgressInfo = progressInfo;
    }
    DebugLog(@"isDuplicate:%d", self.currentProgressInfo.isDuplicate);
    filesCount = [self calculateFilesCountInMediaType:self.currentProgressInfo.mediaType];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.transferInProgressTableView reloadData];
    });
    
}

- (void)transferDidFinished {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIStoryboard *transferStoryboard = [CTStoryboardHelper transferStoryboard];
        CTTransferFinishViewController *transferFinishViewController = [CTTransferFinishViewController initialiseFromStoryboard:transferStoryboard];
        transferFinishViewController.transferFlow = CTTransferFlow_Sender;
        transferFinishViewController.transferStatusAnalytics = self.senderProgressManager.transferStatusAnalytics;
        transferFinishViewController.fileList = self.fileList;
        transferFinishViewController.dataTransferred = self.currentProgressInfo.totalDataAmount;
        transferFinishViewController.transferSpeed = self.averageSpeed < 1 ? @"1.0 Mbps": [NSString stringWithFormat:@"%.1f Mbps", self.averageSpeed];
        transferFinishViewController.resultItemList = self.senderProgressManager.dataInterruptedList;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:self.senderProgressManager.totalFailureSize] forKey:@"totalFailureSize"];
        
        NSDate *endTime = [NSDate date];
        NSTimeInterval transferTime = [endTime timeIntervalSinceDate:self.startTime];
        transferFinishViewController.transferTime = [NSString stringWithFormat:@"%.02f",transferTime];

        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:transferFinishViewController animated:YES];
            });
        } else {
            [self.navigationController pushViewController:transferFinishViewController animated:YES];
        }
        
        [self.senderProgressManager.p2pManager cleanUpAllSocketConnection];
    });
}

- (void)transferShouldGoToNotEnoughStorage {
    dispatch_async(dispatch_get_main_queue(), ^{
        CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
        
        errorViewController.primaryErrorText = CTLocalizedString(CT_NO_STORAGE_TITLE, nil);
        NSString *warningMessage = CTLocalizedString(CT_NO_STORAGE_TEXT, nil);
        errorViewController.secondaryErrorText = warningMessage;
        errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_GOT_IT, nil);
        errorViewController.transferStatusAnalytics = CTTransferStatus_Insufficient_Storage;
        
        [self.navigationController pushViewController:errorViewController animated:NO];
    });
}

- (void)transferShouldBlockForReconnect:(NSString *)warningText {
    if (!_connectionAlert) {
        _connectionAlert = [[CTCustomAlertView alloc] initCustomAlertViewWithText:warningText withOritation:CTAlertViewOritation_HORIZONTAL];
    }
    
    if (!_connectionAlert.visible) {
        [_connectionAlert show];
    } else {
        [_connectionAlert updateLbelText:warningText oritation:CTAlertViewOritation_HORIZONTAL];
    }
}

- (void)transferShouldEnableForContinue:(BOOL)success {
    if (success) {
        if (_connectionAlert.visible) {
            [_connectionAlert hide:nil];
        }
    } else {
        [_connectionAlert hide:^{
            if (USES_CUSTOM_VERIZON_ALERTS) {
                [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                                     context:CTLocalizedString(CT_LAST_TRANSFER_FAILED_ALERT_CONTEXT, nil)
                                                                     btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                     handler:^(CTVerizonAlertViewController *alertVC) {
                                                                         self.senderProgressManager.transferStatusAnalytics = CTTransferStatus_Interrupted;
                                                                         [self.senderProgressManager updateDataInterruptedList];
                                                                         [self viewShouldGotoInterruptedPage];
                                                                     }
                                                                    isGreedy:YES from:self];
            } else {
                [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                              context:CTLocalizedString(CT_LAST_TRANSFER_FAILED_ALERT_CONTEXT, nil)
                                                              btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                              handler:^(UIAlertAction *action) {
                                                                  self.senderProgressManager.transferStatusAnalytics = CTTransferStatus_Interrupted;
                                                                  [self.senderProgressManager updateDataInterruptedList];
                                                                  [self viewShouldGotoInterruptedPage];
                                                              }
                                                             isGreedy:YES];
            }
        }];
    }
}

- (void)viewShouldGotoInterruptedPage {
    dispatch_async(dispatch_get_main_queue(), ^{
        CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
        
        errorViewController.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, nil);
        errorViewController.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, nil);
        errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_TRY_AGAIN, nil);
        errorViewController.leftButtonTitle = CTLocalizedString(BUTTON_TITLE_RECAP, nil);
        errorViewController.totalDataSentUntillInterrupted = self.currentProgressInfo.totalDataAmount;
        errorViewController.totalDataAmount = [NSNumber numberWithLongLong:self.totalDataSize];
        errorViewController.transferSpeed = self.averageSpeed < 1 ? @"1.0 Mbps": [NSString stringWithFormat:@"%.1f Mbps", self.averageSpeed];
        errorViewController.dataInterruptedItemsList = self.senderProgressManager.dataInterruptedList;
        
        //For local analytics
        [self.senderProgressManager.dataInterruptedList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSDictionary *eachDict = (NSDictionary*)obj;
            [eachDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                //            NSDictionary *tempDict = (NSDictionary*)obj;
                
                if ([key isEqualToString:@"Photos"]) {
                    errorViewController.numberOfPhotos = [[obj objectForKey:@"successTransferred"] integerValue];
                } else if ([key isEqualToString:@"Videos"]){
                    errorViewController.numberOfVideos = [[obj objectForKey:@"successTransferred"] integerValue];
                } else if ([key isEqualToString:@"Contacts"]){
                    errorViewController.numberOfContacts = [[obj objectForKey:@"successTransferred"] integerValue];
                } else if ([key isEqualToString:@"Calendars"]){
                    errorViewController.numberOfCalendar = [[obj objectForKey:@"successTransferred"] integerValue];
                } else if ([key isEqualToString:@"Reminders"]){
                    errorViewController.numberOfReminder = [[obj objectForKey:@"successTransferred"] integerValue];
                } else if ([key isEqualToString:@"Audios"]){
                    errorViewController.numberOfAudios = [[obj objectForKey:@"successTransferred"] integerValue];
                }
            }];
            
        }];
        
        errorViewController.transferStatusAnalytics = self.senderProgressManager.transferStatusAnalytics;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:self.senderProgressManager.totalFailureSize] forKey:@"totalFailureSize"];
        
        NSDate *endTime = [NSDate date];
        NSTimeInterval transferTime = [endTime timeIntervalSinceDate:self.startTime];
        errorViewController.transferTime = [NSString stringWithFormat:@"%.02f",transferTime];
        [self.navigationController pushViewController:errorViewController animated:YES];
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.readSocket.delegate = nil;
    [self.readSocket disconnect];
    self.readSocket= nil;
    [self.senderProgressManager.p2pManager cleanUpAllSocketConnection];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CT_NOTIFICATION_EXIT_CONTENT_TRANSFER object:nil];
}
- (void)transferDidCancelled {
    [self viewShouldGotoInterruptedPage];
}

//- (void)goToRootViewController {
//    [self.navigationController popToRootViewControllerAnimated:[CTStartedViewController class]];
//}

- (void)transferShouldUpdatePayload:(NSUInteger)payload {
    DebugLog(@"should update payload");
    self.currentSectionSize = payload;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.transferInProgressTableView reloadData];
    });
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    if ([self viewIfLoaded] && self.view.window) {
        DebugLog(@"Terminate notification received test");
        [self.senderProgressManager mvmCancelTransfer];
    }
}

- (void)exitContentTransfer:(NSNotification*)notification{
    [self.senderProgressManager mvmCancelTransfer];
    NSString *descMsg = [NSString stringWithFormat:@"MF back button,CT app exit-%@",[self class]];
    
    __block NSInteger numberOfContacts = 0;
    __block NSInteger numberOfPhotos   = 0;
    __block NSInteger numberOfVideos   = 0;
    __block NSInteger numberOfCalendar = 0;
    __block NSInteger numberOfReminder = 0;
    __block NSInteger numberOfAudios   = 0;
    [self.senderProgressManager.dataInterruptedList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *eachDict = (NSDictionary*)obj;
        [eachDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            //            NSDictionary *tempDict = (NSDictionary*)obj;
            
            if ([key isEqualToString:@"Photos"]) {
                numberOfPhotos   = [[obj objectForKey:@"successTransferred"] integerValue];
            } else if ([key isEqualToString:@"Videos"]){
                numberOfVideos   = [[obj objectForKey:@"successTransferred"] integerValue];
            } else if ([key isEqualToString:@"Contacts"]){
                numberOfContacts = [[obj objectForKey:@"successTransferred"] integerValue];
            } else if ([key isEqualToString:@"Calendars"]){
                numberOfCalendar = [[obj objectForKey:@"successTransferred"] integerValue];
            } else if ([key isEqualToString:@"Reminders"]){
                numberOfReminder = [[obj objectForKey:@"successTransferred"] integerValue];
            } else if ([key isEqualToString:@"Audios"]){
                numberOfAudios   = [[obj objectForKey:@"successTransferred"] integerValue];
            }
        }];
    }];

        [[CTLocalAnalysticsManager sharedInstance] localAnalyticsData:@"Transfer Cancelled"
                                                  andNumberOfContacts:numberOfContacts
                                                    andNumberOfPhotos:numberOfPhotos
                                                    andNumberOfVideos:numberOfVideos
                                                 andNumberOfCalendars:numberOfCalendar
                                                 andNumberOfReminders:numberOfReminder
                                                      andNumberOfApps:0
                                                    andNumberOfAudios:numberOfAudios
                                                      totalDownloaded:[NSNumber toMBs:self.currentProgressInfo.acutalTransferredAmount]
                                                     totalTimeElapsed:0
                                                         averageSpeed:[NSString stringWithFormat:@"%.1f Mbps",[self calculateSpeed]]
                                                          description:descMsg];
}
@end
