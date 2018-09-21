//
//  CTDataSavingViewController.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/24/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTTransferInProgressViewController.h"
#import "CTCustomLabel.h"
#import "CTFileList.h"

/*!
 Data saving page, showing the progress of import local file system data into certain system app by calling system APIs.
 
 This page will be pushed into navigation stack after transfer finished. But won't start importing immediately, since file writing and receiver and async process.
 
 Page will wait for start importing signal once receiver progress page make sure everything received saved in place.
 
 Saving process is "linear", follow contacts/calendars/reminders/photos/videos order. Progress bar will indicate the general progress for all types.
 */
@interface CTDataSavingViewController : CTTransferInProgressViewController
/*!Bool value indicate that page should start saving progress or wait.*/
@property (nonatomic, assign) BOOL allowSave;
/*!Bool value indicate that page is pushed for receiver cancel or receiver finished.*/
@property (nonatomic, assign) BOOL isCancel;
/*!Speed of transfer.*/
@property (nonatomic, strong) NSString *transferSpeed;
/*!Total time of transfer.*/
@property (nonatomic, strong) NSString *transferTime;
/*!Total data size expect to be transfered, value is long long.*/
@property (nonatomic, strong) NSNumber *totalDataAmount;
/*!Total data size acutally received during the transfer, data is long long.*/
@property (nonatomic, strong) NSNumber *transferredDataAmount;
/*!File list object using for transfer.*/
@property (nonatomic, strong) CTFileList *fileList;
/*! Count of file failure for each of data type.*/
@property (nonatomic, strong) NSArray *transferFailureCounts;
/*! Size of file failure for each of data type.*/
@property (nonatomic, strong) NSArray *transferFailureSize;

/*!Notify the page start saving the data.*/
- (void)allowToSaveUnsavedData;

@end
