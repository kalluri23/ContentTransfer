//
//  CTDeviceSelectionViewController.m
//  contenttransfer
//
//  Created by Development on 8/11/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTCustomTableViewCell.h"
#import "CTDeviceSelectionViewController.h"
#import "CTNetworkUtility.h"
#import "CTPhoneCombinationViewController.h"
#import "CTSettingsUtility.h"
#import "CTMVMStyler.h"
#import "CTPhotosManager.h"
#import "CTEventStoreManager.h"
#import "CTContactsManager.h"
#import "CTDeviceStatusUtility.h"
#import "CTProgressHUD.h"
#import "CTAlertCreateFactory.h"
#import "NSString+CTRootDocument.h"
#import "CTContentTransferSetting.h"
#import "CTQRCodeSwitch.h"
#import "CTDoubleLabelCheckboxCell.h"
#import "CTMVMAlertHandler.h"
#import "CTAudiosManager.h"
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif
#import <AVFoundation/AVFoundation.h>

@interface CTDeviceSelectionViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL shouldShowCheckedDialog; // Default is NO, only set to YES when user click alert dialog go to setting page, then reset to NO.

@end

//static float kProgress = .17;

typedef NS_ENUM(NSInteger, CTDeviceSelectionTableBreakDown) {
    CTDeviceSelectionTableBreakDown_OldPhone,
    CTDeviceSelectionTableBreakDown_NewPhone,
    CTDeviceSelectionTableBreakDown_TotalCells
};

@implementation CTDeviceSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Remove all the temp data from this device
    [CTUserDefaults sharedInstance].tempPhotoLists = @[];
    [CTUserDefaults sharedInstance].tempVideoLists = @[];
    // Photos
    NSString *photoFolder = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferPhoto"];
    // Create new folder if not exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:photoFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:photoFolder withIntermediateDirectories:YES attributes:nil error:nil]; //Create folder
    }
    
    NSString *videoFolder = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferVideo"];
    // Create new folder if not exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:videoFolder withIntermediateDirectories:YES attributes:nil error:nil]; //Create folder
    }
    
    NSString *calendarFolder = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"ReceivedCal"];
    // Create new folder if not exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:calendarFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:calendarFolder withIntermediateDirectories:YES attributes:nil error:nil]; //Create folder
    }
    
    NSString *appFolder = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"ReceivedAppIcons"];
    // Create new folder if not exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:appFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:appFolder withIntermediateDirectories:YES attributes:nil error:nil]; //Create folder
    }
    
    NSString *audioFolder = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferAudio"];
    // Create new folder if not exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:audioFolder withIntermediateDirectories:YES attributes:nil error:nil]; //Create folder
    }
    
    // Do any additional setup after loading the view.
    self.title = CTLocalizedString(CT_DEVICES_STORYBOARD_NAV_TITLE, nil);
    
//    self.progressView.progress = kProgress;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VZTRANSFER_HAS_CLOUD_PHOTO"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VZTRANSFER_HAS_CLOUD_VIDEO"];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hasCloudPhotos"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hasCloudVideos"];
    
    [CTUserDefaults sharedInstance].transferStarted = NO;
    
    // Check permission
    [self requestAuthorization];
    
#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_QuitAndHamburgar];
#endif
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [CTUserDevice userDevice].transferStatus = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.uuid_string = [NSString stringWithFormat:@"%@",[CTUserDevice userDevice].deviceUDID];
    
    //NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //[userDefault setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
    self.analyticsData = @{ANALYTICS_TrackAction_Key_TransactionId:self.uuid_string};// Order is important, set this first
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneSelect;
    
    long long totalFreeSpace = [CTDeviceStatusUtility getFreeDiskSpace];
    [CTUserDevice userDevice].freeSpaceAvaiable = [NSString stringWithFormat:@"%llu",totalFreeSpace];
}

- (IBAction)unwindEverything:(UIStoryboardSegue *)segue {
    [self.navigationController popToViewController:self animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_QuitBack];
#endif
}

#pragma mark Request for requried permission

- (void)requestAuthorization {
    
    __block NSMutableArray *dataTypes = [NSMutableArray new];
    
    __weak typeof(self) weakSelf = self;
    [self requestAddressbookPermissionWithHandler:^(BOOL pass) {
        if (!pass) {
            [dataTypes addObject:CTLocalizedString(CT_CONTACTS_STRING, nil)];
        }
        [weakSelf requestMediaPermissionWithHandler:^(BOOL pass) {
            if (!pass) {
                [dataTypes addObject:CTLocalizedString(CT_PHOTOS_STRING, nil)];
                [dataTypes addObject:CTLocalizedString(CT_VIDEOS_STRING, nil)];
            }
            [weakSelf requestCalendarPermissionWithHandler:^(BOOL pass) {
                if (!pass) {
                    [dataTypes addObject:CTLocalizedString(CT_CALANDERS_STRING, nil)];
                }
                [weakSelf requestReminderPermissionWithHandler:^(BOOL pass) {
                    if (!pass) {
                        [dataTypes addObject:CTLocalizedString(CT_REMINDERS_STRING, nil)];
                    }
                    [weakSelf requestAudioPermissionWithHandler:^(BOOL pass) {
                        if (!pass) {
                            [dataTypes addObject:CTLocalizedString(CT_MUSIC_STRING, nil)];
                        }
                        
                        if ([[CTQRCodeSwitch uniqueSwitch] isOn]) {
                            [weakSelf requestCameraPermissionWithHandler:^(BOOL pass) {
                                if (!pass) {
                                    [dataTypes addObject:CTLocalizedString(CT_CAMERA_STRING, nil)];
                                }
                                
                                [weakSelf performSelectorOnMainThread:@selector(persmissionPostHandleProcess:) withObject:dataTypes waitUntilDone:NO];
                            }];
                        } else {
                            [weakSelf performSelectorOnMainThread:@selector(persmissionPostHandleProcess:) withObject:dataTypes waitUntilDone:NO];
                        }
                    }];
                }];
            }];
        }];
    }];
}

- (void)requestAddressbookPermissionWithHandler:(void (^)(BOOL pass))handler {
    
    if ([CTContactsManager contactsAuthorizationStatus] == CTAuthorizationNotDetermined) {
        [CTContactsManager requestContactsAuthorisation:^(CTAuthorizationStatus status) {
            if (status== CTAuthorizationStatusDenied) {
                
                [CTUserDefaults sharedInstance].hasVcardPermissionError = YES;
                handler(NO);
            } else {
                [CTUserDefaults sharedInstance].hasVcardPermissionError = NO;
                handler(YES);
            }
        }];
    } else if ([CTContactsManager contactsAuthorizationStatus] == CTAuthorizationStatusDenied) {
        [CTUserDefaults sharedInstance].hasVcardPermissionError = YES;
        handler(NO);
    } else {
        [CTUserDefaults sharedInstance].hasVcardPermissionError = NO;
        handler(YES);
    }
}

- (void)requestMediaPermissionWithHandler:(void (^)(BOOL pass))handler {
    if ([CTPhotosManager photoLibraryAuthorizationStatus] == CTAuthorizationNotDetermined) {
        [CTPhotosManager requestPhotoLibraryAuthorisation:^(CTAuthorizationStatus status) {
            if (status== CTAuthorizationStatusDenied) {
                [CTUserDefaults sharedInstance].hasPhotoPermissionError = YES;
                handler(NO);
            } else {
                [CTUserDefaults sharedInstance].hasPhotoPermissionError = NO;
                handler(YES);
            }
        }];
    } else if ([CTPhotosManager photoLibraryAuthorizationStatus] == CTAuthorizationStatusDenied) {
        [CTUserDefaults sharedInstance].hasPhotoPermissionError = YES;
        handler(NO);
    } else {
        [CTUserDefaults sharedInstance].hasPhotoPermissionError = NO;
        handler(YES);
    }
}

- (void)requestCalendarPermissionWithHandler:(void (^)(BOOL pass))handler {
    if ([CTEventStoreManager calendarAuthorizationStatus] == CTAuthorizationNotDetermined) {
        [CTEventStoreManager requestCalendarAuthorisation:^(CTAuthorizationStatus status) {
            if (status == CTAuthorizationStatusDenied) {
                [CTUserDefaults sharedInstance].hasCalendarPermissionError = YES;
                
                handler(NO);
            } else {
                [CTUserDefaults sharedInstance].hasCalendarPermissionError = NO;
                
                handler(YES);
            }
        }];
    } else if ([CTEventStoreManager calendarAuthorizationStatus] == CTAuthorizationStatusDenied) {
        [CTUserDefaults sharedInstance].hasCalendarPermissionError = YES;
        handler(NO);
    } else {
        [CTUserDefaults sharedInstance].hasCalendarPermissionError = NO;
        handler(YES);
    }
}

- (void)requestReminderPermissionWithHandler:(void (^)(BOOL pass))handler {
    if ([CTEventStoreManager reminderAuthorizationStatus] == CTAuthorizationNotDetermined) {
        [CTEventStoreManager requestReminderAuthorisation:^(CTAuthorizationStatus status) {
            if (status == CTAuthorizationStatusDenied) {
                [CTUserDefaults sharedInstance].hasReminderPermissionError = YES;
                handler(NO);
            } else {
                [CTUserDefaults sharedInstance].hasReminderPermissionError = NO;
                handler(YES);
            }
        }];
    } else if ([CTEventStoreManager reminderAuthorizationStatus] == CTAuthorizationStatusDenied) {
        [CTUserDefaults sharedInstance].hasReminderPermissionError = YES;
        handler(NO);
    } else {
        [CTUserDefaults sharedInstance].hasReminderPermissionError = NO;
        handler(YES);
    }
}

- (void)requestAudioPermissionWithHandler:(void (^)(BOOL pass))handler {
    if (SYSTEM_VERSION_LESS_THAN(@"9.3")) { // iOS version below 9.3 not supporting audio transfer
        handler(YES);
        return;
    }
    CTAuthorizationStatus status = [CTAudiosManager audioLibraryAuthorizationStatus];
    if (status == CTAuthorizationNotDetermined) {
        [CTAudiosManager requestAudioLibraryAuthorisation:^(CTAuthorizationStatus status) {
            if (status == CTAuthorizationStatusDenied) {
                [CTUserDefaults sharedInstance].hasReminderPermissionError = YES;
                handler(NO);
            } else {
                [CTUserDefaults sharedInstance].hasReminderPermissionError = NO;
                handler(YES);
            }
        }];
    } else if (status == CTAuthorizationStatusDenied) {
        [CTUserDefaults sharedInstance].hasAudioPermissionError = YES;
        handler(NO);
    } else {
        [CTUserDefaults sharedInstance].hasAudioPermissionError = NO;
        handler(YES);
    }
}

- (void)requestCameraPermissionWithHandler:(void (^)(BOOL pass))handler {
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:
            [CTUserDefaults sharedInstance].hasCameraPermissionError = NO;
            handler(YES);
            break;
            
        case AVAuthorizationStatusDenied:
            [CTUserDefaults sharedInstance].hasCameraPermissionError = YES;
            handler(NO);
            break;
            
        case AVAuthorizationStatusRestricted:
            [CTUserDefaults sharedInstance].hasCameraPermissionError = YES;
            handler(NO);
            break;
            
        case AVAuthorizationStatusNotDetermined:
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (!granted) {
                    [CTUserDefaults sharedInstance].hasCameraPermissionError = YES;
                    handler(NO);
                } else {
                    [CTUserDefaults sharedInstance].hasCameraPermissionError = NO;
                    handler(YES);
                }
            }];
            break;
    }
}

- (void)persmissionPostHandleProcess:(NSArray *)dataTypes {
    if ([dataTypes count]) {
        NSString *commaSeperatedMsg = [dataTypes componentsJoinedByString:@", "];
        NSRange lastCommaRange = [commaSeperatedMsg rangeOfString:@"," options:NSBackwardsSearch];
        if (lastCommaRange.location != NSNotFound) {
            commaSeperatedMsg = [commaSeperatedMsg stringByReplacingCharactersInRange:lastCommaRange withString:[NSString stringWithFormat:@" %@",CTLocalizedString(CT_AND, nil)]]; // replace the last comma with and for context of the alert
        }
        NSString *allowAccessMessage = [NSString stringWithFormat:CTLocalizedString(CT_APP_PERMISSION_ALERT_CONTEXT, nil), commaSeperatedMsg];
        if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
            allowAccessMessage = [NSString stringWithFormat:CTLocalizedString(CT_APP_ACCESS_ALERT_CONTEXT, nil),commaSeperatedMsg];
        }
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:allowAccessMessage cancelBtnText:CTLocalizedString(CT_DECLINE_ALERT_BUTTON_TITLE, nil) confirmBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil) confirmHandler:^(CTVerizonAlertViewController *alertVC) {
                _shouldShowCheckedDialog = YES;
                [CTSettingsUtility openAppCustomSettings];
            } cancelHandler:nil isGreedy:NO from:self];
        } else {
            [CTAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:allowAccessMessage cancelBtnText:CTLocalizedString(CT_DECLINE_ALERT_BUTTON_TITLE, nil) confirmBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil) confirmHandler:^(UIAlertAction *action) {
                _shouldShowCheckedDialog = YES;
                [CTSettingsUtility openAppCustomSettings];
            } cancelHandler:nil isGreedy:NO];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:SEGUE_CTPhoneCombinationViewController]) {
        CTPhoneCombinationViewController *phoneCombinationViewController =
        (CTPhoneCombinationViewController *)segue.destinationViewController;
        
        phoneCombinationViewController.transferFlow = self.transferFlow;
    }
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.frame.size.height / (CGFloat)CTDeviceSelectionTableBreakDown_TotalCells;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CTDeviceSelectionTableBreakDown_TotalCells;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CTDoubleLabelCheckboxCell *cell = (CTDoubleLabelCheckboxCell *)[tableView
                                                                    dequeueReusableCellWithIdentifier:NSStringFromClass([CTDoubleLabelCheckboxCell class])
                                                                    forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case CTDeviceSelectionTableBreakDown_OldPhone:
            cell.primaryLabel.text = CTLocalizedString(CT_OLD_PHONE_PRIM_TEXT, nil);
            cell.secondaryLabel.text = CTLocalizedString(CT_OLD_PHONE_SEC_TEXT, nil);
            break;
        case CTDeviceSelectionTableBreakDown_NewPhone:
            cell.primaryLabel.text = CTLocalizedString(CT_NEW_PHONE_PRIM_TEXT, nil);
            cell.secondaryLabel.text = CTLocalizedString(CT_NEW_PHONE_SEC_TEXT, nil);
            break;
        default:
            break;
    }
    
    return (CTDoubleLabelCheckboxCell *)cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CTDoubleLabelCheckboxCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell highlightCell:YES];
    
    switch (indexPath.row) {
        case CTDeviceSelectionTableBreakDown_OldPhone:
            [CTUserDevice userDevice].deviceType = OLD_DEVICE;
            self.transferFlow = CTTransferFlow_Sender;
            break;
        case CTDeviceSelectionTableBreakDown_NewPhone:
            [CTUserDevice userDevice].deviceType = NEW_DEVICE;
            self.transferFlow = CTTransferFlow_Receiver;
            break;
            
        default:
            break;
    }
    self.nextButton.enabled = YES;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    CTDoubleLabelCheckboxCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell highlightCell:NO];
}

- (IBAction)handleNextButtonTapped:(id)sender {
    if ([[CTUserDevice userDevice].deviceType isEqualToString:NEW_DEVICE]) {
        
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {

            if (USES_CUSTOM_VERIZON_ALERTS) {
                [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil)
                                                                     context:CTLocalizedString(CT_FEATURE_NOT_ALLOWED_ALERT_CONTEXT, nil)
                                                                     btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                                     handler:nil
                                                                    isGreedy:NO from:self];
            }else{
                CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralOKTitle, nil) style:UIAlertActionStyleCancel handler:nil];
                [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) message:CTLocalizedString(CT_FEATURE_NOT_ALLOWED_ALERT_CONTEXT, nil) cancelAction:cancelAction otherActions:nil isGreedy:NO];
            }
            return;
        } else {
            // Create temp folder to store photos.
            NSString *url = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferPhoto"];
            // Create new folder if not exists
            if (![[NSFileManager defaultManager] fileExistsAtPath:url]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:url withIntermediateDirectories:YES attributes:nil error:nil]; //Create folder
            }
            [CTUserDefaults sharedInstance].photoTempFolder = url;
            
            // Create temp folder to store video components for live photo
            NSString *videoComponentURL = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferLivePhoto"];
            // Create new folder if not exists
            if (![[NSFileManager defaultManager] fileExistsAtPath:videoComponentURL]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:videoComponentURL withIntermediateDirectories:YES attributes:nil error:nil]; //Create folder
            }
            [CTUserDefaults sharedInstance].livePhotoTempFolder = videoComponentURL;
            
            // Create temp folder to store video.
            url = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferVideo"];
            // Create new folder if not exists
            if (![[NSFileManager defaultManager] fileExistsAtPath:url]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:url withIntermediateDirectories:YES attributes:nil error:nil]; //Create folder
            }
            [CTUserDefaults sharedInstance].videoTempFolder = url;
        }
    }
    
    [self performSegueWithIdentifier:SEGUE_CTPhoneCombinationViewController sender:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end
