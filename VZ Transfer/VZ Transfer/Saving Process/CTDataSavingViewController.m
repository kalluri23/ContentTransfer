 //
//  CTDataSavingViewController.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/24/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTDataSavingViewController.h"
#import "CTTransferInProgressTableCell.h"
#import "CTColor.h"
#import "CTProgressViewTableCell.h"
#import "CTBundle.h"
#import "CTContactsImport.h"
#import "PhotoStoreHelper.h"
#import "VZRemindersImport.h"
#import "VZCalenderEventsImport.h"
#import "CTStoryboardHelper.h"
#import "NSString+CTRootDocument.h"
#import "CTTransferFinishViewController.h"
#import "CTErrorViewController.h"
#import "NSString+CTMVMConvenience.h"
#import "CTLocalAnalysticsManager.h"
#import "NSNumber+CTHelper.h"
#import "CTDuplicateLists.h"

#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

@interface CTDataSavingViewController () <UITableViewDelegate, UITableViewDataSource, PhotoStoreDelegate, CalendarImportDelegate>
{
    NSInteger totalReminderCount;
}

@property (assign, nonatomic) BOOL hasContacts;
@property (assign, nonatomic) BOOL hasReminders;
@property (assign, nonatomic) BOOL hasCalendars;
@property (assign, nonatomic) BOOL hasPhotos;
@property (assign, nonatomic) BOOL hasVideos;
@property (assign, nonatomic) BOOL hasApps;
@property (assign, nonatomic) NSInteger numberOfPhotos;
@property (assign, nonatomic) NSInteger numberOfVideos;
@property (assign, nonatomic) NSInteger totalPhotoCount;
@property (assign, nonatomic) NSInteger totalVideoCount;
@property (assign, nonatomic) NSInteger totalCalendarCount;
@property (assign, nonatomic) NSInteger totalVcardCount;
@property (assign, nonatomic) NSInteger totalAppsCount;
@property (assign, nonatomic) NSInteger numberOfCalendars;
@property (assign, nonatomic) NSInteger numberOfApps;

@property (atomic, strong) NSMutableArray *photoFailedList;
@property (atomic, strong) NSMutableArray *videoFailedList;
@property (atomic, strong) NSMutableDictionary *localDuplicatePhotoList;
@property (atomic, strong) NSMutableDictionary *localDuplicateVideoList;

@property (nonatomic, strong) NSOperationQueue *serailPhotoQueue;

@property (atomic, assign) NSInteger photoSavedCount;
@property (atomic, assign) NSInteger videoSavedCount;
@property (atomic, assign) NSInteger remindersSavedCount;
@property (nonatomic, assign) NSInteger calendarSavedCount;


@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *informationLabel;
@property (nonatomic, weak) CTProgressView *saveProgress;

@property (nonatomic, assign) NSInteger totalEventCount;

@property (assign, nonatomic) NSInteger successfullySavedPhotos;
@property (assign, nonatomic) NSInteger successfullySavedVideos;
@property (assign, nonatomic) NSInteger successfullySavedReminders;
@property (assign, nonatomic) NSInteger successfullySavedCalendars;
@property (assign, nonatomic) NSInteger successfullySavedContacts;
@property (assign, nonatomic) NSInteger successfullySavedApps;

@property (assign, nonatomic) NSInteger actualSavedPhotoNumber;
@property (assign, nonatomic) NSInteger actualSavedVideoNumber;
@end

static CGFloat kProgressViewTableCellHeight_iPhone = 116.0f;
static CGFloat kDefaultTableViewCellheight_iPhone = 94.0f;
static CGFloat kProgressViewTableCellHeight_iPad = 110.0f;
static CGFloat kDefaultTableViewCellheight_iPad = 80.0f;

typedef NS_ENUM(NSInteger, CTDataSavingTableBreakDown) {
//    CTDataSavingTableBreakDown_TimeLeft, Currently this feature is not supported
    CTDataSavingTableBreakDown_SavingData,
    CTDataSavingTableBreakDown_Total
};

//static float kProgress = 1.0;

@implementation CTDataSavingViewController

@synthesize photoFailedList;
@synthesize videoFailedList;
@synthesize localDuplicatePhotoList;
@synthesize localDuplicateVideoList;
@synthesize photoSavedCount;
@synthesize videoSavedCount;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = CTLocalizedString(CT_DATA_SAVING_NAV_TITLE, nil);
//    self.progressView.progress = kProgress;

    self.primaryMessageLabel.text = CTLocalizedString(CT_ALMOST_DONE_LABEL, nil);
    self.secondaryLabel.text = CTLocalizedString(CT_DATA_SAVING_VC_SEC_LABEL, nil);
    self.cancelButton.hidden = YES;
    
    [self.transferInProgressTableView
     registerNib:[UINib nibWithNibName:NSStringFromClass([CTTransferInProgressTableCell class])
                                bundle:[CTBundle resourceBundle]]
     forCellReuseIdentifier:NSStringFromClass([CTTransferInProgressTableCell class])];
    [self.transferInProgressTableView
     registerNib:[UINib nibWithNibName:NSStringFromClass([CTProgressViewTableCell class])
                                bundle:[CTBundle resourceBundle]]
     forCellReuseIdentifier:NSStringFromClass([CTProgressViewTableCell class])];
    
    self.transferInProgressTableView.delegate = self;
    self.transferInProgressTableView.dataSource = self;
    
    self.serailPhotoQueue = [[NSOperationQueue alloc] init];
    [self.serailPhotoQueue setMaxConcurrentOperationCount:1];
    
    if (self.allowSave) {
        [self allowToSaveUnsavedData];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitContentTransfer:) name:CT_NOTIFICATION_EXIT_CONTENT_TRANSFER object:nil];

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

- (void)allowToSaveUnsavedData {
    if (![self isViewLoaded]) {
        self.allowSave = YES;
        return;
    }
    
    DebugLog(@"flags:%@", [CTUserDefaults sharedInstance].receiveFlags);
    DebugLog(@"photoFileList:%@", [CTUserDefaults sharedInstance].tempPhotoLists);
    DebugLog(@"videoFileList:%@", [CTUserDefaults sharedInstance].tempVideoLists);
    
    if ([[[CTUserDefaults sharedInstance].receiveFlags stringAtIndex:0] isEqualToString:@"true"] && ![CTUserDefaults sharedInstance].hasVcardPermissionError) { // contacts
        self.hasContacts = YES;
    }
    if ([[[CTUserDefaults sharedInstance].receiveFlags stringAtIndex:1] isEqualToString:@"true"] && ![CTUserDefaults sharedInstance].hasCalendarPermissionError) { // calendar
        self.hasCalendars = YES;
    }
    if ([[[CTUserDefaults sharedInstance].receiveFlags stringAtIndex:2] isEqualToString:@"true"] && ![CTUserDefaults sharedInstance].hasReminderPermissionError) { // reminder
        self.hasReminders = YES;
    }
    if ([[[CTUserDefaults sharedInstance].receiveFlags stringAtIndex:3] isEqualToString:@"true"] && ![CTUserDefaults sharedInstance].hasPhotoPermissionError) { // photos
        self.hasPhotos = YES;
    }
    if ([[[CTUserDefaults sharedInstance].receiveFlags stringAtIndex:4] isEqualToString:@"true"] && ![CTUserDefaults sharedInstance].hasPhotoPermissionError) { // videos
        self.hasVideos = YES;
    }
    if ([[[CTUserDefaults sharedInstance].receiveFlags stringAtIndex:5] isEqualToString:@"true"]) { // apps
        self.hasApps = YES;
    }
    
    self.numberOfPhotos = [CTUserDefaults sharedInstance].numberOfPhotosReceived;
    self.numberOfVideos = [CTUserDefaults sharedInstance].numberOfVideosReceived;
    
    self.actualSavedPhotoNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACTUAL_SAVE_PHOTO"] integerValue];
    self.actualSavedVideoNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACTUAL_SAVE_VIDEO"] integerValue];
    
    self.totalPhotoCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PHOTO_TOTAL_COUNT"] integerValue];
    self.totalVideoCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"VIDEO_TOTAL_COUNT"] integerValue];
    self.totalCalendarCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CALENDAR_TOTAL_COUNT"] integerValue];
    totalReminderCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"REMINDER_TOTAL_COUNT"] integerValue];
    self.totalVcardCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CONTACTS_TOTAL_COUNT"] integerValue];
    self.totalAppsCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"APPS_TOTAL_COUNT"] integerValue]; // Total count of app should be received.
    
    NSString *folder = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"ReceivedCal"];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:nil];
    self.numberOfCalendars = dirFiles.count;
    
    NSString *appFolder = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"ReceivedAppIcons"];
    NSArray *appIconFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appFolder error:nil];
    self.numberOfApps = appIconFiles.count; // Number of apps that received, maybe different than total when canceling.
    
    [self receiverShouldStartSaving];
}

- (void)receiverShouldStartSaving {
    __weak typeof(self) weakSelf = self;
    if (self.hasContacts) {
        self.hasContacts = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateSavingInfoWithCurrent:0 totalNumber:0 andCurrent:0];
        });
        [self saveContacts];
    } else if (self.hasPhotos && self.numberOfPhotos > 0 && self.actualSavedPhotoNumber > 0) {
        self.hasPhotos = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateSavingInfoWithCurrent:1 totalNumber:self.actualSavedPhotoNumber andCurrent:0];
        });
        [self startSavePhoto];
    } else if (self.hasVideos && self.numberOfVideos > 0 && self.actualSavedVideoNumber > 0) {
        self.hasVideos = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateSavingInfoWithCurrent:2 totalNumber:self.actualSavedVideoNumber andCurrent:0];
        });
        [self startSaveVideo];
    } else if (self.hasReminders) {
        
        self.hasReminders = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateSavingInfoWithCurrent:3 totalNumber:0 andCurrent:0];
        });
        
        [self startSavingReminders];
        
    } else if (self.hasCalendars && self.numberOfCalendars > 0) {
        
        self.hasCalendars = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateSavingInfoWithCurrent:4 totalNumber:self.numberOfCalendars andCurrent:0];
        });
        [self startSavingCalendars];
        
    } else {
        [self receiverDidFinishSaving];
    }
}

- (void)receiverDidFinishSaving {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.hasApps) { // If has app list received, show app list page
            // SHOULD WE CHECK WIFI CONNECTION BEFORE GO FURTHER?
            CTAppListViewController *targetViewController = [[CTAppListViewController alloc] initWithNibName:@"AppListViewController" bundle:[CTBundle resourceBundle]];
            targetViewController.savedItemsList = [self prepareSavedItemsList];
            targetViewController.transferFlow = CTTransferFlow_Receiver;
            targetViewController.totalDataTransferred = self.totalDataAmount;
            targetViewController.actualDataTransferred = self.transferredDataAmount;
            targetViewController.transferSpeed = self.transferSpeed;
            targetViewController.transferStatusAnalytics = [CTUserDefaults sharedInstance].isCancel?[CTUserDevice userDevice].transferStatus:CTTransferStatus_Success;
            targetViewController.transferTime = self.transferTime;
            targetViewController.photoFailedList = self.photoFailedList;
            targetViewController.videoFailedList = self.videoFailedList;
            
            //Analytics data
            targetViewController.numberOfContacts = self.successfullySavedContacts;
            targetViewController.numberOfPhotos = self.successfullySavedPhotos;
            targetViewController.numberOfVideos = self.successfullySavedVideos;
            targetViewController.numberOfCalendar = self.successfullySavedCalendars;
            targetViewController.numberOfReminder = self.successfullySavedReminders;
            targetViewController.numberOfApps = self.successfullySavedApps;
            
            [self.navigationController pushViewController:targetViewController animated:YES];
            
            return;
        }
        
        if ([CTUserDefaults sharedInstance].isCancel) {
            CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
            errorViewController.dataInterruptedItemsList = [self prepareSavedItemsList];
            errorViewController.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, nil);
            errorViewController.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, nil);
            errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_TRY_AGAIN, nil);
            errorViewController.leftButtonTitle = CTLocalizedString(BUTTON_TITLE_RECAP, nil);
            errorViewController.totalDataAmount = self.totalDataAmount;
            errorViewController.totalDataSentUntillInterrupted = self.transferredDataAmount;
            errorViewController.transferSpeed = self.transferSpeed;
            errorViewController.transferTime = self.transferTime;
            errorViewController.transferStatusAnalytics = [CTUserDevice userDevice].transferStatus;
            errorViewController.photoFailedList = self.photoFailedList;
            errorViewController.videoFailedList = self.videoFailedList;
            
            errorViewController.numberOfPhotos = self.successfullySavedPhotos;
            errorViewController.numberOfVideos = self.successfullySavedVideos;
            errorViewController.numberOfCalendar = self.successfullySavedCalendars;
            errorViewController.numberOfContacts = self.successfullySavedContacts;
            errorViewController.numberOfReminder = totalReminderCount;
            errorViewController.numberOfApps = self.successfullySavedApps;
            
            [self.navigationController pushViewController:errorViewController animated:YES];
        } else {
            UIStoryboard *transferStoryboard = [CTStoryboardHelper transferStoryboard];
            CTTransferFinishViewController *transferFinishViewController = [CTTransferFinishViewController initialiseFromStoryboard:transferStoryboard];
            transferFinishViewController.savedItemsList = [self prepareSavedItemsList];
            transferFinishViewController.transferFlow = CTTransferFlow_Receiver;
            transferFinishViewController.totalDataTransferred = self.totalDataAmount;
            transferFinishViewController.dataTransferred = self.transferredDataAmount;
            transferFinishViewController.transferSpeed = self.transferSpeed;
            transferFinishViewController.transferStatusAnalytics = CTTransferStatus_Success;
            transferFinishViewController.transferTime = self.transferTime;
            transferFinishViewController.photoFailedList = self.photoFailedList;
            transferFinishViewController.videoFailedList = self.videoFailedList;
            
            //Analytics data
            transferFinishViewController.numberOfReminder = self.successfullySavedReminders;
            transferFinishViewController.numberOfPhotos = self.successfullySavedPhotos;
            transferFinishViewController.numberOfVideos = self.successfullySavedVideos;
            transferFinishViewController.numberOfContacts = self.successfullySavedContacts;
            transferFinishViewController.numberOfCalendar = self.successfullySavedCalendars;
            transferFinishViewController.numberOfApps = self.successfullySavedApps;
            
            [self.navigationController pushViewController:transferFinishViewController animated:YES];
        }
    });
}

/*!
    @brief This method will generate the result item list that use for recap page.
    @discussion Method will return a array of dictionary contains all the types of transfer.
                Dictionary will contains Status/FailedNumber/ReceivedNumber.
 
                Status - result of transfer, YES means complete; NO means error happened;
                FailedNumber - How many files failed.
                ReceivedNumber - How many files should be saved/transferred.
 
    @return Array represent the result information for all types of data during the transfer
 */
- (NSArray*)prepareSavedItemsList {
    NSMutableArray *tempArray = [NSMutableArray new];
    
    if ([[[CTUserDefaults sharedInstance].receiveFlags stringAtIndex:0] isEqualToString:@"true"]){ // contacts
        if ([CTUserDefaults sharedInstance].hasVcardPermissionError) {
            NSMutableDictionary *tempDict = [NSMutableDictionary new];
            [tempDict setObject:[NSNumber numberWithBool:NO] forKey:@"Status"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalVcardCount] forKey:@"FailedNumber"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalVcardCount] forKey:@"ReceivedNumber"];
            self.successfullySavedContacts = 0;
            [tempArray addObject:@{@"Contacts":tempDict}];
        } else {
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *tempDict = [NSMutableDictionary new];
            
            NSInteger totalContactNumber = [[userDefault objectForKey:@"CONTACTTOTALCOUNT"] integerValue];
            NSInteger contactSavedNumber = [[userDefault objectForKey:@"CONTACTSIMPORTED"] integerValue];
            [tempDict setObject:[NSNumber numberWithBool:(contactSavedNumber == totalContactNumber)] forKey:@"Status"];
            
            [tempDict setObject:[NSString stringWithFormat:@"%ld", (unsigned long)(totalContactNumber - contactSavedNumber)] forKey:@"FailedNumber"];
            [tempDict setObject:[NSString stringWithFormat:@"%ld", (unsigned long)totalContactNumber] forKey:@"ReceivedNumber"];
//            self.successfullySavedContacts = [[userDefault objectForKey:@"CONTACTSIMPORTED"] integerValue];
            self.successfullySavedContacts = self.fileList.numberOfContacts;

            [tempArray addObject:@{@"Contacts":tempDict}];
        }

    }
    
    if ([[[CTUserDefaults sharedInstance].receiveFlags stringAtIndex:3] isEqualToString:@"true"]){ // photos
        //[tempArray addObject:@{@"Photos":[NSNumber numberWithInteger:self.photoSavedCount]}];
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        if ([CTUserDefaults sharedInstance].hasPhotoPermissionError) {
            [tempDict setObject:[NSNumber numberWithBool:NO] forKey:@"Status"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalPhotoCount] forKey:@"FailedNumber"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalPhotoCount] forKey:@"ReceivedNumber"];
            self.successfullySavedPhotos = 0;
        } else if (self.photoFailedList.count > 0) {
            [tempDict setObject:[NSNumber numberWithBool:NO] forKey:@"Status"];
            [tempDict setObject:[NSNumber numberWithInteger:self.photoFailedList.count] forKey:@"FailedNumber"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalPhotoCount] forKey:@"ReceivedNumber"];
//            self.successfullySavedPhotos =  self.totalPhotoCount - self.photoFailedList.count;
            self.successfullySavedPhotos = self.numberOfPhotos;
        } else {
            [tempDict setObject:[NSNumber numberWithBool:YES] forKey:@"Status"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalPhotoCount - self.numberOfPhotos] forKey:@"FailedNumber"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalPhotoCount] forKey:@"ReceivedNumber"];
            self.successfullySavedPhotos = self.numberOfPhotos;
        }
        //[tempDict setObject:[NSNumber numberWithInteger:self.numberOfPhotos] forKey:@"Photos"];
        [tempArray addObject:@{@"Photos":tempDict}];
    }
    
    if ([[[CTUserDefaults sharedInstance].receiveFlags stringAtIndex:4] isEqualToString:@"true"]) { // is video
        
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        if ([CTUserDefaults sharedInstance].hasPhotoPermissionError) {
            [tempDict setObject:[NSNumber numberWithBool:NO] forKey:@"Status"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalVideoCount] forKey:@"FailedNumber"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalVideoCount] forKey:@"ReceivedNumber"];
            self.successfullySavedVideos = 0;
        } else if (self.videoFailedList.count>0) {
            [tempDict setObject:[NSNumber numberWithBool:NO] forKey:@"Status"];
            [tempDict setObject:[NSNumber numberWithInteger:self.videoFailedList.count] forKey:@"FailedNumber"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalVideoCount] forKey:@"ReceivedNumber"];
//            self.successfullySavedVideos = self.totalVideoCount - self.videoFailedList.count;
            self.successfullySavedVideos = self.numberOfVideos;
        } else {
            [tempDict setObject:[NSNumber numberWithBool:YES] forKey:@"Status"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalVideoCount - self.numberOfVideos] forKey:@"FailedNumber"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalVideoCount] forKey:@"ReceivedNumber"];
            self.successfullySavedVideos = self.numberOfVideos;
        }
        [tempArray addObject:@{@"Videos":tempDict}];

    }
    
    if ([[[CTUserDefaults sharedInstance].receiveFlags stringAtIndex:1] isEqualToString:@"true"]) { // calendars
        if ([CTUserDefaults sharedInstance].hasCalendarPermissionError) {
            NSMutableDictionary *tempDict = [NSMutableDictionary new];
            [tempDict setObject:[NSNumber numberWithBool:NO] forKey:@"Status"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalCalendarCount] forKey:@"FailedNumber"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalCalendarCount] forKey:@"ReceivedNumber"];
            [tempArray addObject:@{@"Calendars":tempDict}];
            self.successfullySavedCalendars = 0;
        } else {
            NSMutableDictionary *tempDict = [NSMutableDictionary new];
            [tempDict setObject:[NSNumber numberWithBool:YES] forKey:@"Status"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalCalendarCount - self.numberOfCalendars] forKey:@"FailedNumber"];
            [tempDict setObject:[NSNumber numberWithInteger:self.totalCalendarCount] forKey:@"ReceivedNumber"];
            self.successfullySavedCalendars = self.numberOfCalendars;
            [tempArray addObject:@{@"Calendars":tempDict}];
        }
        
    }
    
    if ([[[CTUserDefaults sharedInstance].receiveFlags stringAtIndex:2] isEqualToString:@"true"]){ // reminders
        if ([CTUserDefaults sharedInstance].hasReminderPermissionError) {
            NSMutableDictionary *tempDict = [NSMutableDictionary new];
            
            [tempDict setObject:[NSNumber numberWithBool:NO] forKey:@"Status"];
            
            [tempDict setObject:[NSNumber numberWithInteger:totalReminderCount] forKey:@"FailedNumber"];
            [tempDict setObject:[NSNumber numberWithInteger:totalReminderCount] forKey:@"ReceivedNumber"];
            self.successfullySavedReminders = 0;
            [tempArray addObject:@{@"Reminders":tempDict}];
            
        } else {
            NSMutableDictionary *tempDict = [NSMutableDictionary new];
            
            if(self.remindersSavedCount == totalReminderCount)
            {
                [tempDict setObject:[NSNumber numberWithBool:YES] forKey:@"Status"];
            }
            else
            {
                [tempDict setObject:[NSNumber numberWithBool:NO] forKey:@"Status"];
                
            }
            
            [tempDict setObject:[NSNumber numberWithInteger:totalReminderCount - self.remindersSavedCount] forKey:@"FailedNumber"];
            [tempDict setObject:[NSNumber numberWithInteger:totalReminderCount] forKey:@"ReceivedNumber"];
            
            self.successfullySavedReminders = self.fileList.numberOfReminder;
            
            [tempArray addObject:@{@"Reminders":tempDict}];
        }

    }
    
    if ([[[CTUserDefaults sharedInstance].receiveFlags stringAtIndex:5] isEqualToString:@"true"]){ // apps
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        [tempDict setObject:[NSNumber numberWithBool:YES] forKey:@"Status"];
        [tempDict setObject:[NSNumber numberWithInteger:self.totalAppsCount - self.numberOfApps] forKey:@"FailedNumber"];
        [tempDict setObject:[NSNumber numberWithInteger:self.totalAppsCount] forKey:@"ReceivedNumber"];
        self.successfullySavedApps = self.numberOfApps;
        
        [tempArray addObject:@{@"Apps":tempDict}];
    }

    return tempArray;
}

#pragma mark - Save Logic
- (void)saveContacts {
    NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZAllContactBackup.vcf"];
    
    NSData *vcardData = [[NSFileManager defaultManager] contentsAtPath:fileName];
    if (vcardData && vcardData.length > 0) {
        NSInvocationOperation *newoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(importVcardData:) object:vcardData];
        [self.serailPhotoQueue addOperation:newoperation];
    } else {
        [self receiverShouldStartSaving];
    }
}

- (void)importVcardData:(NSData *)vcardData {
    __block int updateNumber = 0;
    // Should Update UI
    CTContactsImport *vCardImport = [[CTContactsImport alloc] init];
    
    __weak typeof(self) weakSelf = self;
    vCardImport.completionHandler = ^(NSInteger contactNumber) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.saveProgress.progress = (float)contactNumber/(float)self.totalVcardCount;
        });
        
        // If success, remove the contact file
        [[NSFileManager defaultManager] removeItemAtPath:[[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZAllContactBackup.vcf"] error:nil];
        
        [weakSelf receiverShouldStartSaving];
    };
    
    vCardImport.updateHandler = ^(NSInteger updateCount) {
        updateNumber += updateCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.saveProgress.progress = (float)updateNumber/(float)self.totalVcardCount;
        });
    };
    
    [vCardImport importAllVcard:vcardData];
}

- (void)startSavePhoto {
    // If photo exists, saving photo first
    PhotoStoreHelper *helper = [[PhotoStoreHelper alloc] initWithOperationDelegate:self andRootPath:[CTUserDefaults sharedInstance].photoTempFolder andDataSets:[CTUserDefaults sharedInstance].tempPhotoLists];
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
        helper.isCrossPlatform = YES;
    }
    [helper startSavingPhotos];
}

- (void)startSaveVideo {
    PhotoStoreHelper *helper = [[PhotoStoreHelper alloc] initWithOperationDelegate:self andRootPath:[CTUserDefaults sharedInstance].videoTempFolder andDataSets:[CTUserDefaults sharedInstance].tempVideoLists];
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
        helper.isCrossPlatform = YES;
    }
    [helper startSavingVideos];
}

- (void)startSavingCalendars {
    
    NSInvocationOperation *newoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(importCalendar) object:nil];
    [[[NSOperationQueue alloc] init] addOperation:newoperation];
    
}

- (void)startSavingReminders {
    NSInvocationOperation *newoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(importReminder) object:nil];
    [[[NSOperationQueue alloc] init] addOperation:newoperation];
}

- (void)importReminder {
    __weak typeof(self) weakSelf = self;
    VZRemindersImport *reminderImport = [[VZRemindersImport alloc] init];
    
    reminderImport.completionHandler = ^(NSInteger totalReminderEventSaved, NSInteger totalReminderEventCount, NSInteger actualSavedListCount) {
        // Remove the reminder file
        [[NSFileManager defaultManager] removeItemAtPath:[[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"reminderLogFile.txt"] error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Fill up the bar code using event count
            if (totalReminderEventCount != 0) {
                self.saveProgress.progress = (float)totalReminderEventSaved/(float)totalReminderEventCount;
            }
            // Capture saved count using list count for analytics.
            self.remindersSavedCount = actualSavedListCount;
        });
        [weakSelf receiverShouldStartSaving];
    };
    
    reminderImport.updateHandler = ^(NSInteger reminderUpdateCount, NSInteger totalReminderEventCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.saveProgress.progress = (float)reminderUpdateCount/(float)totalReminderEventCount;
        });
    };
    
    [reminderImport importAllReminder:NO];
}

- (void)importCalendar {
        
    VZCalenderEventsImport *calendarImport = [[VZCalenderEventsImport alloc] init];
    calendarImport.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.informationLabel.text = @"";
    });
    
    __weak typeof(self) weakSelf = self;
    
    [calendarImport getTotalCalendarEventCount:^(NSInteger eventCount) {
        weakSelf.totalEventCount = eventCount;
        
        [calendarImport createCalendarsSuccess:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.saveProgress.progress = 1.f;
                self.informationLabel.text = @"";
            });
            [weakSelf receiverShouldStartSaving];
        } failure:^{
            DebugLog(@"saving calendar failed");
            dispatch_async(dispatch_get_main_queue(), ^{
                self.saveProgress.progress = 1.f;
                self.informationLabel.text = @"";
            });
            [weakSelf receiverShouldStartSaving];
        }];
    }];
}

#pragma mark - Photo Store Helper Delegate
- (void)updateDuplicatePhoto:(NSArray *)URLs withPhotoInfo:(NSDictionary *)photoInfo withLocalIdentifier:(NSString *)localIdentifier success:(BOOL)success orError:(NSError *)error {
    DebugLog(@"photo done!");
    if (!success) {
        // Save failed photo to fail list
        NSMutableDictionary *dicWithErr = nil;
        if (photoInfo) {
            dicWithErr = [[NSMutableDictionary alloc] initWithDictionary:photoInfo];
        } else {
            dicWithErr = [[NSMutableDictionary alloc] init];
        }
        
        [dicWithErr setValue:error forKey:@"Err"];
        
        if (URLs) {
            [dicWithErr setValue:[URLs objectAtIndex:0] forKey:@"URL"]; // Index 0 is image URL, always exists if URLs array exists.
        }
        
        @synchronized (self) {
            if (!self.photoFailedList) {
                self.photoFailedList = [[NSMutableArray alloc] init];
            }
            [self.photoFailedList addObject:dicWithErr];
        }
    } else {
        // If save success, add local identifier for duplicate logic
        if (localIdentifier) {
            if (!self.localDuplicatePhotoList) {
                self.localDuplicatePhotoList = [[NSMutableDictionary alloc] init];
            }
            
            // Duplicate list hash table: key->received file name; value->local asset id
            [self.localDuplicatePhotoList setObject:localIdentifier forKey:[[URLs objectAtIndex:0] lastPathComponent]];
        }
    }
    
    // Clear the temp file in the folder for successfully saved photo
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (URLs) {
            [[NSFileManager defaultManager] removeItemAtPath:[URLs objectAtIndex:0] error:nil];
            if (URLs.count == 2) {
                // Video component also exist
                [[NSFileManager defaultManager] removeItemAtPath:[URLs objectAtIndex:1] error:nil];
            }
        }
    });
    
    @synchronized (self) {
        self.photoSavedCount++;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.informationLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)self.photoSavedCount, (long)_actualSavedPhotoNumber];
            self.saveProgress.progress = (float)self.photoSavedCount/(float)_actualSavedPhotoNumber;
        });
        
        if (self.photoSavedCount == self.actualSavedPhotoNumber) {
            [[CTDuplicateLists uniqueList] updatePhotos:self.localDuplicatePhotoList];
            [self receiverShouldStartSaving];
        }
    }
}

- (void)updateDuplicateVideo:(NSString *)URL withVideoInfo:(NSDictionary *)videoInfo withLocalIdentifier:(NSString *)localIdentifier success:(BOOL)success orError:(NSError *)error {
    
    DebugLog(@"video done!");
    
    if (!success) {
        // Save failed photo to fail list
        NSMutableDictionary *dicWithErr = nil;
        if (videoInfo) {
            dicWithErr = [[NSMutableDictionary alloc] initWithDictionary:videoInfo];
        } else {
            dicWithErr = [[NSMutableDictionary alloc] init];
        }
        
        [dicWithErr setValue:error forKey:@"Err"];
        
        if (URL) {
            [dicWithErr setValue:URL forKey:@"URL"];
        }
        
        @synchronized (self) {
            if (!self.videoFailedList) {
                self.videoFailedList = [[NSMutableArray alloc] init];
            }
            [self.videoFailedList addObject:dicWithErr];
        }
        
        if (error && error.code != 502) { // 502 means, video not fully transferred, should allow user to transfer it again, not adding them in duplicate list
            
            // Clear the temp file in the folder for successfully saved photo
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                if (URL) {
                    [[NSFileManager defaultManager] removeItemAtPath:URL error:nil];
                }
            });
            
            if (localIdentifier) {
                if (!self.localDuplicateVideoList) {
                    self.localDuplicateVideoList = [[NSMutableDictionary alloc] init];
                }
                
                [self.localDuplicateVideoList setObject:localIdentifier forKey:[URL lastPathComponent]];
            }
        }
    } else {
        if (localIdentifier) {
            if (!self.localDuplicateVideoList) {
                self.localDuplicateVideoList = [[NSMutableDictionary alloc] init];
            }
            
            [self.localDuplicateVideoList setObject:localIdentifier forKey:[URL lastPathComponent]];
        }
            
        // Clear the temp file in the folder for successfully saved photo
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if (URL) {
                [[NSFileManager defaultManager] removeItemAtPath:URL error:nil];
            }
        });
    }
    
    @synchronized (self) {
        self.videoSavedCount++;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.informationLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)self.videoSavedCount, (long)_actualSavedVideoNumber];
            self.saveProgress.progress = (float)self.videoSavedCount/(float)_actualSavedVideoNumber;
        });
        
        if (self.videoSavedCount == self.actualSavedVideoNumber) {
            [[CTDuplicateLists uniqueList] updateVideos:self.localDuplicateVideoList];
            [self receiverShouldStartSaving];
        }
    }
}

#pragma mark - UITableView datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (IS_IPAD) {
        if (indexPath.row == CTDataSavingTableBreakDown_SavingData) {
            return kProgressViewTableCellHeight_iPad;
        }
        return kDefaultTableViewCellheight_iPad;
    } else {
        if (indexPath.row == CTDataSavingTableBreakDown_SavingData) {
            return kProgressViewTableCellHeight_iPhone;
        }
        return kDefaultTableViewCellheight_iPhone;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CTDataSavingTableBreakDown_Total;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case CTDataSavingTableBreakDown_SavingData: {
            CTProgressViewTableCell *cell = (CTProgressViewTableCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CTProgressViewTableCell class]) forIndexPath:indexPath];
            
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
                        
            self.titleLabel = cell.keyLabel;
            
            cell.keyLabel.text = CTLocalizedString(CT_DATA_SAVING_KEY_LABEL, nil);
            
            self.informationLabel = cell.valueLabel;
            
            cell.valueLabel.text = @"";
            
            //cell.customProgressView.progress = [self.currentProgressInfo.transferredAmount floatValue]/totalDataSize;
            self.saveProgress = cell.customProgressView;
            cell.customProgressView.progress = .0;

            return cell;
        } break;
            
        default:
            NSAssert(false, @"Unknown type should've been handled, please check implementation");
            break;
    }
    
    NSAssert(false, @"Execution should not reach to this point");
    return nil;
}

- (void)updateSavingInfoWithCurrent:(NSInteger)type totalNumber:(NSInteger)total andCurrent:(NSInteger)current {
    self.saveProgress.progress = 0.f;
    switch (type) {
        case 0: // contacts
            self.titleLabel.text = CTLocalizedString(CT_SAVING_CONTACTS, nil);
            self.informationLabel.text = @"";
            break;
        case 1: // photos
            self.titleLabel.text = CTLocalizedString(CT_SAVING_PHOTOS, nil);
            self.informationLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)current, (long)total];
            break;
        case 2: // videos
            self.titleLabel.text = CTLocalizedString(CT_SAVING_VIDEOS, nil);
            self.informationLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)current, (long)total];
            break;
        case 3: // reminds
            self.titleLabel.text = CTLocalizedString(CT_SAVING_REMINDERS, nil);
            self.informationLabel.text = @"";
            break;
        case 4: // calendars
            self.titleLabel.text = CTLocalizedString(CT_SAVING_CALENDERS, nil);
            self.informationLabel.text = @"";
            break;
        default:
            self.informationLabel.text = @"";
            break;
    }
}

- (void)shouldUpdateCalendarNumber:(NSInteger)eventCount {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.informationLabel.text = @"";
        
        self.calendarSavedCount += eventCount;
        
        self.saveProgress.progress = (float)self.calendarSavedCount/(float)self.totalEventCount;
    });
}

-(void)exitContentTransfer:(NSNotification*)notification{

    NSString *descMsg = [NSString stringWithFormat:@"MF back button,CT app exit -%@",[self class]];

    [[CTLocalAnalysticsManager sharedInstance] localAnalyticsData:@"Transfer Cancelled"
                                              andNumberOfContacts:self.successfullySavedContacts
                                                andNumberOfPhotos:self.successfullySavedPhotos
                                                andNumberOfVideos:self.successfullySavedVideos
                                             andNumberOfCalendars:self.successfullySavedCalendars
                                             andNumberOfReminders:self.successfullySavedReminders
                                                  andNumberOfApps:self.successfullySavedApps
                                                andNumberOfAudios:0 // No audio on receiver side.
                                                  totalDownloaded:[NSNumber toMBs:[[NSUserDefaults standardUserDefaults] objectForKey:@"NonDuplicateDataSize"]]
                                                 totalTimeElapsed:0
                                                     averageSpeed:self.transferSpeed description:descMsg];
}

@end
