//
//  CTPhoneCombinationViewController.m
//  contenttransfer
//
//  Created by Development on 8/12/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTBonjourReceiverViewController.h"
#import "CTBonjourSenderViewController.h"
#import "CTCustomTableViewCell.h"
#import "CTPhoneCombinationViewController.h"
#import "CTStoryboardHelper.h"
#import "CTWifiSetupViewController.h"
#import "CTDeviceMarco.h"
#import "CTDataCollectionManager.h"
#import "CTQRCodeViewController.h"
#import "CTSenderScannerViewController.h"
#import "CTContentTransferSetting.h"
#import "CTQRCodeSwitch.h"
#import "CTBundle.h"
#import "CTSingleLabelCheckboxCell.h"

#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

typedef NS_ENUM(NSInteger, CTPhoneSelectionTableBreakDown) {
    CTPhoneSelectionTableBreakDown_iOSToiOS,
    
    CTPhoneSelectionTableBreakDown_iOSToAndroid,

    CTPhoneSelectionTableBreakDown_TotalCells
};

@interface CTPhoneCombinationViewController ()

@property (nonatomic, assign) CTPhoneSelectionTableBreakDown selectedDeviceCombination;

@end

//static float kProgress = .33;

@implementation CTPhoneCombinationViewController

- (void)viewDidLoad {
    
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneCombination;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = CTLocalizedString(CT_DEVICES_STORYBOARD_NAV_TITLE, nil);
//    self.progressView.progress = kProgress;

#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
#endif

    NSAssert(self.transferFlow, @"transferFlow should've been set, please check implementation");
    
#if ALLOW_MULTICONNECT
#warning TODO: Should remove for cross? Will change when adding full one-to-many function.
    if (![CTDeviceMarco isiPhone4AndBelow]) { // Only iPhone 5/iPod 5/iPad 4 and above will support multi-peer connection, like Bonjour transfer
        // Add button, easily to disable the method
        [self.stmButton setHidden:false];
    }else {
        [self.stmButton setHidden:true];
    }
#endif

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([segue.identifier isEqualToString:@"adv_opt_segue"]) {
        CTSTMOpionViewController *targetVC = (CTSTMOpionViewController *)segue.destinationViewController;
        targetVC.transferFlow = self.transferFlow;
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.frame.size.height / (CGFloat)CTPhoneSelectionTableBreakDown_TotalCells;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CTPhoneSelectionTableBreakDown_TotalCells;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CTSingleLabelCheckboxCell *cell =
        (CTSingleLabelCheckboxCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CTSingleLabelCheckboxCell class])
                                                                     forIndexPath:indexPath];

    switch (indexPath.row) {
        case CTPhoneSelectionTableBreakDown_iOSToiOS:
            cell.cellLabel.text = CTLocalizedString(CT_IPHONE_TO_IPHONE, nil);
            break;

        case CTPhoneSelectionTableBreakDown_iOSToAndroid:
            
            if([[CTUserDevice userDevice].deviceType isEqualToString:@"OldDevice"]) {
                cell.cellLabel.text = CTLocalizedString(CT_IPHONE_TO_OTHER, nil);
            }else {
                cell.cellLabel.text = CTLocalizedString(CT_OTHER_TO_IPHONE, nil);
            }
            break;
        default:
            break;
    }

    return (CTSingleLabelCheckboxCell *)cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    CTSingleLabelCheckboxCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell highlightCell:YES];
    
    // TODO : Add logic for selection

    self.selectedDeviceCombination = indexPath.row;
    self.nextButton.enabled = YES;
    
    // Remove this line later - only for testing purpose
    //CFRelease(NULL);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CTSingleLabelCheckboxCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell highlightCell:NO];
}

- (IBAction)unwindBonjourFlow:(UIStoryboardSegue *)segue {
    DebugLog(@"unwindBonjourFlow");
}

- (IBAction)handleNextButtonTapped:(id)sender {

    switch (self.selectedDeviceCombination) {
        case CTPhoneSelectionTableBreakDown_iOSToiOS: {
            
            [[CTUserDevice userDevice] setIsAndroidPlatform:@"FALSE"];
            [CTUserDevice userDevice].phoneCombination = IOS_IOS;
            
            if ([CTDeviceMarco isiPhone4AndBelow]/*|| IS_IPAD == 1*/) {
                if ([[CTQRCodeSwitch uniqueSwitch] isOn]) {
//                    [CTUserDefaults sharedInstance].scanType = CTScanQR;
                    if (self.transferFlow == CTTransferFlow_Sender) {
                        CTSenderScannerViewController *ctBonjourSenderScannerViewController =
                        [CTSenderScannerViewController initialiseFromStoryboard:[CTStoryboardHelper qrCodeAndScannerStoryboard]];
                        ctBonjourSenderScannerViewController.transferFlow = self.transferFlow;
                        [self.navigationController pushViewController:ctBonjourSenderScannerViewController animated:YES];
                    } else {
                        CTQRCodeViewController *ctQRCodeViewController =
                        [CTQRCodeViewController initialiseFromStoryboard:[CTStoryboardHelper qrCodeAndScannerStoryboard]];
                        ctQRCodeViewController.transferFlow = self.transferFlow;
                        [self.navigationController pushViewController:ctQRCodeViewController animated:YES];
                    }
                } else {
//                    [CTUserDefaults sharedInstance].scanType = CTScanManual;
                    CTWifiSetupViewController *wifiSetupViewController =
                    [CTWifiSetupViewController initialiseFromStoryboard:[CTStoryboardHelper wifiAndP2PStoryboard]];
                    
                    if (self.transferFlow == CTTransferFlow_Sender) {
                        wifiSetupViewController.transferFlow = CTTransferFlow_Sender;
                    } else {
                        wifiSetupViewController.transferFlow = CTTransferFlow_Receiver;
                    }
                    
                    [self.navigationController pushViewController:wifiSetupViewController animated:YES];
                }
            } else {
                if ([[CTQRCodeSwitch uniqueSwitch] isOn]) {
//                    [CTUserDefaults sharedInstance].scanType = CTScanQR;
                    if (self.transferFlow == CTTransferFlow_Sender) {
                        CTSenderScannerViewController *ctBonjourSenderScannerViewController =
                        [CTSenderScannerViewController initialiseFromStoryboard:[CTStoryboardHelper qrCodeAndScannerStoryboard]];
                        ctBonjourSenderScannerViewController.transferFlow = self.transferFlow;
                        [self.navigationController pushViewController:ctBonjourSenderScannerViewController animated:YES];
                    } else {
                        CTQRCodeViewController *ctQRCodeViewController =
                        [CTQRCodeViewController initialiseFromStoryboard:[CTStoryboardHelper qrCodeAndScannerStoryboard]];
                        ctQRCodeViewController.transferFlow = self.transferFlow;
                        [self.navigationController pushViewController:ctQRCodeViewController animated:YES];
                    }
                } else {
//                    [CTUserDefaults sharedInstance].scanType = CTScanManual;
                    if (self.transferFlow == CTTransferFlow_Sender) {
                        CTBonjourSenderViewController *bonjourSenderViewController =
                        [CTBonjourSenderViewController initialiseFromStoryboard:[CTStoryboardHelper bonjourStoryboard]];
                        [self.navigationController pushViewController:bonjourSenderViewController animated:YES];
                    } else {
                        CTBonjourReceiverViewController *bonjourReceiverViewController =
                        [CTBonjourReceiverViewController initialiseFromStoryboard:[CTStoryboardHelper bonjourStoryboard]];
                        [self.navigationController pushViewController:bonjourReceiverViewController animated:YES];
                    }
                }
            }
        } break;

        case CTPhoneSelectionTableBreakDown_iOSToAndroid: {
            
            [[CTUserDevice userDevice] setIsAndroidPlatform:@"TRUE"];
            [CTUserDevice userDevice].phoneCombination = IOS_Andriod;
            
            if ([[CTQRCodeSwitch uniqueSwitch] isOn]) { // If allow QR Code, always show camera first
//                [CTUserDefaults sharedInstance].scanType = CTScanQR;
                CTSenderScannerViewController *ctBonjourSenderScannerViewController =
                [CTSenderScannerViewController initialiseFromStoryboard:[CTStoryboardHelper qrCodeAndScannerStoryboard]];
                if (self.transferFlow == CTTransferFlow_Sender) {
                    ctBonjourSenderScannerViewController.transferFlow = CTTransferFlow_Sender;
                } else {
                    ctBonjourSenderScannerViewController.transferFlow = CTTransferFlow_Receiver;
                }
                [self.navigationController pushViewController:ctBonjourSenderScannerViewController animated:YES];
            } else {
//                [CTUserDefaults sharedInstance].scanType = CTScanManual;
                CTWifiSetupViewController *wifiSetupViewController =
                [CTWifiSetupViewController initialiseFromStoryboard:[CTStoryboardHelper wifiAndP2PStoryboard]];
                
                if (self.transferFlow == CTTransferFlow_Sender) {
                    wifiSetupViewController.transferFlow = CTTransferFlow_Sender;
                } else {
                    wifiSetupViewController.transferFlow = CTTransferFlow_Receiver;
                }
                
                [self.navigationController pushViewController:wifiSetupViewController animated:YES];
            }
        } break;
        default:
            break;
    }
    
    if (self.transferFlow == CTTransferFlow_Sender) {
        [self startFetchingAllData];
    }
}

- (IBAction)stmButtonClicked:(UIButton *)sender {
    [self performSegueWithIdentifier:@"adv_opt_segue" sender:self];
    
    if (self.transferFlow == CTTransferFlow_Sender) {
        [self startFetchingAllData];
    }
}

- (void)startFetchingAllData {
    NSString *oldSetting = [CTUserDevice userDevice].lastTransferSetting;
    [CTUserDevice userDevice].lastTransferSetting = [CTUserDevice userDevice].phoneCombination;
    
    if ([[CTUserDefaults sharedInstance].transferFinished isEqualToString:@"YES"]) { // If transfer already finished, should start fetch again.
        [CTUserDefaults sharedInstance].transferFinished = @"NO";
        
        // Only fetch once per transfer.
        [[CTDataCollectionManager sharedManager] initPhotoManagerToCollectData];
        [[CTDataCollectionManager sharedManager] startCollectAllData];
    } else {
        if (!oldSetting || ![oldSetting isEqualToString:[CTUserDevice userDevice].phoneCombination]) { // Not same setting
            // Only fetch once per transfer.
            [[CTDataCollectionManager sharedManager] initPhotoManagerToCollectData];
            [[CTDataCollectionManager sharedManager] startCollectAllData];
        }
    }
}


@end
