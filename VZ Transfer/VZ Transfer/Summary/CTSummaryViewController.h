//
//  CTSummaryViewController.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/29/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTViewController.h"
#import "CTCustomButton.h"
#import "CTFileList.h"

/*!
 Recap page. After user finished transfer and click "Recap" button, this page will be pushed.
 
 This page will show how many kinds of data and how many in each type are expect and actually transferred. Also a hidden section blow subtitle contains avg. speed, transfer time, total size information.
 @note Sender and receiver side on this page should show exactly same information.
 */
@interface CTSummaryViewController : CTViewController

@property (nonatomic, weak) IBOutlet UITableView *summaryTableView;
@property (nonatomic, weak) IBOutlet UILabel *dataStatusLabel;
@property (weak, nonatomic) IBOutlet CTRomanFontLabel *infomationLabel;
@property (nonatomic, weak) IBOutlet CTCommonBlackButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

/*!File list using for transfer.*/
@property (nonatomic, strong) CTFileList *fileList;
/*!List of saved items. Receiver side only.*/
@property (nonatomic, strong) NSArray *savedItemsList;
/*!List of transfered items when interrupt happened.*/
@property (nonatomic, strong) NSArray *dataInterruptedItemsList;
/*!Total size of data transfered when interrupt hanppened.*/
@property (nonatomic, strong) NSNumber *totalDataSentUntillInterrupted;
/*!Total size of data selected by user.*/
@property (nonatomic, strong) NSNumber *totalDataAmount;
/*!Average transfer speed.*/
@property (nonatomic, strong) NSString *transferSpeed;
/*!Total transfer time.*/
@property (nonatomic, strong) NSString *totalTimeTaken;
/*!Bool value indicate that cancel is from transfer what page or during the transfer.*/
@property (nonatomic, assign) BOOL cancelFromTransferWhatPage;
/*!List of photos failed to save.*/
@property (nonatomic, strong) NSArray *photoFailedList;
/*!List of videos failed to save.*/
@property (nonatomic, strong) NSArray *videoFailedList;

@end
