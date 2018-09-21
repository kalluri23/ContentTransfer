//
//  VZReceiveDataViewController.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/30/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "CTMVMFonts.h"
#import "VZCalenderEventsImport.h"
#import "VZConcurrentWritingHelper.h"
#import "VZContentTrasnferConstant.h"
#import "VZDeviceMarco.h"
#import "VZReceiveDataViewController.h"
#import "NSMutableDictionary+CTMVMConvenience.h"
#import "NSString+CTContentTransferRootDocuments.h"

#import "PhotoStoreHelper.h"
#import "VZSharedAnalytics+Helpers.h"
#import "NSString+CTMVMConvenience.h"
#import "NSData+CTHelper.h"

@interface VZReceiveDataViewController () <PhotoStoreDelegate>

// intermediate data package, save 200MB each for video
@property(nonatomic, strong) NSMutableData *intermediateData;

// track on how many bytes already be written into the disk for video
@property(atomic, strong) NSMutableDictionary *videoAlreadyWrittenList;

// file waiting to be saved into the album for photos & videos
//@property (atomic, strong) NSMutableArray *videosList;
//@property (atomic, strong) NSMutableArray *photosList;

// thread lock for video & photo saving process
@property(atomic, assign) BOOL videoSavingLock;
@property(atomic, assign) BOOL videoSavingLock2;
@property(strong, atomic) NSMutableArray *videoSavingList;
@property(strong, atomic) NSMutableArray *videoSavingList2;
@property(assign, atomic) NSInteger currentVideoSavingIndex;
@property(assign, atomic) NSInteger currentVideoSavingIndex2;
@property(assign, atomic) BOOL anotherThread;

@property(strong, atomic) NSMutableArray *photoSavingList;
@property(strong, atomic) NSMutableArray *photoSavingList2;
@property(strong, atomic) NSMutableArray *photoSavingList3;
@property(strong, atomic) NSMutableArray *photoSavingList4;
@property(strong, atomic) NSMutableArray *photoSavingList5;
@property(strong, atomic) NSMutableArray *photoSavingList6;
@property(assign, atomic) NSInteger currentSavingIndex;
@property(assign, atomic) NSInteger currentSavingIndex2;
@property(assign, atomic) NSInteger currentSavingIndex3;
@property(assign, atomic) NSInteger currentSavingIndex4;
@property(assign, atomic) NSInteger currentSavingIndex5;
@property(assign, atomic) NSInteger currentSavingIndex6;
@property(atomic, assign) BOOL photoSavingLock;
@property(assign, atomic) BOOL photoSavingLock2;
@property(assign, atomic) BOOL photoSavingLock3;
@property(assign, atomic) BOOL photoSavingLock4;
@property(assign, atomic) BOOL photoSavingLock5;
@property(assign, atomic) BOOL photoSavingLock6;
@property(assign, atomic) NSInteger photoSavingArrayIndex;
//@property (atomic, assign) BOOL photoSavingLock2;

// video writing into the temp disk file concurrent task list
@property(atomic, strong) NSMutableDictionary *videoWrittingTaskList;

@property(nonatomic, assign) NSInteger numberOfContacts;

// constaints
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *circularTopConstaints;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstaints;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *processingTopConstaints;
@property(weak, nonatomic)
IBOutlet NSLayoutConstraint *keepOpenLableTopConstaints;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *cancelBottomConstaints;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *circularHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleBottom;

@property(weak, nonatomic) IBOutlet NSLayoutConstraint *circularWidth;

@property(weak, nonatomic)
IBOutlet NSLayoutConstraint *downLoadBarTopConstaints;

@property(weak, nonatomic) IBOutlet NSLayoutConstraint *aniWidth;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *aniHeight;

@property(weak, nonatomic) IBOutlet UIProgressView *dataProgressView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerTop;
@property(assign, nonatomic) NSInteger packageSize;
@property(assign, nonatomic) NSInteger senderPackageSize;

@property(atomic, strong) NSMutableArray *videoFailedList;
@property(atomic, strong) NSMutableArray *photoFailedList;

@property(nonatomic, assign) BOOL processDone;

@property(nonatomic, strong) ALAssetsLibrary *library;
@property(nonatomic, assign) float maxSpeed;

@property(assign, nonatomic) BOOL hasAlbumPermissionErr;
@property(assign, nonatomic) BOOL hasVcardPermissionErr;
@property(assign, nonatomic) BOOL hasCalendarPermissionErr;
@property(assign, nonatomic) BOOL hasReminderPermissionErr;

@property(assign, nonatomic) BOOL albumPermissionNotDetermine;
@property(assign, nonatomic) BOOL vcardPermissionNotDetermine;
@property(assign, nonatomic) BOOL calendarPermissionNotDetermine;
@property(assign, nonatomic) BOOL reminderPermissionNotDetermine;
@property(assign, nonatomic) BOOL trasnferCancel;

// calendar
@property(nonatomic, strong) NSDictionary *calInfo;
@property(nonatomic, assign) NSInteger calCountIndex;
@property(nonatomic, assign) BOOL hasCalendarSent;

@property(nonatomic, strong) NSArray *calList;

@property(nonatomic, assign) dispatch_once_t once;
@property(nonatomic, assign) dispatch_once_t once_photo;

@property(nonatomic, assign) BOOL vcardReceived;
@property(nonatomic, assign) BOOL calendarReceived;
@property(nonatomic, assign) BOOL reminderReceived;

@property (assign, nonatomic) BOOL firstLayout;

@property (nonatomic, assign) NSInteger targetTypeID;
@property (nonatomic, assign) BOOL transferStarted;

@property (nonatomic, strong) NSMutableData *pendingData;
@end

@implementation VZReceiveDataViewController
@synthesize pendingData;
@synthesize calList;
@synthesize vCardfile_size;
@synthesize receivedData;
@synthesize asyncSocket;
@synthesize photofile_size;
@synthesize photolist;
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
@synthesize totalPayLoadSize;
@synthesize totalDownloadDataSizeLbl;
@synthesize availableStorage;
@synthesize timeestimatedLbl;
@synthesize totalFilesReceived;
@synthesize serailPhotoQueue;
@synthesize serailPhotoQueue2;
@synthesize serailPhotoQueue3;
@synthesize serailPhotoQueue4;
@synthesize serailPhotoQueue5;
@synthesize serailVideoQueue;
@synthesize serailVideoQueue2;
@synthesize videoFlag;
//@synthesize serialQueue;
@synthesize tempPhotoCount;
@synthesize dataReceivingStatus;
@synthesize memoryWarningFlag;
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
@synthesize cancelBtn;
@synthesize tempVideoCount;
@synthesize isAndriodPlatform;
@synthesize numberOfContacts;
@synthesize listenOnPort;
@synthesize videoAlreadyWrittenList;
@synthesize videoWrittingTaskList;
//@synthesize videosList;
//@synthesize photosList;
@synthesize packageSize;
@synthesize senderPackageSize;
@synthesize app;
@synthesize maxSpeed;
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
@synthesize mediaTypePiped;
@synthesize asyncSocketCommPort;
@synthesize listenOnPortCommPort;

- (NSMutableData *)intermediateData {
    if (!_intermediateData) {
        _intermediateData = [[NSMutableData alloc] init];
    }
    
    return _intermediateData;
}

- (id)init {
    
    self = [super init];
    //  asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self
    //  delegateQueue:dispatch_get_main_queue()];
    [asyncSocket setDelegate:self];
    
    return self;
}

- (void)viewDidLoad {
    
    //    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneProcessing;
    
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneTransfer;
    
    [super viewDidLoad];
    
    self.firstLayout = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.keepAppOpenLbl.textAlignment = NSTextAlignmentCenter;
    }
    
    if ([VZDeviceMarco isiPhone4AndBelow]) {
        packageSize = 50; // set for each of the package size for video receiving
    } else if ([VZDeviceMarco isiPhone5Serial]) {
        packageSize = 100;
    } else if ([VZDeviceMarco isiPhone6AndAbove]) {
        packageSize = 150;
    }
    
    // Do any additional setup after loading the view.
    
    listenOnPort.delegate = self;
    asyncSocket.delegate = self;
    
    self.isAndriodPlatform = TRUE;
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
        
        self.isAndriodPlatform = FALSE;
    } else {
        
        self.isAndriodPlatform = TRUE;
    }
    
    //    [self createMediaLogFile];
    
    // listenOnPort = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    uint16_t port = 8988;
    
    [listenOnPort setDelegate:self];
    
    if (![listenOnPort acceptOnPort:port error:&error]) {
        DebugLog(@"Yes i am able to listen on this port");
    } else {
        DebugLog(@"No i am not able to listen on this port");
    }
    
    listenOnPortCommPort = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

    if (![listenOnPortCommPort acceptOnPort:COMM_PORT_NUMBER error:&error]) {
        
        DebugLog(@"Yes i am able to listen on this port");
    } else {
        
        DebugLog(@"No i am not able to listen on this port");
    }
    
    [asyncSocket setDelegate:self];
    //
    //    asyncSocket = listenOnPort;
    
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
    
    serailVideoQueue = [[NSOperationQueue alloc] init];
    serailVideoQueue.maxConcurrentOperationCount = 1;
    serailVideoQueue2 = [[NSOperationQueue alloc] init];
    serailVideoQueue2.maxConcurrentOperationCount = 1;
    
    videoFlag = TRUE;
    
    //    serialQueue = dispatch_queue_create("com.vztransfer.queue", DISPATCH_QUEUE_SERIAL);
    
//    NSString *documentsDirectory1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Documents"];
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
    
    self.navigationItem.title = @"Content Transfer";
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"VZReceiveDataViewController" withExtraInfo:@{} isEncryptedExtras:false];
    
    // Create MyPhoto folder to store photos
    fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferPhoto"];
    
    // Remove old files
    [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
    
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
    
    self.videoAlreadyWrittenList = [[NSMutableDictionary alloc] init];
    self.videoWrittingTaskList = [[NSMutableDictionary alloc] init];
    
    self.processDone = NO;
    
    self.vcardPermissionNotDetermine = YES;
    self.albumPermissionNotDetermine = YES;
    self.calendarPermissionNotDetermine = YES;
    self.reminderPermissionNotDetermine = YES;
    
    // Check for Reminder permission
    [self checkforReminderPermission];
    
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
    
    self.library = [[ALAssetsLibrary alloc] init];
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusNotDetermined) {
        self.albumPermissionNotDetermine = YES;
        
        __weak typeof(self) weakSelf = self;
        [self.library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            // do nothing
            weakSelf.albumPermissionNotDetermine = NO;
            
            if (!weakSelf.vcardPermissionNotDetermine && !weakSelf.calendarPermissionNotDetermine && !weakSelf.reminderPermissionNotDetermine) {
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
        self.hasAlbumPermissionErr = YES;
        self.albumPermissionNotDetermine = NO;
    }
    
    // Check calendar permission
    __weak typeof(self) weakSelf = self;
    [VZCalenderEventsImport checkAuthorizationStatusToAccessEventStoreSuccess:^{
        weakSelf.calendarPermissionNotDetermine = NO;
        
        if (!weakSelf.vcardPermissionNotDetermine && !weakSelf.albumPermissionNotDetermine && !weakSelf.reminderPermissionNotDetermine) {
            [weakSelf performSelector:@selector(generatePermissionAlert) withObject:nil];
        }
        
    } andFailureHandler:^(EKAuthorizationStatus status) {
        weakSelf.calendarPermissionNotDetermine = NO;
        weakSelf.hasCalendarPermissionErr = YES;
        
        if (!weakSelf.vcardPermissionNotDetermine && !weakSelf.albumPermissionNotDetermine && !weakSelf.reminderPermissionNotDetermine) {
            [weakSelf performSelector:@selector(generatePermissionAlert) withObject:nil];
        }
    }];
    
    self.dataProgressView.progress = 0.0f;
    self.trasnferCancel = false;
    self.reminderFound = NO;
    
    self.dataProgressView.tintColor = [CTMVMColor mvmPrimaryRedColor];
    
    self.cancelBtn.hidden = YES;
}

- (void)checkforReminderPermission {
    
    self.reminderPermissionNotDetermine = YES;
    
    __weak typeof(self) weakSelf = self;
    [VZRemindersImoprt updateAuthorizationStatusToAccessEventStoreSuccess:^{
        weakSelf.reminderPermissionNotDetermine = NO;
        
        if (!weakSelf.vcardPermissionNotDetermine &&
            !weakSelf.albumPermissionNotDetermine &&
            !weakSelf.calendarPermissionNotDetermine) {
            [weakSelf performSelector:@selector(generatePermissionAlert)
                           withObject:nil];
        }
    }
                                                                   failed:^(EKAuthorizationStatus status) {
                                                                       weakSelf.reminderPermissionNotDetermine = NO;
                                                                       weakSelf.hasReminderPermissionErr = YES;
                                                                       
                                                                       if (!weakSelf.vcardPermissionNotDetermine &&
                                                                           !weakSelf.albumPermissionNotDetermine &&
                                                                           !weakSelf.calendarPermissionNotDetermine) {
                                                                           [weakSelf performSelector:@selector(generatePermissionAlert)
                                                                                          withObject:nil];
                                                                       }
                                                                   }];
}

- (void)generatePermissionAlert {
    if (self.hasVcardPermissionErr || self.hasAlbumPermissionErr ||
        self.hasCalendarPermissionErr || self.reminderPermissionNotDetermine) {
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction =
        [CTMVMAlertAction actionWithTitle:@"Go to Setting"
                                  style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction *action) {
                                    [weakSelf openSettings];
                                }];
        
        CTMVMAlertAction *cancelAction =
        [CTMVMAlertAction actionWithTitle:@"Continue"
                                  style:UIAlertActionStyleDefault
                                handler:nil];
        
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
        
        message = [NSString stringWithFormat:@"%@. Please give permission for "
                   @"them, otherwise all transferred "
                   @"data will not be saved.",
                   message];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer"
                                                      message:message
                                                 cancelAction:cancelAction
                                                 otherActions:@[okAction]
                                                     isGreedy:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //  if (!self.vcardPermissionNotDetermine && !self.albumPermissionNotDetermine) {
    //    [self performSelector:@selector(generatePermissionAlert) withObject:nil];
    //  }
}

- (void)openSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:url];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - GCDAsyncSocket Delegate methods

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    DebugLog(@"socket:didConnectToHost:%@ port:%hu", host, port);

    
    if (port == COMM_PORT_NUMBER) {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setValue:[NSString stringWithFormat:@"Device ID: %@",self.uuid_string] forKey:USER_DEFAULTS_DB_PARING_DEVICE_INFO];
        
        VZDeviceMarco *deviceMacro = [[VZDeviceMarco alloc] init];
        NSString *modelCode = [deviceMacro getDeviceModel];
        NSString *model = [deviceMacro.models objectForKey:modelCode];
        if (model.length == 0) {
            model = modelCode;
        }
        
        [dict setValue:model forKey:USER_DEFAULTS_PAIRING_MODEL];
        [dict setValue:[[UIDevice currentDevice] systemVersion] forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
        [dict setValue:@"iOS" forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
        [dict setValue:self.uuid_string forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
        [dict setValue:@"P2P" forKey:USER_DEFAULTS_PAIRING_TYPE];

        
        NSError *error;
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:dict
                                                              options:kNilOptions
                                                                error:&error];
        
        [asyncSocketCommPort writeData:requestData withTimeout: -1.0 tag:100];
        [asyncSocketCommPort writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:100];
        
        [asyncSocketCommPort readDataWithTimeout:-1 tag:100];

    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    DebugLog(@"socket:didWriteDataWithTag: %ld",tag);

    //    receivedData = [[NSMutableData alloc] init];
    
    [asyncSocket readDataWithTimeout:-1.0 tag:0];
}

- (void)closeSocket:(int)stat
{
    self.trasnferCancel = true;
    
    self.dataProgressView.hidden = YES;
    self.asyncSocket.delegate = nil;
    self.listenOnPort.delegate = nil;
    
    // Close the socket
    [self.asyncSocket disconnect];
    [self.listenOnPort disconnect];
    
    self.asyncSocket = nil;
    self.listenOnPort = nil;
    
    [self.cancelBtn setEnabled:NO];
    [self.cancelBtn setAlpha:0.4];
    
    [self dataTransferInterrupted:stat];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    if (self.trasnferCancel) {
        return;
    }
    
    if (sock == asyncSocketCommPort) {
        
        if (data.length == 21) {
            NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if ([response isEqualToString:@"VZTRANSFER_FORCE_QUIT"]) {
                DebugLog(@"This is the force quit on the other side test");
                [self closeSocket:USER_FORCE_CLOSE];
                return;
            }
        }
        
        [self readCommPortDeviceInformation:data];
        
        return;
    }
    
    if (data.length <= 0) { // if receive a zero data, keep reading next package;
        [asyncSocket readDataWithTimeout:-1 tag:0];
        return;
    }
    
    if (data.length == 21) {
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([response isEqualToString:@"VZTRANSFER_FORCE_QUIT"]) {
            DebugLog(@"This is the force quit on the other side test");
            [self closeSocket:USER_FORCE_CLOSE];
            return;
        }
    }
    
    if (pendingData.length > 0) {
        [pendingData appendData:data];
        data = (NSData *)pendingData;
        pendingData = nil; // length always be 0;
    }
    
    switch (recevier_state) {
            
        case HAND_SHAKE: {
            
        } break;
            
        case RECEIVE_ALL_FILE_LOG: {
            
            if (!allfileLogStartFound) {
                
                if (data.length < 37) { // less than 37 length data, might be \r\n, should be ignorned.
                    // Trim the first package of the request
                    NSString *dummyHeader = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    DebugLog(@"NSdata to String: %@", dummyHeader);
                    dummyHeader = [dummyHeader formatRequestForXPlatform];
                    
                    if (dummyHeader.length > 0) {
                        pendingData = [[dummyHeader dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                    }
                    
                    [asyncSocket readDataWithTimeout:-1 tag:0];
                    
                    return;
                }
                
                self.transferStarted = YES;
                
                self.startTime = [NSDate date];
                
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                [userDefault setObject:self.startTime forKey:@"STARTTIME"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.dataReceivingStatus setText:@"Receiving..."];
                    self.cancelBtn.hidden = NO;
                });
                
                BOOL headerComplete = NO, headerCompleteSecond = NO;
                NSData *tempdata = [data subdataWithRange:NSMakeRange(0, 37)];
                NSString *response1 = [[[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding] formatRequestForXPlatform];
                
                NSRange range = [response1 rangeOfString:@"VZCONTENTTRANSFERALLFLSTART"];
                if ((range.location != NSNotFound) && (response1.length > 0)) {
                    headerComplete = YES;
                } else if (data.length > 37 + 2) { // 2 more charecters to fill up the \r\n
                    tempdata = [data subdataWithRange:NSMakeRange(2, 37 + 2)];
                    response1 = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
                    
                    NSRange range = [response1 rangeOfString:@"VZCONTENTTRANSFERALLFLSTART"];
                    
                    if ((range.location != NSNotFound) && (response1.length > 0)) {
                        headerCompleteSecond = YES;
                    }
                } else {
                    pendingData = [[response1 dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                    [asyncSocket readDataWithTimeout:-1 tag:0];
                    
                    return;
                }
                
                if (headerComplete || headerCompleteSecond) {
                    NSString *vcardLen = [response1 substringFromIndex:27];
                    
                    vCardfile_size = vcardLen.longLongValue;
                    DebugLog(@"->File List Start");
                    
                    if (!receivedData) {
                        receivedData = [[NSMutableData alloc] init];
                    }
                    
                    if (headerComplete && data.length > 37) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(37, data.length - 37)]];
                    } else if (headerCompleteSecond && data.length > 39) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(39, data.length - 39)]];
                    }
                    
                    if (receivedData.length > vCardfile_size) { // first package get the whole file with /r/n
                        receivedData = [[receivedData subdataWithRange:NSMakeRange(0, vCardfile_size)] mutableCopy]; // ignore /r/n
                    }
                    DebugLog(@"received %lu out of %lld", (unsigned long)receivedData.length, vCardfile_size);
                    allfileLogStartFound = YES;
                    response1 = nil;
                }
                
            } else if (allfileLogStartFound && (receivedData.length + data.length < vCardfile_size)) {
                [receivedData appendData:data];
                DebugLog(@"received %lu out of %lld", (unsigned long)receivedData.length, vCardfile_size);
            } else {
                NSData *lastpacketPortion = [data subdataWithRange:NSMakeRange(0, vCardfile_size - receivedData.length)];
                if (lastpacketPortion.length > 0) {
                    [receivedData appendData:lastpacketPortion];
                }
                DebugLog(@"received %lu out of %lld", (unsigned long)receivedData.length, vCardfile_size);
            }
            
            if (receivedData.length == vCardfile_size) {
                
                allfileLogStartFound = NO;
                self.vCardfile_size = 0;
                
                __weak typeof(self) weakSelf = self;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.receivedFileStatuLbl setText:@"File List Received"];
                });
                
                NSData *fileLogoData = [[NSData alloc] initWithData:receivedData];
                receivedData = nil;
                vcardStartFound = FALSE;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    @autoreleasepool {
                        DebugLog(@"File List Received<-");
                        [weakSelf.fileLogManager storeFileList:fileLogoData];
                        senderPackageSize = weakSelf.fileLogManager.model;
                        
                        BOOL enoughStorage = [weakSelf calculatetotalDownloadableDataSize];
                        if (enoughStorage) {
                            [weakSelf notifyAllFileListCompletion:YES];
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
                    }
                });
            }
        } break;
            
        case RECEIVE_VCARD_FILE: {
            
            if (!vcardfileStartfound) {
                
                if (data.length < 37) { // less than 37 length data, might be \r\n, should be ignorned.
                    // Trim the first package of the request
                    NSString *dummyHeader = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    DebugLog(@"NSdata to String: %@", dummyHeader);
                    dummyHeader = [dummyHeader formatRequestForXPlatform];
                    
                    if (dummyHeader.length > 0) {
                        pendingData = [[dummyHeader dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                    }
                    
                    [asyncSocket readDataWithTimeout:-1 tag:0];
                    
                    return;
                }
                DebugLog(@"->Vcard Start");
                
                BOOL headerComplete = NO, headerCompleteSecond = NO;
                NSData *tempdata = [data subdataWithRange:NSMakeRange(0, 37)];
                NSString *response1 = [[[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding] formatRequestForXPlatform];
                
                NSRange range = [response1 rangeOfString:@"VZCONTENTTRANSFERVCARDSTART"];
                if ((range.location != NSNotFound) && (response1.length > 0)) {
                    headerComplete = YES;
                } else if (data.length > 37 + 2) { // 2 more charecters to fill up the \r\n
                    tempdata = [data subdataWithRange:NSMakeRange(2, 37 + 2)];
                    response1 = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
                    
                    range = [response1 rangeOfString:@"VZCONTENTTRANSFERVCARDSTART"];
                    
                    if ((range.location != NSNotFound) && (response1.length > 0)) {
                        headerCompleteSecond = YES;
                    }
                } else {
                    pendingData = [[response1 dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                    [asyncSocket readDataWithTimeout:-1 tag:0];
                    
                    return;
                }
                
                if (headerComplete || headerCompleteSecond) {
                    NSString *vcardLen = [response1 substringFromIndex:27];
                    
                    vCardfile_size = vcardLen.longLongValue;
                    
                    vcardfileStartfound = YES;
                    
                    ++totalFilesReceived;
                    
                    receivedData = [[NSMutableData alloc] init];
                    if (headerComplete && data.length > 37) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(37, data.length - 37)]];
                    } else if (headerCompleteSecond && data.length > 39) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(39, data.length - 39)]];
                    }
                    
                    if (receivedData.length > vCardfile_size) { // first package get the whole file with /r/n
                        receivedData = [[receivedData subdataWithRange:NSMakeRange(0, vCardfile_size)] mutableCopy]; // ignore /r/n
                    }
                    DebugLog(@"received %lu out of %lld", (unsigned long)receivedData.length, vCardfile_size);
                }
                
            } else if (vcardfileStartfound && (receivedData.length + data.length < vCardfile_size)) {
                [receivedData appendData:data];
                DebugLog(@"received %lu out of %lld", (unsigned long)receivedData.length, vCardfile_size);
            } else {
                NSData *lastpacketPortion = [data subdataWithRange:NSMakeRange(0, vCardfile_size - receivedData.length)];
                
                if (lastpacketPortion.length > 0) {
                    [receivedData appendData:lastpacketPortion];
                }
                DebugLog(@"received %lu out of %lld", (unsigned long)receivedData.length, vCardfile_size);
            }
            
            if (receivedData.length == vCardfile_size) {
                
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.receivedFileStatuLbl setText:@"Vcard Received"];
                });
                
                NSData *vcardData = [[NSData alloc] initWithData:receivedData];
                receivedData = nil;
                
                if (vCardfile_size > 0) {
                    DebugLog(@"vcard received<-");
//                    NSString *documentsDirectory1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Documents"];
                    NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZAllContactBackup.vcf"];
                    
                    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
                        [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
                    }
                    [vcardData writeToFile:fileName atomically:NO];
                    
                    weakSelf.vcardReceived = YES;
                    weakSelf.vcardfileStartfound = NO;
                    
                    [self notifyAllFileListCompletion:NO];
                }
            }
            
        } break;
            
        case RECEIVE_PHOTO_FILE: {
            if (!photofileStartFound) {
                
                if (data.length < 37) { // less than 37 length data, might be \r\n, should be ignorned.
                    // Trim the first package of the request
                    NSString *dummyHeader = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    DebugLog(@"NSdata to String: %@", dummyHeader);
                    dummyHeader = [dummyHeader formatRequestForXPlatform];
                    
                    if (dummyHeader.length > 0) {
                        pendingData = [[dummyHeader dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                    }
                    
                    [asyncSocket readDataWithTimeout:-1 tag:0];
                    
                    return;
                }
                DebugLog(@"->photo start");
                BOOL headerComplete = NO, headerCompleteSecond = NO;
                NSData *tempdata = [data subdataWithRange:NSMakeRange(0, 37)];
                NSString *response1 = [[[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding] formatRequestForXPlatform];
                
                if ([[response1 substringToIndex:27] isEqualToString:@"VZCONTENTTRANSFERPHOTOSTART"]) {
                    headerComplete = YES;
                } else if (data.length > 37 + 2) { // 2 more charecters to fill up the \r\n
                    tempdata = [data subdataWithRange:NSMakeRange(2, 37 + 2)];
                    response1 = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
                    
                    if ([[response1 substringToIndex:27] isEqualToString:@"VZCONTENTTRANSFERPHOTOSTART"]) {
                        headerCompleteSecond = YES;
                    }
                } else {
                    pendingData = [[response1 dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                    [asyncSocket readDataWithTimeout:-1 tag:0];
                    
                    return;
                }
                
                if (headerComplete || headerCompleteSecond) {
                    
                    NSString *vcardLen = [response1 substringFromIndex:27];
                    
                    photofile_size = vcardLen.longLongValue;
                    
                    receivedData = [[NSMutableData alloc] init];
                    if (headerComplete && data.length > 37) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(37, data.length - 37)]];
                    } else if (headerCompleteSecond && data.length > 39) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(39, data.length - 39)]];
                    }
                    
                    if (receivedData.length > photofile_size) { // first package get the whole file with /r/n
                        receivedData = [[receivedData subdataWithRange:NSMakeRange(0, photofile_size)] mutableCopy]; // ignore /r/n
                    }
                    DebugLog(@"received %lu out of %lld", (unsigned long)receivedData.length, photofile_size);
                    photofileStartFound = YES;
                    
                }
                
            } else if (photofileStartFound && receivedData.length + data.length < photofile_size) {
                [receivedData appendData:data];
                DebugLog(@"received %lu out of %lld", (unsigned long)receivedData.length, photofile_size);
            } else {
                if (data.length > photofile_size - receivedData.length) {
                    data = [data subdataWithRange:NSMakeRange(0, photofile_size - receivedData.length)];
                }
                [receivedData appendData:data];
                DebugLog(@"received %lu out of %lld", (unsigned long)receivedData.length, photofile_size);
            }
            
            if (receivedData.length == photofile_size) {

                DebugLog(@"photo received %d out of %lu<-", photoCountIndex, (unsigned long)photolist.count);
  
                photofileStartFound = NO;
                
                [self storePhotoIntoTempDocumentFolder:receivedData photoInfo:photoinfo];
                [self notifySenderRegardingPhotoFileReceiveCompletion];
                
                receivedData = nil;
            }
            
        } break;
            
        case RECEIVE_VIDEO_FILE: {
            
            if (!videofileStartFound) {
                
                if (data.length < 37) { // less than 37 length data, might be \r\n, should be ignorned.
//                    DebugLog(@"dummy received");
                    // Trim the first package of the request
                    NSString *dummyHeader = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    DebugLog(@"NSdata to String: %@", dummyHeader);
                    dummyHeader = [dummyHeader formatRequestForXPlatform];
                    
                    if (dummyHeader.length > 0) {
                        pendingData = [[dummyHeader dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                    }
                    
                    [asyncSocket readDataWithTimeout:-1 tag:0];
                    
                    return;
                }

                DebugLog(@"->video start");
 
                BOOL headerComplete = NO, headerCompleteSecond = NO;
                NSData *tempdata = [data subdataWithRange:NSMakeRange(0, 37)];
                NSString *response1 = [[[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding] formatRequestForXPlatform];
                
                NSRange range = [response1 rangeOfString:@"VZCONTENTTRANSFERVIDEOSTART"];
                
                if ((range.location != NSNotFound) && (response1.length > 0)) {
                    headerComplete = YES;
                } else if (data.length > 37 + 2) { // 2 more charecters to fill up the \r\n
                    tempdata = [data subdataWithRange:NSMakeRange(2, 37 + 2)];
                    response1 = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
                    
                    NSRange range = [response1 rangeOfString:@"VZCONTENTTRANSFERVIDEOSTART"];
                    
                    if ((range.location != NSNotFound) && (response1.length > 0)) {
                        headerCompleteSecond = YES;
                    } else {
                        pendingData = [[response1 dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                        [asyncSocket readDataWithTimeout:-1 tag:0];
                        
                        return;
                    }
                } else {
                    pendingData = [[response1 dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                    [asyncSocket readDataWithTimeout:-1 tag:0];
                    
                    return;
                }
                
                if (headerComplete || headerCompleteSecond) {
                    
                    NSString *vcardLen = [response1 substringFromIndex:27];
                    
                    videofile_size = vcardLen.longLongValue;
                    
//                    NSString *documentsDirectory1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Documents"];
                    NSString *theFileName = [[videoinfo valueForKey:@"Path"] lastPathComponent];
                    NSString *filePath1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:theFileName];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:theFileName]) {
                        [[NSFileManager defaultManager] removeItemAtPath:filePath1 error:nil];
                    }
                    
                    NSData *tempDAta = [[NSData alloc] init];
                    if (headerComplete && data.length > 37) {
                        tempDAta = [data subdataWithRange:NSMakeRange(37, data.length - 37)];
                        tillNowVideoReceived = (int)data.length - 37;
                    } else if (headerCompleteSecond && data.length > 39) {
                        tempDAta = [data subdataWithRange:NSMakeRange(39, data.length - 39)];
                        tillNowVideoReceived = (int)data.length - 39;
                    }
                    
                    if (tillNowVideoReceived > videofile_size) { // first package get the whole file with /r/n
                        tempDAta = [[tempDAta subdataWithRange:NSMakeRange(0, videofile_size)] mutableCopy]; // ignore /r/n
                    }
                    DebugLog(@"received %lld out of %lld", tillNowVideoReceived, videofile_size);
      
                    self.intermediateData = [[NSMutableData alloc] init];
                    [self storeVideoReceivedPacketToTempFile:tempDAta];
                    
                    videofileStartFound = YES;
                    
                    response1 = nil;
                    
                }
                
            } else if (videofileStartFound && (tillNowVideoReceived + data.length) < videofile_size) {
                
                tillNowVideoReceived += data.length;
                
//                DebugLog(@"rest package:%lld/%lld", tillNowVideoReceived, videofile_size);
                
                [self storeVideoReceivedPacketToTempFile:data];
                
                // Checking whether received 300MB video chunk received, only check for
                // ios->ios
                if (isAndriodPlatform && (tillNowVideoReceived - 1024) % (senderPackageSize * 1024 * 1024) == 0) {
                    [self requestfornextVideoChuck];
                }

                DebugLog(@"received %lld out of %lld", tillNowVideoReceived, videofile_size);
                
            } else {
                NSData *lastpacketPortion = [data subdataWithRange:NSMakeRange(0, (videofile_size - tillNowVideoReceived))];
                
                if (lastpacketPortion.length > 0) {
                    tillNowVideoReceived += lastpacketPortion.length;
//                    DebugLog(@"last package:%lld/%lld", tillNowVideoReceived, videofile_size);
                    
                    [self storeVideoReceivedPacketToTempFile:lastpacketPortion];
                    lastpacketPortion = nil;
                }
                DebugLog(@"received %lld out of %lld", tillNowVideoReceived, videofile_size);
            }
            
            if (tillNowVideoReceived == videofile_size) {

                DebugLog(@"video recevied:%d out of %lu", videoCountIndex, (unsigned long)videolist.count);
                
                videofileStartFound = NO;
                tillNowVideoReceived = 0;
                
                [self notifySenderRegardingVideoFileReceiveCompletion];
            }
            
        } break;
            
        case RECEIVE_CALENDER_LOG_FILE: {
            
        } break;
            
        case RECEVIE_REMINDER_LOG_FILE: {
            
        } break;
            
        case RECEVIE_REMINDER_FILE: {
            
            if (!reminderStartFound) {
                
                if (data.length < 37) { // less than 37 length data, might be \r\n, should be ignorned.
                    // Trim the first package of the request
                    NSString *dummyHeader = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    DebugLog(@"NSdata to String: %@", dummyHeader);
                    dummyHeader = [dummyHeader formatRequestForXPlatform];
                    
                    if (dummyHeader.length > 0) {
                        pendingData = [[dummyHeader dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                    }
                    
                    [asyncSocket readDataWithTimeout:-1 tag:0];
                    
                    return;
                }
                DebugLog(@"reminder start");
                
                self.reminderFound = NO;
                
                BOOL headerComplete = NO, headerCompleteSecond = NO;
                NSData *tempdata = [data subdataWithRange:NSMakeRange(0, 37)];
                NSString *response1 = [[[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding] formatRequestForXPlatform];
                
                NSRange range = [response1 rangeOfString:@"VZCONTENTTRANSFERREMINDERLO"];
                
                if ((range.location != NSNotFound) && (response1.length > 0)) {
                    headerComplete = YES;
                } else if (data.length > 37 + 2) { // 2 more charecters to fill up the \r\n
                    tempdata = [data subdataWithRange:NSMakeRange(2, 37 + 2)];
                    response1 = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
                    
                    NSRange range = [response1 rangeOfString:@"VZCONTENTTRANSFERREMINDERLO"];
                    
                    if ((range.location != NSNotFound) && (response1.length > 0)) {
                        headerCompleteSecond = YES;
                    }
                } else {
                    pendingData = [[response1 dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                    [asyncSocket readDataWithTimeout:-1 tag:0];
                    
                    return;
                }
                
                if (headerComplete || headerCompleteSecond) {
                    
                    NSString *vcardLen = [response1 substringFromIndex:27];
                    
                    reminderfile_Size = vcardLen.longLongValue;
                    reminderStartFound = YES;
                    
                    receivedData = [[NSMutableData alloc] init];
                    
                    ++totalFilesReceived;
                    
                    receivedData = [[NSMutableData alloc] init];
                    if (headerComplete && data.length > 37) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(37, data.length - 37)]];
                    } else if (headerCompleteSecond && data.length > 39) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(39, data.length - 39)]];
                    }
                    
                    if (receivedData.length > reminderfile_Size) { // first package get the whole file with /r/n
                        receivedData = [[receivedData subdataWithRange:NSMakeRange(0, reminderfile_Size)] mutableCopy]; // ignore /r/n
                    }
                    DebugLog(@"received %lu out of %lld", (unsigned long)receivedData.length, reminderfile_Size);
                }
                
            } else if (reminderStartFound && (receivedData.length + data.length) < reminderfile_Size) {
                [receivedData appendData:data];
                DebugLog(@"received %lu out of %lld", (unsigned long)receivedData.length, reminderfile_Size);
            } else {
                
                NSData *lastpacketPortion = [data subdataWithRange:NSMakeRange(0, reminderfile_Size - receivedData.length)];
                
                if (lastpacketPortion.length > 0) {
                    [receivedData appendData:lastpacketPortion];
                }
                DebugLog(@"received %lu out of %lld", (unsigned long)receivedData.length, reminderfile_Size);
            }
            
            if (receivedData.length == reminderfile_Size) {
                
                __weak typeof(self) weakSelf = self;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.receivedFileStatuLbl setText:@"Reminder Received"];
                });
                
                if (reminderfile_Size > 0) {
                    
                    weakSelf.reminderFound = YES;
                    DebugLog(@"reminder ends<-");
                    
//                    NSString *documentsDirectory1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Documents"];
                    NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"reminderLogFile.txt"];
                    
                    NSData *vcardData = [[NSData alloc] initWithData:receivedData];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        @autoreleasepool {
                            if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
                                [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
                            }
                            [vcardData writeToFile:fileName atomically:NO];
                            
                            weakSelf.reminderReceived = YES;
                        }
                    });
                    
                    receivedData = nil;
                    reminderStartFound = NO;
                    
                    [self notifyAllFileListCompletion:NO];
                }
            }
        } break;
            
        case RECEVIE_CALENDER_FILE: {
            if (!photofileStartFound) {
                
                if (data.length < 37) { // less than 37 length data, might be \r\n, should be ignorned.
                    // Trim the first package of the request
                    NSString *dummyHeader = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    DebugLog(@"NSdata to String: %@", dummyHeader);
                    dummyHeader = [dummyHeader formatRequestForXPlatform];
                    
                    if (dummyHeader.length > 0) {
                        pendingData = [[dummyHeader dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                    }
                    
                    [asyncSocket readDataWithTimeout:-1 tag:0];
                    
                    return;
                }

                DebugLog(@"calendar start");

                BOOL headerComplete = NO, headerCompleteSecond = NO;
                NSData *tempdata = [data subdataWithRange:NSMakeRange(0, 37)];
                NSString *response1 = [[[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding] formatRequestForXPlatform];
                
                if ([[response1 substringToIndex:27] isEqualToString:@"VZCONTENTTRANSFERCALENSTART"]) {
                    headerComplete = YES;
                } else if (data.length > 37 + 2) { // 2 more charecters to fill up the \r\n
                    tempdata = [data subdataWithRange:NSMakeRange(2, 37 + 2)];
                    response1 = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
                    
                    if ([[response1 substringToIndex:27] isEqualToString:@"VZCONTENTTRANSFERCALENSTART"]) {
                        headerCompleteSecond = YES;
                    }
                } else {
                    pendingData = [[response1 dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                    [asyncSocket readDataWithTimeout:-1 tag:0];
                    
                    return;
                }
                
                if (headerComplete || headerCompleteSecond) {
                    
                    NSString *calLen = [response1 substringFromIndex:30];
                    
                    photofile_size = calLen.longLongValue;
                    
                    receivedData = [[NSMutableData alloc] init];
                    if (headerComplete && data.length > 37) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(37, data.length - 37)]];
                    } else if (headerCompleteSecond && data.length > 39) {
                        [receivedData appendData:[data subdataWithRange:NSMakeRange(39, data.length - 39)]];
                    }
                    
                    if (receivedData.length > photofile_size) { // first package get the whole file with /r/n
                        receivedData = [[receivedData subdataWithRange:NSMakeRange(0, photofile_size)] mutableCopy]; // ignore /r/n
                    }
                    DebugLog(@"received %lu out of %lld and %ld", (unsigned long)receivedData.length, photofile_size, data.length);
                    
                    photofileStartFound = YES;
                    
                    response1 = nil;
                }
                
            } else if (photofileStartFound && (receivedData.length + data.length) < photofile_size) {
                [receivedData appendData:data];
                DebugLog(@"received %lu out of %lld and %ld", (unsigned long)receivedData.length, photofile_size, data.length);
            } else {
                
                if (data.length > photofile_size - receivedData.length) {
                    data = [data subdataWithRange:NSMakeRange(0, photofile_size - receivedData.length)];
                }
                
                [receivedData appendData:data];
                DebugLog(@"received %lu out of %lld and %ld", (unsigned long)receivedData.length, photofile_size, data.length);
            }
            
            if (receivedData.length == photofile_size) {
                photofileStartFound = NO;

                DebugLog(@"calendar received:%ld out of %lu", (long)_calCountIndex, (unsigned long)calList.count);
                
                // Create MyPhoto folder to store photos
                NSString *docPath = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"ReceivedCal"];
                
                // create new folder
                if (![[NSFileManager defaultManager] fileExistsAtPath:docPath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:nil]; // Create folder
                }
                
                __block NSData *calData = receivedData;
                __block NSDictionary *calendar = self.calInfo;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                   @autoreleasepool {
                                       NSString *fullPath = nil;
                                       if (!self.isAndriodPlatform) {
                                           fullPath = [NSString stringWithFormat:@"%@/%@", docPath, [[calendar objectForKey:@"Path"] lastPathComponent]];
                                       } else {
                                           fullPath = [NSString stringWithFormat:@"%@/%@_%@", docPath, [calendar objectForKey:@"CalColor"], [calendar objectForKey:@"Path"]];
                                       }
                                       if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
                                           [[NSFileManager defaultManager] removeItemAtPath:fullPath
                                                                                      error:nil];
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
            
        default:
            break;
    }
    
    [asyncSocket readDataWithTimeout:-1 tag:0];
    
    [self updateDataMatrix:(int)data.length];
}

- (void)notifySenderRegardingCalendarFileReceiveCompletion
{
    ++_calCountIndex;
    
    if (_calCountIndex == self.calList.count) {
        self.calendarReceived = YES;
        [self notifyAllFileListCompletion:NO];
    } else {
        
        self.calInfo = [self.calList objectAtIndex:_calCountIndex];
        DebugLog(@"Calendar info:\n%@", self.calInfo);
        
        NSString *ackMsg = nil;
        if (_calCountIndex == self.calList.count - 1) {
            ++totalFilesReceived;
            if (!self.isAndriodPlatform) { // x-platform
                ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_CALENDAR_%@",  [self.calInfo valueForKey:@"Path"]];
            } else {
                ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_FINAL_REQUEST_FOR_CALENDAR_%@", [self.calInfo valueForKey:@"Path"]];
            }
        } else {
            ++totalFilesReceived;
            if (!self.isAndriodPlatform) { // x-platform
                ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_CALENDAR_%@",  [self.calInfo valueForKey:@"Path"]];
            } else {
                ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_ORIGI_REQUEST_FOR_CALENDAR_%@", [self.calInfo valueForKey:@"Path"]];
            }
            
        }
        DebugLog(@"msg:%@", ackMsg);
        
        NSData *requestData = [[ackMsg dataUsingEncoding:NSUTF8StringEncoding] appendCRLFData];
        
        recevier_state = RECEVIE_CALENDER_FILE;
        
        [asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
        
        [asyncSocket readDataWithTimeout:-1 tag:0];
    }
}

#define GCDAsyncSocketClosedByRemotePeer 7
#define GCDSocketNotConnected 57
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (self.trasnferCancel) {
        return;
    }
    
    if (!self.processDone) { // process doesn't finish
        if (err.code == GCDAsyncSocketClosedByRemotePeer) {
            
            self.trasnferCancel = true;
            
            asyncSocket.delegate = nil;
            listenOnPort.delegate = nil;
            
            [asyncSocket disconnect];
            [listenOnPort disconnect];
            
            asyncSocketCommPort.delegate =nil;
            listenOnPortCommPort.delegate = nil;
            
            [asyncSocketCommPort disconnect];
            [listenOnPortCommPort disconnect];
            
            asyncSocketCommPort= nil;
            listenOnPortCommPort = nil;
            
            
            asyncSocket = nil;
            listenOnPort = nil;
            
            [self.dataProgressView setHidden:YES];
            
            [self.cancelBtn setEnabled:NO];
            [self.cancelBtn setAlpha:0.4];
            
            if (self.transferStarted) { // transfer started, sender side on cancel option, consider as interupted
                [self dataTransferInterrupted:TRANSFER_INTERRUPTED];
            } else { // transfer doesn't start, sender cancel on selection view
                [self dataTransferInterrupted:TRANSFER_CANCELLED];
            }
        } else if (err.code == GCDSocketNotConnected) {
            
            self.trasnferCancel = true;
            
            asyncSocket.delegate = nil;
            listenOnPort.delegate = nil;
            
            [asyncSocket disconnect];
            [listenOnPort disconnect];
            
            asyncSocketCommPort.delegate = nil;
            listenOnPortCommPort.delegate = nil;
            
            [asyncSocketCommPort disconnect];
            [listenOnPortCommPort disconnect];
            
            asyncSocketCommPort= nil;
            listenOnPortCommPort = nil;

            
            asyncSocket = nil;
            listenOnPort = nil;
            
            [self.dataProgressView setHidden:YES];
            
            [self.cancelBtn setEnabled:NO];
            [self.cancelBtn setAlpha:0.4];
            
            [self dataTransferInterrupted:TRANSFER_INTERRUPTED];
        }
    } else {
        // release
        asyncSocket.delegate = nil;
        listenOnPort.delegate = nil;
        
        [asyncSocket disconnect];
        [listenOnPort disconnect];
        
        asyncSocket = nil;
        listenOnPort = nil;
        
        asyncSocketCommPort.delegate = nil;
        listenOnPortCommPort.delegate = nil;
        
        [asyncSocketCommPort disconnect];
        [listenOnPortCommPort disconnect];
        
        asyncSocketCommPort= nil;
        listenOnPortCommPort = nil;

    }
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
    
    if (asyncSocketCommPort == nil) {
        
        asyncSocketCommPort = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        asyncSocketCommPort = newSocket;
        asyncSocketCommPort.delegate = self;
        
        [asyncSocketCommPort readDataWithTimeout:-1 tag:0];
        
    } else {
        
        [self.dataReceivingStatus setText:@"Waiting to Receive Content"];
        
        //    DebugLog(@"Received Connection..");
        asyncSocket = newSocket;
        asyncSocket.delegate = self;
        
        [asyncSocket readDataWithTimeout:-1 tag:0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    //    DebugLog(@"Receive Memory Warning..");
    memoryWarningFlag = TRUE;
    //    [self.processingDataLbl setText:@"Please Wait .. Processing Downloaded
    //    Data"];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
// preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ReceiverCompleted"]) {
        
        VZTransferFinishViewController *destination =
        segue.destinationViewController;
        
        destination.summaryDisplayFlag = 2;
        
        destination.transferInterrupted = self.trasnferCancel;
        
        self.trasnferCancel ? (destination.numberOfPhotos = (tempPhotoCount + 1 > self.photolist.count ? tempPhotoCount : tempPhotoCount + 1)) : (destination.numberOfPhotos = tempPhotoCount);
        [self nothingToWrite:[self.videoWrittingTaskList allValues]] ? (destination.numberOfVideos = (self.videoAlreadyWrittenList.count > 0 ? tempVideoCount + self.videoAlreadyWrittenList.count : tempVideoCount)) : (destination.numberOfVideos = tempVideoCount + videoAlreadyWrittenList.count);
        destination.numberOfContacts = self.numberOfContacts;
        destination.numberOfCalendar = self.calList.count;
        destination.numberOfReminder =
        reminderFound ? 1 : 0; // hard coded, file number
        
        destination.maxspeed = maxSpeed;
        destination.isSender = NO;
        destination.calendarReceived = self.hasCalendarSent;
        destination.importReminder = reminderFound;
        
        destination.hasVcardPermissionErr = self.hasVcardPermissionErr;
        destination.hasAlbumPermissionErr = self.hasAlbumPermissionErr;
        destination.mediaTypePiped = mediaTypePiped;
        destination.transferStarted = self.transferStarted;
        
        destination.delegate = destination;
        self.delegate = destination.delegate;
        destination.analyticsTypeID = self.targetTypeID;
        
        int notReadyVideoCount = (int)videoAlreadyWrittenList.count;
        
        if (tempPhotoCount > 0 || (tempVideoCount > 0 || notReadyVideoCount > 0)) {
            if ((tempVideoCount > 0 || notReadyVideoCount > 0) &&
                tempPhotoCount > 0) {
                if (self.videoAlreadyWrittenList.count == 0) {
                    destination.downLoadDataLblStr = [NSString stringWithFormat: @"Please wait.. %d Photo(s) and %d Video(s) to be saved", tempPhotoCount, tempVideoCount];
                } else {
                    destination.downLoadDataLblStr = [NSString stringWithFormat: @"Please wait.. %d Photo(s) and %d Video(s) to be saved", tempPhotoCount, tempVideoCount + notReadyVideoCount];
                }
            } else if (tempPhotoCount > 0) {
                destination.downLoadDataLblStr =
                [NSString stringWithFormat:@"Please wait.. %d Photo(s) to be saved",
                 tempPhotoCount];
            } else if (tempVideoCount > 0 || notReadyVideoCount > 0) {
                videoWrittingTaskList.count == 0
                ? (destination.downLoadDataLblStr = [NSString
                                                     stringWithFormat:@"Please wait.. %d Video(s) to be saved",
                                                     tempVideoCount])
                : (destination.downLoadDataLblStr = [NSString
                                                     stringWithFormat:@"Please wait.. %d Video(s) to be saved",
                                                     tempVideoCount + notReadyVideoCount]);
            } else {
                destination.downLoadDataLblStr =
                @"Please wait.. Processing Downloaded Data";
            }
            
            destination.processEnd = NO;
            
        } else {
            destination.calendarReceived = self.hasCalendarSent;
            if (self.hasCalendarSent && !self.trasnferCancel) {
                destination.downLoadDataLblStr = @"Please wait.. Importing Calendars";
            } else {
                if (self.trasnferCancel) {
                    destination.downLoadDataLblStr =
                    @"Transfer did not complete. Please review transfer summary.";
                } else if (self.videoFailedList.count == 0 &&
                           self.photoFailedList.count == 0 &&
                           !self.hasAlbumPermissionErr && !self.hasVcardPermissionErr) {
                    destination.downLoadDataLblStr =
                    @"Data Transfer completed successfully!";
                } else {
                    destination.photoErrList = self.photoFailedList;
                    destination.videoErrList = self.videoFailedList;
                    destination.downLoadDataLblStr = @"Download completed with Error(s), tap on \"Summary\" to check the detail.";
                }
                
                if (!self.trasnferCancel) {
                    // Because the synchronize for NSUserDefault is async, so wait for 2
                    // sec to finish writing
                    [[NSUserDefaults standardUserDefaults]
                     removeObjectForKey:@"PHOTODUPLICATELIST"];
                    [[NSUserDefaults standardUserDefaults]
                     removeObjectForKey:@"VIDEODUPLICATELIST"]; // after all data saved
                    // finished, remove the
                    // duplicate list
                    [[NSUserDefaults standardUserDefaults] synchronize];
                } else { // if cancelled
                    [[NSUserDefaults standardUserDefaults] setBool:self.vcardReceived
                                                            forKey:@"VCARDDUPLICATELIST"];
                    [[NSUserDefaults standardUserDefaults]
                     setBool:self.calendarReceived
                     forKey:@"CALENDARDUPLICATELIST"];
                    [[NSUserDefaults standardUserDefaults]
                     setBool:self.reminderReceived
                     forKey:@"REMINDERDUPLICATELIST"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            
            destination.processEnd = YES;
        }
    }
}

#pragma mark import contacts method
- (void)importVcardData:(NSData *)vcardData {
    
    VZContactsImport *vCardImport = [[VZContactsImport alloc] init];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.dataProgressView setHidden:YES];
        
        [weakSelf.dataReceivingStatus setText:@"Saving Contacts"];
        [weakSelf.processingDataLbl setText:@"Please wait... Importing Contacts"];
    });
    
    vCardImport.completionHandler = ^(NSInteger contactNumber) {
        weakSelf.numberOfContacts = contactNumber;
        weakSelf.vCardfile_size = 0;
        [weakSelf finishedAllOperation];
    };
    
    [vCardImport importAllVcard:vcardData];
}

- (void)storePhotoLogfile:(NSData *)photoLogFileData {
    
    // NSdata to NAarray
    
    NSString *response = [[NSString alloc] initWithData:photoLogFileData
                                               encoding:NSUTF8StringEncoding];
    
    NSArray *jsonObject = [NSJSONSerialization
                           JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding]
                           options:0
                           error:NULL];
    
    photolist = [[NSArray alloc] initWithArray:jsonObject];
    
    //    DebugLog(@"Photo Log file is %@", jsonObject);
}

- (void)storeVideoLogfile:(NSData *)videoLogFileData {
    
    // NSdata to NAarray
    
    NSString *response = [[NSString alloc] initWithData:videoLogFileData
                                               encoding:NSUTF8StringEncoding];
    
    NSArray *jsonObject = [NSJSONSerialization
                           JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding]
                           options:0
                           error:NULL];
    
    videolist = [[NSArray alloc] initWithArray:jsonObject];
    
    //    DebugLog(@"Video Log file is %@", jsonObject);
}

- (void)notifyAllFileListCompletion:(BOOL)shouldUpdateUI {
    
    if (shouldUpdateUI)
        [self.receivedFileStatuLbl setText:@"Received File List"];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dict =
    [[userDefault valueForKey:@"itemList"] mutableCopy];
    
    BOOL flag = YES;
    if (!self.hasCalendarPermissionErr && [[dict valueForKey:@"calendar"] isEqualToString:@"true"]) {
        
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
        
        DebugLog(@"Calendar info:\n%@", self.calInfo);

        NSString *ackMsg = nil;
        if (self.calList.count == 1) {
            ++totalFilesReceived;
            if (self.isAndriodPlatform) { // x-platform
                ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_FINAL_REQUEST_FOR_CALENDAR_%@", [self.calInfo valueForKey:@"Path"]];
            } else {
                ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_CALENDAR_%@", [self.calInfo valueForKey:@"Path"]];
            }
        } else {
            ++totalFilesReceived;
            if (self.isAndriodPlatform) { // x-platform
                ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_START_REQUEST_FOR_CALENDAR_%@",  [self.calInfo valueForKey:@"Path"]];
            } else {
                ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_CALENDAR_%@",  [self.calInfo valueForKey:@"Path"]];
            }
        }
        DebugLog(@"msg:%@", ackMsg);
        
        NSData *requestData = [[ackMsg dataUsingEncoding:NSUTF8StringEncoding] appendCRLFData];
        
        recevier_state = RECEVIE_CALENDER_FILE;
        
        [asyncSocket writeData:requestData withTimeout:-1.0 tag:100];
        //        [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:100];
        
        [asyncSocket readDataWithTimeout:-1 tag:0];
        
    } else if (!self.hasVcardPermissionErr && [[dict valueForKey:@"contacts"] isEqualToString:@"true"]) {
        
        [dict setValue:@"false" forKey:@"contacts"];
        
        flag = NO;
        
        [userDefault setValue:dict forKey:@"itemList"];
        
        NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_VCARD"];
        
        DebugLog(@"msg:%@", shareKey);
        
        NSData *requestData = [[shareKey dataUsingEncoding:NSUTF8StringEncoding] appendCRLFData];
        
        recevier_state = RECEIVE_VCARD_FILE;
        
        [asyncSocket writeData:requestData withTimeout:-1.0 tag:100];
        //        [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:100];
        
        [asyncSocket readDataWithTimeout:-1 tag:0];
        
    } else if (!self.hasReminderPermissionErr && [[dict valueForKey:@"reminder"] isEqualToString:@"true"]) {
        
        [dict setValue:@"false" forKey:@"reminder"];
        
        flag = NO;
        
        [userDefault setValue:dict forKey:@"itemList"];
        
        NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_REMIN"];
        
        DebugLog(@"msg:%@", shareKey);

        NSData *requestData = [[shareKey dataUsingEncoding:NSUTF8StringEncoding] appendCRLFData];
        
        recevier_state = RECEVIE_REMINDER_FILE;
        
        [asyncSocket writeData:requestData withTimeout:-1.0 tag:100];
        //        [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:100];
        
        [asyncSocket readDataWithTimeout:-1 tag:0];
        
    } else {
        
        if (!self.hasAlbumPermissionErr && [[dict valueForKey:@"photos"] isEqualToString:@"true"]) {
            
            self.photolist = [userDefault valueForKey:@"photoFilteredFileList"];
            
            [dict setValue:@"false" forKey:@"photos"];
            
            [userDefault setValue:dict forKey:@"itemList"];
            
            if ([self.photolist count] > 0) {
                
                ++totalFilesReceived;
            }
            
            __weak typeof(self) weakSelf = self;
            
            if ([self.photolist count] > 0) {
                
                flag = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.receivedFileStatuLbl
                     setText:[NSString
                              stringWithFormat:@"Photo %d of %lu",
                              weakSelf.photoCountIndex,
                              (unsigned long)
                              [weakSelf.photolist count]]];
                });
                
                photoinfo = [photolist objectAtIndex:photoCountIndex];
                
                photoCountIndex++;
                
                // NSdictionary has "Path" and "Size" has keys
                NSString *ackMsg = [NSString
                                    stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_%@",
                                    [self encodeStringTo64:[photoinfo valueForKey:@"Path"]]];
                DebugLog(@"msg:%@", ackMsg);
                
                NSData *requestData = [[ackMsg dataUsingEncoding:NSUTF8StringEncoding] appendCRLFData];
                
                recevier_state = RECEIVE_PHOTO_FILE;
                
                [asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
                //                [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];
                
                [asyncSocket readDataWithTimeout:-1 tag:0];
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
                    
                    if (weakSelf.videoCountIndex != 0) {
                        [weakSelf.receivedFileStatuLbl setText:[NSString stringWithFormat:@"Video %d of %lu", weakSelf.videoCountIndex, (unsigned long)[weakSelf.videolist count]]];
                    }
                });
                
                videoinfo = [videolist objectAtIndex:videoCountIndex];
                videoCountIndex++;
                
                // NSdictionary has "Path" and "Size" has keys
                
                NSString *ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_%@", [self encodeStringTo64:[videoinfo valueForKey:@"Path"]]];
                DebugLog(@"msg:%@", ackMsg);
                
                NSData *requestData = [[ackMsg dataUsingEncoding:NSUTF8StringEncoding] appendCRLFData];
                
                recevier_state = RECEIVE_VIDEO_FILE;
                
                [asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
                //                [asyncSocket writeData:[GCDAsyncSocket CRLFData]
                //                           withTimeout:-1.0
                //                                   tag:0];
                
                [asyncSocket readDataWithTimeout:-1 tag:0];
            }
        }
    }
    
    if (flag) {
        [self dataTransferFinished];
    }
}

- (void)notifySenderRegardingPhotoFileReceiveCompletion {
    
    recevier_state = RECEIVE_PHOTO_FILE;
    
    __weak typeof(self) weakSelf = self;
    
    if (photoCountIndex == [photolist count]) {
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        NSDictionary *dict = [userDefault valueForKey:@"itemList"];
        
        if ([[dict valueForKey:@"videos"] isEqualToString:@"true"]) {
            
            self.videolist = [userDefault valueForKey:@"videoFilteredFileList"];
            
            __weak typeof(self) weakSelf = self;
            
            if ([self.videolist count] > 0) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.videoCountIndex != 0) {
                        [weakSelf.receivedFileStatuLbl setText:[NSString stringWithFormat:@"Video 1 of %lu", (unsigned long)[weakSelf.videolist count]]];
                    }
                    
                    ++weakSelf.totalFilesReceived;
                });
                
                if (videoCountIndex < [videolist count]) {
                    
                    videoinfo = [videolist objectAtIndex:videoCountIndex];
                    videoCountIndex++;
                    
                    // NSdictionary has "Path" and "Size" has keys
                    
                    NSString *ackMsg = [NSString
                                        stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_%@",
                                        [self encodeStringTo64:[videoinfo valueForKey:@"Path"]]];

                    DebugLog(@"msg:%@", ackMsg);
  
                    NSData *requestData = [[ackMsg dataUsingEncoding:NSUTF8StringEncoding] appendCRLFData];
                    
                    recevier_state = RECEIVE_VIDEO_FILE;
                    
                    [asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
                    //                    [asyncSocket writeData:[GCDAsyncSocket CRLFData]
                    //                               withTimeout:-1.0
                    //                                       tag:0];
                    
                    [asyncSocket readDataWithTimeout:-1 tag:0];
                }
                
            } else {
                
                [self dataTransferFinished];
            }
            
        } else {
            
            [self dataTransferFinished];
        }
        
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.receivedFileStatuLbl
             setText:[NSString stringWithFormat:@"Photo %d of %lu",
                      weakSelf.photoCountIndex,
                      (unsigned long)
                      [weakSelf.photolist count]]];
        });
        
        if (memoryWarningFlag) {
            
            [self.dataProgressView setHidden:YES];
            [self.processingDataLbl
             setText:@"Please wait.. Processing Downloaded Data"];
            
            return;
        }
        
        photoinfo = [photolist objectAtIndex:photoCountIndex];
        
        photoCountIndex++;
        // NSdictionary has "Path" and "Size" has keys
        
        // wait to complete pending task
        ++totalFilesReceived;
        
        NSString *ackMsg =
        [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_%@",
         [self encodeStringTo64:[photoinfo valueForKey:@"Path"]]];
        
        NSData *requestData = [[ackMsg dataUsingEncoding:NSUTF8StringEncoding] appendCRLFData];
        
        [asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
        //        [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];
        
        [asyncSocket readDataWithTimeout:-1 tag:0];
    }
}

- (void)notifySenderRegardingVideoFileReceiveCompletion {
    
    recevier_state = RECEIVE_VIDEO_FILE;
    
    __weak typeof(self) weakSelf = self;
    
    if (videoCountIndex == [videolist count]) {
        
        [self dataTransferFinished];
        
    } else {
        
        if ([self.videolist count] > 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.videoCountIndex != 0)
                    [weakSelf.receivedFileStatuLbl
                     setText:[NSString
                              stringWithFormat:@"Video %d of %lu",
                              weakSelf.videoCountIndex,
                              (unsigned long)
                              [weakSelf.videolist count]]];
                
                ++weakSelf.totalFilesReceived;
            });
        }
        
        videoinfo = [videolist objectAtIndex:videoCountIndex];
        videoCountIndex++;
        
        // NSdictionary has "Path" and "Size" has keys
        
        // are iphone supported video formats .m4v, .mp4, and .mov file formats;
        
        NSString *ackMsg =
        [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_%@",
         [self encodeStringTo64:[videoinfo valueForKey:@"Path"]]];
        DebugLog(@"msg:%@", ackMsg);

        NSData *requestData = [[ackMsg dataUsingEncoding:NSUTF8StringEncoding] appendCRLFData];
        
        [asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
        //        [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];
        
        [asyncSocket readDataWithTimeout:-1 tag:0];
    }
}

- (void)updateDuplicatePhoto:(NSString *)URL
               withPhotoInfo:(NSDictionary *)photoInfo
                     success:(BOOL)success
                     orError:(NSError *)error {
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
    
    @synchronized(self) {
        self.tempPhotoCount--;
        DebugLog(@"photo left:%d", self.tempPhotoCount);
        if (self.tempPhotoCount == 0) {
            DebugLog(@"video count:%d, videowrtting list count:%lu, videotasklistcount:%lu", self.tempPhotoCount,(unsigned long)self.videoAlreadyWrittenList.count,(unsigned long)self.videoWrittingTaskList.count);
            if ((self.tempVideoCount > 0 || self.videoAlreadyWrittenList.count > 0) &&
                [self nothingToWrite:[videoWrittingTaskList allValues]]) {
                DebugLog(@"store videos when photo finished");
                // photos saving completed, start saving videos
                [self storeVideoIntoGallery];
            }
        }
    }
    
    // Clear the temp file in the folder for successfully saved photo
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
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
    
    if (self.trasnferCancel &&
        self.localDuplicateList.count ==
        (self.photoSavingList.count + self.photoSavingList2.count +
         self.photoSavingList3.count + self.photoSavingList4.count +
         self.photoSavingList5.count +
         self.photoSavingList6
         .count)) { // only cancel transfer need to save duplicate list
            
            NSMutableArray *duplicateList = [[[NSUserDefaults standardUserDefaults]
                                              valueForKey:@"PHOTODUPLICATELIST"] mutableCopy];
            [duplicateList addObjectsFromArray:self.localDuplicateList];
            [[NSUserDefaults standardUserDefaults] setObject:duplicateList
                                                      forKey:@"PHOTODUPLICATELIST"];
            [[NSUserDefaults standardUserDefaults] setBool:self.vcardReceived
                                                    forKey:@"VCARDDUPLICATELIST"];
            [[NSUserDefaults standardUserDefaults] setBool:self.calendarReceived
                                                    forKey:@"CALENDARDUPLICATELIST"];
            [[NSUserDefaults standardUserDefaults] setBool:self.reminderReceived
                                                    forKey:@"REMINDERDUPLICATELIST"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.localDuplicateList = nil;
        }
    
    if (delegate) { // Already go to finish view, transfer finished saving process
        if (self.videoAlreadyWrittenList.count == 0) {
            [delegate updateSavingProcessDataWithPhotoNumber:tempPhotoCount
                                              andVideoNumber:tempVideoCount
                                          andVideoFailedInfo:self.videoFailedList
                                          andPhotoFailedInfo:self.photoFailedList];
        } else {
            [delegate
             updateSavingProcessDataWithPhotoNumber:tempPhotoCount
             andVideoNumber:tempVideoCount +
             (int)videoAlreadyWrittenList
             .count
             andVideoFailedInfo:self.videoFailedList
             andPhotoFailedInfo:self.photoFailedList];
        }
    }
}

- (void)sendCancelMsg {
    
    NSString *ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_FINISHED"];
    
    NSData *requestData = [[ackMsg dataUsingEncoding:NSUTF8StringEncoding] appendCRLFData];
    
    // Waiting for All pending task to complete
    
    [asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
    //    [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];
}

int videoCountAdapt = 0;
- (void)updateDuplicateVideo:(NSString *)URL
               withVideoInfo:(NSDictionary *)videoInfo
                     success:(BOOL)success
                     orError:(NSError *)error {
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
    
    @synchronized(self) {
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
        videoCountAdapt++;
    }
    
    if (self.trasnferCancel && self.localDuplicateVideoList.count == (self.videoSavingList.count + self.videoSavingList2.count -
         videoCountAdapt)) { // only cancel transfer need to save duplicate
            // list
            
            NSMutableArray *duplicateList = [[[NSUserDefaults standardUserDefaults]
                                              valueForKey:@"VIDEODUPLICATELIST"] mutableCopy];
            [duplicateList addObjectsFromArray:self.localDuplicateVideoList];
            [[NSUserDefaults standardUserDefaults] setObject:duplicateList
                                                      forKey:@"VIDEODUPLICATELIST"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSUserDefaults standardUserDefaults] setBool:self.vcardReceived
                                                    forKey:@"VCARDDUPLICATELIST"];
            [[NSUserDefaults standardUserDefaults] setBool:self.calendarReceived
                                                    forKey:@"CALENDARDUPLICATELIST"];
            [[NSUserDefaults standardUserDefaults] setBool:self.reminderReceived
                                                    forKey:@"REMINDERDUPLICATELIST"];
            
            self.localDuplicateVideoList = nil;
        }
    
    if (delegate) { // Already go to finish view, transfer finished saving process
        [delegate updateSavingProcessDataWithPhotoNumber:tempPhotoCount
                                          andVideoNumber:tempVideoCount
                                      andVideoFailedInfo:self.videoFailedList
                                      andPhotoFailedInfo:self.photoFailedList];
    }
}

- (void)dataTransferFinished {
    //    // Need this wait in case of just contact transfer
    //    sleep(1);
    
    self.processDone = YES;
    
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
        totalDownloadStr =
        [NSString stringWithFormat:@"%.fMB", totalDownloadedData];
    }
    
    [userDefault setObject:totalDownloadStr forKey:@"TOTALDOWNLOADEDDATA"];
    
    [userDefault setValue:[NSString stringWithFormat:@"%d", totalFilesReceived]
                   forKey:@"TOTALFILESRECEIVED"];
    
    NSString *ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_FINISHED"];
    NSData *requestData = [[ackMsg dataUsingEncoding:NSUTF8StringEncoding] appendCRLFData];
    
    // Waiting for All pending task to complete
    
    //    [serailPhotoQueue waitUntilAllOperationsAreFinished];
    
    [asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
    //    [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([weakSelf.videolist count] > 0) {
            
            if (weakSelf.videoCountIndex != 0)
                [weakSelf.receivedFileStatuLbl
                 setText:[NSString stringWithFormat:@"Video %d of %lu",
                          weakSelf.videoCountIndex,
                          (unsigned long)
                          [weakSelf.videolist count]]];
        }
    });
    
    self.targetTypeID = TRANSFER_SUCCESS;
    
    if (!self.hasVcardPermissionErr && vCardfile_size > 0) {
        
//        NSString *documentsDirectory1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Documents"];
        NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZAllContactBackup.vcf"];
        
        NSData *vcardData = [[NSFileManager defaultManager] contentsAtPath:fileName];
        if (vcardData && vcardData.length > 0) {
            NSInvocationOperation *newoperation = [[NSInvocationOperation alloc]
                                                   initWithTarget:self
                                                   selector:@selector(importVcardData:)
                                                   object:vcardData];
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
        totalDownloadStr =
        [NSString stringWithFormat:@"%.fMB", totalDownloadedData];
    }
    
    [userDefault setObject:totalDownloadStr forKey:@"TOTALDOWNLOADEDDATA"];
    [userDefault setValue:[NSString stringWithFormat:@"%d", totalFilesReceived]
                   forKey:@"TOTALFILESRECEIVED"];
    
    self.targetTypeID = typeID;
    
    if (!self.hasVcardPermissionErr &&
        vCardfile_size > 0) { // Cancel saving contacts
        
//        NSString *documentsDirectory1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Documents"];
        NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZAllContactBackup.vcf"];
        NSData *vcardData = [[NSFileManager defaultManager] contentsAtPath:fileName];
        if (vcardData && vcardData.length > 0) {
            NSInvocationOperation *newoperation = [[NSInvocationOperation alloc]
                                                   initWithTarget:self
                                                   selector:@selector(importVcardData:)
                                                   object:vcardData];
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
    
    if (tempPhotoCount > 0 &&
        tempPhotoCount ==
        (self.photoSavingList.count + self.photoSavingList2.count +
         self.photoSavingList3.count + self.photoSavingList4.count +
         self.photoSavingList5.count +
         self.photoSavingList6
         .count)) { // if photos need to be saved, save photo first
            allPhotoDownLoadFlag = NO;
            DebugLog(@"store photos in finish");
            [self storePhotoIntoGallery];
        } else if (tempVideoCount > 0 ||
                   videoAlreadyWrittenList.count > 0) { // no photos, save videos
            allPhotoDownLoadFlag = NO;
            
            if ([self nothingToWrite:[videoWrittingTaskList allValues]]) { // all the file writting processes are done
                DebugLog(@"store videos in finish");
                [self storeVideoIntoGallery];
            }
        }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
        
        [infoDict
         setObjectIfValid:[NSString
                           stringWithFormat:@"%ld", (long)weakSelf.numberOfContacts]
         forKey:@"ContactCount" defaultObject:@0];
        [infoDict
         setObjectIfValid:[NSString
                           stringWithFormat:@"%lu",
                           (unsigned long)weakSelf.photolist.count]
         forKey:@"PhotosCount" defaultObject:@0];
        [infoDict
         setObjectIfValid:[NSString
                           stringWithFormat:@"%lu",
                           (unsigned long)weakSelf.videolist.count]
         forKey:@"VideosCount" defaultObject:@0];
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%ld",
                                    (long)weakSelf.calList.count]
                            forKey:@"CalendarCount" defaultObject:@0];
        [infoDict setObject:reminderFound ? @"1" : @"0" forKey:@"ReminderCount"];
        [infoDict setObject:@"0" forKey:@"SmsCount"];
        [infoDict setObject:@"0" forKey:@"CallLogsCount"];
        [infoDict setObject:@"0" forKey:@"MusicCount"];
        [infoDict setValue:@"P2P" forKey:@"ConnectionType"];
        [infoDict
         setObjectIfValid:[NSString stringWithFormat:@"%lld", weakSelf.totalPayLoadSize]
         forKey:@"TotalDataReceived" defaultObject:@0];
        [infoDict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
        
        [[CTMVMSessionSingleton sharedGlobal]
         .vzctAnalyticsObject trackEvent:weakSelf.view
         withTrackTag:@"ReceiveDataScreen"
         withExtraInfo:infoDict
         isEncryptedExtras:false];
        
        [self performSegueWithIdentifier:@"ReceiverCompleted" sender:nil];
    });
}

- (void)readSocketRepeated {
    
    [asyncSocket readDataWithTimeout:-1 tag:0];
    //
    //    dispatch_queue_t alwaysReadQueue =
    //    dispatch_queue_create([GCD_ALWAYS_READ_QUEUE UTF8String], NULL);
    //
    //    dispatch_async(alwaysReadQueue, ^{
    //        while(![asyncSocket isDisconnected]) {
    //            [NSThread sleepForTimeInterval:0.1];
    //            [asyncSocket readDataWithTimeout:-1 tag:0];
    //        }
    //    });
}

- (void)updateDataMatrix:(int)datalen {
    
    totalDownloadedData += (float)datalen / (1000 * 1000);
    
    NSDate *currentTime = [NSDate date];
    
    NSTimeInterval secondsBetween =
    [currentTime timeIntervalSinceDate:self.startTime];
    
    int hh = secondsBetween / (60 * 60);
    double rem = fmod(secondsBetween, (60 * 60));
    int mm = rem / 60;
    rem = fmod(rem, 60);
    int ss = rem;
    
    NSString *str = [NSString stringWithFormat:@"%02d:%02d:%02d", hh, mm, ss];
    
    downloadSpeed = totalDownloadedData / (float)secondsBetween * 8;
    
    if (downloadSpeed > self.maxSpeed) {
        
        self.maxSpeed = downloadSpeed;
    }
    
    NSTimeInterval estimatedSeconds =
    (totaldownloadableData / (1000 * 1000) - totalDownloadedData) /
    downloadSpeed * 8;
    
    hh = estimatedSeconds / (60 * 60);
    rem = fmod(estimatedSeconds, (60 * 60));
    mm = rem / 60;
    rem = fmod(rem, 60);
    ss = rem;
    
    if (ss < 0) {
        ss = 0;
    }
    
    NSString *str1 = [NSString stringWithFormat:@"%02d:%02d:%02d", hh, mm, ss];
    
    __weak typeof(self) weakSelf = self;
    
    // update progress bar
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf.downloadSpeedLbl
         setText:[NSString stringWithFormat:@"Speed: %.f Mbps", downloadSpeed]];
        
        [weakSelf.timeElaspedLbl
         setText:[NSString stringWithFormat:@"Time Elapsed:%@", str]];
        
        [weakSelf.timeestimatedLbl
         setText:[NSString stringWithFormat:@"Time Estimated:%@", str1]];
        
        [weakSelf.totalDownLoadedDataLbl
         setText:[NSString
                  stringWithFormat:@"Received: %.f MB",
                  (totalDownloadedData * (1000 * 1000)) /
                  (1024.0f * 1024.0f)]];
        
        weakSelf.dataProgressView.progress =
        totalDownloadedData / (totaldownloadableData / (1000 * 1000));
        
        [weakSelf.downloadSpeedLbl layoutIfNeeded];
        [weakSelf.timeElaspedLbl layoutIfNeeded];
        [weakSelf.timeestimatedLbl layoutIfNeeded];
        [weakSelf.totalDownLoadedDataLbl layoutIfNeeded];
        
    });
}

- (void)startAnimationReccevierImageView {
    
    self.receiverAnimationImgVIew.animationImages =
    [NSArray arrayWithObjects:[ UIImage getImageFromBundleWithImageName:@"anim_left_1x_00" ],
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
     [ UIImage getImageFromBundleWithImageName:@"anim_left_1x_27" ], nil];
    
    // all frames will execute in 1.75 seconds
    self.receiverAnimationImgVIew.animationDuration = 1.75;
    // repeat the animation forever
    self.receiverAnimationImgVIew.animationRepeatCount = 0;
    // start animating
    [self.receiverAnimationImgVIew startAnimating];
}

- (void)stopAnimationReceiverImageVIew {
    
    [self.receiverAnimationImgVIew stopAnimating];
}

//-(void) createMediaLogFile {
//
//    VZPhotosExport *mediaList = [[VZPhotosExport alloc] init];
//
//    [mediaList createphotoLogfile];
//
//    mediaList.photocallBackHandler = ^(int photocount) {
//
//        DebugLog(@"Number of Photo found %d", photocount);
//    };
//    [mediaList createvideoLogfile];
//
//    mediaList.videocallBackHandler = ^(int videocount) {
//
//        DebugLog(@"Number of Video found %d", videocount);
//    };
//}

- (BOOL)calculatetotalDownloadableDataSize {
    long long photoDataSize = 0;
    long long videoDataSize = 0;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dict =
    [[userDefault valueForKey:@"itemList"] mutableCopy];
    
    [dict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
    
    [[CTMVMSessionSingleton sharedGlobal]
     .vzctAnalyticsObject trackEvent:self.view
     withTrackTag:@"ReceiveDataScreen"
     withExtraInfo:dict
     isEncryptedExtras:false];
    
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
    
    long long calFileSize = 0;
    
    if ([[dict valueForKey:@"calendar"] isEqualToString:@"true"]) {
        NSArray *cals = [userDefault valueForKey:@"calFileList"];
        for (NSDictionary *cal in cals) {
            calFileSize += [[cal objectForKey:@"Size"] integerValue];
        }
    }
    totaldownloadableData += calFileSize;
    
    totalPayLoadSize = (long)(totaldownloadableData / (1000 * 1000));
    availableStorage = self.getFreeDiskspace;
    
    __weak typeof(self) weakSelf = self;
    if (totalPayLoadSize > availableStorage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *str = [NSString
                             stringWithFormat:@"Insufficient storage. Only %lld MB available on the device. Free some space and try again.",
                             (availableStorage)];
            
            CTMVMAlertAction *okAction = [CTMVMAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                                            [self dataTransferInterrupted:INSUFFICIENT_STORAGE];
                                            
                                            //                                            [self performSegueWithIdentifier:@"ReceiverCompleted" sender:nil];
                                        }];
            
            [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer"
                                                          message:str
                                                     cancelAction:nil
                                                     otherActions:@[ okAction ]
                                                         isGreedy:NO];
        });
        
        return NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.totalDownloadDataSizeLbl
         setText:[NSString stringWithFormat:@"Total Size : %lld MB",
                  totalPayLoadSize]];
    });
    
    return YES;
}

- (long long)getFreeDiskspace {
    long long totalSpace = 0;
    long long totalFreeSpace = 0;
    NSError *error = nil;
    NSString *basePath = [NSString appRootDocumentDirectory];
    NSDictionary *dictionary = [[NSFileManager defaultManager]
                                attributesOfFileSystemForPath:basePath
                                error:&error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes =
        [dictionary objectForKey:NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes =
        [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        //        DebugLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory
        //        available.", ((totalSpace/1024ll)/1024ll),
        //        ((totalFreeSpace/1024ll)/1024ll));
    } else {
        DebugLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld",
              [error domain], (long)[error code]);
    }
    
    return ((totalFreeSpace / 1024ll) / 1024ll);
}

- (void)storeVideoReceivedPacketToTempFile:(NSData *)receivedPacket {
    
    NSString *tempstr = [videoinfo valueForKey:@"Path"];
    NSString *theFileName = [tempstr lastPathComponent];
    
    NSString *key = @"";
    
    NSString *fileName = @"";
    if (!self.isAndriodPlatform) {
        fileName = [NSString stringWithFormat:@"%@/%@", videoFolderPath, [tempstr stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
        key = fileName;
    } else {
        fileName =
        [NSString stringWithFormat:@"%@/%@", videoFolderPath, theFileName];
        key = theFileName;
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
    
    if (fileHandle) {
        
        if ((self.intermediateData.length + receivedPacket.length < packageSize * 1024 * 1024) && (tillNowVideoReceived != videofile_size)) {
            [self.intermediateData appendData:receivedPacket];
            
            return;
        }
        //        DebugLog(@"->above 200MB, should write");
        [self.intermediateData appendData:receivedPacket];
        
        // NSData *packData = [[NSData alloc] initWithData:self.intermediateData];
        
        // Add data to be written to the list
        if (![self.videoWrittingTaskList objectForKey:key]) {
            @synchronized(self) {
                VZConcurrentWritingHelper *videoPackage = [[VZConcurrentWritingHelper alloc] initWithID:key
                                                                                                andSize:videofile_size
                                                                                                andInfo:videoinfo
                                                                                             andPackage:self.intermediateData];
                [self.videoWrittingTaskList setObject:videoPackage forKey:key];
            }
        } else {
            @synchronized(self) {
                [((VZConcurrentWritingHelper *)[self.videoWrittingTaskList objectForKey:key]).packagesWaitingForWriting addObject:self.intermediateData];
            }
        }
        DebugLog(@"task list:%lu", (unsigned long)self.videoWrittingTaskList.count);
        DebugLog(@"already writing list:%lu", (unsigned long)self.videoAlreadyWrittenList.count);
        
        __weak typeof(self) weakSelf = self;
        DebugLog(@"->check file:%@", key);
        if (!((VZConcurrentWritingHelper *)[self.videoWrittingTaskList objectForKey:key]).currentLock) { // current file writting is not start
            
            @synchronized (self) {
                ((VZConcurrentWritingHelper *)[self.videoWrittingTaskList objectForKey:key]).currentLock = YES; // add lock
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                @autoreleasepool {
                    DebugLog(@"debug:%lu", (unsigned long)((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).packagesWaitingForWriting.count);
                    while (((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).packagesWaitingForWriting.count > 0) {
                        
                        DebugLog(@"->start writing key:%@", key);
                        
                        @autoreleasepool {
                            [fileHandle seekToEndOfFile];
                            
                            NSData *videoPackage = (NSData *)[((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).packagesWaitingForWriting objectAtIndex:0];
                            
                            [fileHandle writeData:videoPackage];
                            
                            DebugLog(@"->package written:%lu", (unsigned long)videoPackage.length);
                            
                            @synchronized(weakSelf) {
                                [((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).packagesWaitingForWriting removeObjectAtIndex:0];
                            }
                            
                            DebugLog(@"->rest package:%lu", (unsigned long)((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).packagesWaitingForWriting.count);
                            
                            [weakSelf updateVideoWritingListFor:key
                                                  withVideoSize:((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).videoSize
                                                 withDataLength:videoPackage.length
                                                  withVideoInfo:((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).videoInfo];
                            
                            videoPackage = nil;
                        }
                    }
                    
                    ((VZConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).currentLock = NO; // remove lock
                }
            });
        }
    } else { // first package
        [receivedPacket writeToFile:fileName atomically:NO];
        
        [self updateVideoWritingListFor:key
                          withVideoSize:videofile_size
                         withDataLength:receivedPacket.length
                          withVideoInfo:videoinfo];
    }
    
    self.intermediateData = nil;
    self.intermediateData = [[NSMutableData alloc] init];
}

- (void)updateVideoWritingListFor:(NSString *)fileName
                    withVideoSize:(long long)videoSize
                   withDataLength:(long long)length
                    withVideoInfo:(NSDictionary *)localVideoInfo {
    
    if ([self.videoAlreadyWrittenList objectForKey:fileName]) { // exist
        long long currentPackLength = [(NSNumber *)[self.videoAlreadyWrittenList objectForKey:fileName] unsignedIntegerValue];
        currentPackLength += length;
        
        DebugLog(@"video already written rest packages:%lld/%lld", currentPackLength, videoSize);
        if (currentPackLength == videoSize) {
            DebugLog(@"%@ completed", fileName);
            
            @synchronized(self) {
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
            
            @synchronized(self) {
                self.tempVideoCount++;
                DebugLog(@"->video saved:%d", self.tempVideoCount);
            }
            if (self.tempVideoCount == self.videolist.count) {
                DebugLog(@"break point");
            }
            
            if (self.processDone && videoAlreadyWrittenList.count == 0 && self.tempPhotoCount == 0 && (self.hasVcardPermissionErr || vCardfile_size <= 0)) {
                [self storeVideoIntoGallery];
            } else if (self.trasnferCancel && [self nothingToWrite:[videoWrittingTaskList allValues]] && self.tempPhotoCount == 0 && (self.hasVcardPermissionErr || vCardfile_size <= 0)) {
                [self storeVideoIntoGallery];
            }
            
            DebugLog(@"video %@ saving done!\n =================\n", fileName);
        } else {
            [self.videoAlreadyWrittenList setObject:[NSNumber numberWithLongLong:currentPackLength] forKey:fileName];
            
            if (self.trasnferCancel && [self nothingToWrite:[videoWrittingTaskList allValues]] && self.tempPhotoCount == 0 && (self.hasVcardPermissionErr || vCardfile_size <= 0)) {
                [self storeVideoIntoGallery];
            }
        }
    } else {                     // not exist
        if (length == videoSize) { // video size is equals to package size(200MB)
            @synchronized(self) {
                tempVideoCount++;
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
            if (delegate) {
                DebugLog(@"break point");
            }

            if (delegate && self.processDone && videoAlreadyWrittenList.count == 0 && self.tempPhotoCount == 0 && (self.hasVcardPermissionErr || vCardfile_size <= 0)) {
                [self storeVideoIntoGallery];
            } else if (self.trasnferCancel && [self nothingToWrite:[videoWrittingTaskList allValues]] && self.tempPhotoCount == 0 && (self.hasVcardPermissionErr || vCardfile_size <= 0)) {
                [self storeVideoIntoGallery];
            }
        } else {
            [self.videoAlreadyWrittenList setObject:[NSNumber numberWithLongLong:length] forKey:fileName];
            DebugLog(@"video already written first packages:%lld/%lld", length, videoSize);
            
            if (self.trasnferCancel && [self nothingToWrite:[videoWrittingTaskList allValues]] && self.tempPhotoCount == 0 && (self.hasVcardPermissionErr || vCardfile_size <= 0)) {
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.firstLayout) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) { // UI adaption for iPhones
            // Build selection list UI adaption
            CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
            if (screenHeight <= 480) { // IPhone 4 UI resolution.
                self.circularWidth.constant = 250.f;
                
                self.titleTopConstaints.constant /= 4.f;
                self.titleBottom.constant /= 2.f;
                
                self.headerTop.constant /= 4.f;
                
                self.cancelBottomConstaints.constant /= 2;
                self.processingTopConstaints.constant /= 2;
                self.downLoadBarTopConstaints.constant /= 2;
                self.circularTopConstaints.constant /= 2;
            }
            
            self.firstLayout = NO;
        } else {
            self.keepAppOpenLbl.textAlignment = NSTextAlignmentCenter;
        }
    }
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
//        PhotoStoreHelper *helper = [[PhotoStoreHelper alloc]
//                                    initWithOperationDelegate:self
//                                    andRootPath:videoFolderPath
//                                    andDataSets:self.videoSavingList, self.videoSavingList2,
//                                    nil];
//        helper.isCrossPlatform = !self.isAndriodPlatform;
//        
//        [helper startSavingVideos];
    });
}

- (IBAction)TransferCancelBtnClicked:(id)sender {
    
    NSMutableDictionary *paramDictionary = [[NSMutableDictionary alloc] init];
    
    [paramDictionary setObject:ANALYTICS_TrackAction_Param_Value_FlowInitiated_1 forKey:ANALYTICS_TrackAction_Key_CancelTransfer];
    [paramDictionary setObject:ANALYTICS_TrackAction_Value_CancelTransfer forKey:ANALYTICS_TrackAction_Key_LinkName];
    NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneProcessing, ANALYTICS_TrackAction_Value_CancelTransfer);
    [paramDictionary setObject:pageLink forKey:ANALYTICS_TrackAction_Key_PageLink];
    
    [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Value_CancelTransfer
                                 data:paramDictionary];
    
    CTMVMAlertAction *cancelAction =
    [CTMVMAlertAction actionWithTitle:@"No"
                              style:UIAlertActionStyleCancel
                            handler:nil];
    
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *okAction =
    [CTMVMAlertAction actionWithTitle:@"Yes"
                              style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action) {
                                
                                weakSelf.trasnferCancel = true;
                                
                                weakSelf.dataProgressView.hidden = YES;
                                weakSelf.asyncSocket.delegate = nil;
                                weakSelf.listenOnPort.delegate = nil;
                                
                                // Close the socket
                                [weakSelf.asyncSocket disconnect];
                                [weakSelf.listenOnPort disconnect];
                                
                                weakSelf.asyncSocket = nil;
                                weakSelf.listenOnPort = nil;
                                
                                [weakSelf.cancelBtn setEnabled:NO];
                                [weakSelf.cancelBtn setAlpha:0.4];
                                
                                [weakSelf dataTransferInterrupted:TRANSFER_CANCELLED];
                            }];
    
    [[CTMVMAlertHandler sharedAlertHandler]
     showAlertWithTitle:@"Content Transfer"
     message:@"Are you sure you want to cancel the transfer"
     cancelAction:cancelAction
     otherActions:@[ okAction ]
     isGreedy:NO];
}

- (void)receivedNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"ALLPHOTODOWNLOADCOMPLETED"]) {
        
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:@"ALLPHOTODOWNLOADCOMPLETED"
         object:nil];
        //        [[self navigationController] popToRootViewControllerAnimated:YES];
        //        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication
        //        sharedApplication] delegate];
        //        [appDelegate.window.rootViewController
        //        dismissViewControllerAnimated:NO completion:nil];
        
        [self performSegueWithIdentifier:@"ReceiverCompleted" sender:nil];
    }
}

- (void)requestfornextVideoChuck {
    
    NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_VPART_"];
    NSData *requestData = [[shareKey dataUsingEncoding:NSUTF8StringEncoding] appendCRLFData];
    
    [asyncSocket writeData:requestData withTimeout:-1.0 tag:100];
    //    [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:100];
}

- (void)blink {
    __weak typeof(self) weakSelf = self;
    self.processingDataLbl.alpha = 0;
    [UIView animateWithDuration:1.5
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionRepeat |
     UIViewAnimationOptionAutoreverse |
     UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         weakSelf.processingDataLbl.alpha = 1;
                     }
                     completion:nil];
}

- (void)storePhotoIntoTempDocumentFolder:(NSData *)photoData
                               photoInfo:(NSDictionary *)photoPath {
    tempPhotoCount++;
    
    NSString *tempPhotoPath = [photoPath valueForKey:@"Path"];
    
    
    NSString *fileName = @"";
    if (!self.isAndriodPlatform) {
        fileName = [NSString
                    stringWithFormat:@"%@/%@", photoFolderPath,
                    [tempPhotoPath
                     stringByReplacingOccurrencesOfString:@"/"
                     withString:@"_"]];
    } else {
        fileName = [NSString
                    stringWithFormat:@"%@/%@", photoFolderPath,
                    [tempPhotoPath lastPathComponent]];
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ // writing files into the disk in background
                       @autoreleasepool {
                           [photoData writeToFile:fileName atomically:NO];
                           
                           @synchronized(weakSelf) {
                               if (photoSavingArrayIndex == 0) {
                                   photoSavingArrayIndex++;
                                   
                                   if (!photoSavingList) {
                                       photoSavingList = [[NSMutableArray alloc] init];
                                   }
                                   [photoSavingList addObject:photoPath];
                               } else if (photoSavingArrayIndex == 1) {
                                   photoSavingArrayIndex++;
                                   
                                   if (!photoSavingList2) {
                                       photoSavingList2 = [[NSMutableArray alloc] init];
                                   }
                                   [photoSavingList2 addObject:photoPath];
                               } else if (photoSavingArrayIndex == 2) {
                                   photoSavingArrayIndex++;
                                   
                                   if (!photoSavingList3) {
                                       photoSavingList3 = [[NSMutableArray alloc] init];
                                   }
                                   [photoSavingList3 addObject:photoPath];
                               } else if (photoSavingArrayIndex == 3) {
                                   photoSavingArrayIndex++;
                                   
                                   if (!photoSavingList4) {
                                       photoSavingList4 = [[NSMutableArray alloc] init];
                                   }
                                   [photoSavingList4 addObject:photoPath];
                               } else if (photoSavingArrayIndex == 4) {
                                   photoSavingArrayIndex = 5;
                                   
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

                           
                           if ((self.trasnferCancel || self.processDone) && tempPhotoCount == (self.photoSavingList.count + self.photoSavingList2.count + self.photoSavingList3.count + self.photoSavingList4.count + self.photoSavingList5.count + self.photoSavingList6.count) && vCardfile_size <= 0 ) {
                               DebugLog(@"store photo in update");
                               [self storePhotoIntoGallery];
                           }
                       }
                   });
}

- (void)storePhotoIntoGallery {
    // If photo exists, saving photo first
    dispatch_once(&_once_photo, ^{
//        PhotoStoreHelper *helper = [[PhotoStoreHelper alloc]
//                                    initWithOperationDelegate:self
//                                    andRootPath:photoFolderPath
//                                    andDataSets:self.photoSavingList, self.photoSavingList2,
//                                    self.photoSavingList3, self.photoSavingList4,
//                                    self.photoSavingList5, self.photoSavingList6,
//                                    nil];
//        helper.isCrossPlatform = !self.isAndriodPlatform;
//        
//        [helper startSavingPhotos];
    });
}

- (NSString*)decodeStringTo64:(NSString*)fromString{
    
    DebugLog(@"string received %@",fromString);
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:fromString options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    DebugLog(@"string decoded %@",fromString);
    
    return decodedString;
}


- (NSString*)encodeStringTo64:(NSString*)fromString
{
    NSData *plainData = [fromString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String;
    if ([plainData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        base64String = [plainData base64EncodedStringWithOptions:kNilOptions];
    }
    
    return base64String;
}


#pragma Reading COMM port information 

- (void) readCommPortDeviceInformation:(NSData *)data {
    
    NSError *errorJson=nil;
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
    // read COMM port information
    DebugLog(@"read comm port information : %@",responseDict);
    if (responseDict && [responseDict objectForKey:USER_DEFAULTS_PAIRING_DEVICE_ID]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[responseDict objectForKey:USER_DEFAULTS_PAIRING_DEVICE_ID] forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
        [userDefaults setObject:[responseDict objectForKey:USER_DEFAULTS_PAIRING_OS_VERSION] forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
        [userDefaults setObject:[responseDict objectForKey:USER_DEFAULTS_PAIRING_MODEL] forKey:USER_DEFAULTS_PAIRING_MODEL];
        [userDefaults setObject:[responseDict objectForKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE] forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
        
        [userDefaults synchronize];
    }
  
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (self.getFreeDiskspace) {
        
        [dict setValue:[NSString stringWithFormat:@"Insufficient storage space%lld",self.getFreeDiskspace*1024*1024] forKey:USER_DEFAULTS_DB_PARING_DEVICE_INFO];
    } else {
        
        [dict setValue:[NSString stringWithFormat:@"Insufficient storage space00000"] forKey:USER_DEFAULTS_DB_PARING_DEVICE_INFO];
    }
    
    
    
    VZDeviceMarco *deviceMacro = [[VZDeviceMarco alloc] init];
    NSString *modelCode = [deviceMacro getDeviceModel];
    NSString *model = [deviceMacro.models objectForKey:modelCode];
    if (model.length == 0) {
        model = modelCode;
    }
    
    [dict setValue:model forKey:USER_DEFAULTS_PAIRING_MODEL];
    [dict setValue:[[UIDevice currentDevice] systemVersion] forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
    [dict setValue:@"iOS" forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
    [dict setValue:@"P2P" forKey:USER_DEFAULTS_PAIRING_TYPE];

    [dict setValue:self.uuid_string forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
    
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:dict
                                                          options:kNilOptions
                                                            error:&error];
    
    [asyncSocketCommPort writeData:requestData withTimeout: -1.0 tag:100];
    [asyncSocketCommPort writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:100];
    
    [asyncSocketCommPort readDataWithTimeout:-1 tag:100];

}




@end
