//
//  CTSummaryViewController.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/29/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTSummaryViewController.h"
#import "CTCustomTableViewCell.h"
#import "CTTransferDetailsViewController.h"
#import "NSString+CTMVMConvenience.h"
#import "UIViewController+Convenience.h"
#import "CTStoryboardHelper.h"
#import "NSNumber+CTHelper.h"
#import "CTDataInfoCell.h"

@interface CTSummaryViewController ()
@property (nonatomic,strong) NSMutableArray *filesTransferredList;
@property (nonatomic,strong) NSNumber *totalDataSize; //Using this when transfer happens successfully

@property (nonatomic, strong) NSIndexPath *targetIndex;

@property (nonatomic, assign) BOOL extraInfoShouldShow;

/*! Total count of failure files. This paramter can be nil.*/
@property (nonatomic, strong) NSArray *transferFailureCounts;
/*! Total size of failure files. This paramter can be nil.*/
@property (nonatomic, strong) NSArray *transferFailureSize;
@end

@implementation CTSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.summaryTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.transferFailureCounts = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"transferFailureCounts"];
    self.transferFailureSize   = (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"transferFailureSize"];
    
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dataLabelTapped)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.dataStatusLabel addGestureRecognizer:tapGestureRecognizer];
    self.dataStatusLabel.userInteractionEnabled = YES;
    [self.speedLabel setHidden:!_extraInfoShouldShow];
    [self.totalTimeLabel setHidden:!_extraInfoShouldShow];
    
    self.title = CTLocalizedString(CT_TRANSFER_SUMMARY_VC_NAV_TITLE, nil);
    if (self.cancelFromTransferWhatPage) { // Cancel from transfer what page.
        self.dataStatusLabel.text = CTLocalizedString(CT_TRANSFER_SUMMARY_DATA_STATUS_LABEL, nil);
    } else if (self.fileList) { // When data transferred successfully sender side
        [self prepareFilesTransferredList];
        long long failureSize = [[[NSUserDefaults standardUserDefaults] objectForKey:@"totalFailureSize"] longLongValue];
        self.dataStatusLabel.text = [self formattedStringWithDataSize:[NSNumber numberWithLongLong:[self.totalDataSentUntillInterrupted longLongValue] - failureSize] andTotalDataSize:self.totalDataSize];
    } else if (self.totalDataAmount && !self.dataInterruptedItemsList) { // transfer successfully receiver side
        NSString *transferredAmnt = [NSString stringWithFormat:@"%.1f", [self.totalDataSentUntillInterrupted doubleValue] - [NSNumber getOnly2Decimal:[NSNumber toMB:[self calculateTotalFailureSize]]]];
        self.dataStatusLabel.text = [NSString stringWithFormat:CTLocalizedString(CT_TRANSFER_SUMMARY_TRANSFERRED_DATA_STATUS_LABEL, nil), transferredAmnt,[NSNumber formattedDataSizeText:self.totalDataAmount]];
    } else if (self.dataInterruptedItemsList) { // Interrupted case
        if ([[CTUserDevice userDevice].deviceType isEqualToString:NEW_DEVICE]) { // receiver
            NSString *transferredAmnt = [NSString stringWithFormat:@"%.1f", [self.totalDataSentUntillInterrupted doubleValue] - [NSNumber toMB:[self calculateTotalFailureSize]]];
            self.dataStatusLabel.text = [NSString stringWithFormat:CTLocalizedString(CT_TRANSFER_SUMMARY_TRANSFERRED_DATA_STATUS_LABEL, nil),transferredAmnt,[NSNumber formattedDataSizeText:self.totalDataAmount]];
        } else { // sender
            long long failureSize = [[[NSUserDefaults standardUserDefaults] objectForKey:@"totalFailureSize"] longLongValue];
            self.dataStatusLabel.text = [self formattedStringWithDataSize:[NSNumber numberWithLongLong:[self.totalDataSentUntillInterrupted longLongValue] - failureSize] andTotalDataSize:self.totalDataAmount];
        }
    } else {
        [self.dataStatusLabel setHidden:YES];
    }
    
#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
#endif
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod] && self.transferFlow == CTTransferFlow_Sender)    {
        self.infomationLabel.hidden = NO;
        self.infomationLabel.text = CTLocalizedString(CT_TRANSFER_SUMMARY_INFO_LABEL, nil);
    } else {
        self.infomationLabel.hidden = YES;
        self.infomationLabel.text = @"";
    }
    [self.infomationLabel layoutIfNeeded];
}
/*!
    @brief Calculate the total size of all failure files.
    @return Long long value represents the size in Bytes.
 */
- (long long)calculateTotalFailureSize {
    long long totalFailureSize = 0;
    if (self.transferFailureSize) {
        for (NSNumber *size in self.transferFailureSize) { // zero item should be fine
            totalFailureSize += [size longLongValue];
        }
    }
    
    return totalFailureSize;
}
/*! 
    @brief Get the failure count for section.
    @param key NSString value represents the type of the file.
    @return NSInteger value represents the failure count;
 */
- (NSInteger)getFailedCountFor:(NSString *)key {
    if (!self.transferFailureCounts || self.transferFailureCounts.count <= 0) {
        return 0;
    }
    if ([key isEqualToString:@"Contacts"]) {
        return [self.transferFailureCounts[0] integerValue];
    } else if ([key isEqualToString:@"Calendars"]) {
        return [self.transferFailureCounts[1] integerValue];
    } else if ([key isEqualToString:@"Reminders"]) {
        return [self.transferFailureCounts[2] integerValue];
    } else if ([key isEqualToString:@"Photos"]) {
        return [self.transferFailureCounts[3] integerValue];
    } else if ([key isEqualToString:@"Videos"]) {
        return [self.transferFailureCounts[4] integerValue];
    } else { // "Apps" is the key
        return [self.transferFailureCounts[5] integerValue];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dataLabelTapped{
    if (self.transferSpeed && self.totalTimeTaken) {
        _extraInfoShouldShow = !_extraInfoShouldShow;
        self.speedLabel.text = [NSString stringWithFormat:CTLocalizedString(CT_TRANSFER_SUMMARY_SPEED_INFO_LABEL, nil), self.transferSpeed];
        self.totalTimeLabel.text = [NSString stringWithFormat:CTLocalizedString(CT_TRANSFER_SUMMARY_TOTAL_TIME_LABEL, nil), [self timeFormatted:self.totalTimeTaken]];
        [self.speedLabel setHidden:!_extraInfoShouldShow];
        [self.totalTimeLabel setHidden:!_extraInfoShouldShow];
    } else { // For not enough storage error
        [self.speedLabel setHidden:YES];
        [self.totalTimeLabel setHidden:YES];
    }
}

- (NSString *)timeFormatted:(NSString *)totalTimeTaken {
    NSInteger totalTime = [totalTimeTaken integerValue];
    NSInteger hh = totalTime / (60 * 60);
    NSInteger mm = totalTime / 60 - (hh * 60);
    NSInteger ss = totalTime - (hh * 60 * 60) - (mm * 60);
    
    NSString *timeFormatted = @"";
    if (hh > 0) {
        timeFormatted = [timeFormatted stringByAppendingString:[NSString stringWithFormat:CTLocalizedString(CT_LOCALIZED_HRS_FORMAT, nil), (long)hh]];
    }
    
    if (mm > 0) {
        if (timeFormatted.length > 0) {
            timeFormatted = [timeFormatted stringByAppendingString:@" "];
        }
        timeFormatted = [timeFormatted stringByAppendingString:[NSString stringWithFormat:CTLocalizedString(CT_LOCALIZED_MIN_FORMAT, nil), (long)mm]];
    }
    
    if (ss > 0) {
        if (timeFormatted.length > 0) {
            timeFormatted = [timeFormatted stringByAppendingString:@" "];
        }
        timeFormatted = [timeFormatted stringByAppendingString:[NSString stringWithFormat:CTLocalizedString(CT_LOCALIZED_SEC_FORMAT, nil), (long)ss]];
    }
    
    if (timeFormatted.length == 0) {
        timeFormatted = CTLocalizedString(CT_LOCALIZED_1SEC_FORMAT, nil);
    }
    
    return timeFormatted;
}

- (void)prepareFilesTransferredList{
    
    self.filesTransferredList = [NSMutableArray new];
    __block long long totalData = 0;
    [self.fileList.selectItemList enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSDictionary *eachDataType = (NSDictionary*)obj;
        BOOL status = [[eachDataType objectForKey:@"status"] boolValue];
        if (status) {
            NSMutableDictionary *eachDict = [NSMutableDictionary new];
            [eachDict setValue:[eachDataType objectForKey:@"totalCount"] forKey:key];
            totalData+=[[eachDataType objectForKey:@"totalSize"] longLongValue];
            [self.filesTransferredList addObject:eachDict];
        }
        
    }];
    
    self.totalDataSize = [NSNumber numberWithLongLong:totalData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.destinationViewController isKindOfClass:[CTTransferDetailsViewController class]]) {
        
        CTTransferDetailsViewController *transferDetailsViewController = (CTTransferDetailsViewController *)segue.destinationViewController;
        [self prepareDetailPage:transferDetailsViewController];
    }
}

- (void)prepareDetailPage:(CTTransferDetailsViewController *)targetViewController {

    CTDataInfoCell *cell = (CTDataInfoCell *)[self.summaryTableView cellForRowAtIndexPath:self.targetIndex];
    
    NSArray *localList = nil;
    if (self.dataInterruptedItemsList) {
        localList = self.dataInterruptedItemsList;
    } else {
        localList = self.savedItemsList;
    }
    
    NSDictionary *targetDic = [localList objectAtIndex:self.targetIndex.row];
    if ([CTUserDefaults sharedInstance].hasPhotoPermissionError && [targetDic objectForKey:@"Photos"]) {
        targetViewController.dataTransferStatus = CTDataTransferStatus_Permission_Photo;
    } else if ([CTUserDefaults sharedInstance].hasPhotoPermissionError && [targetDic objectForKey:@"Videos"]) {
        targetViewController.dataTransferStatus = CTDataTransferStatus_Permission_Video;
    } else if ([CTUserDefaults sharedInstance].hasCalendarPermissionError && [targetDic objectForKey:@"Calendars"]) {
        targetViewController.dataTransferStatus = CTDataTransferStatus_Permission_Calendar;
    } else if ([CTUserDefaults sharedInstance].hasReminderPermissionError && [targetDic objectForKey:@"Reminders"]) {
        targetViewController.dataTransferStatus = CTDataTransferStatus_Permission_Reminder;
    } else if ([CTUserDefaults sharedInstance].hasVcardPermissionError && [targetDic objectForKey:@"Contacts"]) {
        targetViewController.dataTransferStatus = CTDataTransferStatus_Permission_Vcard;
    } else {
        if (cell.isTransferError) {
            targetViewController.dataTransferStatus = CTDataTransferStatus_Warning;
            if ([targetDic objectForKey:@"Photos"]) {
                targetViewController.targetFailedList = self.photoFailedList;
            } else if ([targetDic objectForKey:@"Videos"]) {
                targetViewController.targetFailedList = self.videoFailedList;
            }
        } else {
            targetViewController.dataTransferStatus = CTDataTransferStatus_Ok;
        }
    }
    
    if ([targetDic objectForKey:@"Photos"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"hasCloudPhotos"]) {
        targetViewController.shouldShowCloudInfo = YES;
        targetViewController.cloudType = 0;
    } else if([targetDic objectForKey:@"Videos"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"hasCloudVideos"]) {
        targetViewController.shouldShowCloudInfo = YES;
        targetViewController.cloudType = 1;
    }
}


//REVIEW : Change it to NSNumber if possible
- (NSString *)formattedStringWithTransferredCount:(NSInteger)transferredCount
                                    andTotalCount:(NSInteger)totalCount {
    return [NSString stringWithFormat:CTLocalizedString(CT_TRANSFERRED_OF_TOTAL_LABEL_LONG, nil),(long)transferredCount,(long)totalCount];
}
- (NSString *)formattedStringWithDataSize:(NSNumber*)transferredData
                                    andTotalDataSize:(NSNumber*)totalData {
    
    return [NSString stringWithFormat:CTLocalizedString(CT_TRANSFER_SUMMARY_LABEL, nil), [NSString formattedDataSizeText:[transferredData longLongValue]],[NSString formattedDataSizeText:[totalData longLongValue]]];
}

#pragma UITableView datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.summaryTableView.frame.size.height / (CGFloat)CTTransferItemsTableBreakDown_Total;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[CTUserDevice userDevice].deviceType isEqualToString:OLD_DEVICE]) {
        if (self.dataInterruptedItemsList) {
            return [self.dataInterruptedItemsList count];
        }
        return [self.filesTransferredList count];

    }else{
        if (self.dataInterruptedItemsList) {
            return [self.dataInterruptedItemsList count];
        }

        return [self.savedItemsList count];
    }

}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod] && self.transferFlow == CTTransferFlow_Sender)
//    {
//        CTRomanFontLabel * headerView = [[CTRomanFontLabel alloc] initWithFrame:CGRectZero];
//        
//        headerView.textAlignment = NSTextAlignmentCenter;
//        headerView.numberOfLines = 0;
//        headerView.font = [UIFont systemFontOfSize:13];
//        
//        headerView.text = @".Mov and .PNG files may not be viewed by Android Gallery, please download app that can support .Mov and .PNG to verify.";
//        
//        [headerView sizeToFit];
//        return headerView;
//    }
//    
//    return nil;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CTDataInfoCell *cell = (CTDataInfoCell *)[tableView
                                              dequeueReusableCellWithIdentifier:NSStringFromClass([CTDataInfoCell class])
                                              forIndexPath:indexPath];
    
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        cell.customerSeparator.hidden = NO;
    } else {
        cell.customerSeparator.hidden = NO;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0")) { // fix label size issue on iOS 8
        cell.dataInfoLabel.font = [CTMVMFonts mvmBookFontOfSize:13.f];
    }
    
    //Have to improve this logic when have time
    if ([[CTUserDevice userDevice].deviceType isEqualToString:OLD_DEVICE]) {
        
        NSDictionary *tempDict = [self.dataInterruptedItemsList objectAtIndex:indexPath.row];
        for (id key in tempDict) {
            cell.dataLabel.text = [NSString stringWithFormat:@"%@",CTLocalizedString(key, nil)];
            NSDictionary *detailDict = [tempDict objectForKey:key];
            
            NSInteger successTransferred = [[detailDict objectForKey:@"successTransferred"] integerValue];
            
            NSInteger totalSelected = [[detailDict objectForKey:@"totalSelected"] integerValue];
            
            if (([key isEqualToString:@"Contacts"] || [key isEqualToString:@"Reminders"]) && successTransferred == 1) {
                successTransferred = totalSelected;
            }
            
            if (totalSelected == successTransferred) {
                if ([key isEqualToString:@"Photos"] && [CTUserDefaults sharedInstance].errorLivePhotoList.count > 0) {
                    // Some of the live photo saved as plain photo.
                    cell.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"yellowExclaimation"];
                    cell.isTransferError = YES;
                } else {
                    cell.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"greenCheck"];
                    cell.isTransferError = NO;
                }
            }else{
                cell.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"yellowExclaimation"];
                cell.isTransferError = YES;
            }
            cell.dataInfoLabel.text = [self formattedStringWithTransferredCount:successTransferred andTotalCount:totalSelected];
        }
    } else if (self.savedItemsList) { // Receiver side on successfull Transfer
        NSDictionary *tempDict1 = [self.savedItemsList objectAtIndex:indexPath.row];
        for (id key in tempDict1) {
            // Get failure count
            NSInteger failureCount = [self getFailedCountFor:key];
            
            NSDictionary *tempDict = [tempDict1 objectForKey:key];
            cell.dataLabel.text = [key isEqualToString:@"Apps"] ? CTLocalizedString(CT_APPS_LIST, nil) : [NSString stringWithFormat:@"%@",CTLocalizedString(key, nil)];
            
            if (([[tempDict objectForKey:@"Status"] boolValue] && failureCount == 0)
                || [key isEqualToString:@"Apps"]) { // if it's app list section, or other sections without error, show check mark
                if ([key isEqualToString:@"Photos"] && [CTUserDefaults sharedInstance].errorLivePhotoList.count > 0) {
                    // Some of the live photo saved as plain photo.
                    cell.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"yellowExclaimation"];
                    cell.isTransferError = YES;
                } else {
                    cell.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"greenCheck"];
                    cell.isTransferError = NO;
                }
                
                if (![key isEqualToString:@"Apps"]) { // only show numbers for non-app sections
                    cell.dataInfoLabel.hidden = NO;
                    NSInteger fileCount = [[tempDict objectForKey:@"ReceivedNumber"] integerValue];
                    cell.dataInfoLabel.text = [self formattedStringWithTransferredCount:fileCount andTotalCount:fileCount];
                } else {
                    cell.dataInfoLabel.hidden = YES;
                }
            } else {
                cell.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"yellowExclaimation"];
                NSInteger failedfileCount = [[tempDict objectForKey:@"FailedNumber"] integerValue] + failureCount;
                NSInteger fileCount = [[tempDict objectForKey:@"ReceivedNumber"] integerValue];
                
                cell.dataInfoLabel.text = [self formattedStringWithTransferredCount:fileCount-failedfileCount andTotalCount:fileCount];
                cell.isTransferError = YES;
            }
        }
    } else if (self.dataInterruptedItemsList) {
        NSDictionary *tempDict1 = [self.dataInterruptedItemsList objectAtIndex:indexPath.row];
        for (id key in tempDict1) {
            // Get failure count
            NSInteger failureCount = [self getFailedCountFor:key];
            
            NSDictionary *tempDict = [tempDict1 objectForKey:key];
            
            NSInteger failedfileCount = [[tempDict objectForKey:@"FailedNumber"] integerValue] + failureCount;
            NSInteger fileCount = [[tempDict objectForKey:@"ReceivedNumber"] integerValue];
            
            cell.dataLabel.text = [NSString stringWithFormat:@"%@",key];
            
            if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod])
            {
                if (([key isEqualToString:@"Photos"] || [key isEqualToString:@"Videos"])){
                    
                }
            }

            
            if ([[tempDict objectForKey:@"Status"] boolValue] && failedfileCount == 0 && fileCount != 0) {
                cell.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"greenCheck"];
                cell.dataInfoLabel.text = [self formattedStringWithTransferredCount:fileCount - failedfileCount andTotalCount:fileCount];
                cell.isTransferError = NO;
            } else {
                cell.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"yellowExclaimation"];
                
                cell.dataInfoLabel.text = [self formattedStringWithTransferredCount:fileCount - failedfileCount andTotalCount:fileCount];
                cell.isTransferError = YES;
            }
        }
    }
    
    return cell;
}

#pragma UITableView delegate
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 0;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.targetIndex = indexPath;
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
         CTTransferDetailsViewController *transferDetailsViewController = [CTTransferDetailsViewController initialiseFromStoryboard:[CTStoryboardHelper transferStoryboard]];
        [self prepareDetailPage:transferDetailsViewController];
        [self.navigationController pushViewController:transferDetailsViewController animated:YES];
    } else {
        [self performSegueWithIdentifier:NSStringFromClass([CTTransferDetailsViewController class])
                                  sender:self];
    }
}

#pragma doneButtonTapped:
- (IBAction)handleDoneButtonTapped:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

@end
