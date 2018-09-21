//
//  VZBonjourReceiveDataVC.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 2/2/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import "VZBonjourReceiveDataVC.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "VZConcurrentWritingHelper.h"
#import "VZDeviceMarco.h"
#import "CTMVMFonts.h"
#import "CTMVMColor.h"
#import "VZContentTrasnferConstant.h"
#import "VZCalenderEventsImport.h"
#import "EKEvent+Utilities.h"
#import "PhotoStoreHelper.h"

#import "VZLocalAnalysticsManager.h"
#import "NSMutableDictionary+CTMVMConvenience.h"
#import "VZSharedAnalytics+Helpers.h"

#import "NSString+CTContentTransferRootDocuments.h"

@interface VZBonjourReceiveDataVC ()<NSNetServiceDelegate, NSStreamDelegate, PhotoStoreDelegate>

@property (nonatomic, assign) BOOL serverRestarted;
@property (nonatomic, assign) BOOL receiverStreamReopened;
@property (nonatomic, assign) BOOL disableCountDown;

@property (nonatomic, assign) BOOL processStart;

@property (nonatomic, strong) NSTimer *timeoutCountingTimer;
//@property (nonatomic, strong) NSTimer *keepAliveTimerBeforeTransactionStart;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarTopConstraints;
@property (nonatomic, strong) NSString *currentReqeust;

// intermediate data package, save 200MB each for video
@property (nonatomic, strong) NSMutableData *intermediateData;

// track on how many bytes already be written into the disk for video
@property (atomic, strong) NSMutableDictionary *videoAlreadyWrittenList;

// video writing into the temp disk file concurrent task list
@property (atomic, strong) NSMutableDictionary *videoWrittingTaskList;

@property (nonatomic, assign) NSInteger numberOfContacts;
@property (assign, nonatomic) NSInteger packageSize;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelBottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *processingLblTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keepAliveTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circularTopConstaints;

@property (strong, atomic) NSMutableArray *videoFailedList;
@property (strong, atomic) NSMutableArray *photoFailedList;

@property (strong, atomic) NSMutableArray *photoSavingList;
@property (strong, atomic) NSMutableArray *photoSavingList2;
@property (strong, atomic) NSMutableArray *photoSavingList3;
@property (strong, atomic) NSMutableArray *photoSavingList4;
@property (strong, atomic) NSMutableArray *photoSavingList5;
@property (strong, atomic) NSMutableArray *photoSavingList6;
@property (assign, atomic) NSInteger currentSavingIndex;
@property (assign, atomic) NSInteger currentSavingIndex2;
@property (assign, atomic) NSInteger currentSavingIndex3;
@property (assign, atomic) NSInteger currentSavingIndex4;
@property (assign, atomic) NSInteger currentSavingIndex5;
@property (assign, atomic) NSInteger currentSavingIndex6;
@property (assign, atomic) BOOL photoSavingLock;
@property (assign, atomic) BOOL photoSavingLock2;
@property (assign, atomic) BOOL photoSavingLock3;
@property (assign, atomic) BOOL photoSavingLock4;
@property (assign, atomic) BOOL photoSavingLock5;
@property (assign, atomic) BOOL photoSavingLock6;
@property (assign, atomic) NSInteger photoSavingArrayIndex;

@property (strong, atomic) NSMutableArray *videoSavingList;
@property (strong, atomic) NSMutableArray *videoSavingList2;
@property (assign, atomic) NSInteger currentVideoSavingIndex;
@property (assign, atomic) NSInteger currentVideoSavingIndex2;
@property (assign, atomic) BOOL videoSavingLock;
@property (assign, atomic) BOOL videoSavingLock2;
@property (assign, atomic) BOOL anotherThread;
@property (nonatomic,assign) float maxspeed;

@property (nonatomic, strong) ALAssetsLibrary *library;

@property (assign, nonatomic) BOOL hasAlbumPermissionErr;
@property (assign, nonatomic) BOOL hasVcardPermissionErr;
@property (assign, nonatomic) BOOL hasCalendarPermissionErr;
@property (assign, nonatomic) BOOL hasReminderPermissionErr;

@property (weak, nonatomic) IBOutlet UIProgressView *dataDownloadProgressBar;

@property (assign, nonatomic) BOOL albumPermissionNotDetermine;
@property (assign, nonatomic) BOOL vcardPermissionNotDetermine;
@property (assign, nonatomic) BOOL calendarPermissionNotDetermine;

@property (assign,nonatomic) BOOL trasnferCancel;

@property (nonatomic, strong) NSDictionary *calInfo;
@property (nonatomic, assign) NSInteger calCountIndex;
@property (nonatomic, assign) BOOL hasCalendarSent;

@property (nonatomic, assign) dispatch_once_t once;
@property (nonatomic, assign) dispatch_once_t once_photo;

@property (nonatomic, assign) BOOL vcardReceived;
@property (nonatomic, assign) BOOL calendarReceived;
@property (nonatomic, assign) BOOL reminderReceived;

@property (nonatomic, assign) NSInteger targetType;

@property (nonatomic, strong) NSMutableData *pendingData;
@end

@implementation VZBonjourReceiveDataVC
@synthesize pendingData;
@synthesize vCardfile_size;
@synthesize receivedData;
@synthesize photofile_size;
@synthesize photolist;
@synthesize calList;
@synthesize photoCountIndex;
@synthesize photoinfo;
@synthesize receivedFileStatuLbl;
@synthesize videofile_size;
@synthesize videoCountIndex;
@synthesize videolist;
@synthesize videoinfo;
//@synthesize fileHandle;
@synthesize filePath;
@synthesize documentsDirectory;
@synthesize totalDownloadedData;
@synthesize totalDownLoadedDataLbl;
@synthesize timeElaspedLbl;
@synthesize startTime;
@synthesize downloadSpeed;
@synthesize downloadSpeedLbl;
@synthesize receiverAnimationImgVIew;
@synthesize tillNowVideoReceived;
@synthesize fileLogManager;
@synthesize totaldownloadableData;
@synthesize totalDownloadDataSizeLbl;
@synthesize timeestimatedLbl;
@synthesize totalFilesReceived;
@synthesize serailPhotoQueue;
@synthesize serailPhotoQueue2;
@synthesize serailPhotoQueue3;
@synthesize serailPhotoQueue4;
@synthesize serailPhotoQueue5;
@synthesize serailPhotoQueue6;
@synthesize serailVideoQueue;
@synthesize serailVideoQueue2;
@synthesize videoFlag;
//@synthesize serialQueue;
@synthesize tempPhotoCount;
@synthesize tempVideoCount;
@synthesize dataReceivingStatus;
@synthesize memoryWarningFlag;
@synthesize totalPayLoadSize;
@synthesize availableStorage;
@synthesize processingDataLbl;
@synthesize processLblTimer;
@synthesize allPhotoDownLoadFlag;
@synthesize allfileLogStartFound;
@synthesize vcardfileStartfound;
@synthesize photofileStartFound;
@synthesize videofileStartFound;
@synthesize photoFolderPath;
@synthesize videoFolderPath;
@synthesize delegate;
@synthesize heartBeatTimer;
@synthesize serverRestarted;
@synthesize timeoutCountingTimer;
@synthesize receiverStreamReopened;
@synthesize currentReqeust;
@synthesize cancelBtn;
@synthesize app;
@synthesize videoAlreadyWrittenList;
@synthesize videoWrittingTaskList;
@synthesize numberOfContacts;
@synthesize packageSize;
@synthesize maxspeed;
@synthesize photoSavingArrayIndex;
@synthesize localDuplicateList;
@synthesize localDuplicateVideoList;
@synthesize photoSavingList;
@synthesize photoSavingList2;
@synthesize photoSavingList3;
@synthesize photoSavingList4;
@synthesize photoSavingList5;
@synthesize photoSavingList6;
@synthesize videoSavingList;
@synthesize videoSavingList2;
@synthesize anotherThread;
@synthesize reminderStartFound;
@synthesize reminderFound;
@synthesize reminderfile_Size;
@synthesize reminderPermissionNotDetermine;
@synthesize mediaTypePiped;
@synthesize receviedCancelRequest;

- (NSMutableData *)intermediateData {
    if (!_intermediateData) {
        _intermediateData = [[NSMutableData alloc] init];
    }
    
    return _intermediateData;
}

#pragma mark - UIViewControllerLifeCycle

- (void)viewDidLoad {
    
    //    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneProcessing;
    
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneTransfer;
    
    [super viewDidLoad];
    
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (screenHeight <= 568) { // IPhone 4 & 5 & SE UI resolution.
        [self.cancelBottomConstraints setConstant:self.cancelBottomConstraints.constant-10];
        [self.circularTopConstaints setConstant:self.circularTopConstaints.constant-20];
        [self.processingLblTopConstaints setConstant:self.processingLblTopConstaints.constant-15];
        [self.progressBarTopConstraints setConstant:self.progressBarTopConstraints.constant-25];
        [self.keepAliveTopConstaints setConstant:self.keepAliveTopConstaints.constant-10];
    }
    
    if ([VZDeviceMarco isiPhone4AndBelow]) {
        packageSize = 50; // set for each of the package size for video receiving
    } else if ([VZDeviceMarco isiPhone5Serial]) {
        packageSize = 100;
    } else if ([VZDeviceMarco isiPhone6AndAbove]) {
        packageSize = 150;
    }
    // Do any additional setup after loading the view.
    
    receivedData = [[NSMutableData alloc] init];
    photoinfo = [[NSDictionary alloc] init];
    videoinfo = [[NSDictionary alloc] init];
    vcardStartFound = FALSE;
    newImageFound = TRUE;
    
    //    [self readSocketRepeated];
    
    vCardFileImportedSucessful = FALSE;
    photoLogFileReceived = FALSE;
    
    recevier_state = RECEIVE_ALL_FILE_LOG;
    
    photoCountIndex = 0;
    videoCountIndex = 0;
    
    [receivedFileStatuLbl setText:@"Waiting for Data"];
    
    totalDownloadedData = 0.0f;
    tillNowVideoReceived = 0;
    
    self.fileLogManager = [[VZFileLogManager alloc] init];
    
    videofile_size = 0;
    
    totalFilesReceived = 0;
    
    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"TOTALFILESRECEIVED"];
    
    serailPhotoQueue = [[NSOperationQueue alloc] init];
    serailPhotoQueue.maxConcurrentOperationCount = 1;
    serailPhotoQueue2 = [[NSOperationQueue alloc] init];
    serailPhotoQueue2.maxConcurrentOperationCount = 1;
    serailPhotoQueue3 = [[NSOperationQueue alloc] init];
    serailPhotoQueue3.maxConcurrentOperationCount = 1;
    serailPhotoQueue4 = [[NSOperationQueue alloc] init];
    serailPhotoQueue4.maxConcurrentOperationCount = 1;
    serailPhotoQueue5 = [[NSOperationQueue alloc] init];
    serailPhotoQueue5.maxConcurrentOperationCount = 1;
    serailPhotoQueue6 = [[NSOperationQueue alloc] init];
    serailPhotoQueue6.maxConcurrentOperationCount = 1;
    
    serailVideoQueue = [[NSOperationQueue alloc] init];
    serailVideoQueue.maxConcurrentOperationCount = 1;
    serailVideoQueue2 = [[NSOperationQueue alloc] init];
    serailVideoQueue2.maxConcurrentOperationCount = 1;
    
    videoFlag = TRUE;
    
    NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZAllContactBackup.vcf"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
    }
    
    tempPhotoCount = 0;
    tempVideoCount = 0;
    
    [self startAnimationReccevierImageView];
    
    memoryWarningFlag = NO;
    
    [self.processingDataLbl setText:@""];
    
    self.allPhotoDownLoadFlag = YES;
    
    self.allfileLogStartFound = NO;
    self.videofileStartFound = NO;
    self.vcardfileStartfound = NO;
    self.videofileStartFound = NO;
    
    self.vcardPermissionNotDetermine = YES;
    self.albumPermissionNotDetermine = YES;
    self.calendarPermissionNotDetermine = YES;
    self.reminderPermissionNotDetermine = YES;
    
    // Bonjour service setup for current view
    [[BonjourManager sharedInstance] setServerDelegate:self];
    
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined){
        self.vcardPermissionNotDetermine = YES;
        
        __weak typeof(self) weakSelf = self;
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            weakSelf.vcardPermissionNotDetermine = NO;
            if (!granted) {
                weakSelf.hasVcardPermissionErr = YES;
            }
            
            if (!weakSelf.albumPermissionNotDetermine && !weakSelf.calendarPermissionNotDetermine && !weakSelf.reminderPermissionNotDetermine) {
                [weakSelf performSelector:@selector(generatePermissionAlert) withObject:nil];
            }
        });
    } else if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
        self.vcardPermissionNotDetermine = NO;
        self.hasVcardPermissionErr = YES;
    }
    
//    EKEventStore *eventStore = [[EKEventStore alloc] init];
//    [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
//        
//        DebugLog(@"No access granted");
//    }];
    
    [self checkforReminderPermission];
    
    // Create MyPhoto folder to store photos
    fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferPhoto"];
    
    // Remove old files
    [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
    
    NSError *error = nil;
    // create new folder
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
    
    photoFolderPath = fileName;
    
    // Create MyPhoto folder to store photos
    fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferVideo"];
    
    // Remove old files
    [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
    
    // create new folder
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        [[NSFileManager defaultManager] createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
    
    videoFolderPath = fileName;
    
	[CTMVMButtons primaryRedButton:self.cancelBtn constrainHeight:YES];
    
#if STANDALONE
    
    self.dataReceivingStatus.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.dataReceivingStatus.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
#else
    
    self.dataReceivingStatus.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.dataReceivingStatus.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
#endif
    self.downloadSpeedLbl.font = [CTMVMFonts mvmBookFontOfSize:11];
    self.timeElaspedLbl.font = [CTMVMFonts mvmBookFontOfSize:11];
    self.totalDownloadDataSizeLbl.font = [CTMVMFonts mvmBookFontOfSize:11];
    self.totalDownLoadedDataLbl.font = [CTMVMFonts mvmBookFontOfSize:11];
    self.timeestimatedLbl.font = [CTMVMFonts mvmBookFontOfSize:11];
    self.processingDataLbl.font = [CTMVMFonts mvmBookFontOfSize:13];
    
    
    self.keepAppOpenLbl.font = [CTMVMFonts mvmBookFontOfSize:13];
    self.keepAppOpenLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    
    self.navigationItem.title = @"Content Transfer";
	
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"VZBonjourReceiverVC" withExtraInfo:@{} isEncryptedExtras:false];
    
	self.disableCountDown = NO;
    self.processStart = NO;
    self.receviedCancelRequest = NO;
    
    self.trasnferCancel = NO;
    
    self.videoAlreadyWrittenList = [[NSMutableDictionary alloc] init];
    self.videoWrittingTaskList = [[NSMutableDictionary alloc] init];
    
    self.library = [[ALAssetsLibrary alloc] init];
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusNotDetermined) {
        self.albumPermissionNotDetermine = YES;
        
        __weak typeof(self) weakSelf = self;
        [self.library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            // do nothing
            weakSelf.albumPermissionNotDetermine = NO;
            
            if (!weakSelf.vcardPermissionNotDetermine && !weakSelf.albumPermissionNotDetermine && !weakSelf.calendarPermissionNotDetermine) {
                [weakSelf performSelector:@selector(generatePermissionAlert) withObject:nil];
            }
        } failureBlock:^(NSError *error) {
            weakSelf.albumPermissionNotDetermine = NO;
            if (error.code == ALAssetsLibraryAccessUserDeniedError || error.code == ALAssetsLibraryAccessGloballyDeniedError) {
                self.hasAlbumPermissionErr = YES;
                
                if (!weakSelf.vcardPermissionNotDetermine && !weakSelf.calendarPermissionNotDetermine && !weakSelf.reminderPermissionNotDetermine) {
                    [weakSelf performSelector:@selector(generatePermissionAlert) withObject:nil];
                }
            }
        }];
    } else if (status != ALAuthorizationStatusAuthorized) {
        self.albumPermissionNotDetermine = NO;
        self.hasAlbumPermissionErr = NO;
    }
    
    // Check calendar permission
    __weak typeof(self) weakSelf = self;
    [VZCalenderEventsImport checkAuthorizationStatusToAccessEventStoreSuccess:^{
        weakSelf.calendarPermissionNotDetermine = NO;
        
        if (!weakSelf.vcardPermissionNotDetermine && !weakSelf.albumPermissionNotDetermine && !weakSelf.calendarPermissionNotDetermine) {
            [weakSelf performSelector:@selector(generatePermissionAlert) withObject:nil];
        }
    } andFailureHandler:^(EKAuthorizationStatus status) {
        weakSelf.calendarPermissionNotDetermine = NO;
        weakSelf.hasCalendarPermissionErr = YES;
        
        if (!weakSelf.vcardPermissionNotDetermine && !weakSelf.albumPermissionNotDetermine && !weakSelf.reminderPermissionNotDetermine) {
            [weakSelf performSelector:@selector(generatePermissionAlert) withObject:nil];
        }
    }];
    
    self.dataDownloadProgressBar.progress = 0.0f;
    
    self.dataDownloadProgressBar.tintColor = [CTMVMColor mvmPrimaryRedColor];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"photoFilteredFileList"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"videoFilteredFileList"];

    self.cancelBtn.hidden = YES;
}

- (void)checkforReminderPermission {
    
    self.reminderPermissionNotDetermine = YES;
    
    __weak typeof(self) weakSelf = self;
    [VZRemindersImoprt updateAuthorizationStatusToAccessEventStoreSuccess:^{
        weakSelf.reminderPermissionNotDetermine = NO;
        
        if (!weakSelf.vcardPermissionNotDetermine && !weakSelf.albumPermissionNotDetermine && !weakSelf.calendarPermissionNotDetermine) {
            [weakSelf performSelector:@selector(generatePermissionAlert) withObject:nil];
        }
        
    } failed:^(EKAuthorizationStatus status) {
        weakSelf.reminderPermissionNotDetermine = NO;
        weakSelf.hasReminderPermissionErr = YES;
        
        if (!weakSelf.vcardPermissionNotDetermine && !weakSelf.albumPermissionNotDetermine && !weakSelf.calendarPermissionNotDetermine) {
            [weakSelf performSelector:@selector(generatePermissionAlert) withObject:nil];
        }
    }];
}

- (void)openSettings
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)generatePermissionAlert
{
    if (self.hasVcardPermissionErr || self.hasAlbumPermissionErr || self.hasCalendarPermissionErr || self.reminderPermissionNotDetermine) {
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Go to Setting" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [weakSelf openSettings];
        }];
        
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:nil];
        
        NSString *message = @"";
        if (self.hasVcardPermissionErr) {
            message = @"Unable to import contacts";
        }
        
        if (self.hasAlbumPermissionErr) {
            if (message.length == 0)
                message = @"Unable to import photos and videos";
            else
                message = [NSString stringWithFormat:@"%@, photos and videos", message];
        }
        
        if (self.hasCalendarPermissionErr) {
            if (message.length == 0)
                message = @"Unable to import calendars";
            else
                message = [NSString stringWithFormat:@"%@, calendars", message];
        }
        
        if (self.hasReminderPermissionErr) {
            if (message.length == 0)
                message = @"Unable to import to reminders";
            else
                message = [NSString stringWithFormat:@"%@, and reminders", message];
        }
        
        message = [NSString stringWithFormat:@"%@. Please give permission for them, otherwise all transferred data will not be saved.", message];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if (!self.vcardPermissionNotDetermine && !self.albumPermissionNotDetermine) {
//        [self performSelector:@selector(generatePermissionAlert) withObject:nil];
//    }
    
    self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(keepBonjourConnectionAlive:) userInfo:nil repeats:YES]; // send keep alive heartbeat back to the receiver;
}

- (void)keepBonjourConnectionAlive:(NSTimer *)timer {
    if (self.processStart) {
        [timer invalidate];
        timer = nil;
    }
    
//    DebugLog(@"send keep alive heart beat...");
    
    NSString *message = @"VZTRANSFER_KEEP_ALIVE_HEARTBEAT";
    NSData *data =[message dataUsingEncoding:NSUTF8StringEncoding];
    
    [[BonjourManager sharedInstance] sendFileStream:data];
    
//    delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([heartBeatTimer isValid]) {
        [heartBeatTimer invalidate];
    }
    
    // shutdown any play or record queue..
    if ([self.timeoutCountingTimer isValid]) {
        [self.timeoutCountingTimer invalidate];
        self.timeoutCountingTimer = nil;
    }
    
    self.receiverAnimationImgVIew = nil;
    
    [[BonjourManager sharedInstance] stopServer]; // stop server, so other device won't find this device
    [[BonjourManager sharedInstance] closeStreamForController:self];
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)backButtonPressed {
    
    [self ClickedOnCancelBtn:nil];
}

- (void) startAnimationReccevierImageView {
    
//    self.receiverAnimationImgVIew.animationImages = [NSArray arrayWithObjects:[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_01"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_02"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_03"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_04"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_05"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_06"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_07"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_08"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_09"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_10"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_11"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_12"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_13"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_14"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_15"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_16"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_17"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_18"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_18"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_20"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_21"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_22"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_23"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_24"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_25"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_26"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_27"],[ UIImage getImageFromBundleWithImageName:@"anim-left_alpha_1x_28"],nil];
    
    self.receiverAnimationImgVIew.animationImages = [NSArray arrayWithObjects:
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_00" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_01" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_02" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_03" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_04" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_05" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_06" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_07" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_08" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_09" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_10" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_11" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_12" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_13" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_14" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_15" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_16" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_17" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_18" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_19" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_20" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_21" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_22" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_23" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_24" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_25" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_26" ],
                [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_27" ],nil];
    
    // all frames will execute in 1.75 seconds
    self.receiverAnimationImgVIew.animationDuration = 1.75;
    // repeat the animation forever
    self.receiverAnimationImgVIew.animationRepeatCount = 0;
    // start animating
    [self.receiverAnimationImgVIew startAnimating];
}

- (void) stopAnimationReceiverImageVIew {
    
    [self.receiverAnimationImgVIew stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    memoryWarningFlag = YES; // If memory warning received, wait for rest process finished, otherwise the app will crash
}

#pragma mark - NSStreamDelegate
#define TIMEOUT_LIMIT 30

static int timeoutTimerCountdown = 0;
static int closeCount = 0;

bool threadShouldStop = false;
// Stream connection event
int testtotolbytesread = 0;
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) { // streams opened
        case NSStreamEventOpenCompleted: {
            [BonjourManager sharedInstance].streamOpenCount += 1;
            // DebugLog(@"--->connected:%d",[BonjourManager sharedInstance].streamOpenCount);
            assert([BonjourManager sharedInstance].streamOpenCount <= 2);
            // once both streams are open we hide the picker
            if ([BonjourManager sharedInstance].streamOpenCount == 2) {
                // DebugLog(@"Close server");
                [[BonjourManager sharedInstance] stopServer];
                [BonjourManager sharedInstance].isServerStarted = NO;
                
                self.receiverStreamReopened = YES;
            }
        } break;
            
        case NSStreamEventHasSpaceAvailable: { // stream has space
            assert(stream == [BonjourManager sharedInstance].outputStream);
            
        } break;
            
        case NSStreamEventHasBytesAvailable: {
            if (self.disableCountDown) { // connection already cancelled, disgard all the data received after stop.
                break;
            }
            
            if (!self.processStart) {
                self.processStart = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.cancelBtn.hidden = NO;
                });
            }
            
            if (![timeoutCountingTimer isValid]) { // reset the timeout timer
                timeoutCountingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeoutcountingHandler:) userInfo:nil repeats:YES];
            }
            
            timeoutTimerCountdown = 0;
            
            if (!serverRestarted && self.processingDataLbl.text.length > 0) {
                self.processingDataLbl.text = @"";
                self.dataDownloadProgressBar.hidden = NO;
            }
            
            // stream has data
            // (in a real app you have gather up multiple data packets into the sent data)
            NSUInteger bsize;
            if (recevier_state == RECEIVE_VIDEO_FILE) {
                // Only change the buffer size of receiving videos
                bsize = 131072;
            } else {
                bsize = 16384;
            }
            
//            NSUInteger bsize = 1024;
//            uint8_t buf[bsize];
            
//            NSMutableData *myBuffer = [NSMutableData dataWithLength:bsize];
            uint8_t buf[bsize];
            NSInteger bytesRead = [(NSInputStream *)stream read:buf maxLength:bsize];
            if (bytesRead < 0) {
                // handle EOF and error in NSStreamEventEndEncountered and NSStreamEventErrorOccurred cases
                // DebugLog(@"byte read error.");
            } else if (bytesRead == 0) {
                // DebugLog(@"byte read end.");
            } else {
                // received remote data
                BOOL isCancelRequest = NO;
                int localStat = -1;
                
                NSData *data = [NSData dataWithBytes:buf length:bytesRead];
                if (data.length == 15) {
                    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if ([response isEqualToString:@"VZTRANSFER_QUIT"]) { // Only worked in MVM build
                        response = nil;
                        
                        [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
                        
                        if ([[[[self navigationController]viewControllers]objectAtIndex:0] isKindOfClass:[CTNoInternetViewController class]]) {
                            [self.navigationController setNavigationBarHidden:YES animated:NO];
                        }
                        
                        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
                        }
                        
                        NSString *screenName = @"VZBonjourReceiveDataVC";
                        
                        NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
                        
                        [infoDict setObject:[screenName stringByAppendingString:@"_Application exited by user"] forKey:@"dataTransferStatusMsg"];
                        [infoDict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
                        
                        [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_EXITAPP withExtraInfo:infoDict isEncryptedExtras:false];
                        
                        [UIApplication sharedApplication].idleTimerDisabled = NO;
                        
                        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                        [appDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                        //        [appDelegate.window makeKeyAndVisible];
                        [appDelegate setViewControllerToPresentAlertsOnAutomatic];
                        
//                        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                        
                        [appDelegate displayStatusChanged];

                        return;
                    }
                } else if (data.length == 17) { // Cancel on the other side
                    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if ([response isEqualToString:@"VZTRANSFER_CANCEL"]) {
                        response = nil;
                        isCancelRequest = YES;
                        
                        localStat = TRANSFER_CANCELLED;
                    }
                } else if (data.length == 21) {
                    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if ([response isEqualToString:@"VZTRANSFER_FORCE_QUIT"]) {
                        DebugLog(@"This is the force quit on the other side test");
                        isCancelRequest = YES;
                        response = nil;
                        
                        localStat = USER_FORCE_CLOSE;
                    }
                } else {
                    BOOL matched = NO;
                    if (data.length > 21) {
                        NSData *tmpData = [data subdataWithRange:NSMakeRange(data.length-21, 21)];
                        NSString *response = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
                        
                        if ([response isEqualToString:@"VZTRANSFER_FORCE_QUIT"]) {
                            DebugLog(@"This is the force quit on the other side test");
                            isCancelRequest = YES;
                            response = nil;
                            matched = YES;
                            
                            localStat = USER_FORCE_CLOSE;
                        }
                    }
                    
                    if (!matched && data.length > 17) {
                        NSData *tmpData = [data subdataWithRange:NSMakeRange(data.length-17, 17)];
                        NSString *response = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
                        
                        if ([response isEqualToString:@"VZTRANSFER_CANCEL"]) {
                            response = nil;
                            isCancelRequest = YES;
                            matched = YES;
                            
                            localStat = TRANSFER_CANCELLED;
                        }
                    }
                    
                    if (!matched && data.length > 15) { // Only work for MVM build
                        
                        NSData *tmpData = [data subdataWithRange:NSMakeRange(data.length-15, 15)];
                        NSString *response = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
                        
                        if ([response isEqualToString:@"VZTRANSFER_QUIT"]) {
                            response = nil;
                            
                            [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
                            
                            if([[[[self navigationController]viewControllers]objectAtIndex:0] isKindOfClass:[CTNoInternetViewController class]]) {
                                [self.navigationController setNavigationBarHidden:YES animated:NO];
                            }
                            
                            if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                                self.navigationController.interactivePopGestureRecognizer.enabled = YES;
                            }
                            
                            NSString *screenName = @"VZBonjourReceiveDataVC";
                            
                            NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
                            
                            [infoDict setObject:[screenName stringByAppendingString:@"_Application exited by user"] forKey:@"dataTransferStatusMsg"];
                            [infoDict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
                            
                            [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_EXITAPP withExtraInfo:infoDict isEncryptedExtras:false];
                            
                            [UIApplication sharedApplication].idleTimerDisabled = NO;
                            
                            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                            [appDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                            //        [appDelegate.window makeKeyAndVisible];
                            [appDelegate setViewControllerToPresentAlertsOnAutomatic];
                            
//                            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                            
                            [appDelegate displayStatusChanged];
                            
                            return;
                        }
                    }
                }
 
                if (isCancelRequest) { // receiver cancel connection
                    self.dataDownloadProgressBar.hidden = YES;
                    self.trasnferCancel = YES;
                    
                    self.disableCountDown = YES;
                    
                    if ([timeoutCountingTimer isValid]) { // disable the timer
                        [timeoutCountingTimer invalidate];
                        timeoutCountingTimer = nil;
                    }
                    timeoutTimerCountdown = 0;
                    
                    // By Prakash to fix #1930754
                    if ([heartBeatTimer isValid]) {
                        [heartBeatTimer invalidate];
                        heartBeatTimer = nil;
                    }
                    
                    [self.cancelBtn setEnabled:NO];
                    [self.cancelBtn setAlpha:0.4];
                    
                    // Saving
                    self.receviedCancelRequest = NO;
                    [self dataTransferInterrupted:localStat];
                } else {
                    self.receviedCancelRequest = YES;
                    [self BonjourreceivedData:data];
                }
            }
        } break;
            // all others cases
        case NSStreamEventEndEncountered:
//            self.disableCountDown = YES;
//            
//            if ([timeoutCountingTimer isValid]) { // disable the timer
//                [timeoutCountingTimer invalidate];
//                timeoutCountingTimer = nil;
//            }
//            timeoutTimerCountdown = 0;
//            
////            [self.navigationController popToRootViewControllerAnimated:YES];
            
            self.dataDownloadProgressBar.hidden = YES;
            self.trasnferCancel = YES;
            
            //                    DebugLog(@"received cancel");
            self.disableCountDown = YES;
            
            if ([timeoutCountingTimer isValid]) { // disable the timer
                [timeoutCountingTimer invalidate];
                timeoutCountingTimer = nil;
            }
            timeoutTimerCountdown = 0;
            
            // By Prakash to fix #1930754
            if ([heartBeatTimer isValid]) {
                [heartBeatTimer invalidate];
                heartBeatTimer = nil;
            }
            
            [self.cancelBtn setEnabled:NO];
            [self.cancelBtn setAlpha:0.4];
            
            // Saving
            [self dataTransferInterrupted:TRANSFER_INTERRUPTED];
            
            break;
        case NSStreamEventNone:
            break;
        case NSStreamEventErrorOccurred:{
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [BonjourManager sharedInstance].streamOpenCount --;
            
            if ([stream isEqual:[BonjourManager sharedInstance].inputStream]) {
                [BonjourManager sharedInstance].inputStream = nil;
            } else {
                [BonjourManager sharedInstance].outputStream = nil;
            }
            
            if (++closeCount == 2) {
                closeCount = 0;
                if (!serverRestarted && self.processStart) {
                    serverRestarted = [[BonjourManager sharedInstance] createReconnectServerForController:self];
                }
            } else {
                self.dataDownloadProgressBar.hidden = YES;
                [self performSelectorOnMainThread:@selector(updateTitleLabelInMainThread:) withObject:@"Something wrong with your connection. Trying to reconnect for you..." waitUntilDone:NO];
//                self.processingDataLbl.text = @"error occurred.";
                
                if ([timeoutCountingTimer isValid]) { // disable the timer
                    [timeoutCountingTimer invalidate];
                    timeoutCountingTimer = nil;
                }
                timeoutTimerCountdown = 0;
                receiverStreamReopened = NO;
                responseSent = false;
            }
            
        }
            break;
        default:
            // transferring files
            break;
    }
}

- (void)timeoutcountingHandler:(NSTimer *)timer
{
    if (delegate) {
        [timer invalidate];
    }
    timeoutTimerCountdown++;
//    DebugLog(@"-->count:%d",timeoutTimerCountdown);
    // DebugLog(@"========>%d", tillNowVideoReceived);
    
    if (timeoutTimerCountdown == TIMEOUT_LIMIT) { // 1 min for timeout
//        self.receivedFileStatuLbl.text = [NSString stringWithFormat:@"received:%lld", tillNowVideoReceived];
        
        [[BonjourManager sharedInstance] closeStreamForController:self];
        [timeoutCountingTimer invalidate]; // disable the timer
        timeoutCountingTimer = 0;
        
        if (!serverRestarted) {
            serverRestarted = [[BonjourManager sharedInstance] createReconnectServerForController:self];
        }
    } else if (timeoutTimerCountdown == 15) {
        self.dataDownloadProgressBar.hidden = YES;
        self.processingDataLbl.text = @"Your connection timeout. Trying to reconnect for you...";
    }
    
}

- (void)BonjourreceivedData:(NSData *)data {
    
    // REVIEW
    if (pendingData.length > 0) { // if we have pending data, then merge the new data with it, get the new package
        [pendingData appendData:data];
        data = (NSData *)pendingData;
        pendingData = nil; // make sure clear pending data everytime, keep it length 0
    }
    
    switch (recevier_state) {
        case HAND_SHAKE:
            break;
        case RECEIVE_ALL_FILE_LOG:
        {
            if (!allfileLogStartFound) {
                
                // Receive logic
                self.startTime = [NSDate date];
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                [userDefault setObject:self.startTime forKey:@"STARTTIME"];
                [userDefault synchronize];
                
                if (data.length < 37) { // if header less than 37, package not complete, store it and wait for next package comes
                    pendingData = [NSMutableData dataWithData:data];
                    return;
                }
                
                NSData *tempdata = [data subdataWithRange:NSMakeRange(0, 37)];
                NSString *header = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
                
                NSRange range = [header rangeOfString:@"VZCONTENTTRANSFERALLFLSTART"];
                if ((range.location != NSNotFound) && (header.length > 0)) {
                    
                    NSString *fileLogLen = [header substringFromIndex:27];
                    vCardfile_size = fileLogLen.longLongValue;
                    
                    if (data.length > 37) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(37, data.length - 37)]];
                    }
                    
                    __weak typeof(self) weakSelf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{ // Update UI in main thread
                        [weakSelf.dataReceivingStatus setText:@"Receiving..."];
                    });
                    
                    allfileLogStartFound = YES;
                    header = nil;
                    
                }
            } else {
                [receivedData appendData:data];
            }
            
//            else if (allfileLogStartFound && (receivedData.length + data.length < vCardfile_size)) {
//                [receivedData appendData:data];
//            } else {
//                NSData *lastpacketPortion  = [data subdataWithRange:NSMakeRange(0, vCardfile_size - receivedData.length)];
//                
//                if (lastpacketPortion.length > 0) {
//                    [receivedData appendData:lastpacketPortion];
//                }
//            }
            
            if (receivedData.length == vCardfile_size) {
                
                vCardfile_size = 0;
                allfileLogStartFound = NO;
                
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.receivedFileStatuLbl setText:@"File List Received"];
                });
                
                __block NSData *localData = receivedData;
                receivedData = nil;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    @autoreleasepool {
                        [weakSelf.fileLogManager storeFileList:localData];
                        localData = nil;
                        
                        BOOL enoughStorage = [weakSelf calculatetotalDownloadableDataSize];
                        if (enoughStorage) {
                            [weakSelf notifyAllFileListCompletion:YES];
                        }
                    }
                    __block NSMutableDictionary *paramDictionary = [NSMutableDictionary dictionary];
                    
                    [self.sharedAnalytics getMediaInfoForMedia:self.fileLogManager.allMediaInfo withAnalyticsMediaInfoBlock:^(NSDictionary *mediaAnalyticsDictionary) {
                        
                        paramDictionary = [mediaAnalyticsDictionary mutableCopy];
                        
                        [paramDictionary setObject:ANALYTICS_TrackAction_Param_Value_FlowInitiated_1
                                            forKey:ANALYTICS_TrackAction_Param_Key_FlowInitiated];
                        [paramDictionary setObject:ANALYTICS_TrackAction_Param_Value_FlowName_TransferToReceiver
                                            forKey:ANALYTICS_TrackAction_Param_Key_FlowName];
                        [paramDictionary setObject:self.uuid_string forKey:ANALYTICS_TrackAction_Key_TransactionId];
                        // Prakash_Analytics Changes
                        NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneTransfer, ANALYTICS_TrackAction_Value_LinkName_MetaDataFileRead);
                        
                        [paramDictionary setObject:ANALYTICS_TrackAction_Value_LinkName_MetaDataFileRead forKey:ANALYTICS_TrackAction_Key_LinkName];
                        [paramDictionary setObject:pageLink forKey:ANALYTICS_TrackAction_Key_PageLink];
                        [paramDictionary setObject:ANALYTICS_TrackAction_Value_SenderReceiver_Receiver forKey:ANALYTICS_TrackAction_Key_SenderReceiver];
                        
                        [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Value_LinkName_MetaDataFileRead
                                                     data:paramDictionary];
                        
                        if ([paramDictionary valueForKey:ANALYTICS_TrackAction_Key_MediaSelected]) {
                            mediaTypePiped = [paramDictionary valueForKey:ANALYTICS_TrackAction_Key_MediaSelected];
                        }
                        self.analyticsData = nil;
                        self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneProcessing;
                    }];
                });
            }
        } break;
            
        case RECEIVE_VCARD_FILE:
        {
            if (!vcardfileStartfound) {
                
                if (data.length < 37) { // if header less than 37, package not complete, store it and wait for next package comes
                    pendingData = [NSMutableData dataWithData:data];
                    return;
                }
                
                NSData *tempdata = [data subdataWithRange:NSMakeRange(0, 37)];
                NSString *header = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
                // DebugLog(@"VCARD_RECEIVE String from NSdata is %@",response1);
                
                NSRange range = [header rangeOfString:@"VZCONTENTTRANSFERVCARDSTART"];
                if ((range.location != NSNotFound) && (header.length > 0)) {
                    
                    NSString *vcardLen = [header substringFromIndex:27];
                    vCardfile_size = vcardLen.longLongValue;
                    vcardfileStartfound = YES;
                    ++totalFilesReceived;
                    
//                    if (vCardfile_size == 0) {
//                        --totalFilesReceived;
//                        [self notifyAllFileListCompletion:NO];
//                        vcardfileStartfound = NO;
//                    }
                    
                    receivedData = [[NSMutableData alloc] init];
                    if (data.length > 37) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(37, data.length - 37)]];
                    }
                }
                
            } else {
                [receivedData appendData:data];
            }
            
//            else if (vcardfileStartfound && ((receivedData.length + data.length) < vCardfile_size)) {
//                [receivedData appendData:data];
//            } else {
//                NSData *lastpacketPortion = [data subdataWithRange:NSMakeRange(0, vCardfile_size - receivedData.length)];
//                
//                if (lastpacketPortion.length > 0) {
//                    [receivedData appendData:data];
//                }
//            }
            
            if (receivedData.length == vCardfile_size) {
                
                self.vcardReceived = YES;
                vcardfileStartfound = NO;
                
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.receivedFileStatuLbl setText:@"Vcard Received"];
                });
                
                if (vCardfile_size > 0) {
//                    NSString *documentsDirectory1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Documents"];
                    NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZAllContactBackup.vcf"];
                    
                    [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
                    [receivedData writeToFile:fileName atomically:NO];
                    
                    [self notifyAllFileListCompletion:NO];
                    
                    receivedData = nil;
                } else {
                    receivedData = nil;
                }
            }
            
        } break;
            
        case RECEIVE_PHOTO_FILE:
        {
            if (!photofileStartFound) {
                
                if (data.length < 37) { // if header less than 37, package not complete, store it and wait for next package comes
                    pendingData = [NSMutableData dataWithData:data];
                    return;
                }
                
                NSData *tempdata = [data subdataWithRange:NSMakeRange(0, 37)];
                NSString *header = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
  
                if ([[header substringToIndex:27] isEqualToString:@"VZCONTENTTRANSFERPHOTOSTART"]) {
                    
                    NSString *vcardLen = [header substringFromIndex:27];
                    
                    photofile_size = vcardLen.longLongValue;
                    receivedData = [[NSMutableData alloc] init];
                    
                    if (data.length > 37) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(37, data.length - 37)]];
                    }
                    
                    photofileStartFound = YES;
                }
                
            } else {
                [receivedData appendData:data];
            }
            
            if (receivedData.length == photofile_size) {
                
                photofileStartFound = NO;
                photofile_size = 0;
                
                [self storePhotoIntoTempDocumentFolder:receivedData photoInfo:photoinfo];
                
                [self notifySenderRegardingPhotoFileReceiveCompletion];
                
                receivedData = nil;
                
            }
        } break;
            
        case RECEIVE_VIDEO_FILE:
        {
            if (!videofileStartFound) {
                
                if (data.length < 37) { // if header less than 37, package not complete, store it and wait for next package comes
                    pendingData = [NSMutableData dataWithData:data];
                    return;
                }
                
                NSData *tempdata = [data subdataWithRange:NSMakeRange(0, 37)];
                NSString *header = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
                
                NSRange range = [header rangeOfString:@"VZCONTENTTRANSFERVIDEOSTART"];
                if ((range.location != NSNotFound) && (header.length > 0)) {
                    
                    NSString *vcardLen = [header substringFromIndex:27];
                    videofile_size = vcardLen.longLongValue;
                    
                    tillNowVideoReceived = (long long)data.length - 37;
                    
                    // Clear previous video file
//                    NSString *documentsDirectory1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Documents"];
                    NSString *theFileName = [[videoinfo valueForKey:@"Path"] lastPathComponent];
                    NSString *filePath1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:theFileName];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath1]) {
                        [[NSFileManager defaultManager] removeItemAtPath:filePath1 error:nil];
                    }
                    
                    if (data.length > 37) {
                        NSData *tempDAta = [data subdataWithRange:NSMakeRange(37, data.length - 37)];
                        
                        self.intermediateData = nil;
                        self.intermediateData = [[NSMutableData alloc] init];
                        
                        [self storeVideoReceivedPacketToTempFile:tempDAta];
                    }
                    
                    videofileStartFound = YES;
                    
                    header = nil;
                }
                
            } else {
                tillNowVideoReceived += data.length;
                
                [self storeVideoReceivedPacketToTempFile:data];
            }
            
//            else if ((tillNowVideoReceived + data.length) < videofile_size) {
//                
//                // DebugLog(@"Video Data Received Still now :%lu out of %lu", tillNowVideoReceived,videofile_size);
//                
//                tillNowVideoReceived +=data.length;
//                
//                [self storeVideoReceivedPacketToTempFile:data];
//                
//            } else {
//                
//                NSData *lastpacketPortion  = [data subdataWithRange:NSMakeRange(0, (videofile_size-tillNowVideoReceived))];
//                
//                if (lastpacketPortion.length > 0) {
//                    
//                    // DebugLog(@"Video Data Received last packet now : %lu out of %lu", tillNowVideoReceived,videofile_size);
//                    
//                    tillNowVideoReceived +=lastpacketPortion.length;
//                    
//                    [self storeVideoReceivedPacketToTempFile:lastpacketPortion];
//                    lastpacketPortion = nil;
//                    
//                }
//            }
            
            if (tillNowVideoReceived == videofile_size) {
                
                videofileStartFound = NO;
                tillNowVideoReceived = 0;
                
                [self notifySenderRegardingVideoFileReceiveCompletion];
            }
        } break;
         
        case RECEIVE_CALENDAR_FILE:
        {
            if (!photofileStartFound) {
                
                if (data.length < 40) { // if header less than 37, package not complete, store it and wait for next package comes
                    pendingData = [NSMutableData dataWithData:data];
                    return;
                }
                
                NSData *tempdata = [data subdataWithRange:NSMakeRange(0, 40)];
                NSString *response = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
                
                if ([[response substringToIndex:30] isEqualToString:@"VZCONTENTTRANSFERCALENDARSTART"]) {
                    
                    NSString *calLen = [response substringFromIndex:30];
                    photofile_size = calLen.longLongValue;
                    
                    receivedData = [[NSMutableData alloc] init];
                    if (data.length > 40) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(40, data.length - 40)]];
                    }
                    
                    photofileStartFound = YES;
                    response = nil;
                }
                
            } else {
                [receivedData appendData:data];
            }
//            else if ((receivedData.length + data.length) < photofile_size) {
//                
//                [receivedData appendData:data];
//                
//            } else {
//                
//                if (data.length > photofile_size - receivedData.length) {
//                    data  = [data subdataWithRange:NSMakeRange(0, photofile_size - receivedData.length)];
//                }
//                
//                [receivedData appendData:data];
//            }
            
            if (receivedData.length == photofile_size) {
                
                photofileStartFound = NO;
                
                // Create MyPhoto folder to store photos
                NSString *docPath = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"ReceivedCal"];
                
                // create new folder
                if (![[NSFileManager defaultManager] fileExistsAtPath:docPath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:nil]; //Create folder
                }
                
                __block NSData *calData = receivedData;
                __block NSDictionary *calendar = self.calInfo;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    @autoreleasepool {
                        NSString *fullPath = [NSString stringWithFormat:@"%@/%@_%@",docPath,[calendar objectForKey:@"CalColor"], [calendar objectForKey:@"Path"]];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
                            [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
                        }
                        [calData writeToFile:fullPath atomically:NO];
                        
                        calData = nil;
                        calendar = nil;
                    }
                });
                
                receivedData = nil;
                
                [self notifySenderRegardingCalendarFileReceiveCompletion];
            }
        } break;
            
        case RECEVIE_REMINDER_FILE: {
            
            if (!reminderStartFound) {
                
                self.reminderFound = NO;
                
                if (data.length < 37) { // if header less than 37, package not complete, store it and wait for next package comes
                    pendingData = [NSMutableData dataWithData:data];
                    return;
                }
                
                NSData *tempdata = [data subdataWithRange:NSMakeRange(0, 37)];
                NSString *response1 = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
                
                NSRange range = [response1 rangeOfString:@"VZCONTENTTRANSFERREMINDERLO"];
                if ((range.location != NSNotFound) && (response1.length > 0)) {
                    
                    NSString *vcardLen = [response1 substringFromIndex:27];
                    
                    reminderfile_Size = vcardLen.longLongValue;
                    
                    reminderStartFound = YES;
                    
                    ++totalFilesReceived;
                    
//                    receivedData = nil;
                    receivedData = [[NSMutableData alloc] init];
                    
//                    if (reminderfile_Size == 0) {
//                        
//                        self.reminderFound = NO;
//                        
//                        --totalFilesReceived;
//                        [self notifySenderRegardingReminderFileReceiveCompletion];
//                        vcardfileStartfound = NO;
//                    }
                    
                    if (data.length > 37) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(37, data.length - 37)]];
                    }
                }
            } else {
                [receivedData appendData:data];
            }
            
//            else if (vcardStartFound && ((receivedData.length + data.length) < reminderfile_Size)) {
//                
//                [receivedData appendData:data];
//            } else {
//                
//                NSData *lastpacketPortion  = [data subdataWithRange:NSMakeRange(0, reminderfile_Size - receivedData.length)];
//                
//                vcardStartFound = TRUE;
//                
//                if (lastpacketPortion.length > 0) {
//                    
//                    [receivedData appendData:lastpacketPortion];
//                    
//                }
//            }
            
            if (receivedData.length == reminderfile_Size) {
                
                self.reminderFound = YES;
                
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.receivedFileStatuLbl setText:@"Reminder Received"];
                });
                
                __block NSData *vcardData = [[NSData alloc]initWithData:receivedData];
                
                if (reminderfile_Size > 0) {
                    
                    weakSelf.reminderFound = YES;
                    
//                    NSString *documentsDirectory1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Documents"];
                    NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"reminderLogFile.txt"];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        @autoreleasepool {
                            [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
                            [vcardData writeToFile:fileName atomically:NO];
                            
                            weakSelf.reminderReceived = YES;
                            
                            vcardData = nil;
                        }
                    });
                    
                    reminderStartFound = NO;
                    receivedData = nil;
                    
                    [self notifySenderRegardingReminderFileReceiveCompletion];
                }
                
            }
            
        } break;
            
        default:
            break;
    }
    
    [self updateDataMatrix:(int)data.length];
}

- (long long)getFreeDiskspace {
    long long totalSpace = 0;
    long long totalFreeSpace = 0;
    
    NSError *error = nil;
    NSString *basePath = [NSString appRootDocumentDirectory];
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:basePath error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        // DebugLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        // DebugLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return ((totalFreeSpace/1024ll)/1024ll);
}



- (BOOL)calculatetotalDownloadableDataSize {
    
    long long photoDataSize = 0;
    long long videoDataSize = 0;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
//    NSArray *photoArray = [userDefault valueForKey:@"photoFilteredFileList"];
//    
//    NSArray *videoArray = [userDefault valueForKey:@"videoFilteredFileList"];
        
    NSMutableDictionary *dict = [[userDefault valueForKey:@"itemList"] mutableCopy];
  
    [dict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"ReceiveDataScreen" withExtraInfo:dict isEncryptedExtras:false];

    
    if ([[dict valueForKey:@"photos"] isEqualToString:@"true"]) {
        NSArray *photoArray = [userDefault valueForKey:@"photoFilteredFileList"];
        for (NSDictionary *dict in photoArray) {
            @autoreleasepool {
                photoDataSize += [[dict valueForKey:@"Size"] longLongValue];
            }
        }
        
    }
    
    if ([[dict valueForKey:@"videos"] isEqualToString:@"true"]) {
        
        NSArray *videoArray = [userDefault valueForKey:@"videoFilteredFileList"];
        for (NSDictionary *dict in videoArray) {
            @autoreleasepool {
                videoDataSize += [[dict valueForKey:@"Size"] longLongValue];
            }
        }
    }
    
    
    totaldownloadableData = (long)vCardfile_size + photoDataSize + videoDataSize;
    
//#ifdef DEV_ENV
    
    long long calFileSize = 0;
    
    if ([[dict valueForKey:@"calendar"] isEqualToString:@"true"]) {
        NSArray *cals = [userDefault valueForKey:@"calFileList"];
        for (NSDictionary *cal in cals) {
            calFileSize += [[cal objectForKey:@"Size"] integerValue];
        }
    }
    totaldownloadableData += calFileSize;
    
//#endif
    
    totalPayLoadSize =(long)(totaldownloadableData/(1000 * 1000));
    availableStorage = self.getFreeDiskspace;
    
    __weak typeof(self) weakSelf = self;
    if (totalPayLoadSize > availableStorage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = [NSString stringWithFormat:@"Insufficient storage. Only %lld MB  available on the device. Free some space and try again.",(availableStorage)];
            
            CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self dataTransferInterrupted:INSUFFICIENT_STORAGE];
//                [self performSegueWithIdentifier:@"ReceiverBonJourCompleted" sender:nil];
            }];
            
            [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:str cancelAction:nil otherActions:@[okAction] isGreedy:NO];
        });
        
        return NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.totalDownloadDataSizeLbl setText:[NSString stringWithFormat:@"Total Size : %lld MB",weakSelf.totalPayLoadSize]];
    });
    
  
    
    return YES;
}

- (void) updateDataMatrix:(int)datalen {
    
    totalDownloadedData +=  (float)datalen/(1000 * 1000);
    
    NSDate *currentTime = [NSDate date];
    
    NSTimeInterval secondsBetween = [currentTime timeIntervalSinceDate:self.startTime];
    
    int hh = secondsBetween / (60*60);
    double rem = fmod(secondsBetween, (60*60));
    int mm = rem / 60;
    rem = fmod(rem, 60);
    int ss = rem;
    
    NSString *str = [NSString stringWithFormat:@"%02d:%02d:%02d",hh,mm,ss];
    
    downloadSpeed = totalDownloadedData/(float)secondsBetween * 8;
    
    if (downloadSpeed > maxspeed) {
        maxspeed = downloadSpeed;
    }
    
    NSTimeInterval estimatedSeconds =  (totaldownloadableData/(1000 * 1000) - totalDownloadedData)/downloadSpeed * 8;
    
    hh = estimatedSeconds / (60*60);
    rem = fmod(estimatedSeconds, (60*60));
    mm = rem / 60;
    rem = fmod(rem, 60);
    ss = rem;
    
    if (ss < 0) {
        ss = 0;
    }
    
    NSString *str1 = [NSString stringWithFormat:@"%02d:%02d:%02d",hh,mm,ss];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf.downloadSpeedLbl setText:[NSString stringWithFormat:@"Speed: %.f Mbps",weakSelf.downloadSpeed]];
        
        [weakSelf.timeElaspedLbl setText:[NSString stringWithFormat:@"Time Elapsed:%@",str]];
        
        [weakSelf.timeestimatedLbl setText:[NSString stringWithFormat:@"Time Estimated:%@",str1]];
        
        [weakSelf.totalDownLoadedDataLbl setText:[NSString stringWithFormat:@"Received: %.f MB",(weakSelf.totalDownloadedData * (1000 * 1000))/(1024.0f * 1024.0f)]];
        
        if (recevier_state != RECEIVE_ALL_FILE_LOG) {
            weakSelf.dataDownloadProgressBar.progress = totalDownloadedData/(totaldownloadableData/(1000 * 1000));
        }
    });
}

#pragma mark - Finish functions for each section
- (void)notifyAllFileListCompletion:(BOOL)shouldUpdateUI {
//    DebugLog(@"->received file list");
    
    if (shouldUpdateUI) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.receivedFileStatuLbl setText:@"Received File List"];
        });
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dict = [[userDefault valueForKey:@"itemList"] mutableCopy];
    
    BOOL flag = YES;
    
    if (!self.hasCalendarPermissionErr && [[dict valueForKey:@"calendar"] isEqualToString:@"true"]) {
#warning TODO: SHOULD SHOW PERMISSION ERROR IN FINAL LIST
        self.hasCalendarSent = YES;
        
        self.calList = [userDefault valueForKey:@"calFileList"];
        
        [dict setValue:@"false" forKey:@"calendar"];
        [userDefault setValue:dict forKey:@"itemList"];
        
        flag = NO;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.receivedFileStatuLbl setText:@"Receiving Calendars"];
        });
        
        self.calCountIndex = 0; // 0 index init
        self.calInfo = [self.calList objectAtIndex:_calCountIndex];
        
        DebugLog(@"Calendar info:\n%@",self.calInfo);
        
        NSString *ackMsg = nil;
        if (self.calList.count == 1) {
            ++ totalFilesReceived;
            ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_FINAL_REQUEST_FOR_CALENDAR_%@",[self.calInfo valueForKey:@"Path"]];
        } else {
            ++ totalFilesReceived;
            ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_START_REQUEST_FOR_CALENDAR_%@",[self.calInfo valueForKey:@"Path"]];
        }
        NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
        
        recevier_state = RECEIVE_CALENDAR_FILE;
        
        [[BonjourManager sharedInstance] sendFileStream:requestData];
        
    } else if (!self.hasVcardPermissionErr && [[dict valueForKey:@"contacts"] isEqualToString:@"true"]) {
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.receivedFileStatuLbl setText:@"Receiving contacts..."];
        });
        
        self.photolist = [userDefault valueForKey:@"photoFilteredFileList"];
        
        [dict setValue:@"false" forKey:@"contacts"];
        [userDefault setValue:dict forKey:@"itemList"];
        [userDefault synchronize];
        
        flag = NO;
        
        NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_VCARD"];
        
        NSData *requestData = [shareKey dataUsingEncoding:NSUTF8StringEncoding];
        
        recevier_state = RECEIVE_VCARD_FILE;

        [[BonjourManager sharedInstance] sendFileStream:requestData];
        
    } else if (!self.hasReminderPermissionErr && [[dict valueForKey:@"reminder"] isEqualToString:@"true"] && flag) {

            [dict setValue:@"false" forKey:@"reminder"];
            
            [userDefault setValue:dict forKey:@"itemList"];
        
//            ++totalFilesReceived;
        
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.receivedFileStatuLbl setText:@"Receiving Reminder"];
            });
            
            
            flag = NO;
            
            NSString *ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_REMIN"];
            
            NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
            
            recevier_state = RECEVIE_REMINDER_FILE;
            
            [[BonjourManager sharedInstance] sendFileStream:requestData];
    
    
    } else {
        
        if (!self.hasAlbumPermissionErr && [[dict valueForKey:@"photos"] isEqualToString:@"true"]) {
            
            recevier_state = RECEIVE_PHOTO_FILE;
        
            self.photolist = [userDefault valueForKey:@"photoFilteredFileList"];
            [dict setValue:@"false" forKey:@"photos"];
            [userDefault setValue:dict forKey:@"itemList"];
            [userDefault synchronize];
            
            __weak typeof(self) weakSelf = self;
            if ([self.photolist count] > 0) {
                
                ++totalFilesReceived;
                
                flag = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.receivedFileStatuLbl setText:[NSString stringWithFormat:@"Photos %d of %lu",weakSelf.photoCountIndex,(unsigned long)[weakSelf.photolist count]]];
                });
                
                photoinfo = [photolist objectAtIndex:photoCountIndex];
                
                // DebugLog(@"Photo to be downlaoded %d",photoCountIndex);
                
                photoCountIndex++;
                
                // NSdictionary has "Path" and "Size" has keys
                
                NSString *ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_%@",[photoinfo valueForKey:@"Path"]];
                
                NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
                
                [[BonjourManager sharedInstance] sendFileStream:requestData];
            }
        }
        
        if (!self.hasAlbumPermissionErr && [[dict valueForKey:@"videos"] isEqualToString:@"true"] && flag) {
            
            self.videolist = [userDefault valueForKey:@"videoFilteredFileList"];
            
            [dict setValue:@"false" forKey:@"videos"];
            
            [userDefault setValue:dict forKey:@"itemList"];
            
            
            
            __weak typeof(self) weakSelf = self;
            
            if ([self.videolist count] > 0) {
                
                ++totalFilesReceived;
                
                flag = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if(weakSelf.videoCountIndex != 0)
                    [weakSelf.receivedFileStatuLbl setText:[NSString stringWithFormat:@"Video %d of %lu",weakSelf.videoCountIndex,(unsigned long)[weakSelf.videolist count]]];
                });
                
                videoinfo = [videolist objectAtIndex:videoCountIndex];
                videoCountIndex++;
                
                // DebugLog(@"Video to be downlaoded %@",videoinfo);
                
                // NSdictionary has "Path" and "Size" has keys
                
                NSString *ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_%@",[videoinfo valueForKey:@"Path"]];
                
                NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
                
                recevier_state = RECEIVE_VIDEO_FILE;
                
                [[BonjourManager sharedInstance] sendFileStream:requestData];
                
            }
        }
        
        if (flag) {
            
            [self dataTransferFinished];
        }
        
    }
    
}


- (void) notifySenderRegardingPhotoFileReceiveCompletion
{
    recevier_state = RECEIVE_PHOTO_FILE;
    
    __weak typeof(self) weakSelf = self;
    
    if (photoCountIndex == [photolist count]) {
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSDictionary *dict = [userDefault valueForKey:@"itemList"];
        
        if ([[dict valueForKey:@"videos"] isEqualToString:@"true"]) {
            
            recevier_state = RECEIVE_VIDEO_FILE;
            
            self.videolist = [userDefault valueForKey:@"videoFilteredFileList"];
            
            ++totalFilesReceived;
            
            if ([self.videolist count] > 0) {
                
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.receivedFileStatuLbl setText:[NSString stringWithFormat:@"Video 1 of %lu",(unsigned long)[weakSelf.videolist count]]];
                });
                
                videoinfo = [videolist objectAtIndex:videoCountIndex];
                videoCountIndex++;
                
                NSString *ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_%@",[videoinfo valueForKey:@"Path"]];
                
                NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
                
                [[BonjourManager sharedInstance] sendFileStream:requestData];
            } else {
                [self dataTransferFinished];
            }
        } else {
            [self dataTransferFinished];
        }
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.receivedFileStatuLbl setText:[NSString stringWithFormat:@"Photo %d of %lu",weakSelf.photoCountIndex,(unsigned long)[weakSelf.photolist count]]];
        });
        
        
        if (memoryWarningFlag) {
            self.dataDownloadProgressBar.hidden = YES;
            [self.processingDataLbl setText:@"Please wait.. Processing Downloaded Data"];
            
            return;
        }
        
        photoinfo = [photolist objectAtIndex:photoCountIndex];
        photoCountIndex++;
        
        ++totalFilesReceived;
        
        NSString *ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_%@",[photoinfo valueForKey:@"Path"]];
        NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
        [[BonjourManager sharedInstance] sendFileStream:requestData];
    }
}

- (void)notifySenderRegardingCalendarFileReceiveCompletion
{
    ++ _calCountIndex;
    
    if (_calCountIndex >= self.calList.count) {
        self.calendarReceived = YES;
        [self notifyAllFileListCompletion:NO];
    } else {
        self.calInfo = [self.calList objectAtIndex:_calCountIndex];
        DebugLog(@"Calendar info:\n%@",self.calInfo);
        
        NSString *ackMsg = nil;
        if (_calCountIndex == self.calList.count - 1) {
            ++ totalFilesReceived;
            ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_FINAL_REQUEST_FOR_CALENDAR_%@",[self.calInfo valueForKey:@"Path"]];
        } else {
            ++ totalFilesReceived;
            ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_ORIGI_REQUEST_FOR_CALENDAR_%@",[self.calInfo valueForKey:@"Path"]];
        }
        
        NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
        
        recevier_state = RECEIVE_CALENDAR_FILE;
        [[BonjourManager sharedInstance] sendFileStream:requestData];
    }
}


- (void)notifySenderRegardingReminderFileReceiveCompletion
{
    [self notifyAllFileListCompletion:YES];
}

- (void) notifySenderRegardingVideoFileReceiveCompletion {
    
    recevier_state = RECEIVE_VIDEO_FILE;
    
    if (videoCountIndex >= [videolist count]) {
        [self dataTransferFinished];
    } else {
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([weakSelf.videolist count] > 0) {
                if (weakSelf.videoCountIndex != 0)
                    [weakSelf.receivedFileStatuLbl setText:[NSString stringWithFormat:@"Video %d of %lu", weakSelf.videoCountIndex,(unsigned long)[weakSelf.videolist count]]];
            }
            
        });
        
        videoinfo = [videolist objectAtIndex:videoCountIndex];
        videoCountIndex++;
        
        ++totalFilesReceived;
        
        NSString *ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_%@",[videoinfo valueForKey:@"Path"]];
        
        NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
        
        [[BonjourManager sharedInstance] sendFileStream:requestData];
    }
}

- (void)dataTransferFinished {
    
    // Need this wait in case of just contact transfer
    self.disableCountDown = YES;
    
//    sleep(1);
    
    if ([timeoutCountingTimer isValid]) { // disable the timer once data transfer finished, ignoring the saving process
        [timeoutCountingTimer invalidate];
    }
    
    [self.cancelBtn setEnabled:NO];
    [self.cancelBtn setAlpha:0.4];
    
    NSDate *date = [NSDate date];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault setObject:date forKey:@"ENDTIME"];
    
    NSString *totalDownloadStr = @"";
    if (totalDownloadedData == 0) {
        totalDownloadStr = @"0MB";
    } else if (totalDownloadedData < 1.0f) {
        totalDownloadStr = @"Less than 1MB";
    } else {
        totalDownloadStr = [NSString stringWithFormat:@"%.fMB",totalDownloadedData];
    }
    
    [userDefault setObject:totalDownloadStr forKey:@"TOTALDOWNLOADEDDATA"];
    
    [userDefault setValue:[NSString stringWithFormat:@"%d",totalFilesReceived] forKey:@"TOTALFILESRECEIVED"];
    
    NSString *ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_FINISHED"];
    
    NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
    
    // Waiting for All pending task to complete
    
    //    [serailPhotoQueue waitUntilAllOperationsAreFinished];
    
    [[BonjourManager sharedInstance] sendFileStream:requestData];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([weakSelf.videolist count] > 0) {
            
            if(weakSelf.videoCountIndex != 0)
                [weakSelf.receivedFileStatuLbl setText:[NSString stringWithFormat:@"Video %d of %lu",weakSelf.videoCountIndex,(unsigned long)[weakSelf.videolist count]]];
        }
        
    });
    
    self.targetType = TRANSFER_SUCCESS;
    
    if (!self.hasVcardPermissionErr && vCardfile_size > 0) { // save contacts first
        
//        NSString *documentsDirectory1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Documents"];
        NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZAllContactBackup.vcf"];
        
        NSData *vcardData = [[NSFileManager defaultManager] contentsAtPath:fileName];
        
        if (vcardData && vcardData.length > 0) {
            NSInvocationOperation *newoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(importVcardData:) object:vcardData];
            [serailPhotoQueue addOperation:newoperation];
        } else {
            self.vCardfile_size = 0;
            [self finishedAllOperation];
        }
    } else {
        [self finishedAllOperation];
    }
}

- (void)dataTransferInterrupted:(NSInteger)typeID {
    
    NSDate *date = [NSDate date];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:date forKey:@"ENDTIME"];
    
    NSString *totalDownloadStr = @"";
    if (totalDownloadedData == 0) {
        totalDownloadStr = @"0MB";
    } else if (totalDownloadedData < 1.0f) {
        totalDownloadStr = @"Less than 1MB";
    } else {
        totalDownloadStr = [NSString stringWithFormat:@"%.fMB",totalDownloadedData];
    }
    
    [userDefault setObject:totalDownloadStr forKey:@"TOTALDOWNLOADEDDATA"];
    [userDefault setValue:[NSString stringWithFormat:@"%d",totalFilesReceived] forKey:@"TOTALFILESRECEIVED"];
    
    self.targetType = typeID;
    
    if (!self.hasVcardPermissionErr && vCardfile_size > 0) { // Cancel saving contacts  
//        NSString *documentsDirectory1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Documents"];
        NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZAllContactBackup.vcf"];
        NSData *vcardData = [[NSFileManager defaultManager] contentsAtPath:fileName];
        if (vcardData && vcardData.length > 0) {
            NSInvocationOperation *newoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(importVcardData:) object:vcardData];
            [serailPhotoQueue addOperation:newoperation];
        } else {
            self.vCardfile_size = 0;
            [self finishedAllOperation];
        }
    } else {
        [self finishedAllOperation];
    }
}

- (void)finishedAllOperation {
    
    if (tempPhotoCount > 0 && tempPhotoCount == (self.photoSavingList.count + self.photoSavingList2.count + self.photoSavingList3.count + self.photoSavingList4.count + self.photoSavingList5.count + self.photoSavingList6.count)) { // if photos need to be saved, save photo first
        allPhotoDownLoadFlag = NO;
        [self storePhotoIntoGallery];
    } else if (tempVideoCount > 0 || videoAlreadyWrittenList.count > 0) { // no photos, save videos
        allPhotoDownLoadFlag = NO;
        
        if ([self nothingToWrite:[videoWrittingTaskList allValues]]) {
            [self storeVideoIntoGallery];
        }
    }
    
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
    
    [infoDict setObjectIfValid:[NSString stringWithFormat:@"%ld",(long)self.numberOfContacts] forKey:@"ContactCount" defaultObject:@0];
    [infoDict setObjectIfValid:[NSString stringWithFormat:@"%lu", (unsigned long)self.photolist.count] forKey:@"PhotosCount" defaultObject:@0];
    [infoDict setObjectIfValid:[NSString stringWithFormat:@"%lu",(unsigned long)self.videolist.count] forKey:@"VideosCount" defaultObject:@0];
    [infoDict setObjectIfValid:[NSString stringWithFormat:@"%ld",(long)self.calList.count] forKey:@"CalendarCount" defaultObject:@0];
    [infoDict setObject:reminderFound?@"1":@"0" forKey:@"ReminderCount"];
    [infoDict setObject:@"0" forKey:@"SmsCount"];
    [infoDict setObject:@"0" forKey:@"CallLogsCount"];
    [infoDict setObject:@"0" forKey:@"MusicCount"];
    [infoDict setValue:@"Bonjour" forKey:@"ConnectionType"];
    [infoDict setObjectIfValid:[NSString stringWithFormat:@"%lld",self.totalPayLoadSize] forKey:@"TotalDataReceived" defaultObject:@0];
    [infoDict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"ReceiveDataScreen" withExtraInfo:infoDict isEncryptedExtras:false];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"VZContentTransfer" bundle:nil];
        VZTransferFinishViewController *viewController = (VZTransferFinishViewController *)[storyboard instantiateViewControllerWithIdentifier:@"vzfinish"];
        if (viewController != nil) {
            [weakSelf pushViewController:viewController];
        }
    });
}

- (void)pushViewController:(UIViewController *)viewController
{
    NSAssert([NSThread isMainThread], @"Trying to push new viewcontroller in background thread, might cause crash.");
    
    VZTransferFinishViewController *destination = (VZTransferFinishViewController *)viewController;
    
    destination.summaryDisplayFlag = 2;
    // Manipulate the data
    self.trasnferCancel ? (destination.numberOfPhotos = (tempPhotoCount + 1 > self.photolist.count ? tempPhotoCount : tempPhotoCount + 1)) : (destination.numberOfPhotos = tempPhotoCount);
    [self nothingToWrite:[self.videoWrittingTaskList allValues]] ? (destination.numberOfVideos = (self.videoAlreadyWrittenList.count > 0 ? tempVideoCount + self.videoAlreadyWrittenList.count : tempVideoCount)) : (destination.numberOfVideos = tempVideoCount + videoAlreadyWrittenList.count);
    destination.numberOfContacts = self.numberOfContacts;
    destination.numberOfCalendar = self.calList.count;
    destination.numberOfReminder = reminderFound?1:0; // hard coded, file number
    destination.maxspeed = maxspeed;
    destination.isSender = NO;
    destination.transferInterrupted = self.trasnferCancel;
    destination.importReminder = reminderFound;
    destination.mediaTypePiped = mediaTypePiped;
    destination.transferStarted = self.receviedCancelRequest;
    
    int notReadyVideoCount = (int)videoAlreadyWrittenList.count;
    
    destination.hasAlbumPermissionErr = self.hasAlbumPermissionErr;
    destination.hasVcardPermissionErr = self.hasVcardPermissionErr;
    
    destination.analyticsTypeID = self.targetType;
    
    destination.delegate = destination;
    self.delegate = destination.delegate;
    
    if (tempPhotoCount > 0 || (tempVideoCount > 0 || notReadyVideoCount > 0)) {
        if ((tempVideoCount > 0 || notReadyVideoCount > 0) && tempPhotoCount > 0) {
            if (self.videoAlreadyWrittenList.count == 0) {
                destination.downLoadDataLblStr = [NSString stringWithFormat:@"Please wait.. %d Photo(s) and %d Video(s) to be saved",tempPhotoCount, tempVideoCount];
            } else {
                destination.downLoadDataLblStr = [NSString stringWithFormat:@"Please wait.. %d Photo(s) and %d Video(s) to be saved",tempPhotoCount, tempVideoCount+notReadyVideoCount];
            }
        } else if (tempPhotoCount > 0) {
            destination.downLoadDataLblStr = [NSString stringWithFormat:@"Please wait.. %d Photo(s) to be saved", tempPhotoCount];
        } else if (tempVideoCount > 0 || notReadyVideoCount > 0) {
            videoWrittingTaskList.count == 0 ? (destination.downLoadDataLblStr = [NSString stringWithFormat:@"Please wait.. %d Video(s) to be saved", tempVideoCount]) : (destination.downLoadDataLblStr = [NSString stringWithFormat:@"Please wait.. %d Video(s) to be saved", tempVideoCount + notReadyVideoCount]);
        } else {
            destination.downLoadDataLblStr = @"Please wait.. Processing Downloaded Data";
        }
        
        destination.processEnd = NO;
        destination.calendarReceived = self.hasCalendarSent;
        
    } else {
        destination.calendarReceived = self.hasCalendarSent;
        if (self.hasCalendarSent && !self.trasnferCancel) {
            destination.downLoadDataLblStr = @"Please wait.. Importing Calendars";
        } else if (reminderFound) {
            destination.downLoadDataLblStr = @"Please wait.. Importing Reminders";
        } else {
            if (self.trasnferCancel) {
                destination.downLoadDataLblStr = @"Transfer did not complete. Please review transfer summary.";
            } else if (self.videoFailedList.count == 0 && self.photoFailedList.count == 0 && !self.hasAlbumPermissionErr && !self.hasVcardPermissionErr) {
                destination.downLoadDataLblStr = @"Data Transfer completed successfully!";
            } else {
                destination.photoErrList = self.photoFailedList;
                destination.videoErrList = self.videoFailedList;
                destination.downLoadDataLblStr = @"Download completed with Error(s), tap on \"Summary\" to check the detail.";
            }
            
            if (!self.trasnferCancel) {
                // Because the synchronize for NSUserDefault is async, so wait for 2 sec to finish writing
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PHOTODUPLICATELIST"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VIDEODUPLICATELIST"]; // after all data saved finished, remove the duplicate list
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else { // if cancelled
                [[NSUserDefaults standardUserDefaults] setBool:self.vcardReceived forKey:@"VCARDDUPLICATELIST"];
                [[NSUserDefaults standardUserDefaults] setBool:self.calendarReceived forKey:@"CALENDARDUPLICATELIST"];
                [[NSUserDefaults standardUserDefaults] setBool:self.reminderReceived forKey:@"REMINDERDUPLICATELIST"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
        destination.processEnd = YES;
    }
    
    [self.navigationController pushViewController:destination animated:YES];
}

#pragma mark - Saving Methods

- (void)importVcardData:(NSData *)vcardData {

    VZContactsImport *vCardImport = [[VZContactsImport alloc] init];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.vCardfile_size = 0;
        [weakSelf.processingDataLbl setText:@"Please wait... Importing Contacts"];
        [weakSelf.dataReceivingStatus setText:@"Saving Contacts"];
        weakSelf.dataDownloadProgressBar.hidden = YES;
    });
    
    vCardImport.completionHandler = ^(NSInteger contactNumber) {
        weakSelf.numberOfContacts = contactNumber;
        weakSelf.vCardfile_size = 0;
        [weakSelf finishedAllOperation];
    };
    
    [vCardImport importAllVcard:vcardData];
}

- (void)storePhotoIntoTempDocumentFolder:(NSData*)photoData
                               photoInfo:(NSDictionary *)photoPath {
    
    tempPhotoCount++;
    
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",self.photoFolderPath,[photoPath valueForKey:@"Path"]];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ // writing files into the disk in background
        @autoreleasepool {
            [photoData writeToFile:fileName atomically:NO];
            
            @synchronized (weakSelf) {
                if (photoSavingArrayIndex == 0) {
                    photoSavingArrayIndex ++;
                    
                    if (!photoSavingList) {
                        photoSavingList = [[NSMutableArray alloc] init];
                    }
                    [photoSavingList addObject:photoPath];
                } else if (photoSavingArrayIndex == 1) {
                    photoSavingArrayIndex ++;
                    
                    if (!photoSavingList2) {
                        photoSavingList2 = [[NSMutableArray alloc] init];
                    }
                    [photoSavingList2 addObject:photoPath];
                } else if (photoSavingArrayIndex == 2) {
                    photoSavingArrayIndex ++;
                    
                    if (!photoSavingList3) {
                        photoSavingList3 = [[NSMutableArray alloc] init];
                    }
                    [photoSavingList3 addObject:photoPath];
                } else if (photoSavingArrayIndex == 3) {
                    photoSavingArrayIndex ++;
                    
                    if (!photoSavingList4) {
                        photoSavingList4 = [[NSMutableArray alloc] init];
                    }
                    [photoSavingList4 addObject:photoPath];
                } else if (photoSavingArrayIndex == 4) {
                    photoSavingArrayIndex ++;
                    
                    if (!photoSavingList5) {
                        photoSavingList5 = [[NSMutableArray alloc] init];
                    }
                    [photoSavingList5 addObject:photoPath];
                } else if (photoSavingArrayIndex == 5) {
                    photoSavingArrayIndex = 0;
                    
                    if (!photoSavingList6) {
                        photoSavingList6 = [[NSMutableArray alloc] init];
                    }
                    [photoSavingList6 addObject:photoPath];
                }
            }
            
            if (tempPhotoCount == self.photolist.count) {
                DebugLog(@"break point");
            }
            
            if ((self.trasnferCancel || self.disableCountDown) && tempPhotoCount == (self.photoSavingList.count + self.photoSavingList2.count + self.photoSavingList3.count + self.photoSavingList4.count + self.photoSavingList5.count + self.photoSavingList6.count) && vCardfile_size <= 0) {
                [self storePhotoIntoGallery];
            }
        }
    });
}

- (void)storePhotoIntoGallery
{
    dispatch_once(&_once_photo, ^{
        // If photo exists, saving photo first
//        PhotoStoreHelper *helper = [[PhotoStoreHelper alloc] initWithOperationDelegate:self andRootPath:photoFolderPath andDataSets:self.photoSavingList, self.photoSavingList2, self.photoSavingList3, self.photoSavingList4, self.photoSavingList5, self.photoSavingList6, nil];
//        [helper startSavingPhotos];
    });
}

- (void)storeVideoIntoGallery
{
    if (self.videoAlreadyWrittenList.count > 0) {
        NSArray *fileNames = [self.videoAlreadyWrittenList allKeys];
        for (NSString *fileName in fileNames) {
            NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
            [info setValue:fileName forKey:@"Path"];
            DebugLog(@"%@", info);
            
            if (!self.anotherThread) {
                if (!self.videoSavingList) {
                    self.videoSavingList = [[NSMutableArray alloc] init];
                }
                [self.videoSavingList addObject:info];
                
                self.anotherThread = YES;
            } else {
                if (!self.videoSavingList2) {
                    self.videoSavingList2 = [[NSMutableArray alloc] init];
                }
                [self.videoSavingList2 addObject:info];
                
                self.anotherThread = NO;
            }
            
            self.tempVideoCount++;
        }
        
        [self.videoWrittingTaskList removeAllObjects];
        [self.videoAlreadyWrittenList removeAllObjects];
    }
    
    dispatch_once(&_once, ^{
//        PhotoStoreHelper *helper = [[PhotoStoreHelper alloc] initWithOperationDelegate:self andRootPath:videoFolderPath andDataSets:self.videoSavingList, self.videoSavingList2, nil];
//        [helper startSavingVideos];
    });
}


- (void)storeVideoReceivedPacketToTempFile:(NSData *)receivedPacket {
    
    NSString *tempstr = [videoinfo valueForKey:@"Path"];
    NSString *theFileName = [tempstr lastPathComponent];
    
//    NSString *fileName = [documentsDirectory1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",theFileName]];
    
    
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",self.videoFolderPath,theFileName];
    
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForWritingAtPath:fileName];
    
    if (fileHandler){
        
        if ((self.intermediateData.length + receivedPacket.length < packageSize * 1024 * 1024) && (tillNowVideoReceived != videofile_size)) {
            [self.intermediateData appendData:receivedPacket];
            
            return;
        }
        
        [self.intermediateData appendData:receivedPacket];
        
        // Add data to be written to the list
        if (![self.videoWrittingTaskList objectForKey:theFileName]) {
            VZConcurrentWritingHelper *videoPackage = [[VZConcurrentWritingHelper alloc] initWithID:theFileName andSize:videofile_size andInfo:videoinfo andPackage:self.intermediateData];
            [self.videoWrittingTaskList setObject:videoPackage forKey:theFileName];
        } else {
            @synchronized (self) {
                [((VZConcurrentWritingHelper *)[self.videoWrittingTaskList objectForKey:theFileName]).packagesWaitingForWriting addObject:self.intermediateData];
            }
        }
        
        __weak typeof(self) weakSelf = self;
        if (!((VZConcurrentWritingHelper *)[self.videoWrittingTaskList objectForKey:theFileName]).currentLock) { // current file writting is not start
            
            @synchronized (self) {
                ((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:theFileName]).currentLock = YES; // add lock
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                @autoreleasepool {
                    while (((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:theFileName]).packagesWaitingForWriting.count > 0) {
                        @autoreleasepool {
                            [fileHandler seekToEndOfFile];
                            
                            NSData *videoPackage = (NSData *)[((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:theFileName]).packagesWaitingForWriting objectAtIndex:0];
                            
                            [fileHandler writeData:videoPackage];
                            
                            @synchronized (weakSelf) {
                                [((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:theFileName]).packagesWaitingForWriting removeObjectAtIndex:0];
                            }
                            
                            [weakSelf updateVideoWritingListFor:theFileName
                                                  withVideoSize:((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:theFileName]).videoSize
                                                 withDataLength:videoPackage.length
                                                  withVideoInfo:((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:theFileName]).videoInfo];
                            
                            videoPackage = nil;
                        }
                    }
                    
                    ((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:theFileName]).currentLock = NO; // remove lock
                }
            });
        }
    } else { // first package
        [receivedPacket writeToFile:fileName atomically:NO];
        [self updateVideoWritingListFor:theFileName withVideoSize:videofile_size withDataLength:receivedPacket.length withVideoInfo:videoinfo];
    }
    
    self.intermediateData = nil;
    self.intermediateData = [[NSMutableData alloc] init];
}

- (void)updateVideoWritingListFor:(NSString *)fileName
                    withVideoSize:(long long)videoSize
                   withDataLength:(NSUInteger)length
                    withVideoInfo:(NSDictionary *)localVideoInfo {
    
    if ([self.videoAlreadyWrittenList objectForKey:fileName]) { // exist
        NSUInteger currentPackLength = [(NSNumber *)[self.videoAlreadyWrittenList objectForKey:fileName] unsignedIntegerValue];
        currentPackLength += length;
        if (currentPackLength == videoSize) {
            
            @synchronized (self) {
                if (!self.anotherThread) {
                    if (!self.videoSavingList) {
                        self.videoSavingList = [[NSMutableArray alloc] init];
                    }
                    [self.videoSavingList addObject:localVideoInfo];
                    
                    self.anotherThread = YES;
                } else {
                    if (!self.videoSavingList2) {
                        self.videoSavingList2 = [[NSMutableArray alloc] init];
                    }
                    [self.videoSavingList2 addObject:localVideoInfo];
                    self.anotherThread = NO;
                }
            }
            
            // clear
            [self.videoAlreadyWrittenList removeObjectForKey:fileName];
            [self.videoWrittingTaskList removeObjectForKey:fileName];
            
            @synchronized (self) {
                self.tempVideoCount++;
            }
            
            // call save function
            if (!self.trasnferCancel && self.disableCountDown && videoAlreadyWrittenList.count == 0 && self.tempPhotoCount == 0 && (self.hasVcardPermissionErr || vCardfile_size <= 0)) {
                [self storeVideoIntoGallery];
            } else if (self.trasnferCancel && self.disableCountDown && [self nothingToWrite:[videoWrittingTaskList allValues]] && self.tempPhotoCount == 0 && (self.hasVcardPermissionErr || vCardfile_size <= 0)) {
                [self storeVideoIntoGallery];
            }
        } else {
            [self.videoAlreadyWrittenList setObject:[NSNumber numberWithUnsignedInteger:currentPackLength] forKey:fileName];
            
            if (self.trasnferCancel && self.disableCountDown && [self nothingToWrite:[videoWrittingTaskList allValues]] && self.tempPhotoCount == 0 && (self.hasVcardPermissionErr || vCardfile_size <= 0)) {
                [self storeVideoIntoGallery];
            }
        }
    } else { // not exist
        if (length == videoSize) { // video size is equals to package size
            @synchronized (self) {
                tempVideoCount++;
                if (!self.anotherThread) {
                    if (!self.videoSavingList) {
                        self.videoSavingList = [[NSMutableArray alloc] init];
                    }
                    [self.videoSavingList addObject:localVideoInfo];
                    
                    self.anotherThread = YES;
                } else {
                    //                    @synchronized (self) {
                    if (!self.videoSavingList2) {
                        self.videoSavingList2 = [[NSMutableArray alloc] init];
                    }
                    [self.videoSavingList2 addObject:localVideoInfo];
                    //                    }
                    self.anotherThread = NO;
                }
            }
            
            // call save function
            if (!self.trasnferCancel && self.disableCountDown && videoAlreadyWrittenList.count == 0 && self.tempPhotoCount == 0 && (self.hasVcardPermissionErr || vCardfile_size <= 0)) {
                [self storeVideoIntoGallery];
            } else if (self.trasnferCancel && self.disableCountDown && [self nothingToWrite:[videoWrittingTaskList allValues]] && self.tempPhotoCount == 0 && (self.hasVcardPermissionErr || vCardfile_size <= 0)) {
                [self storeVideoIntoGallery];
            }
        } else {
            [self.videoAlreadyWrittenList setObject:[NSNumber numberWithUnsignedInteger:length] forKey:fileName];
            
            if (self.trasnferCancel && self.disableCountDown && [self nothingToWrite:[videoWrittingTaskList allValues]] && self.tempPhotoCount == 0 && (self.hasVcardPermissionErr || vCardfile_size <= 0)) {
                [self storeVideoIntoGallery];
            }
        }
    }
}

- (BOOL)nothingToWrite:(NSArray *)taskList
{
    BOOL result = YES;
    for (VZConcurrentWritingHelper *helper in taskList) {
        if (helper.packagesWaitingForWriting.count > 0) {
            result = NO;
        }
    }
    
    return result;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ReceiverBonJourCompleted"]) {
        
    }
}


#pragma mark - NSNetServiceDelegate

#define WAIT_FOR_STREAMS_LIMIT 80
int ReceiverStreamWaitingCountdown = 0;

- (void)netServiceDidPublish:(NSNetService *)sender
{
    self.processingDataLbl.text = @"Service published...";
    
    [NSThread detachNewThreadSelector:@selector(newThreadHandler:) toTarget:self withObject:nil];
}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
    [self performSelectorOnMainThread:@selector(updateTitleLabelInMainThread:) withObject:@"Building the connection..." waitUntilDone:NO];
    
    [BonjourManager sharedInstance].inputStream = nil;
    [BonjourManager sharedInstance].outputStream = nil;
    [BonjourManager sharedInstance].streamOpenCount = 0;
    
    // user tapped device: so create and open streams with that devices
    assert([BonjourManager sharedInstance].inputStream == nil);
    assert([BonjourManager sharedInstance].outputStream == nil);
    assert([BonjourManager sharedInstance].streamOpenCount == 0);
    
    // streams must exist but aren't open
    assert([NSThread isMainThread]);
    
    // we accepted connection to another device so open in/out connection streams
    [BonjourManager sharedInstance].inputStream  = inputStream;
    [BonjourManager sharedInstance].outputStream = outputStream;
    
    [[BonjourManager sharedInstance].outputStream setDelegate:self];
    [[BonjourManager sharedInstance].inputStream  setDelegate:self];
    
}

- (void)newThreadHandler:(NSThread *)thread
{
    // streams must exist but aren't open
    assert(![NSThread isMainThread]);
    
    ReceiverStreamWaitingCountdown = 0;
    NSTimer *runloopController = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(runloopLive:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:runloopController forMode:NSDefaultRunLoopMode];
    
    [[NSRunLoop currentRunLoop] run];
}

- (void)runloopLive:(NSTimer *)timer {
    ReceiverStreamWaitingCountdown ++;
    if (!self.receiverStreamReopened) {
        if (ReceiverStreamWaitingCountdown > WAIT_FOR_STREAMS_LIMIT) { // above 1 min, show the popup
            [[BonjourManager sharedInstance] stopServer];
            [self performSelectorOnMainThread:@selector(showDialogOnMainThread) withObject:nil waitUntilDone:NO];
            [timer invalidate];
            timer = nil;
            [NSThread exit];
        }
        [self performSelectorOnMainThread:@selector(openStreamsInMainThread) withObject:nil waitUntilDone:NO]; // try to open the steam
    } else if (!responseSent && [[BonjourManager sharedInstance].outputStream hasSpaceAvailable]) {
        [self performSelectorOnMainThread:@selector(buildingResponseInMainThread) withObject:nil waitUntilDone:NO];
        responseSent = true;
        serverRestarted = NO;
    } else if (self.receiverStreamReopened && responseSent) {
        [timer invalidate];
        timer = nil;
        [NSThread exit];
    }
}

bool responseSent = false;
// Send response
- (void)sendSimpleResponse:(NSString *)string {
    
    photofileStartFound = NO;
    videofileStartFound = NO;
    vcardStartFound = NO;
    
    totalDownloadedData -=  (float)tillNowVideoReceived/(1000 * 1000);
    [self.totalDownLoadedDataLbl setText:[NSString stringWithFormat:@"Downloaded: %.f MB",(totalDownloadedData * (1000 * 1000))/(1024.0f * 1024.0f)]];
    
    NSData * data =[string dataUsingEncoding:NSUTF8StringEncoding];
    [[BonjourManager sharedInstance] sendStream:data]; // Send bits heart beats
    
    [self performSelectorOnMainThread:@selector(updateTitleLabelInMainThread:) withObject:@"" waitUntilDone:NO];
    
}

- (void)buildingResponseInMainThread
{
    assert([NSThread mainThread]);
//    self.processingDataLbl.text = @"sending...";
    NSString *responseContent = @"";
    if (recevier_state == RECEIVE_VIDEO_FILE) {
        
        if (videolist.count > videoCountIndex) {
            videoinfo = [videolist objectAtIndex:videoCountIndex];
        } else {
            videoinfo = [videolist lastObject]; // resend last object
        }
        
        videoinfo = [videolist objectAtIndex:videoCountIndex];
        self.currentReqeust = (NSString *)[videoinfo valueForKey:@"Path"];
        
        responseContent = [NSString stringWithFormat:@"VZCONTENTTRANSFER_RECONNECTED_FOR_VIDEO_%@/%d/%d", self.currentReqeust, 0, videoCountIndex-1];
        
        [self sendSimpleResponse:responseContent];
        
    } else if (recevier_state == RECEIVE_PHOTO_FILE) {
        
        if (photolist.count > photoCountIndex) {
            photoinfo = [photolist objectAtIndex:photoCountIndex];
        } else {
            photoinfo = [photolist lastObject]; // resend last object
        }
        
        photoinfo = [photolist objectAtIndex:photoCountIndex];
        self.currentReqeust = (NSString *)[photoinfo valueForKey:@"Path"];
        
        responseContent = [NSString stringWithFormat:@"VZCONTENTTRANSFER_RECONNECTED_FOR_PHOTO_%@/%d", self.currentReqeust, photoCountIndex];
        [self sendSimpleResponse:responseContent];
    } else if (recevier_state == RECEIVE_VCARD_FILE) {
        responseContent = [NSString stringWithFormat:@"VZCONTENTTRANSFER_RECONNECTED_FOR_VCARD"];
        [self sendSimpleResponse:responseContent];
    }
}

- (void)openStreamsInMainThread
{
    assert([NSThread isMainThread]);
    self.processingDataLbl.text = @"Opening the connection...";
    
    // open input
    [[BonjourManager sharedInstance].inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    // open output
    [[BonjourManager sharedInstance].outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [[BonjourManager sharedInstance].inputStream open];
    [[BonjourManager sharedInstance].outputStream open];
}

- (void)updateTitleLabelInMainThread:(NSString *)title
{
    self.processingDataLbl.text = title;
}

- (void)showDialogOnMainThread
{
    [self createConnectionFailDialogWithTitle:@"Content Transfer" andContent:@"It seems like your last connection failed, please restart it again."];
}

- (void)createConnectionFailDialogWithTitle:(NSString *)title andContent:(NSString *)content
{
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [weakSelf dataTransferInterrupted:CONNECTION_FAILED];
    }];
    
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:title message:content cancelAction:cancelAction otherActions:nil isGreedy:NO];
}

#pragma mark - Photo save delegate
- (void)updateDuplicatePhoto:(NSString *)URL withPhotoInfo:(NSDictionary *)photoInfo success:(BOOL)success orError:(NSError *)error
{
    if (!success) {
        // Save failed photo to fail list
        NSMutableDictionary *dicWithErr = nil;
        if (photoInfo) {
            dicWithErr = [[NSMutableDictionary alloc] initWithDictionary:photoInfo];
        } else {
            dicWithErr = [[NSMutableDictionary alloc] init];
        }
        
        [dicWithErr setValue:error forKey:@"Err"];
        
        if (URL) {
            [dicWithErr setValue:URL forKey:@"URL"];
        }
        
        @synchronized (self) {
            if (!self.photoFailedList) {
                self.photoFailedList = [[NSMutableArray alloc] init];
            }
            [self.photoFailedList addObject:dicWithErr];
        }
    }
    
    @synchronized (self) {
        self.tempPhotoCount--;
        if (self.tempPhotoCount == 0) {
            if ((self.tempVideoCount > 0 || self.videoAlreadyWrittenList.count > 0) && [self nothingToWrite:[videoWrittingTaskList allValues]]) {
                // photos saving completed, start saving videos
                [self storeVideoIntoGallery];
            }
        }
    }
    
    // Clear the temp file in the folder for successfully saved photo
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (URL) {
            [[NSFileManager defaultManager] removeItemAtPath:URL error:nil];
        }
    });
    
    
    // Duplicate list logic
    if (photoInfo) {
        if (!self.localDuplicateList) {
            self.localDuplicateList = [[NSMutableArray alloc] init];
        }
        [self.localDuplicateList addObject:photoInfo];
    }
    
    if (self.trasnferCancel && self.localDuplicateList.count == (self.photoSavingList.count + self.photoSavingList2.count + self.photoSavingList3.count + self.photoSavingList4.count + self.photoSavingList5.count + self.photoSavingList6.count)) { // only cancel transfer need to save duplicate list
        
        NSMutableArray *duplicateList = [[[NSUserDefaults standardUserDefaults] valueForKey:@"PHOTODUPLICATELIST"] mutableCopy];
        [duplicateList addObjectsFromArray:self.localDuplicateList];
        [[NSUserDefaults standardUserDefaults] setObject:duplicateList forKey:@"PHOTODUPLICATELIST"];
        
        [[NSUserDefaults standardUserDefaults] setBool:self.vcardReceived forKey:@"VCARDDUPLICATELIST"];
        [[NSUserDefaults standardUserDefaults] setBool:self.calendarReceived forKey:@"CALENDARDUPLICATELIST"];
        [[NSUserDefaults standardUserDefaults] setBool:self.reminderReceived forKey:@"REMINDERDUPLICATELIST"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.localDuplicateList = nil;
    }
    
//    __weak typeof(self) weakSelf = self;
    if (delegate) { // Already go to finish view, transfer finished saving process
        if (self.videoAlreadyWrittenList.count == 0) {
            [delegate updateSavingProcessDataWithPhotoNumber:tempPhotoCount andVideoNumber:tempVideoCount andVideoFailedInfo:self.videoFailedList andPhotoFailedInfo:self.photoFailedList];
        } else {
            [delegate updateSavingProcessDataWithPhotoNumber:tempPhotoCount andVideoNumber:tempVideoCount+(int)videoAlreadyWrittenList.count andVideoFailedInfo:self.videoFailedList andPhotoFailedInfo:self.photoFailedList];
        }
    }
}

int videoCountAdaptNumber = 0;
- (void)updateDuplicateVideo:(NSString *)URL withVideoInfo:(NSDictionary *)videoInfo success:(BOOL)success orError:(NSError *)error
{
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
    }
    
    @synchronized (self) {
        --tempVideoCount;
    }
    
    // Clear the temp file in the folder for successfully saved photo
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (URL) {
            [[NSFileManager defaultManager] removeItemAtPath:URL error:nil];
        }
    });
    
    // Duplicate list logic
    if (videoInfo) {
        if (!self.localDuplicateVideoList) {
            self.localDuplicateVideoList = [[NSMutableArray alloc] init];
        }
        [self.localDuplicateVideoList addObject:videoInfo];
    }
    
    if (!error || (error && error.code != 502)) {
        [self.localDuplicateVideoList addObject:videoInfo];
    } else if (error && error.code == 502) {
        videoCountAdaptNumber ++;
    }
    
    if (self.trasnferCancel && self.localDuplicateVideoList.count == (self.videoSavingList.count + self.videoSavingList2.count - videoCountAdaptNumber)){ // only cancel transfer need to save duplicate list
        
        NSMutableArray *duplicateList = [[[NSUserDefaults standardUserDefaults] valueForKey:@"VIDEODUPLICATELIST"] mutableCopy];
        [duplicateList addObjectsFromArray:self.localDuplicateVideoList];
        [[NSUserDefaults standardUserDefaults] setObject:duplicateList forKey:@"VIDEODUPLICATELIST"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setBool:self.vcardReceived forKey:@"VCARDDUPLICATELIST"];
        [[NSUserDefaults standardUserDefaults] setBool:self.calendarReceived forKey:@"CALENDARDUPLICATELIST"];
        [[NSUserDefaults standardUserDefaults] setBool:self.reminderReceived forKey:@"REMINDERDUPLICATELIST"];
        
        self.localDuplicateVideoList = nil;
    }
    
    if (delegate) { // Already go to finish view, transfer finished saving process
        [delegate updateSavingProcessDataWithPhotoNumber:tempPhotoCount andVideoNumber:tempVideoCount andVideoFailedInfo:self.videoFailedList andPhotoFailedInfo:self.photoFailedList];
    }
}

#pragma mark - Actions method
- (IBAction)ClickedOnCancelBtn:(id)sender {
    
    
    NSMutableDictionary *paramDictionary = [[NSMutableDictionary alloc] init];
    
    [paramDictionary setObject:ANALYTICS_TrackAction_Param_Value_FlowInitiated_1 forKey:ANALYTICS_TrackAction_Key_CancelTransfer];
    [paramDictionary setObject:ANALYTICS_TrackAction_Value_CancelTransfer forKey:ANALYTICS_TrackAction_Key_LinkName];
    NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneProcessing, ANALYTICS_TrackAction_Value_CancelTransfer);
    [paramDictionary setObject:pageLink forKey:ANALYTICS_TrackAction_Key_PageLink];
    
    [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Value_CancelTransfer
                                 data:paramDictionary];
    
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        weakSelf.dataDownloadProgressBar.hidden = YES;
        
        self.trasnferCancel = YES;
        
        [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
        weakSelf.disableCountDown = YES;
        if ([weakSelf.timeoutCountingTimer isValid]) {
            [weakSelf.timeoutCountingTimer invalidate];
            weakSelf.timeoutCountingTimer = nil;
        }
        timeoutTimerCountdown = 0;
        
        
        if ([weakSelf.heartBeatTimer isValid]) {
            [weakSelf.heartBeatTimer invalidate];
            weakSelf.heartBeatTimer = nil;
        }
        
        [weakSelf.cancelBtn setEnabled:NO];
        [weakSelf.cancelBtn setAlpha:0.4];
        
        // send stream
        NSString *str = @"";
        if (sender == nil)
            str = @"VZTRANSFER_QUIT";
        else
            str = @"VZTRANSFER_CANCEL";
        [[BonjourManager sharedInstance] sendStream:[str dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (sender == nil) {
            [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
            
            if([[[[self navigationController]viewControllers]objectAtIndex:0] isKindOfClass:[CTNoInternetViewController class]]) {
                [self.navigationController setNavigationBarHidden:YES animated:NO];
            }
            
            if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            }
            
            NSString *screenName = @"VZBonjourReceiveDataVC";
            
            NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
            
            [infoDict setObject:[screenName stringByAppendingString:@"_Application exited by user"] forKey:@"dataTransferStatusMsg"];
            [infoDict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
            
            [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_EXITAPP withExtraInfo:infoDict isEncryptedExtras:false];
            
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            
            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
            //        [appDelegate.window makeKeyAndVisible];
            [appDelegate setViewControllerToPresentAlertsOnAutomatic];
            
            [appDelegate displayStatusChanged];
            
            //            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        } else {
            
            [self dataTransferInterrupted:TRANSFER_CANCELLED];
            
            NSString *pageLink = pageLink(ANALYTICS_TrackAction_Param_Value_FlowName_TransferToReceiver, ANALYTICS_TrackAction_Name_Cancel_Transfer);
            [weakSelf.sharedAnalytics trackAction:ANALYTICS_TrackAction_Name_Cancel_Transfer
                                             data:@{ANALYTICS_TrackAction_Key_PageLink:pageLink,
                                                    ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Name_Cancel_Transfer,
                                                    @"vzwi.mvmapp.cancelTransfer":@"1"}];

        }
    }];
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    
    if (sender == nil) {
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:@"Are you sure you want to quit? Data will not be saved." cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    } else {
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:@"Are you sure you want to cancel the transfer?" cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    }
}

- (NSString*)decodeStringTo64:(NSString*)fromString{
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:fromString options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    return decodedString;
}

@end
