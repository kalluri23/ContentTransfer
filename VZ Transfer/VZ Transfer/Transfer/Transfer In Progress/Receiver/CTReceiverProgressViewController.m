//
//  CTReceiverProgressViewController.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/17/16.
//  Copyright © 2016 Verizon. All rights reserved.
//
#import "CTReceiverProgressViewController.h"
#import "CTBundle.h"
#import "CTColor.h"
#import "CTProgressViewTableCell.h"
#import "CTTransferInProgressTableCell.h"
#import "CTProgressInfo.h"
#import "CTDataSavingViewController.h"
#import "CTErrorViewController.h"
#import "CTStoryboardHelper.h"
#import "NSNumber+CTHelper.h"
#import "NSString+CTMVMConvenience.h"
#import "NSString+CTHelper.h"
#import "CTDeviceMarco.h"
#import "CTAlertCreateFactory.h"
#import "CTCustomAlertView.h"
#import "CTLocalAnalysticsManager.h"
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif
typedef void (^AllowSavingHandler)(void);

@interface CTReceiverProgressViewController () <UITableViewDataSource, UITableViewDelegate, CTReceiverProgressManagerDelegate>

@property (atomic, strong) CTProgressInfo *currentProgressInfo;
@property (nonatomic, strong) AllowSavingHandler handler;
@property (nonatomic, strong, nonnull) CTCustomAlertView *connectionAlert;

@property (nonatomic, assign) BOOL allowSaving;
@property (nonatomic,strong) NSDate *startTime;

@property (nonatomic, strong) UILabel *timeLeftLabel;
@property (nonatomic, strong) UILabel *receivedLabel;
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) UILabel *receivingKeyLabel;
@property (nonatomic, strong) UILabel *receivingValueLabel;
@property (nonatomic, strong) CTProgressView *cellProgressView;

@property (atomic, assign) BOOL updateUILock;

@end

@implementation CTReceiverProgressViewController
@synthesize updateUILock;
@synthesize currentProgressInfo;

static CGFloat kProgressViewTableCellHeight_iPhone = 102.0f;
static CGFloat kDefaultTableViewCellheight_iPhone = 67.0f;
static CGFloat kProgressViewTableCellHeight_iPad = 110.0f;
static CGFloat kDefaultTableViewCellheight_iPad = 80.0f;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.transferInProgressTableView
     registerNib:[UINib nibWithNibName:NSStringFromClass([CTTransferInProgressTableCell class])
                                bundle:[CTBundle resourceBundle]]
     forCellReuseIdentifier:NSStringFromClass([CTTransferInProgressTableCell class])];
    [self.transferInProgressTableView
     registerNib:[UINib nibWithNibName:NSStringFromClass([CTProgressViewTableCell class])
                                bundle:[CTBundle resourceBundle]]
     forCellReuseIdentifier:NSStringFromClass([CTProgressViewTableCell class])];
    
    [self.cancelButton addTarget:self action:@selector(handleCancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.manager.delegate = self;
    self.startTime = [NSDate date];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitContentTransfer:) name:CT_NOTIFICATION_EXIT_CONTENT_TRANSFER object:nil];
    
    self.currentProgressInfo = [[CTProgressInfo alloc] initWithMediaType:@"file list"];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CT_NOTIFICATION_EXIT_CONTENT_TRANSFER object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma UITableView datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (IS_IPAD) {
        if (indexPath.row == CTTransferInProgressTableBreakDown_CurrentTransferringContent) {
            return kProgressViewTableCellHeight_iPad;
        }
        return kDefaultTableViewCellheight_iPad;
    }else {
        if (indexPath.row == CTTransferInProgressTableBreakDown_CurrentTransferringContent) {
            return kProgressViewTableCellHeight_iPhone;
        }
        
        if ([CTDeviceMarco isiPhone4AndBelow]) {
            return 40.0;
        }else
        {
            return kDefaultTableViewCellheight_iPhone;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CTTransferInProgressTableBreakDown_Total;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case CTTransferInProgressTableBreakDown_TimeLeft: {
            CTTransferInProgressTableCell *cell = (CTTransferInProgressTableCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CTTransferInProgressTableCell class]) forIndexPath:indexPath];
            cell.keyLabel.text = CTLocalizedString(CT_TIME_LEFT, nil);
            self.timeLeftLabel = cell.valueLabel;
            @synchronized(self.currentProgressInfo) {
                if (self.currentProgressInfo.speed.doubleValue > 0) {
                    cell.valueLabel.text = self.currentProgressInfo.timeLeft;
                }
            }
            
            return cell;
        } break;
        case CTTransferInProgressTableBreakDown_TransferredAmount: {
            CTTransferInProgressTableCell *cell = (CTTransferInProgressTableCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CTTransferInProgressTableCell class]) forIndexPath:indexPath];
            cell.keyLabel.text = CTLocalizedString(CT_RECEIVED, nil);
            
            cell.widthOfValueLabel.constant = 180.0;
            
            NSString *totalSize = [NSNumber formattedDataSizeText:self.currentProgressInfo.totalDataAmount];

            NSString *transferredAmnt = [NSString stringWithFormat:@"%.1f", [self.currentProgressInfo.transferredAmount doubleValue]];
            
            self.receivedLabel = cell.valueLabel;
            cell.valueLabel.text = [NSString stringWithFormat:CTLocalizedString(CT_TRANSFERRED_OF_TOTAL_LABEL_STRING, nil),transferredAmnt,totalSize];
            
            return cell;
        } break;
        case CTTransferInProgressTableBreakDown_Speed: {
            CTTransferInProgressTableCell *cell = (CTTransferInProgressTableCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CTTransferInProgressTableCell class]) forIndexPath:indexPath];
            cell.keyLabel.text = CTLocalizedString(CT_SPEED, nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%.1f Mbps",[self.currentProgressInfo.speed doubleValue]];
            self.speedLabel = cell.valueLabel;
            
            return cell;
        } break;
        case CTTransferInProgressTableBreakDown_CurrentTransferringContent: {
            CTProgressViewTableCell *cell = (CTProgressViewTableCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CTProgressViewTableCell class]) forIndexPath:indexPath];
            
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
            
            self.receivingKeyLabel = cell.keyLabel;
            cell.keyLabel.text = [NSString stringWithFormat:CTLocalizedString(CT_RECEIVING_AMOUNT, nil), [self.currentProgressInfo.mediaType pluralMediaType]];
            self.receivingValueLabel = cell.valueLabel;
            cell.valueLabel.text = [NSString stringWithFormat:@"%@/%@",self.currentProgressInfo.transferredCount,self.currentProgressInfo.totalFileCount];
            
            self.cellProgressView = cell.customProgressView;
            if ([self.currentProgressInfo.totalDataAmount floatValue] > 0) {
                cell.customProgressView.progress = [self.currentProgressInfo.transferredAmount floatValue]/([self.currentProgressInfo.totalDataAmount floatValue]/(1024 * 1024));
            } else {
                cell.customProgressView.progress = 0;
            }
            
            
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
//        NSLog(@"%@", self.currentProgressInfo);
    
        if (!self.updateUILock) { // Didn't lock
            self.updateUILock = YES;
//            NSLog(@"->Should update UI using latest progress info.");
            __block CTProgressInfo *newProgressObject = [progressInfo copy]; // Copy a new object
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.transferInProgressTableView.delegate) {
                    self.transferInProgressTableView.dataSource = self;
                    self.transferInProgressTableView.delegate = self;
                    
                    [self.transferInProgressTableView reloadData];
                    @synchronized (self) {
                        self.updateUILock = NO;
                        //                        NSLog(@"->unlock the UI from reload data. Could be able to update for next package.");
                    }
                } else {
                    [self reloadNecessaryInformation:newProgressObject];
                    newProgressObject = nil;
                    
                    @synchronized (self) {
                        self.updateUILock = NO;
                        //                        NSLog(@"->unlock the UI from update data. Could be able to update for next package.");
                    }
                }
            });
        } else { // Locked, only update current package
            NSLog(@"->Locked. Only update progress.");
        }
    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//    });
//    @synchronized (self) {
//        if (!self.updateUILock) {
//            self.updateUILock = YES;
//            NSLog(@"->Should update UI using latest progress info.");
//            __block CTProgressInfo *newProgressObject = [progressInfo copy]; // Copy a new object
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (!self.transferInProgressTableView.delegate) {
//                    self.transferInProgressTableView.dataSource = self;
//                    self.transferInProgressTableView.delegate = self;
//                    [self.transferInProgressTableView reloadData];
//                } else {
//                    [self reloadNecessaryInformation:newProgressObject];
//
//                }
//            });
//        }
//    }
//    self.currentProgressInfo = progressInfo;
//    NSLog(@"%@", self.currentProgressInfo);
    
}

- (void)reloadNecessaryInformation:(CTProgressInfo *)localProgressInfo {
//    NSLog(@"==================start updating=================");
//    NSLog(@"time: %@", localProgressInfo.timeLeft);
    self.timeLeftLabel.text = localProgressInfo.timeLeft;
    
    NSString *totalSize = [NSNumber formattedDataSizeText:localProgressInfo.totalDataAmount];
    NSString *transferredAmnt = [NSString stringWithFormat:@"%.1f", [localProgressInfo.transferredAmount doubleValue]];
//    NSLog(@"received: %@", [NSString stringWithFormat:@"%@ of %@",transferredAmnt,totalSize]);
    self.receivedLabel.text = [NSString stringWithFormat:@"%@ of %@",transferredAmnt,totalSize];
    
//    NSLog(@"speed: %@", [NSString stringWithFormat:@"%.1f Mbps",[localProgressInfo.speed doubleValue]]);
    self.speedLabel.text = [NSString stringWithFormat:@"%.1f Mbps",[localProgressInfo.speed doubleValue]];
    
//    NSLog(@"Receiving: %@", [NSString stringWithFormat:@"%@/%@",localProgressInfo.transferredCount,localProgressInfo.totalFileCount]);
    self.receivingKeyLabel.text = [NSString stringWithFormat:CTLocalizedString(CT_RECEIVING_AMOUNT, nil), [localProgressInfo.mediaType pluralMediaType]];
    self.receivingValueLabel.text = [NSString stringWithFormat:@"%@/%@",localProgressInfo.transferredCount,localProgressInfo.totalFileCount];
    
    if ([localProgressInfo.totalDataAmount floatValue] > 0) {
//        NSLog(@"Percentage: %f", [localProgressInfo.transferredAmount floatValue] / ([localProgressInfo.totalDataAmount floatValue] / (1024 * 1024)));
        self.cellProgressView.progress = [localProgressInfo.transferredAmount floatValue] / ([localProgressInfo.totalDataAmount floatValue] / (1024 * 1024));
    }
    
//    NSLog(@"==================end updating=================");
}

- (void)didGetErrorLowSpaceForAmount:(NSNumber *)amountOfData {
    CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
    
    errorViewController.primaryErrorText = CTLocalizedString(CT_NO_STORAGE_TITLE, nil);
    errorViewController.secondaryErrorText = CTLocalizedString(CT_NO_STORAGE_TEXT, nil);
    errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_GOT_IT, nil);
    errorViewController.transferStatusAnalytics = CTTransferStatus_Insufficient_Storage;
    
    [self.manager removeObeserver];
    [self.navigationController pushViewController:errorViewController animated:NO];
}

- (void)viewShouldGotoSavingView {
    DebugLog(@"received go to next view signal");
    dispatch_async(dispatch_get_main_queue(), ^{
        CTDataSavingViewController *dataSavingViewController = [[CTDataSavingViewController alloc] initWithNibName:NSStringFromClass([CTTransferInProgressViewController class]) bundle:[CTBundle resourceBundle]];
        self.handler = ^ {
            [dataSavingViewController allowToSaveUnsavedData];
        };
        dataSavingViewController.transferFlow = CTTransferFlow_Receiver;
        dataSavingViewController.allowSave = self.allowSaving;
        dataSavingViewController.fileList = self.manager.fileList;
        
        NSString *speedStr = @"";
        if (self.currentProgressInfo) {
            double speed = [self.currentProgressInfo.generalAvgSpeed doubleValue];
            if (speed >= 0 && speed < 1) {
                speed = 1;
            }
            speedStr = [NSString stringWithFormat:@"%.1f Mbps", speed];
        } else {
            speedStr = @"0 Mbps";
        }
        dataSavingViewController.transferSpeed = speedStr;
        
        NSDate *stopTime = [NSDate date];
        NSTimeInterval timeTaken = [stopTime timeIntervalSinceDate:self.startTime];
        dataSavingViewController.transferTime = [NSString stringWithFormat:@"%f",timeTaken];
        
        dataSavingViewController.totalDataAmount = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_TOTAL_PAYLOAD];
        DebugLog(@"pass total size:%lld", [dataSavingViewController.totalDataAmount longLongValue]);
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_TOTAL_PAYLOAD]; // remove totalplayload each time receiver side to go saving page
        
        dataSavingViewController.transferredDataAmount = self.currentProgressInfo ? self.currentProgressInfo.transferredAmount : [NSNumber numberWithInteger:0];
        
        // Newly added for failure handshake
        if (self.currentProgressInfo){
            [[NSUserDefaults standardUserDefaults] setObject:self.currentProgressInfo.transferFailureCounts forKey:@"transferFailureCounts"];
            [[NSUserDefaults standardUserDefaults] setObject:self.currentProgressInfo.transferFailureSize forKey:@"transferFailureSize"];
        }
        
        [self.manager removeObeserver];
        
        [self.navigationController pushViewController:dataSavingViewController animated:YES];
        
        [self cleanupSocketConnectionOnUserCancelRequest];
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
        
        [self.manager removeObeserver];
        [self.navigationController pushViewController:errorViewController animated:YES];
    });
}

- (void)viewShouldAllowSavingProcess {
    DebugLog(@"received allow saving signal");
    self.allowSaving = YES;
    if (self.handler) {
        self.handler();
    }
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
                                                                         [self viewShouldGotoSavingView];
                                                                     }
                                                                    isGreedy:YES from:self];
            } else {
                [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(CTAlertGeneralTitle, nil)
                                                              context:CTLocalizedString(CT_LAST_TRANSFER_FAILED_ALERT_CONTEXT, nil)
                                                              btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                              handler:^(UIAlertAction *action) {
                                                                  [self viewShouldGotoSavingView];
                                                              }
                                                             isGreedy:YES];
            }
        }];
    }
}

#pragma mark to close sockets 

- (void)cleanupSocketConnectionOnUserCancelRequest{

    [self.manager.p2pManager cleanupSocketConnectionOnUserCancelRequest];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.manager.p2pManager cleanUpAllSocketConnection];
}

#pragma mark - Cancel Action
- (void)handleCancelButtonTapped:(UIButton *)sender {
    [CTUserDevice userDevice].transferStatus = CTTransferStatus_Cancelled;
    __weak typeof(self) weakSelf = self;
    NSString *message = CTLocalizedString(CT_STOP_TRANSFER_ALERT_CONTEXT, nil);
    if (USES_CUSTOM_VERIZON_ALERTS) {
        [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CT_STOP_TRANSFER_ALERT_TITLE, nil) context:message cancelBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil) confirmBtnText:CTLocalizedString(CT_CONFIRM_ALERT_BUTTON_TITLE, nil) confirmHandler:^(CTVerizonAlertViewController *alertVC){
            [weakSelf.cancelButton setEnabled:NO];
            [weakSelf.cancelButton setAlpha:0.4];
            
            [weakSelf.manager cancelTransfer:CTTransferCancelMode_Cancel];
            [weakSelf viewShouldGotoSavingView];
        } cancelHandler:nil isGreedy:NO from:weakSelf];
    } else {
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralCancelTitle, nil) style:UIAlertActionStyleCancel handler:nil];
        CTMVMAlertAction *confirmAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CT_CONFIRM_ALERT_BUTTON_TITLE, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            [weakSelf.cancelButton setEnabled:NO];
            [weakSelf.cancelButton setAlpha:0.4];
            
            [weakSelf.manager cancelTransfer:CTTransferCancelMode_Cancel];
            [weakSelf viewShouldGotoSavingView];
        }];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(CT_STOP_TRANSFER_ALERT_TITLE, nil) message:message cancelAction:cancelAction otherActions:@[confirmAction] isGreedy:NO];
    }
}

- (void)exitContentTransfer:(NSNotification*)notification {
    
    [self.manager removeObeserver];
    [self.manager mvmCancelTransfer];

    NSString *descMsg = [NSString stringWithFormat:@"MF back button,CT app exit-%@",[self class]];
    
    [[CTLocalAnalysticsManager sharedInstance] localAnalyticsData:@"Transfer Cancelled"
                                              andNumberOfContacts:0
                                                andNumberOfPhotos:0
                                                andNumberOfVideos:0
                                             andNumberOfCalendars:0
                                             andNumberOfReminders:0
                                                  andNumberOfApps:0
                                                andNumberOfAudios:0
                                                  totalDownloaded:0
                                                 totalTimeElapsed:0
                                                     averageSpeed:@""
                                                      description:descMsg];
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
    if ([self viewIfLoaded] && self.view.window) {
        DebugLog(@"Terminate notification received test");
        [self.manager removeObeserver];
        [self.manager cancelTransfer:CTTransferCancelMode_UserForceExit];
    }
}

@end
