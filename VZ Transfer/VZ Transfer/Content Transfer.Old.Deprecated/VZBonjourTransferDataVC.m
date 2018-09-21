//
//  VZBonjourTransferDataVC.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 2/2/16.
//  Copyright © 2016 Testing. All rights reserved.
//


#import "VZBonjourTransferDataVC.h"
#import "CTMVMFonts.h"
#import "VZContentTrasnferConstant.h"
#import "NSData+CTHelper.h"
#import "NSMutableDictionary+CTMVMConvenience.h"
#import "VZLocalAnalysticsManager.h"

#import <Photos/Photos.h>

#import "VZCalenderEventsExport.h"
#import "NSString+CTContentTransferRootDocuments.h"

#define RGB(r, g, b) \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface VZBonjourTransferDataVC () <NSNetServiceDelegate, NSNetServiceBrowserDelegate, NSStreamDelegate, PhotoUpdateUIDelegate, CalendarUpdateUIDelegate>

@property (nonatomic, assign) BOOL processing;
@property (nonatomic, assign) BOOL serverRestarted;
@property (nonatomic, assign) BOOL senderStreamsOpened;
@property (nonatomic, assign) BOOL disableProcess;
@property (nonatomic, assign) BOOL cancelSent;
@property (nonatomic, assign) BOOL isQuit;
@property (nonatomic, assign) BOOL isForceQuit;

@property (nonatomic, assign) NSInteger prepareProcessFinishCount;

@property (nonatomic, strong) NSTimer *timeoutTimer;
@property (weak, nonatomic) IBOutlet UILabel *keepAliveLbl;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopConstaints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendingTitleTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circularTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keepTitleTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelBottomConstaints;
@property (weak, nonatomic) IBOutlet UILabel *cloudWarningLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cloudBottomConstaints;

@property (assign, nonatomic) BOOL hasContactPermissionErr;
@property (assign, nonatomic) BOOL hasAlbumPermissionErr;
@property (assign, nonatomic) BOOL hasCalendarPermissionErr;
@property (assign, nonatomic) BOOL hasReminderPermissionErr;

@property (assign,nonatomic) BOOL trasnferCancel;
@property(nonatomic,strong) NSTimer *bonjourConnectionTimeOut;
@property (assign,nonatomic) int bonjourReconnectionTimeOutTimer;

@property (nonatomic, strong) VZCalenderEventsExport *calenderExport;

// Calendar outlets
@property (weak, nonatomic) IBOutlet UIImageView *calendarIcon;
@property (weak, nonatomic) IBOutlet UILabel *calendarTitle;
@property (weak, nonatomic) IBOutlet UILabel *calendarPermissionLbl;
@property (weak, nonatomic) IBOutlet UILabel *numberOfCalendarLbl;
@property (weak, nonatomic) IBOutlet UIButton *calendarBtn;
@property (weak, nonatomic) IBOutlet UIButton *calendarBackBtn;
@property (nonatomic, assign) NSInteger numberOfCalendar;

// reminder
@property (weak, nonatomic) IBOutlet UIImageView *reminderIcon;
@property (weak, nonatomic) IBOutlet UILabel *reminderTitle;
@property (weak, nonatomic) IBOutlet UILabel *reminderPermissionLbl;
@property (weak, nonatomic) IBOutlet UILabel *numberOfReminders;
@property (weak, nonatomic) IBOutlet UIButton *reminderBtn;
@property (weak, nonatomic) IBOutlet UIButton *reminderBackBtn;
@property (nonatomic, assign) NSInteger numberOfReminder;
@property (nonatomic, assign) BOOL reminderSent;

@property (nonatomic, strong) AVURLAsset *currentVideoURL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vcardBtnTop;

@property (nonatomic, assign) NSInteger targetType;
@property (nonatomic, strong) NSMutableData *incompleteData;

@property (nonatomic, strong) UIView *backgroundView;

@property (assign, nonatomic) BOOL hasPhotoFetchErr;
@property (assign, nonatomic) BOOL hasVideoFetchErr;
@end

@implementation VZBonjourTransferDataVC
@synthesize incompleteData;
@synthesize numberOfContacts;
@synthesize transferBtn;
@synthesize numberOfPhotos;
@synthesize photolist;
@synthesize photoCount;
@synthesize videoCount;

@synthesize itemListView;
@synthesize sendingStatusView;
@synthesize transferStatusLbl;
@synthesize photoTransferCount;
@synthesize numberOfVideo;
@synthesize videoTransferCount;
@synthesize videofileize;
@synthesize offset;
@synthesize BUFFERSIZE;
@synthesize trasnferAnimationImgView;
@synthesize itemlist;
@synthesize overlayActivity;
@synthesize totalNoOfFilesTransfered;
@synthesize vcardBtn;
@synthesize photoBtn;
@synthesize videoBtn;
@synthesize dataTobeTransmitted;
@synthesize startIndex;
@synthesize videoALAssetRepresentation;
@synthesize videofirstPacket;
//@synthesize sentDataSize;
@synthesize isVideo;
@synthesize byteActuallyWrite;
@synthesize selectAllBtn;
@synthesize cancelBtn;
@synthesize processing;
@synthesize serverRestarted;
@synthesize timeoutTimer;
@synthesize app;

@synthesize prepareProcessFinishCount;
@synthesize countOfVideo;
@synthesize countOfPhotos;
@synthesize countOfContacts;

@synthesize backgroundView;

#define TIMEOUT_LIMIT 30
static int timeoutCountdown = 0;

- (void)viewDidLoad {
    
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneTransfer;
    self.analyticsData = @{ANALYTICS_TrackState_Key_Param_PageName:ANALYTICS_TrackState_Value_PageName_PhoneTransfer,
                           ANALYTICS_TrackAction_Key_FlowCompleted:ANALYTICS_TrackAction_Param_Value_FlowInitiated_1,
                           ANALYTICS_TrackAction_Param_Key_FlowName:ANALYTICS_TrackAction_Param_Value_FlowInitiated_PairingOfSenderAndReceiver,
                           ANALYTICS_TrackAction_Key_TransactionId:self.uuid_string,
                           ANALYTICS_TrackAction_Key_SenderReceiver:ANALYTICS_TrackAction_Value_SenderReceiver_Sender
                           };
    
    [super viewDidLoad];
    
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    if (screenHeight <= 568) { // IPhone 5 UI resolution.
        [self.sendingTitleTopConstaints setConstant:self.sendingTitleTopConstaints.constant-20];
        [self.circularTopConstaints setConstant:self.circularTopConstaints.constant-50];
        [self.cancelBottomConstaints setConstant:self.cancelBottomConstaints.constant-40];
        
        self.titleTopConstaints.constant /= 2;
        self.titleTopConstaints.constant += 10;
        self.vcardBtnTop.constant /= 2;
        self.cloudBottomConstaints.constant = 20;
        [self.viewTopConstaints setConstant:self.viewTopConstaints.constant - 50];
    } else {
        [self.circularTopConstaints setConstant:self.circularTopConstaints.constant-50];
        [self.viewTopConstaints setConstant:self.viewTopConstaints.constant - 20];
    }
    
    // Do any additional setup after loading the view.
    self.keepAliveLbl.font = [CTMVMFonts mvmBookFontOfSize:13];
    self.keepAliveLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    
    transferBtn.enabled = NO;
    
    self.navigationItem.title = @"Content Transfer";
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    itemListView.hidden = NO;
    sendingStatusView.hidden = YES;
    
    [self.selectionView bringSubviewToFront:self.vcardBackBtn];
    [self.vcardBackBtn setEnabled:YES];
    [self.selectionView bringSubviewToFront:self.photoBackBTN];
    [self.photoBackBTN setEnabled:YES];
    [self.selectionView bringSubviewToFront:self.videoBackBtn];
    [self.videoBackBtn setEnabled:YES];
    [self.selectionView bringSubviewToFront:self.calendarBackBtn];
    [self.calendarBackBtn setEnabled:YES];
    [self.selectionView bringSubviewToFront:self.reminderBackBtn];
    [self.reminderBackBtn setEnabled:YES];
    
    [CTMVMButtons primaryRedButton:self.cancelBtn constrainHeight:YES];
    [CTMVMButtons primaryRedButton:self.leftCancelBtn constrainHeight:YES];
    [CTMVMButtons primaryRedButton:self.transferBtn constrainHeight:YES];
    
    self.contactsLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
    self.contactsLbl.textColor = [CTMVMColor darkGrayColor];
    
#if STANDALONE
    
    self.transferWhtLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.transferWhtLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
    self.sendingLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.sendingLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
#else
    
    self.transferWhtLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.transferWhtLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
    self.sendingLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.sendingLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
#endif
    
    self.photosLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
    self.photosLbl.textColor = [CTMVMColor darkGrayColor];
    self.videosLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
    self.videosLbl.textColor = [CTMVMColor darkGrayColor];
    self.calendarTitle.font = [CTMVMFonts mvmBookFontOfSize:18];
    self.calendarTitle.textColor = [CTMVMColor darkGrayColor];
    self.reminderTitle.font = [CTMVMFonts mvmBookFontOfSize:18];
    self.reminderTitle.textColor = [CTMVMColor darkGrayColor];
    
    self.transferStatusLbl.font = [CTMVMFonts mvmBookFontOfSize:13];
    self.numberOfPhotos.font = [CTMVMFonts mvmBookFontOfSize:14];
    self.numberOfVideo.font = [CTMVMFonts mvmBookFontOfSize:14];
    self.numberOfContacts.font = [CTMVMFonts mvmBookFontOfSize:14];
    self.numberOfCalendarLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
    self.numberOfReminders.font = [CTMVMFonts mvmBookFontOfSize:14];
    
    self.numberOfPhotos.textColor = [CTMVMColor darkGrayColor];
    self.numberOfVideo.textColor =  [CTMVMColor darkGrayColor];
    self.numberOfContacts.textColor = [CTMVMColor darkGrayColor];
    self.numberOfCalendarLbl.textColor = [CTMVMColor darkGrayColor];
    self.numberOfReminders.textColor = [CTMVMColor darkGrayColor];
    
    self.selectAllLbl.font = [CTMVMFonts mvmBookFontOfSize:16];
    self.selectAllLbl.textColor= [CTMVMColor mvmPrimaryRedColor];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"VZBonjourTransferDataVC" withExtraInfo:@{} isEncryptedExtras:false];
    
    self.hasContactPermissionErr = NO;
    self.hasAlbumPermissionErr = NO;
    self.hasCalendarPermissionErr = NO;
    self.hasReminderPermissionErr = NO;
    
    self.trasnferCancel = NO;
    
    self.permissionVcardLbl.font = [CTMVMFonts mvmBookFontOfSize:9];
    [self.permissionVcardLbl setTextColor:[UIColor redColor]];
    self.permissionPhotoLbl.font = [CTMVMFonts mvmBookFontOfSize:9];
    [self.permissionPhotoLbl setTextColor:[UIColor redColor]];
    self.permissionVideoLbl.font = [CTMVMFonts mvmBookFontOfSize:9];
    [self.permissionVideoLbl setTextColor:[UIColor redColor]];
    self.calendarPermissionLbl.font = [CTMVMFonts mvmBookFontOfSize:9];
    [self.calendarPermissionLbl setTextColor:[UIColor redColor]];
    self.reminderPermissionLbl.font = [CTMVMFonts mvmBookFontOfSize:9];
    [self.reminderPermissionLbl setTextColor:[UIColor redColor]];
    self.cloudWarningLbl.font = [CTMVMFonts mvmBookFontOfSize:13];
    
    self.vcardIcon.image = [self.vcardIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.vcardIcon setTintColor:[UIColor colorWithRed:167/255.0 green:169/255.0 blue:172/255.0 alpha:1.0]];
    self.photoIcon.image = [self.photoIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.photoIcon setTintColor:[UIColor colorWithRed:167/255.0 green:169/255.0 blue:172/255.0 alpha:1.0]];
    self.videoIcon.image = [self.videoIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.videoIcon setTintColor:[UIColor colorWithRed:167/255.0 green:169/255.0 blue:172/255.0 alpha:1.0]];
    self.calendarIcon.image = [self.calendarIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.calendarIcon setTintColor:[UIColor colorWithRed:167/255.0 green:169/255.0 blue:172/255.0 alpha:1.0]];
    self.reminderIcon.image = [self.reminderIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.reminderIcon setTintColor:[UIColor colorWithRed:167/255.0 green:169/255.0 blue:172/255.0 alpha:1.0]];
    
    // Tranfser
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AppWillTerminateByUser:) name:CTApplicationWillTerminate object:nil];
    
    // Add layer for spinner
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [self.backgroundView setBackgroundColor:[UIColor lightGrayColor]];
    self.backgroundView.alpha = 0.4f;
    
    [self.view addSubview:self.backgroundView];
    
    overlayActivity.image = [ UIImage getImageFromBundleWithImageName:@"spinner-1.png" ];

    [self.view bringSubviewToFront:self.backgroundView];
    [self.view bringSubviewToFront:self.overlayActivity];
    
    [self.transferBtn setAlpha:0.4f];
    
    [self.view setUserInteractionEnabled:YES];
}

- (void)shouldUpdateCalendarNumber:(NSInteger)number
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.numberOfCalendarLbl.text = [NSString stringWithFormat:@"%ld", (long)number];
    });
}


- (void)AppWillTerminateByUser:(NSNotification *)notification
{
    if ([notification.name isEqualToString:CTApplicationWillTerminate]) {
        DebugLog(@"Terminate notification received test");
        [self sendForceQuitRequest];
    }
}

- (void)ReminderSelected {
    __weak typeof(self) weakSelf = self;
    VZRemindersExport *exportReminder = [[VZRemindersExport alloc] init];
    
    exportReminder.remindercallBackHandler = ^(int reminderCount) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.numberOfReminders.text = [NSString stringWithFormat:@"%d", reminderCount];
        });
    };
    
    [VZRemindersExport updateAuthorizationStatusToAccessEventStoreSuccess:^{
        [exportReminder fetchLocalReminderLists:^(int reminderCount) {
            if (reminderCount == 0) {
                weakSelf.reminderBtn.tag = 20;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.numberOfReminders.text = [NSString stringWithFormat:@"%lu", (unsigned long)reminderCount];
                
                if (++weakSelf.prepareProcessFinishCount == 5) {
                    [weakSelf stopSpinner];
                    
                    [self disableUnavailableItems];
                    if (weakSelf.hasContactPermissionErr || weakSelf.hasAlbumPermissionErr || weakSelf.hasCalendarPermissionErr) {
                        // show permission alert
                        [weakSelf showPermissionAlert];
                    }
                }
            });
        }];
        
    } failed:^(EKAuthorizationStatus status) {
        weakSelf.hasReminderPermissionErr = YES;
        weakSelf.reminderBtn.tag = 20;
        
        if (++weakSelf.prepareProcessFinishCount == 5) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf stopSpinner];
                // show permission alert
                [weakSelf showPermissionAlert];
            });
        }
    }];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    VZContactsExport *vcardexport = [[VZContactsExport alloc] init];
    photolist = [[VZPhotosExport alloc] init];
    self.calenderExport = [[VZCalenderEventsExport alloc] init];
    self.calenderExport.delegate = self;
    photolist.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    // fetch photos
    photolist.photocallBackHandler = ^(NSInteger photocount, NSInteger streamCount, NSInteger unavailableCount) {
        
//        DebugLog(@"Number of Photo found %ld", (long)photocount);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.numberOfPhotos setText:[NSString stringWithFormat:@"%ld",(long)photocount]];
            if (streamCount > 0 || unavailableCount > 0) {
                [weakSelf.permissionPhotoLbl setHidden:NO];
                [weakSelf.permissionPhotoLbl setText:[NSString stringWithFormat:@"%ld photos backed up to iCloud *", (long)streamCount + unavailableCount]];
                [weakSelf.cloudWarningLbl setHidden:NO];
            }
            
            if (photocount == 0) {
                weakSelf.photoBtn.tag = 20;
            }
            
            weakSelf.prepareProcessFinishCount++;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                // video
                [weakSelf.photolist createvideoLogfile];
            });
            
        });
    };
    photolist.fetchfailure = ^(NSString *errMsg, BOOL isPermissionErr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.numberOfPhotos setText:@"-"];
            
            weakSelf.prepareProcessFinishCount++;
            weakSelf.photoBtn.tag = 20;
            
            if (isPermissionErr) {
                weakSelf.hasAlbumPermissionErr = YES;
            } else {
                weakSelf.hasPhotoFetchErr = YES; // new for fetch error
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                // video
                [weakSelf.photolist createvideoLogfile];
            });
        });
    };
    
    photolist.videocallBackHandler = ^(NSInteger videocount, NSInteger streamCount, NSInteger unavailableCount) {
        
//        DebugLog(@"Number of Video found %ld", (long)videocount);
        
        [weakSelf performSelectorOnMainThread:@selector(updateVideoNumbers:) withObject:[NSString stringWithFormat:@"%ld",(long)videocount] waitUntilDone:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (streamCount > 0 || unavailableCount > 0) {
                [weakSelf.permissionVideoLbl setHidden:NO];
                [weakSelf.permissionVideoLbl setText:[NSString stringWithFormat:@"%ld videos backed up to iCloud *", (long)streamCount + unavailableCount]];
                [weakSelf.cloudWarningLbl setHidden:NO];
            }
        });
        
        if (videocount == 0) {
            weakSelf.videoBtn.tag = 20;
        }
        
        weakSelf.prepareProcessFinishCount++;
        
        assert(![NSThread isMainThread]);
        // calendar permission check
        [weakSelf.calenderExport checkAuthorizationStatusToAccessEventStoreSuccess:^{
            //                DebugLog(@"calender permission granted, should fetch the calendar enties");
            [weakSelf.calenderExport fetchLocalCalendarsWithSuccessHandler:^(NSInteger numberOfEvents) {
                
                //                    DebugLog(@"fetch success:%ld", (long)numberOfEvents);
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.numberOfCalendarLbl.text = [NSString stringWithFormat:@"%ld", (long)numberOfEvents];
                });
                ++weakSelf.prepareProcessFinishCount;
                
                if (numberOfEvents == 0) {
                    weakSelf.calendarBtn.tag = 20;
                }
                
                [weakSelf ReminderSelected];
                
            } andFailureHandler:^(NSError *err) {
                DebugLog(@"events failed:%@", err.localizedDescription);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.numberOfCalendarLbl.text = @"0";
                });
                
                weakSelf.calendarBtn.tag = 20;
                
                ++weakSelf.prepareProcessFinishCount;
                
                [weakSelf ReminderSelected];
            }];
        } andFailureHandler:^(EKAuthorizationStatus status) {
            weakSelf.hasCalendarPermissionErr = YES;
            //                DebugLog(@"calender permission denied");
            ++weakSelf.prepareProcessFinishCount;
            
            weakSelf.calendarBtn.tag = 20;
            
            [weakSelf ReminderSelected];
        }];
    };
    
    photolist.videofetchfailure = ^(NSString *errMsg, BOOL isPermissionErr) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf performSelectorOnMainThread:@selector(updateVideoNumbers:) withObject:@"-" waitUntilDone:YES];
        });
        
        if (isPermissionErr) {
            weakSelf.hasAlbumPermissionErr = YES;
        } else {
            weakSelf.hasVideoFetchErr = YES;
        }
        
        weakSelf.prepareProcessFinishCount++;
        weakSelf.videoBtn.tag = 20;
        
        // calendar permission check
        [weakSelf.calenderExport checkAuthorizationStatusToAccessEventStoreSuccess:^{
            //                DebugLog(@"calender permission granted, should fetch the calendar enties");
            [weakSelf.calenderExport fetchLocalCalendarsWithSuccessHandler:^(NSInteger numberOfEvents) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.numberOfCalendarLbl.text = [NSString stringWithFormat:@"%ld", (long)numberOfEvents];
                });
                ++weakSelf.prepareProcessFinishCount;
                
                if (numberOfEvents == 0) {
                    weakSelf.calendarBtn.tag = 20;
                }
                
                [weakSelf ReminderSelected];
            } andFailureHandler:^(NSError *err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.numberOfCalendarLbl.text = @"0";
                });
                ++weakSelf.prepareProcessFinishCount;
                
                weakSelf.calendarBtn.tag = 20;
                
                [weakSelf ReminderSelected];
            }];
        } andFailureHandler:^(EKAuthorizationStatus status) {
            weakSelf.hasCalendarPermissionErr = YES;
            ++weakSelf.prepareProcessFinishCount;
            
            weakSelf.calendarBtn.tag = 20;
            
            [weakSelf ReminderSelected];
        }];
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // contact
        [vcardexport exportContactsAsVcard:^(int result) {
            dispatch_async(dispatch_get_main_queue(), ^{ // main queue make sure title will be updated once the process done.
                [weakSelf.numberOfContacts setText:[NSString stringWithFormat:@"%d",result]];
                weakSelf.prepareProcessFinishCount ++;
                
                if (result == 0) {
                    vcardBtn.tag = 20;
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [weakSelf.photolist createphotoLogfile];
                });
            });
        } andFailure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{ // main queue make sure title will be updated once the process done.
                [weakSelf.numberOfContacts setText:@"0"];
                weakSelf.prepareProcessFinishCount ++;
                vcardBtn.tag = 20;
                
                weakSelf.hasContactPermissionErr = YES;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [weakSelf.photolist createphotoLogfile];
                });
            });
        }];
    });
    
    transfer_state = HAND_SHAKE;
    
    presentState = TRANSFER_ALL_FILE;
    nextState = TRANSFER_VCARD_FILE;
    
    photoCount = 0;
    videoCount = 0;
    photoTransferCount = 0;
    videoTransferCount = 0;
    
    itemListView.hidden = NO;
    sendingStatusView.hidden = YES;
    
    BUFFERSIZE = 1024 * 1;
    
    itemlist = [[NSMutableDictionary alloc] init];
    
    [itemlist setObject:@"false" forKey:@"contacts"];
    [itemlist setObject:@"false" forKey:@"photos"];
    [itemlist setObject:@"false" forKey:@"videos"];
    [itemlist setObject:@"false" forKey:@"calendar"];
    [itemlist setObject:@"false" forKey:@"reminder"];
    
    totalNoOfFilesTransfered = 0;
    
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",totalNoOfFilesTransfered] forKey:@"TOTALFILETRANSFERED"];
    
    // Bonjour service setup for current view
    [[BonjourManager sharedInstance] setServerDelegate:self];
    
    dataTobeTransmitted = [[NSData alloc] init];
    
    videofirstPacket = NO;
    
    isVideo = 0;
    
    self.disableProcess = NO;
}

- (void)updateVideoNumbers:(NSString *)number
{
    [self.numberOfVideo setText:number];
}

- (void)shouldUpdatePhotoNumber:(NSInteger)number {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.numberOfPhotos setText:[NSString stringWithFormat:@"%ld",(long)number]];
    });
}

- (void)shouldUpdateVideoNumber:(NSInteger)number {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.numberOfVideo setText:[NSString stringWithFormat:@"%ld",(long)number]];
    });
}

- (void)showPermissionAlert
{
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [weakSelf openSettings];
    }];
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:nil];
    
    NSString *message = @"";
    NSString *backMsg = @"";
    if (self.hasContactPermissionErr) {
        message = @"Unable to read contacts";
        backMsg = @"Please give permission for contacts";
    }
    
    if (self.hasAlbumPermissionErr) {
        if (message.length == 0) {
            message = @"Unable to read photos and videos";
        } else {
            message = [NSString stringWithFormat:@"%@, photos, videos", message];
        }
        
        if (backMsg.length == 0) {
            backMsg = @"Please give permission for photos and videos";
        } else {
            backMsg = [NSString stringWithFormat:@"%@, photos, videos", backMsg];
        }
    }
    
    if (self.hasCalendarPermissionErr) {
        if (message.length == 0) {
            message = @"Unable to read calendars";
        } else {
            message = [NSString stringWithFormat:@"%@, calendars", message];
        }
        
        if (backMsg.length == 0) {
            backMsg = @"Please give permission for calendars";
        } else {
            backMsg = [NSString stringWithFormat:@"%@, calendars", backMsg];
        }
    }
    
    if (self.hasReminderPermissionErr) {
        if (message.length == 0) {
            message = @"Unable to read reminders";
        } else {
            message = [NSString stringWithFormat:@"%@, reminders", message];
        }
        
        if (backMsg.length == 0) {
            backMsg = @"Please give permission for reminders";
        } else {
            backMsg = [NSString stringWithFormat:@"%@, reminders", backMsg];
        }
    }
    NSString *finalMessage = [NSString stringWithFormat:@"%@. %@.", message, backMsg];
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:finalMessage cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
}

- (void)disableUnavailableItems {
    
    if (self.hasAlbumPermissionErr && self.hasContactPermissionErr && self.hasCalendarPermissionErr && self.hasReminderPermissionErr) {
        [self.selectAllBtn setTintColor:[UIColor lightGrayColor]];
        [self.selectAllBtn setEnabled:NO];
        
        [self.selectionView bringSubviewToFront:self.selectallBackBtn];
        [self.selectallBackBtn setEnabled:YES];
    }
    
    if (self.hasContactPermissionErr) {
        [self.vcardBtn setTintColor:[UIColor lightGrayColor]];
        [self.vcardBtn setEnabled:NO];
        
        self.numberOfContacts.text = @"-";
        [self.numberOfContacts setTextColor:[UIColor lightGrayColor]];
        
        [self.contactsLbl setTextColor:[UIColor lightGrayColor]];
        
        self.vcardIcon.image = [self.vcardIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.vcardIcon setTintColor:[UIColor lightGrayColor]];
        
//        [self.selectionView bringSubviewToFront:self.vcardBackBtn];
//        [self.vcardBackBtn setEnabled:YES];
        
        [self.permissionVcardLbl setHidden:NO];
    }
    
    if (self.hasAlbumPermissionErr) {
        [self.photoBtn setTintColor:[UIColor lightGrayColor]];
        [self.photoBtn setEnabled:NO];
        
        self.numberOfPhotos.text = @"-";
        [self.numberOfPhotos setTextColor:[UIColor lightGrayColor]];
        
        [self.photosLbl setTextColor:[UIColor lightGrayColor]];
        
        self.photoIcon.image = [self.photoIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.photoIcon setTintColor:[UIColor lightGrayColor]];
        
//        [self.selectionView bringSubviewToFront:self.photoBackBTN];
//        [self.photoBackBTN setEnabled:YES];
        
        
        [self.videoBtn setTintColor:[UIColor lightGrayColor]];
        [self.videoBtn setEnabled:NO];
        
        self.numberOfVideo.text = @"-";
        [self.numberOfVideo setTextColor:[UIColor lightGrayColor]];
        
        [self.videosLbl setTextColor:[UIColor lightGrayColor]];
        
        self.videoIcon.image = [self.videoIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.videoIcon setTintColor:[UIColor lightGrayColor]];
        
//        [self.selectionView bringSubviewToFront:self.videoBackBtn];
//        [self.videoBackBtn setEnabled:YES];
        
        [self.permissionPhotoLbl setHidden:NO];
        [self.permissionVideoLbl setHidden:NO];
    }
    
    if (self.hasPhotoFetchErr) {
        [self.photoBtn setTintColor:[UIColor lightGrayColor]];
        [self.photoBtn setEnabled:NO];
        
        self.numberOfPhotos.text = @"-";
        [self.numberOfPhotos setTextColor:[UIColor lightGrayColor]];
        
        [self.photosLbl setTextColor:[UIColor lightGrayColor]];
        
        self.photoIcon.image = [self.photoIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.photoIcon setTintColor:[UIColor lightGrayColor]];
        
        [self.permissionPhotoLbl setHidden:NO];
        self.permissionPhotoLbl.text = @"Error when fetching photos";
    }
    
    if (self.hasPhotoFetchErr) {
        [self.photoBtn setTintColor:[UIColor lightGrayColor]];
        [self.photoBtn setEnabled:NO];
        
        self.numberOfPhotos.text = @"-";
        [self.numberOfPhotos setTextColor:[UIColor lightGrayColor]];
        
        [self.photosLbl setTextColor:[UIColor lightGrayColor]];
        
        self.photoIcon.image = [self.photoIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.photoIcon setTintColor:[UIColor lightGrayColor]];
        
        [self.permissionPhotoLbl setHidden:NO];
        self.permissionPhotoLbl.text = @"Error when fetching photos";
    }
    
    if (self.hasVideoFetchErr) {
        [self.videoBtn setTintColor:[UIColor lightGrayColor]];
        [self.videoBtn setEnabled:NO];
        
        self.numberOfVideo.text = @"-";
        [self.numberOfVideo setTextColor:[UIColor lightGrayColor]];
        
        [self.videosLbl setTextColor:[UIColor lightGrayColor]];
        
        self.videoIcon.image = [self.videoIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.videoIcon setTintColor:[UIColor lightGrayColor]];
        
        [self.permissionVideoLbl setHidden:NO];
        self.permissionVideoLbl.text = @"Error when fetching videos";
    }
    
    if (self.hasReminderPermissionErr) {
        [self.reminderBtn setTintColor:[UIColor lightGrayColor]];
        [self.reminderBtn setEnabled:NO];
        
        self.numberOfReminders.text = @"-";
        [self.numberOfReminders setTextColor:[UIColor lightGrayColor]];
        
        [self.reminderTitle setTextColor:[UIColor lightGrayColor]];
        
        self.reminderIcon.image = [self.reminderIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.reminderIcon setTintColor:[UIColor lightGrayColor]];
        
        [self.reminderPermissionLbl setHidden:NO];
    }
}

- (void)openSettings
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)stopSpinner {
    
    [self.view setUserInteractionEnabled:YES];
    
    transferBtn.enabled = YES;
    [self.transferBtn setAlpha:1.f];
    
    [self.backgroundView removeFromSuperview];
    
    overlayActivity.hidden = YES;
    [overlayActivity stopAnimating];
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"SenderTransferCompletedBonJour"]) {
        
        VZTransferFinishViewController *destination = segue.destinationViewController;
        destination.summaryDisplayFlag = 1;
        destination.processEnd = YES;
        destination.numberOfContacts = countOfContacts;
        destination.numberOfPhotos = countOfPhotos;
        destination.numberOfVideos = countOfVideo;
        destination.numberOfReminder = _numberOfReminder;
        destination.numberOfCalendar = _numberOfCalendar;
        destination.transferInterrupted = self.trasnferCancel;
        destination.analyticsTypeID = self.targetType;
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        destination.isSender = YES;
    }
}

- (IBAction)clickedOnTransferCancel:(id)sender {
    
    __weak typeof(self) weakSelf = self;
     CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
         if (sender == nil) {
             [weakSelf sendQuitRequest];
         } else {
             [weakSelf sendCancelRequest];
         }
         
         if (sender == nil) {
             
             [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
             
             if([[[[self navigationController]viewControllers]objectAtIndex:0] isKindOfClass:[CTNoInternetViewController class]]) {
                 [self.navigationController setNavigationBarHidden:YES animated:NO];
             }
             
             if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                 self.navigationController.interactivePopGestureRecognizer.enabled = YES;
             }
             
             
             NSString *screenName = @"VZBonjourTransferDataVC";

             NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
             
             [infoDict setObject:[screenName stringByAppendingString:@"_Application exited by user"] forKey:@"dataTransferStatusMsg"];
             [infoDict setObjectIfValid:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID defaultObject:@""];
             
             [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_EXITAPP withExtraInfo:infoDict isEncryptedExtras:false];
            
             [UIApplication sharedApplication].idleTimerDisabled = NO;

             AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
             [appDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
             //        [appDelegate.window makeKeyAndVisible];
             [appDelegate setViewControllerToPresentAlertsOnAutomatic];
             
//             [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
             
             [appDelegate displayStatusChanged];
             
         } else {
             
//             NSString *pageLink = pageLink(self.pageName, ANALYTICS_TrackAction_Name_Cancel_Transfer);
//             [weakSelf.sharedAnalytics trackAction:ANALYTICS_TrackAction_Name_Cancel_Transfer
//                                              data:@{ANALYTICS_TrackAction_Key_PageLink:pageLink,
//                                                     ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Name_Cancel_Transfer,
//                                                     @"vzwi.mvmapp.cancelTransfer":@"1"}];
             
             NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneTransfer, ANALYTICS_TrackAction__Param_Value_LinkName_CancelTransferBeforeBegin);
             [self.sharedAnalytics trackAction:ANALYTICS_TrackAction__Param_Value_LinkName_CancelTransferBeforeBegin
                                          data:@{ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction__Param_Value_LinkName_CancelTransferBeforeBegin,
                                                 ANALYTICS_TrackAction_Key_PageLink:pageLink
                                                 ,
                                                 ANALYTICS_TrackAction_Key_SenderReceiver:ANALYTICS_TrackAction_Value_SenderReceiver_Sender}];
             
             weakSelf.targetType = TRANSFER_CANCELLED;
             [weakSelf performSegueWithIdentifier:@"SenderTransferCompletedBonJour" sender:nil];
             
         }

     }];
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];

    if (sender == nil) {
         [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:@"Are you sure you want to quit? Data will not be saved." cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    } else {
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:@"Are you sure you want to cancel the transfer" cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    }
}

- (void)sendCancelRequest
{
    // Send cancel msg to recevier phone to stop heart beat msg
    self.isQuit = NO;
    NSString *msg = @"VZTRANSFER_CANCEL";
    
    NSData *message = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    [self sendRequest:message];
}

- (void)sendForceQuitRequest
{
    // Send cancel msg to recevier phone to stop heart beat msg
    self.isForceQuit = YES;
    NSString *msg = @"VZTRANSFER_FORCE_QUIT";
    
    NSData *message = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    [self sendRequest:message];
}

- (void)sendQuitRequest
{
    // Send cancel msg to recevier phone to stop heart beat msg
    self.isQuit = YES;
    NSString *msg = @"VZTRANSFER_QUIT";
   
    NSData *message = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [self sendRequest:message];
}

- (void)sendRequest:(NSData *)message
{
    // Get pointer to NSData bytes
    const uint8_t *bytes = (const uint8_t*)[message bytes];
    NSUInteger len = (NSUInteger)[message length];
    
    NSInteger bytesWritten;
    if ([[BonjourManager sharedInstance].outputStream hasSpaceAvailable]) {
        bytesWritten = [[BonjourManager sharedInstance].outputStream write:bytes maxLength:len];
        //             DebugLog(@"cancel sent from button");
        self.cancelSent = YES;
    }
    
    self.disableProcess = YES;
    if ([self.timeoutTimer isValid]) {
        [self.timeoutTimer invalidate];
        self.timeoutTimer = nil;
    }
    
    self.trasnferCancel = YES;
    
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",totalNoOfFilesTransfered] forKey:@"TOTALFILETRANSFERED"];
}

- (void)backButtonPressed {
    
    [self clickedOnTransferCancel:nil];
}

- (IBAction)clickedOnTransfer:(id)sender {
    
    NSArray *itemsValue = [self.itemlist allValues];
    
    if ([itemsValue containsObject:@"true"]) {
        
        transferBtn.enabled = NO;
        transferBtn.alpha = 0.4f;
        
        itemListView.hidden = YES;
        sendingStatusView.hidden = NO;
        
        [self startAnimationSenderImageView];
        
        processing = YES;
        
        [self transferSelecteditem:presentState receivedData:nil];
        
        //REVIEW: Is this right place ?
        self.analyticsData = nil;
        self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneProcessing;
        
    } else {
        
        [self displayAlter:@"Please select any items"];
    }
    
    [self captureAnalyticsPart];
    
}


- (void) transferSelecteditem:(enum state_machine)item receivedData:(NSString *)response {
    
    
    switch (item) {
        case HAND_SHAKE:
        {
            
        }
            break;
            
        case TRANSFER_ALL_FILE : {
            
            [self sendAllFileList];
        }
            break;
            
        case TRANSFER_VCARD_FILE:
        {
            if(![[[self numberOfContacts] text] isEqual:@"0"]) {
                totalNoOfFilesTransfered++;}
            [self sendContacts_Vcard];
        }
            break;
            
        case TRANSFER_PHOTO_FILE:
        {
            totalNoOfFilesTransfered++;
            NSArray *photoInfo = [self parsePhotoNameFromData:response forReconnect:NO];
            [self sendRequestedPhoto:photoInfo[0]];
        }
            break;
            
        case TRANSFER_VIDEO_FILE:
        {
            totalNoOfFilesTransfered++;
            
            isVideo = 1;
            NSArray *videoInfo = [self parseVideoFromData:response forReconnect:NO];
            [self sendRequestedVideo:videoInfo[0] withByte:videoInfo[1]];
        }
            break;
            
        case TRANSFER_PHOTO_RECONNECTED: {
            NSArray *photoInfo = [self parsePhotoNameFromData:response forReconnect:YES];
            totalNoOfFilesTransfered = [photoInfo[1] intValue];
            [self sendRequestedPhoto:photoInfo[0]];
        }
            break;
            
        case TRANSFER_VIDEO_RECONNECTED: {
            isVideo = 1;
            NSArray *videoInfo = [self parseVideoFromData:response forReconnect:YES];
            totalNoOfFilesTransfered = [videoInfo[2] intValue] + 1;
            
            [self sendRequestedVideo:videoInfo[0] withByte:videoInfo[1]];
        }
            break;
            
        case TRANSFER_VCARD_RECONNECTED: {
            if(![[[self numberOfContacts] text] isEqual:@"0"]) {
                totalNoOfFilesTransfered++;}
            [self sendContacts_Vcard];
        }
            break;
            
#warning TODO: CALENDAR RECONNECT NEEDED?
        case TRANSFER_CALENDAR_FILE_START:
        {
            ++ totalNoOfFilesTransfered;
            [self sendRequestCalendar:[self parseCalendarFromData:response needUpdateUI:YES]];
        }
            break;
            
        case TRANSFER_CALENDAR_FILE:
        {
            ++ totalNoOfFilesTransfered;
            [self sendRequestCalendar:[self parseCalendarFromData:response needUpdateUI:NO]];
        }
            break;
            
        case TRANSFER_CALENDAR_FILE_END:
        {
             ++ totalNoOfFilesTransfered;
            [self sendRequestCalendar:[self parseCalendarFromData:response needUpdateUI:NO]];
        }
            break;
            
        case TRANSFER_REMINDER_LOG_FILE: {
            
            ++ totalNoOfFilesTransfered;
            [self transferReminderLogFile];
        }
            
        default:
            break;
            
    }
}


- (void)transferReminderLogFile {
    
    [self.transferStatusLbl setText:@"Exporting Reminders"];
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    
    NSData *reminderdata = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/Reminder/ReminderLogoFile.txt",basePath]];
    
    NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERREMINDERLO"];
    
    
    NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%d",(int)reminderdata.length];
    
    //    DebugLog(@"file len %d", (int)tempstr.length);
    
    int gap = 10 - (int)tempstr.length;
    
    for (int i = 0; i < gap ; i++) {
        
        [tempstr insertString:@"0" atIndex:0];
    }
    
    [tempstr insertString:requestStr atIndex:0];
    
    NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    
    [finaldata appendData:requestData];
    
    [finaldata appendData:reminderdata];
    
    self.dataTobeTransmitted = finaldata;
    startIndex = 0;
    byteActuallyWrite = 0;
    
    _numberOfReminder += 1;
    _reminderSent = YES;
    
    [self sendPacket];
    
    DebugLog(@"sending reminders");
    
    [self.transferStatusLbl setText:@"Sending Reminder"];
    
//    [asyncSocket writeData:finaldata withTimeout:-1.0 tag:10];
    
    presentState = TRANSFER_REMINDER_LOG_FILE;
//    nextState = TRANSFER_PHOTO_FILE;
    
}


- (NSString *)parseCalendarFromData:(NSString *)response needUpdateUI:(BOOL)flag {
    
    if (flag) {
        [self performSelectorOnMainThread:@selector(updateTitleLabelInMainThread:) withObject:@"Sending Calendar" waitUntilDone:NO];
    }
    
    // Ignore VZCONTENTTRANSFER_START_REQUEST_FOR_CALENDAR_
    NSString *calInfo = [response substringWithRange:NSMakeRange(45, response.length - 45)];
    
    return calInfo;
}

- (NSArray *)parseVideoFromData:(NSString *)response forReconnect:(BOOL)isReconnect {
    if (!isReconnect) {
        // Skip VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_ number of characters
        
        [self.transferStatusLbl setText:[NSString stringWithFormat:@"%d Video(s) Sent ",++videoTransferCount]];
        
        NSString *imgname = [response substringWithRange:NSMakeRange(36, response.length - 36)];
//        NSString *imgname = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
        //        DebugLog(@"String from NSdata is %@",imgname);
        
        return [[NSArray alloc] initWithObjects:imgname, @"0", nil];
    } else {
        [self.transferStatusLbl setText:[NSString stringWithFormat:@"%d Video(s) Sent ",videoTransferCount]];
        
        NSString *VideoInfo = [response substringWithRange:NSMakeRange(40, response.length - 40)];
//        NSString *VideoInfo = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
        NSArray *conponents = [VideoInfo componentsSeparatedByString:@"/"];
        
        //        DebugLog(@"String from NSdata is %@ with %lld bytes and count %@",conponents[0], [conponents[1] longLongValue], conponents[2]);
        
        return conponents;
    }
}

- (NSArray *)parsePhotoNameFromData:(NSString *)response forReconnect:(BOOL)isReconnect {
    
    if (!isReconnect) {
        // Skip VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_ number of characters
        
        [self performSelectorOnMainThread:@selector(updateTitleLabelInMainThread:) withObject:[NSString stringWithFormat:@"%d Photo(s) Sent ",++photoTransferCount] waitUntilDone:NO];
        //    [self.transferStatusLbl setText:[NSString stringWithFormat:@"%d Photos Sent ",++photoTransferCount]];
        
//        NSData *tempdata = [data subdataWithRange:NSMakeRange(36, data.length - 36)];
        NSString *imgname = [response substringWithRange:NSMakeRange(36, response.length - 36)];
//        NSString *imgname = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
//        DebugLog(@"String from NSdata is %@",imgname);
        
        return [[NSArray alloc] initWithObjects:imgname, @"0", nil];
    } else {
        // Skip VZCONTENTTRANSFER_RECONNECTED_FOR_PHOTO_ number of characters
        
        [self performSelectorOnMainThread:@selector(updateTitleLabelInMainThread:) withObject:[NSString stringWithFormat:@"%d Photo(s) Sent ",photoTransferCount] waitUntilDone:NO];
        
//        NSData *tempdata = [data subdataWithRange:NSMakeRange(40, data.length - 40)];
        NSString *photoInfo = [response substringWithRange:NSMakeRange(40, response.length - 40)];
//        NSString *photoInfo = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
        NSArray *conponents = [photoInfo componentsSeparatedByString:@"/"];
        //        DebugLog(@"x4 %@",conponents[0]);
        
        return conponents;
    }
}

- (void)sendRequestCalendar:(NSString *)calName
{
    NSString *calURL = [self.calenderExport getEventURL:calName];

    NSData *data = [[NSFileManager defaultManager] contentsAtPath:calURL];
    
    NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERCALENDARSTART"];
    
    NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%d",(int)data.length];
    
    //    DebugLog(@"file len %d", (int)tempstr.length);
    
    int gap = 10 - (int)tempstr.length;
    
    for (int i = 0; i < gap ; i++) {
        
        [tempstr insertString:@"0" atIndex:0];
    }
    
    [tempstr insertString:requestStr atIndex:0];
    
    NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    
    [finaldata appendData:requestData];
    
    [finaldata appendData:data];
    
    startIndex = 0;
    
    self.dataTobeTransmitted = finaldata;
    
    self.numberOfCalendar += 1;

    [self sendPacket];
}

- (void)sendRequestedPhoto:(NSString *)imgname {
    
    __weak typeof(self) weakSelf = self;
    
//    NSString *imgnameTemp = [self decodeStringTo64:imgname];
    
    [photolist getPhotoData:imgname Sucess:^(id myasset) {
        PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.synchronous = YES;
        
        [[PHImageManager defaultManager] requestImageDataForAsset:myasset options:imageRequestOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            @autoreleasepool {
                long long totalPhotoSize = imageData.length;
                
                NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERPHOTOSTART"];
                NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%llu",totalPhotoSize];
                
                int gap = 10 - (int)tempstr.length;
                
                for (int i = 0; i < gap ; i++) {
                    [tempstr insertString:@"0" atIndex:0];
                }
                
                [tempstr insertString:requestStr atIndex:0];
                NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
                
                NSMutableData *finaldata = [[NSMutableData alloc] init];
                [finaldata appendData:requestData];
                [finaldata appendData:imageData];
                
                weakSelf.dataTobeTransmitted = finaldata;
                weakSelf.byteActuallyWrite = 0;
                weakSelf.startIndex = 0;
                
//                DebugLog(@"Total Byte Sent : %lu",(unsigned long)finaldata.length);
                [weakSelf sendPacket];
            }
        }];
    }];
    
    countOfPhotos++;
}

- (void)sendRequestedVideo:(NSString *)imgname withByte:(NSString *)bytesSent {
  
    __weak typeof(self) weakSelf = self;
    [photolist getVideoData:imgname Sucess:^(AVURLAsset *asset) {
        
        NSNumber *size;
        [asset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
        DebugLog(@"size is %lld",[size longLongValue]);
        
        weakSelf.videofileize = [size longLongValue];
        weakSelf.videofirstPacket = YES;
        weakSelf.byteActuallyWrite = 0;
        weakSelf.currentVideoURL = asset;
//        weakSelf.videoALAssetRepresentation = rep;
        
        [weakSelf sendVideoPacket];
    }];
    
}

#define BUFFER_SIZE 65536
- (void) sendVideoPacket {
    
    if (videofirstPacket) {
        
//        Byte *bufferInit = (Byte*)malloc(BUFFER_SIZE);
//        NSUInteger buffered = [videoALAssetRepresentation getBytes:bufferInit fromOffset:0 length:BUFFER_SIZE error:nil];
        
//        NSData *videoDatainit = [NSData dataWithBytesNoCopy:bufferInit length:buffered freeWhenDone:YES];
        
        NSData *videoDatainit = [NSData dataWithContentsOfFile:_currentVideoURL.URL atOffset:0 withSize:BUFFER_SIZE];
        
        NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERVIDEOSTART"];
        
        NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%llu",videofileize];
        
        // DebugLog(@" Video file len %d", (int)tempstr.length);
        
        int gap = 10 - (int)tempstr.length;
        
        for (int i = 0; i < gap ; i++) {
            
            [tempstr insertString:@"0" atIndex:0];
        }
        
        [tempstr insertString:requestStr atIndex:0];
        
        NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *finaldata = [[NSMutableData alloc] init];
        
        [finaldata appendData:requestData];
        [finaldata appendData:videoDatainit];
        
        uint8_t *bytes1 = ( uint8_t*)[finaldata bytes];
        NSInteger  bytesWritten;
        
        bytesWritten = [[BonjourManager sharedInstance].outputStream write:bytes1 maxLength:(NSUInteger)finaldata.length];
        byteActuallyWrite = bytesWritten - 37;
        if (bytesWritten < 0) {
            self.transferStatusLbl.text = [BonjourManager sharedInstance].outputStream.streamError.localizedDescription;
        }
        
        if ([timeoutTimer isValid]) {
//            [timeoutTimer invalidate];
            timeoutCountdown = 0;
        } else if (!serverRestarted) {
            timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeoutcountingHandler:) userInfo:nil repeats:YES]; // set the timeoout timer
        }
        
        DebugLog(@"%ld Video bytes sent\n\n",(long)bytesWritten);
        
        videofirstPacket = NO;
        
        //        DebugLog(@"Video data Sending : First Packet written Successfully");
        
        countOfVideo++;
        
    } else {
        
        NSData *videoData = [[NSData alloc] init];
        
        if ((byteActuallyWrite + BUFFER_SIZE) > videofileize) {
            
//            Byte *buffer = (Byte*)malloc(videofileize - byteActuallyWrite);
//            NSUInteger buffered = [videoALAssetRepresentation getBytes:buffer fromOffset:byteActuallyWrite  length:(videofileize - byteActuallyWrite) error:nil];
//            videoData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            
            videoData = [NSData dataWithContentsOfFile:_currentVideoURL.URL atOffset:byteActuallyWrite withSize:videofileize - byteActuallyWrite];
            
            uint8_t *bytes = (uint8_t*)[videoData bytes];
            NSInteger  bytesWritten;
            bytesWritten = [[BonjourManager sharedInstance].outputStream write:bytes maxLength:(NSUInteger)videoData.length];
            
            byteActuallyWrite += bytesWritten;
            
            if (bytesWritten < 0) {
                self.transferStatusLbl.text = [BonjourManager sharedInstance].outputStream.streamError.localizedDescription;
            }
            
            if ([timeoutTimer isValid]) {
//                [timeoutTimer invalidate];
                timeoutCountdown = 0;
            } else if (!serverRestarted) {
                timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeoutcountingHandler:) userInfo:nil repeats:YES]; // set the timeoout timer
            }
            
            if (byteActuallyWrite == videofileize) {
                isVideo = 2;
            }
            
//            DebugLog(@"Video data Sending :  %lld data written out of %lld", byteActuallyWrite, videofileize);
            
        } else {
            
//            Byte *buffer = (Byte*)malloc(BUFFER_SIZE);
//            NSUInteger buffered = [videoALAssetRepresentation getBytes:buffer fromOffset:byteActuallyWrite length:BUFFER_SIZE error:nil];
//            videoData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            
            videoData = [NSData dataWithContentsOfFile:_currentVideoURL.URL atOffset:byteActuallyWrite withSize:BUFFER_SIZE];
            
            uint8_t *bytes = ( uint8_t*)[videoData bytes];
            NSInteger  bytesWritten;
            bytesWritten = [[BonjourManager sharedInstance].outputStream write:bytes maxLength:(NSUInteger)videoData.length];
            
            byteActuallyWrite +=bytesWritten;
            
            if (bytesWritten < 0) {
                self.transferStatusLbl.text = [BonjourManager sharedInstance].outputStream.streamError.localizedDescription;
            }
            
            if ([timeoutTimer isValid]) {
//                [timeoutTimer invalidate];
                timeoutCountdown = 0;
            } else if (!serverRestarted) {
                timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeoutcountingHandler:) userInfo:nil repeats:YES]; // set the timeoout timer
            }
            
//            DebugLog(@"Video data Sending :  %lld data written out of %lld", byteActuallyWrite,videofileize);
            
        }
    }
}



- (enum state_machine) identifyRequest:(NSString *)response {
    
    if (response.length > 0) {
        
        if ( [response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_VCARD"].location != NSNotFound) {
            
            return TRANSFER_VCARD_FILE;
            
        } else if ( [response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_LOG_FILE"].location != NSNotFound) {
            
            return TRANSFER_PHOTO_LOG_FILE;
            
        } else if ( [response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_"].location != NSNotFound) {
            
            return TRANSFER_PHOTO_FILE;
            
        } else if ( [response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_LOG_FILE"].location != NSNotFound) {
            
            return TRANSFER_VIDEO_LOG_FILE;
            
        } else if ( [response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_"].location != NSNotFound) {
            
            return TRANSFER_VIDEO_FILE;
            
        } else if ( [response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_REMIN"].location != NSNotFound) {
            
            return TRANSFER_REMINDER_LOG_FILE;
            
        } else if ([response rangeOfString:@"VZCONTENTTRANSFER_FINISHED"].location != NSNotFound) {
            
            if ([timeoutTimer isValid]) {
                [timeoutTimer invalidate];
            }
            timeoutCountdown = 0;
            
            processing = NO;
            
            [self stopAnimationReceiverImageVIew];
            
            [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",totalNoOfFilesTransfered] forKey:@"TOTALFILETRANSFERED"];
            
            NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
            [infoDict setObjectIfValid:[NSString stringWithFormat:@"%d",countOfContacts] forKey:@"Contacts Transferred" defaultObject:@0];
            [infoDict setObjectIfValid:[NSString stringWithFormat:@"%d",countOfPhotos] forKey:@"Photos Transferred" defaultObject:@0];
            [infoDict setObjectIfValid:[NSString stringWithFormat:@"%d",countOfVideo] forKey:@"Videos Transferred" defaultObject:@0];
            [infoDict setObjectIfValid:[NSString stringWithFormat:@"%ld",(long)_numberOfCalendar] forKey:@"Calendar Transferred" defaultObject:@0];
            [infoDict setObjectIfValid:[NSString stringWithFormat:@"%ld",(long)_numberOfReminder] forKey:@"Reminder Transferred" defaultObject:@0];
            [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_ITEMS_BONJOUR_TRANSFERRED  withExtraInfo:infoDict isEncryptedExtras:false];
            
            self.targetType = TRANSFER_SUCCESS;
            
            [self performSegueWithIdentifier:@"SenderTransferCompletedBonJour" sender:nil];
            
            return TRANSFER_COMPLETED;
        } else if ([response rangeOfString:@"VZCONTENTTRANSFER_RECONNECTED_FOR_PHOTO_"].location != NSNotFound) {
            serverRestarted = NO;
            
            return TRANSFER_PHOTO_RECONNECTED;
        } else if ([response rangeOfString:@"VZCONTENTTRANSFER_RECONNECTED_FOR_VIDEO_"].location != NSNotFound && serverRestarted) {
            serverRestarted = NO;
            
            return TRANSFER_VIDEO_RECONNECTED;
        } else if ([response rangeOfString:@"VZCONTENTTRANSFER_RECONNECTED_FOR_VCARD"].location != NSNotFound) {
            serverRestarted = NO;
            
            return TRANSFER_VCARD_RECONNECTED;
        } else if ([response rangeOfString:@"VZCONTENTTRANSFER_START_REQUEST_FOR_CALENDAR_"].location != NSNotFound) {
            serverRestarted = NO;
            
            return TRANSFER_CALENDAR_FILE_START;
        } else if ([response rangeOfString:@"VZCONTENTTRANSFER_ORIGI_REQUEST_FOR_CALENDAR_"].location != NSNotFound) {
            serverRestarted = NO;
            
            return TRANSFER_CALENDAR_FILE;
        } else if ([response rangeOfString:@"VZCONTENTTRANSFER_FINAL_REQUEST_FOR_CALENDAR_"].location != NSNotFound) {
            serverRestarted = NO;
            
            return TRANSFER_CALENDAR_FILE_END;
        }
        
    }
    
    return HAND_SHAKE;
}



- (void)sendAllFileList {

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    
    NSData *fileList = nil;
    // Photos
    if ([[self.itemlist valueForKey:@"photos"] isEqualToString:@"true"]) {
        
        fileList = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/VZPhotoLogfile.txt",basePath]];
        if (fileList != nil) {
            NSError *err = nil;
            @try {
                NSArray *photofilelist = [NSJSONSerialization JSONObjectWithData:fileList options:0 error:&err];
                
                [dict setObjectIfValid:photofilelist forKey:@"photoFileList" defaultObject:@[]];
                
                long long photoTotalSize = 0;
                if (photofilelist.count > 0) {
                    photoTotalSize  = [[photofilelist valueForKeyPath:@"@sum.Size"] longLongValue];
                }
                
                NSMutableDictionary *photoStatus = [[NSMutableDictionary alloc] init];
                
                [photoStatus setValue:@"true" forKey:@"status"];
                [photoStatus setValue:[NSString stringWithFormat:@"%lld",photoTotalSize] forKey:@"totalSize"];
                [photoStatus setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[photofilelist count]] forKey:@"totalCount"];
                
                [self.itemlist setObjectIfValid:photoStatus forKey:@"photos" defaultObject:@[]];
            } @catch (NSException *exception) {
                DebugLog(@"Error:%@.\nNot transfer photos.", err.localizedDescription);
                
                NSMutableDictionary *photoStatus = [[NSMutableDictionary alloc] init];
                
                [photoStatus setValue:@"false" forKey:@"status"];
                [photoStatus setValue:[NSString stringWithFormat:@"0"] forKey:@"totalSize"];
                [photoStatus setValue:@"0" forKey:@"totalCount"];
                
                [self.itemlist setObjectIfValid:photoStatus forKey:@"photos" defaultObject:@[]];
                
                [dict setObject:[NSArray new] forKey:@"photoFileList"];
            }
        } else {
            
            NSMutableDictionary *photoStatus = [[NSMutableDictionary alloc] init];
            
            [photoStatus setValue:@"false" forKey:@"status"];
            [photoStatus setValue:[NSString stringWithFormat:@"0"] forKey:@"totalSize"];
            [photoStatus setValue:@"0" forKey:@"totalCount"];
            
            [self.itemlist setObjectIfValid:photoStatus forKey:@"photos" defaultObject:@[]];
            
            [dict setObject:[NSArray new] forKey:@"photoFileList"];
        }
    } else {
        
        NSMutableDictionary *photoStatus = [[NSMutableDictionary alloc] init];
        
        [photoStatus setValue:@"false" forKey:@"status"];
        [photoStatus setValue:[NSString stringWithFormat:@"0"] forKey:@"totalSize"];
        [photoStatus setValue:@"0" forKey:@"totalCount"];
        
        [self.itemlist setObjectIfValid:photoStatus forKey:@"photos" defaultObject:@[]];
        
        [dict setObject:[NSArray new] forKey:@"photoFileList"];
    }
    
    // Videos
    if ([[self.itemlist valueForKey:@"videos"] isEqualToString:@"true"]) {
        
        fileList = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/VZVideoLogfile.txt",basePath]];
        
        if (fileList != nil) {
            NSError *err = nil;
            @try {
                NSArray *videofilelist = [NSJSONSerialization JSONObjectWithData:fileList options:0 error:NULL];
                [dict setObjectIfValid:videofilelist forKey:@"videoFileList" defaultObject:@[]];
                
                long long videoTotalSize = 0;
                
                if (videofilelist.count > 0) {
                    
                    videoTotalSize  = [[videofilelist valueForKeyPath:@"@sum.Size"] longLongValue];
                }
                
                NSMutableDictionary *videoStatus = [[NSMutableDictionary alloc] init];
                
                [videoStatus setValue:@"true" forKey:@"status"];
                [videoStatus setValue:[NSString stringWithFormat:@"%lld",videoTotalSize] forKey:@"totalSize"];
                [videoStatus setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[videofilelist count]] forKey:@"totalCount"];
                
                [self.itemlist setObjectIfValid:videoStatus forKey:@"videos" defaultObject:@[]];
            } @catch (NSException *exception) {
                DebugLog(@"Error:%@.\nNot transfer videos.", err.localizedDescription);
                NSMutableDictionary *videoStatus = [[NSMutableDictionary alloc] init];
                
                [videoStatus setValue:@"false" forKey:@"status"];
                [videoStatus setValue:[NSString stringWithFormat:@"0"] forKey:@"totalSize"];
                [videoStatus setValue:@"0" forKey:@"totalCount"];
                
                [self.itemlist setObjectIfValid:videoStatus forKey:@"videos" defaultObject:@[]];
                
                [dict setObject:[NSArray new] forKey:@"videoFileList"];
            }
        } else {
            NSMutableDictionary *videoStatus = [[NSMutableDictionary alloc] init];
            
            [videoStatus setValue:@"false" forKey:@"status"];
            [videoStatus setValue:[NSString stringWithFormat:@"0"] forKey:@"totalSize"];
            [videoStatus setValue:@"0" forKey:@"totalCount"];
            
            [self.itemlist setObjectIfValid:videoStatus forKey:@"videos" defaultObject:@[]];
            
            [dict setObject:[NSArray new] forKey:@"videoFileList"];
        }
    } else {
        
        NSMutableDictionary *videoStatus = [[NSMutableDictionary alloc] init];
        
        [videoStatus setValue:@"false" forKey:@"status"];
        [videoStatus setValue:[NSString stringWithFormat:@"0"] forKey:@"totalSize"];
        [videoStatus setValue:@"0" forKey:@"totalCount"];
        
        [self.itemlist setObjectIfValid:videoStatus forKey:@"videos" defaultObject:@[]];
        
        [dict setObject:[NSArray new] forKey:@"videoFileList"];
    }
    
    // Contacts
    
    if ([[self.itemlist valueForKey:@"contacts"] isEqualToString:@"true"]) {
        
        NSMutableDictionary *contactStatus = [[NSMutableDictionary alloc] init];
        
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        
        [contactStatus setValue:@"true" forKey:@"status"];
        [contactStatus setValue:[userdefault valueForKey:@"CONTACTTOTALSIZE"] forKey:@"totalSize"];
        [contactStatus setValue:numberOfContacts.text forKey:@"totalCount"];
        
        [self.itemlist setObjectIfValid:contactStatus forKey:@"contacts" defaultObject:@[]];
        
    } else {
        
        NSMutableDictionary *contactsStatus = [[NSMutableDictionary alloc] init];
        [contactsStatus setValue:@"false" forKey:@"status"];
        [contactsStatus setValue:@"0" forKey:@"totalSize"];
        [contactsStatus setValue:@"0" forKey:@"totalCount"];
        
        [self.itemlist setObjectIfValid:contactsStatus forKey:@"contacts" defaultObject:@[]];
    }

    
    if ([[self.itemlist valueForKey:@"reminder"] isEqualToString:@"true"]) {
        
        NSMutableDictionary *reminderStatus = [[NSMutableDictionary alloc] init];
        
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        
        [reminderStatus setValue:@"true" forKey:@"status"];
        [reminderStatus setValue:[userdefault valueForKey:@"REMINDERLOGSIZE"] forKey:@"totalSize"];
        [reminderStatus setValue:@"1" forKey:@"totalCount"];

        [self.itemlist setObjectIfValid:reminderStatus forKey:@"reminder" defaultObject:@[]];
        
    }else {
        
        NSMutableDictionary *reminderStatus = [[NSMutableDictionary alloc] init];
        [reminderStatus setValue:@"false" forKey:@"status"];
        [reminderStatus setValue:@"0" forKey:@"totalSize"];
        [reminderStatus setValue:@"0" forKey:@"totalCount"];
        [self.itemlist setObjectIfValid:reminderStatus forKey:@"reminder" defaultObject:@[]];
        
    }
    
    // Calendar events
    if ([[self.itemlist valueForKey:@"calendar"] isEqualToString:@"true"]) {
        fileList = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/VZCalenderLogoFile.txt", basePath]];
        
        if (fileList != nil) {
            NSArray *calFilelist = [NSJSONSerialization JSONObjectWithData:fileList options:0 error:NULL];
            [dict setObjectIfValid:calFilelist forKey:@"calFileList" defaultObject:@[]];
            
            NSMutableDictionary *calenderStatus = [[NSMutableDictionary alloc] init];
            
            NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
            
            [calenderStatus setValue:@"true" forKey:@"status"];
            [calenderStatus setValue:[userdefault valueForKey:@"CALENDARTOTALSIZE"] forKey:@"totalSize"];
            if ([calFilelist count] > 0) {
                
                [calenderStatus setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[calFilelist count]] forKey:@"totalCount"];
            } else {
                
                [calenderStatus setValue:@"0" forKey:@"totalCount"];
            }
            
            [self.itemlist setObjectIfValid:calenderStatus forKey:@"calendar" defaultObject:@[]];
        } else {
            NSMutableDictionary *calenderStatus = [[NSMutableDictionary alloc] init];
            [calenderStatus setValue:@"false" forKey:@"status"];
            [calenderStatus setValue:@"0" forKey:@"totalSize"];
            [calenderStatus setValue:@"0" forKey:@"totalCount"];
            [self.itemlist setObjectIfValid:calenderStatus forKey:@"calendar" defaultObject:@[]];
        }
    } else {
        NSMutableDictionary *calenderStatus = [[NSMutableDictionary alloc] init];
        [calenderStatus setValue:@"false" forKey:@"status"];
        [calenderStatus setValue:@"0" forKey:@"totalSize"];
        [calenderStatus setValue:@"0" forKey:@"totalCount"];
        [self.itemlist setObjectIfValid:calenderStatus forKey:@"calendar" defaultObject:@[]];
    }
    
    [dict setObjectIfValid:self.itemlist forKey:@"itemList" defaultObject:@{}];
    
    NSError *err = nil;
    @try {
        NSData *fileListData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
        
        // Prepare file list data package
        NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERALLFLSTART"];
        NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%d",(int)fileListData.length];
        
        int gap = 10 - (int)tempstr.length;
        
        for (int i = 0; i < gap ; i++) {
            [tempstr insertString:@"0" atIndex:0];
        }
        
        [tempstr insertString:requestStr atIndex:0];
        
        NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *finaldata = [[NSMutableData alloc] init];
        
        [finaldata appendData:requestData];
        [finaldata appendData:fileListData];
        
        [self.transferStatusLbl setText:@"Sending File List"];
        
        dataTobeTransmitted = finaldata;
        startIndex = 0;
        byteActuallyWrite = 0;
        
        [self sendPacket];
        
        [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_TRANSFER_SCREEN_BONJOUR  withExtraInfo:self.itemlist isEncryptedExtras:false];
    } @catch (NSException *exception) {
        
        DebugLog(@"Json create failed:%@", err.debugDescription);
        self.targetType = TRANSFER_INTERRUPTED;
        dispatch_async(dispatch_get_main_queue(), ^{\
            // If error happened, should go to data transfer interrupted page
            [self sendCancelRequest];
            
            NSString *pageLink = pageLink(self.pageName, ANALYTICS_TrackAction_Name_Cancel_Transfer);
            [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Name_Cancel_Transfer
                                         data:@{ANALYTICS_TrackAction_Key_PageLink:pageLink,
                                                ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Name_Cancel_Transfer,
                                                @"vzwi.mvmapp.cancelTransfer":@"1"}];
            
            [self performSegueWithIdentifier:@"SenderTransferCompletedBonJour" sender:nil];
        });
    }
}


- (void)sendContacts_Vcard {
    
    
    [self.transferStatusLbl setText:@"Exporting Contacts"];
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    
    /*
     * We are assigning our filePath variable with our application's document path appended with our file's name.
     */
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/VZAllContactBackup.vcf",basePath]];
    
    //    NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //    DebugLog(@"%@",newStr);
    
    NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERVCARDSTART"];
    
    NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%d",(int)data.length];
    
    //    DebugLog(@"file len %d", (int)tempstr.length);
    
    int gap = 10 - (int)tempstr.length;
    
    for (int i = 0; i < gap ; i++) {
        
        [tempstr insertString:@"0" atIndex:0];
    }
    
    [tempstr insertString:requestStr atIndex:0];
    
    NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    
    [finaldata appendData:requestData];
    
    [finaldata appendData:data];
    
    [self.transferStatusLbl setText:@"Sending VCard"];
    
    //    [[BonjourManager sharedInstance] sendFileStream:finaldata];
    
    startIndex = 0;
    
    self.dataTobeTransmitted = finaldata;
    [self sendPacket];
    
    //    [asyncSocket writeData:finaldata withTimeout:-1.0 tag:10];
    //    [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:10];
    
    //    [asyncSocket readDataWithTimeout:-1.0 tag:0];
    
    self.countOfContacts = (int)numberOfContacts.text.integerValue;
}


- (void) startAnimationSenderImageView {
    
    //    self.trasnferAnimationImgView.animationImages = [NSArray arrayWithObjects:[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_01"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_02"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_03"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_04"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_05"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_06"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_07"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_08"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_09"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_10"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_11"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_12"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_13"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_14"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_15"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_16"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_17"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_18"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_18"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_20"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_21"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_22"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_23"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_24"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_25"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_26"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_27"],[ UIImage getImageFromBundleWithImageName:@"anim-right_alpha_1x_28"],nil];
    
    self.trasnferAnimationImgView.animationImages = [NSArray arrayWithObjects:
                                    [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_00" ]         ,[ UIImage getImageFromBundleWithImageName:@"anim_right_1x_01" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_02" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_03" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_04" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_05" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_06" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_07" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_08" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_08" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_10" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_11" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_12" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_13" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_14" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_15" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_16" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_17" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_18" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_19" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_20" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_21" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_22" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_23" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_24" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_25" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_26" ],
                                        [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_27" ],nil];
    
    // all frames will execute in 1.75 seconds
    self.trasnferAnimationImgView.animationDuration = 1.75;
    // repeat the animation forever
    self.trasnferAnimationImgView.animationRepeatCount = 0;
    // start animating
    [self.trasnferAnimationImgView startAnimating];
}


- (void) stopAnimationReceiverImageVIew {
    
    [self.trasnferAnimationImgView stopAnimating];
}


- (void) displayAlter:(NSString *)str {
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:str cancelAction:cancelAction otherActions:nil isGreedy:NO];
    
}



- (IBAction)ClickedSelectAll:(id)sender {
    
    if ([sender isSelected]) {
        [sender setSelected:NO];
        [[self selectAllLbl] setText:@"Select All"];
        
        vcardBtn.tag = 20;
        photoBtn.tag = 20;
        videoBtn.tag = 20;
        _calendarBtn.tag = 20;
        _reminderBtn.tag = 20;
        
    } else {
        [sender setSelected:YES];
        [[self selectAllLbl] setText:@"Deselect All"];
        
        if (numberOfContacts.text.integerValue > 0) vcardBtn.tag = 10;
        if (numberOfPhotos.text.integerValue > 0) photoBtn.tag = 10;
        if (numberOfVideo.text.integerValue > 0) videoBtn.tag = 10;
        if (_numberOfCalendarLbl.text.integerValue > 0) _calendarBtn.tag = 10;
        if (_numberOfReminders.text.integerValue > 0) _reminderBtn.tag = 10;
    }
    
    if (!self.hasContactPermissionErr) {
        [self vcardSelected:vcardBtn];
    }
    
    if (!self.hasAlbumPermissionErr) {
        [self photSelected:photoBtn];
        [self videoSelected:videoBtn];
    }
    
    if (!self.hasCalendarPermissionErr) {
        [self CalendarSelected:_calendarBtn];
    }
    
    if (!self.hasReminderPermissionErr) {
        [self reminderSelected:_reminderBtn];
    }
}

- (IBAction)vcardSelected:(id)sender {
    
    UIButton *tempbtn = (UIButton *)sender;
    
    if (numberOfContacts.text.integerValue > 0) {
        
        if (tempbtn.tag == 10) {
            
            [tempbtn setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_check" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"true" forKey:@"contacts"];
            
            self.vcardIcon.image = [self.vcardIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
            self.vcardIcon.tintColor = RGB(205, 4, 11);
            
            
            if (self.videoBtn.tag == 20 && self.photoBtn.tag == 20 && self.calendarBtn.tag == 20 && self.reminderBtn.tag == 20) {
                [selectAllBtn setSelected:YES];
                [[self selectAllLbl] setText:@"Deselect All"];}

            
            tempbtn.tag = 20;
            
        } else {
            
            [tempbtn setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_uncheck" ] forState:UIControlStateNormal];
            
            self.vcardIcon.tintColor = RGB(167,169,172);
            
            [itemlist setObject:@"false" forKey:@"contacts"];
            
            [selectAllBtn setSelected:NO];
            [[self selectAllLbl] setText:@"Select All"];
            
            tempbtn.tag = 10;
        }

    }
}

- (IBAction)photSelected:(id)sender {
    
    
    UIButton *tempbtn = (UIButton *)sender;
    
    if (numberOfPhotos.text.integerValue > 0) {
        
        if (tempbtn.tag == 10) {
            
            [tempbtn setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_check" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"true" forKey:@"photos"];
            
            self.photoIcon.tintColor = RGB(205, 4, 11);
            
            if (self.videoBtn.tag == 20 && self.vcardBtn.tag == 20 && self.calendarBtn.tag == 20 && self.reminderBtn.tag == 20) {
                [selectAllBtn setSelected:YES];
                [[self selectAllLbl] setText:@"Deselect All"];}
            
            tempbtn.tag = 20;
            
        } else {
            
            [tempbtn setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_uncheck" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"false" forKey:@"photos"];
            
            self.photoIcon.tintColor = RGB(167,169,172);
            
//            [selectAllBtn setImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_red_uncheck"] forState:UIControlStateNormal];
            
            [selectAllBtn setSelected:NO];
            [[self selectAllLbl] setText:@"Select All"];
            tempbtn.tag = 10;
        }

    }
    
}


- (void) captureAnalyticsPart {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:self.itemlist];
    
    [dict setValue:@"UNKNOWN" forKey:@"Music"];
    [dict setValue:@"UNKNOWN" forKey:@"CallLogs"];
    [dict setValue:@"UNKNOWN" forKey:@"Sms"];
    [dict setValue:@"Bonjour" forKey:@"ConnectionType"];
    [dict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"Onclicktransfer"  withExtraInfo:dict isEncryptedExtras:false];
    
}

- (IBAction)videoSelected:(id)sender {
    
    UIButton *tempbtn = (UIButton *)sender;
    
    if (numberOfVideo.text.integerValue > 0) {
        
        if (tempbtn.tag == 10) {
            
            [tempbtn setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_check" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"true" forKey:@"videos"];
            
            self.videoIcon.tintColor = RGB(205, 4, 11);
            
            if (self.photoBtn.tag == 20 && self.vcardBtn.tag == 20 && self.calendarBtn.tag == 20 && self.reminderBtn.tag == 20) {
                [selectAllBtn setSelected:YES];
                [[self selectAllLbl] setText:@"Deselect All"];}
            
            tempbtn.tag = 20;
            
        } else {
            
            [tempbtn setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_uncheck" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"false" forKey:@"videos"];
            
            self.videoIcon.tintColor = RGB(167,169,172);
            
//            [selectAllBtn setImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_red_uncheck"] forState:UIControlStateNormal];
            
            [selectAllBtn setSelected:NO];
            [[self selectAllLbl] setText:@"Select All"];
            tempbtn.tag = 10;
        }

    }
    
    
}

- (IBAction)reminderSelected:(id)sender {
    UIButton *tempbtn = (UIButton *)sender;
    
    if (_numberOfReminders.text.integerValue > 0) {
        
        if (tempbtn.tag == 10) {
            
            [tempbtn setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_check" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"true" forKey:@"reminder"];
            
            self.reminderIcon.tintColor = RGB(205, 4, 11);
            
            if (self.photoBtn.tag == 20 && self.vcardBtn.tag == 20 && self.videoBtn.tag == 20 && self.calendarBtn.tag == 20) {
                [selectAllBtn setSelected:YES];
                [[self selectAllLbl] setText:@"Deselect All"];}
            
            tempbtn.tag = 20;
            
        } else {
            
            [tempbtn setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_uncheck" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"false" forKey:@"reminder"];
            
            self.reminderIcon.tintColor = RGB(167,169,172);
            
            //            [selectAllBtn setImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_red_uncheck"] forState:UIControlStateNormal];
            
            [selectAllBtn setSelected:NO];
            [[self selectAllLbl] setText:@"Select All"];
            tempbtn.tag = 10;
        }
    }
}

- (IBAction)CalendarSelected:(id)sender {
    
    UIButton *tempbtn = (UIButton *)sender;
    
    if (_numberOfCalendarLbl.text.integerValue > 0) {
        
        if (tempbtn.tag == 10) {
            
            [tempbtn setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_check" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"true" forKey:@"calendar"];
            
            self.calendarIcon.tintColor = RGB(205, 4, 11);
            
            if (self.photoBtn.tag == 20 && self.vcardBtn.tag == 20 && self.videoBtn.tag == 20 && self.reminderBtn.tag == 20) {
                [selectAllBtn setSelected:YES];
                [[self selectAllLbl] setText:@"Deselect All"];}
            
            tempbtn.tag = 20;
            
        } else {
            
            [tempbtn setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_uncheck" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"false" forKey:@"calendar"];
            
            self.calendarIcon.tintColor = RGB(167,169,172);
            
            //            [selectAllBtn setImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_red_uncheck"] forState:UIControlStateNormal];
            
            [selectAllBtn setSelected:NO];
            [[self selectAllLbl] setText:@"Select All"];
            tempbtn.tag = 10;
        }
    }
}

- (IBAction)selectAllAskForPermission:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [weakSelf openSettings];
    }];
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:nil];
    
    NSString *message = @"Unable to read photos, videos, contacts and calendars. Please give permission for media, contacts and calendars.";
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
}

- (IBAction)vcardAskForPermission:(UIButton *)sender {
    
    if(self.hasContactPermissionErr) {
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [weakSelf openSettings];
    }];
    
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:nil];
    
    NSString *message = @"Unable to read contacts. Please give permission for contacts.";
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
        
    } else {
        
         [self vcardSelected:vcardBtn];
        
    }
}

- (IBAction)photoAskForPermission:(id)sender {
    if (self.hasAlbumPermissionErr)  {
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [weakSelf openSettings];
    }];
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:nil];
    
    NSString *message = @"Unable to read photos. Please give permission for photos.";
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    } else {
        [self photSelected:photoBtn];
    }
}

- (IBAction)calendarAskForPermission:(id)sender {
    if (self.hasCalendarPermissionErr)  {
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [weakSelf openSettings];
        }];
        
        
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:nil];
        
        NSString *message = @"Unable to read calendars. Please give permission for calendars.";
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    } else {
        [self CalendarSelected:_calendarBtn];
    }
}

- (IBAction)reminderAskForPermission:(id)sender {
    if (self.hasReminderPermissionErr)  {
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [weakSelf openSettings];
        }];
        
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:nil];
        
        NSString *message = @"Unable to read reminders. Please give permission for reminders.";
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    } else {
        [self reminderSelected:_reminderBtn];
    }
}

- (IBAction)videoAskForPermission:(UIButton *)sender {
    
    if (self.hasAlbumPermissionErr)  {
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [weakSelf openSettings];
    }];
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:nil];
    
    NSString *message = @"Unable to read videos. Please give permission for videos.";
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    } else {
        [self videoSelected:videoBtn];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[BonjourManager sharedInstance] stopServer]; // stop server, so other device won't find this device
    [[BonjourManager sharedInstance] closeStreamForController:self];
}

#pragma mark - NSStreamDelegate

bool shouldStop = false;
int closeSenderCount = 0;

// Stream connection event
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) { // streams opened
        case NSStreamEventOpenCompleted: {
            [BonjourManager sharedInstance].streamOpenCount += 1;
            //            DebugLog(@"--->connected:%lu",(unsigned long)[BonjourManager sharedInstance].streamOpenCount);
            assert([BonjourManager sharedInstance].streamOpenCount <= 2);
            if ([BonjourManager sharedInstance].streamOpenCount == 2) {
                //                DebugLog(@"Close server");
                [[BonjourManager sharedInstance] stopServer];
                [BonjourManager sharedInstance].isServerStarted = NO;
                
                self.transferStatusLbl.text = @"Connection Opened";
                
                self.senderStreamsOpened = YES;
            }
            break;
        }
            
        case NSStreamEventHasSpaceAvailable: { // stream has space
            assert(stream == [BonjourManager sharedInstance].outputStream);
            
            if (self.disableProcess) { // process should be stopped
                if(self.cancelSent) { // cancel request already sent
                    break;
                }
                
                // send cancel request
                NSString *msg = nil;
                if (self.isQuit) {
                    msg = @"VZTRANSFER_QUIT";
                } else if (self.isForceQuit) {
                    msg = @"VZTRANSFER_FORCE_QUIT";
                } else {
                    msg = @"VZTRANSFER_CANCEL";
                }
                NSData *message = [msg dataUsingEncoding:NSUTF8StringEncoding];
                // Get pointer to NSData bytes
                const uint8_t *bytes = (const uint8_t*)[message bytes];
                NSUInteger len = (NSUInteger)[message length];
                
                NSInteger bytesWritten;
                bytesWritten = [(NSOutputStream *)stream write:bytes maxLength:len];
                if (bytesWritten) {
                    //                    DebugLog(@"cancel sent");
                    self.cancelSent = YES;
                }
                break;
            } else if (serverRestarted) { // server resstarting...
                DebugLog(@"transferring before received request, disgard it...");
                break;
            }
            
            switch (isVideo) {
                    
                case 0:
                {
                    if (dataTobeTransmitted.length != byteActuallyWrite) {
                        
                        [self sendPacket];
                    }
                }
                    
                    break;
                    
                case 1: {
                    
                    if (byteActuallyWrite != videofileize) {
                        
                        [self sendVideoPacket];
                        
                        //                        DebugLog(@"Video Data sending : Yes space avaialbe to write data");
                    } else {
                        
                        //                        DebugLog(@"Video Data sending : No Space Avaialbe to writw data");
                    }
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        case NSStreamEventHasBytesAvailable: {
            
            if (self.disableProcess) { // process stopped, disgard all the data read from stream after.
                break;
            }
            
            NSUInteger bsize = 1024;
            uint8_t buf[bsize];
            NSInteger bytesRead = 0;
            bytesRead = [[BonjourManager sharedInstance].inputStream read:buf maxLength:bsize];
            if (bytesRead <= 0) {
                // handle EOF and error in NSStreamEventEndEncountered and NSStreamEventErrorOccurred cases
            } else {
                // received remote data
//                DebugLog(@"Bonjour received data: %ld bytes\n\n",(long)bytesRead);
                
                NSData *data = [NSData dataWithBytes:buf length:bytesRead];
                if (incompleteData.length > 0) {
                    [incompleteData appendData:data];
                    data = incompleteData;
                    incompleteData = nil;
                }
                
                NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
//                NSRange range = [response rangeOfString:@"VZTRANSFER_KEEP_ALIVE_HEARTBEAT"];
                if ([response isEqualToString:@"VZTRANSFER_KEEP_ALIVE_HEARTBEAT"]) { // receiver cancel connection
//                    DebugLog(@"received keep alive heartbeat, hope it will work.");
                    break;
                }
                
//                range = [response rangeOfString:@"VZTRANSFER_CANCEL"];
                if ([response isEqualToString:@"VZTRANSFER_CANCEL"]) { // receiver cancel connection
                    
                    //                        DebugLog(@"received cancel");
                    self.disableProcess = YES;
                    self.cancelSent = YES;
                    self.trasnferCancel = YES;
                    
                    if ([timeoutTimer isValid]) { // disable the timer
                        [timeoutTimer invalidate];
                        timeoutTimer = nil;
                    }
                    timeoutCountdown = 0;
                    
                    // By Prakash to fix 1930754
                    //                    [self performSegueWithIdentifier:@"goHome" sender:nil];
                    
//                    [[self navigationController] popToRootViewControllerAnimated:YES];
                    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",totalNoOfFilesTransfered] forKey:@"TOTALFILETRANSFERED"];
                    
                    self.targetType = TRANSFER_CANCELLED;
                    [self performSegueWithIdentifier:@"SenderTransferCompletedBonJour" sender:nil];
                    
                    break;
                }
                
                if ([response isEqualToString:@"VZTRANSFER_QUIT"]) { // receiver cancel connection
                    
                    self.disableProcess = YES;
                    self.cancelSent = YES;
                    self.trasnferCancel = YES;
                    
                    if ([timeoutTimer isValid]) { // disable the timer
                        [timeoutTimer invalidate];
                        timeoutTimer = nil;
                    }
                    timeoutCountdown = 0;
                    
                    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",totalNoOfFilesTransfered] forKey:@"TOTALFILETRANSFERED"];
                    
                    [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
                    
                    if([[[[self navigationController]viewControllers]objectAtIndex:0] isKindOfClass:[CTNoInternetViewController class]]) {
                        [self.navigationController setNavigationBarHidden:YES animated:NO];
                    }
                    
                    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
                    }
                    
                    NSString *screenName = @"VZBonjourTransferDataVC";
                    
                    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
                    
                    [infoDict setObject:[screenName stringByAppendingString:@"_Application exited by user"] forKey:@"dataTransferStatusMsg"];
                    [infoDict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
                    
                    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_EXITAPP withExtraInfo:infoDict isEncryptedExtras:false];
                    
                    [UIApplication sharedApplication].idleTimerDisabled = NO;
                    
                    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    [appDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                    //        [appDelegate.window makeKeyAndVisible];
                    [appDelegate setViewControllerToPresentAlertsOnAutomatic];
                    
//                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                    
                    [appDelegate displayStatusChanged];
                    
                    break;
                }
                
                nextState = [self identifyRequest:response];
                
                switch (nextState) {
                        
                    case TRANSFER_VCARD_FILE : {
                        [self transferSelecteditem:TRANSFER_VCARD_FILE receivedData:response];
                    }
                        break;
                        
                    case TRANSFER_PHOTO_FILE : {
                        [self transferSelecteditem:TRANSFER_PHOTO_FILE receivedData:response];
                    }
                        break;
                        
                    case TRANSFER_VIDEO_FILE : {
                        [self transferSelecteditem:TRANSFER_VIDEO_FILE receivedData:response];
                    }
                        break;
                        
                    case TRANSFER_PHOTO_RECONNECTED: { // if received image reconnect request from receiver
                        [self transferSelecteditem:TRANSFER_PHOTO_RECONNECTED receivedData:response]; // reconnect for photo
                    }
                        break;
                        
                    case TRANSFER_VIDEO_RECONNECTED: { // if received video reconnect request from receiver
                        [self transferSelecteditem:TRANSFER_VIDEO_RECONNECTED receivedData:response]; // reconnect for photo
                    }
                        break;
                        
                    case TRANSFER_VCARD_RECONNECTED: { // if received video reconnect request from receiver
                        [self transferSelecteditem:TRANSFER_VCARD_RECONNECTED receivedData:response]; // reconnect for photo
                    }
                        break;
                        
                    case TRANSFER_CALENDAR_FILE_START: {
                        [self transferSelecteditem:TRANSFER_CALENDAR_FILE_START receivedData:response]; // reconnect for photo
                    }
                        break;
                        
                    case TRANSFER_CALENDAR_FILE: {
                        [self transferSelecteditem:TRANSFER_CALENDAR_FILE receivedData:response]; // reconnect for photo
                    }
                        break;
                        
                    case TRANSFER_CALENDAR_FILE_END: {
                        [self transferSelecteditem:TRANSFER_CALENDAR_FILE_END receivedData:response]; // reconnect for photo
                    }
                        break;
                        
                    case TRANSFER_REMINDER_LOG_FILE: {
                        [self transferSelecteditem:TRANSFER_REMINDER_LOG_FILE receivedData:response];
                    }
                        break;
                        
                    default: {
                        incompleteData = [data mutableCopy];
                    }
                        break;
                }
                
            }
            
            break;
        }
            // all others cases
        case NSStreamEventEndEncountered: {
            if ([timeoutTimer isValid]) {
                [timeoutTimer invalidate];
            }
            timeoutCountdown = 0;
            self.senderStreamsOpened = NO;
            
            //            DebugLog(@"connection ends");
            self.transferStatusLbl.text = @"Connection Ends";
            
            self.disableProcess = YES;
            
            [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",totalNoOfFilesTransfered] forKey:@"TOTALFILETRANSFERED"];
            // Saving
            self.targetType = TRANSFER_INTERRUPTED;
            [self performSegueWithIdentifier:@"SenderTransferCompletedBonJour" sender:nil];
        }
            break;
        case NSStreamEventNone:
            break;
        case NSStreamEventErrorOccurred: {
            
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [BonjourManager sharedInstance].streamOpenCount --;
            if ([stream isEqual:[BonjourManager sharedInstance].inputStream]) {
                [BonjourManager sharedInstance].inputStream = nil;
            } else {
                [BonjourManager sharedInstance].outputStream = nil;
            }
            
            if (++closeSenderCount == 2) {
                closeSenderCount = 0;
                if (processing) {
                    tryTimes = 0;
                    [self searchForOriginService];
                }
            } else {
                self.transferStatusLbl.text = @"Connection Error";
                
                if ([timeoutTimer isValid]) {
                    [timeoutTimer invalidate];
                    timeoutTimer = nil;
                }
                timeoutCountdown = 0;
                self.senderStreamsOpened = NO;
            }
        }
            break;
        default:
            break;
    }
}

- (void)searchForOriginService
{
    tryTimes ++;
    if (!self.serverRestarted) {
        self.serverRestarted = [[BonjourManager sharedInstance] createReconnectServerForController:self];
    }
}


- (void)sendPacket {
    if (dataTobeTransmitted.length == 0) {
        DebugLog(@"Why received 0 length package?");
        return;
    }
    
    NSUInteger bufferSize = 0;
    
    BOOL flag = NO;
    if(startIndex + BONJOUR_BUFFERSIZE > dataTobeTransmitted.length) {
        bufferSize = dataTobeTransmitted.length - startIndex;

        DebugLog(@"%d photo last package is sent and total data transmitted is %lu of %lu", photoTransferCount, startIndex+bufferSize, (unsigned long)dataTobeTransmitted.length);
        
        flag = YES;
    } else {
        bufferSize = BONJOUR_BUFFERSIZE;
//        DebugLog(@"data transfered %d out of %lu", startIndex+BONJOUR_BUFFERSIZE, (unsigned long)dataTobeTransmitted.length);
    }
    
    NSData *packet = [dataTobeTransmitted subdataWithRange:NSMakeRange((NSUInteger)startIndex, (NSUInteger)bufferSize)];
    
    uint8_t *bytes1 = ( uint8_t*)[packet bytes];
    NSInteger bytesWritten = [[BonjourManager sharedInstance].outputStream write:bytes1 maxLength:(NSUInteger)bufferSize];
    
    if ([timeoutTimer isValid]) {
        timeoutCountdown = 0;
    } else if (!serverRestarted) {
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeoutcountingHandler:) userInfo:nil repeats:YES]; // set the timeoout timer
    }
    
    byteActuallyWrite += bytesWritten;
    
    startIndex += bytesWritten;
    
    if (flag) {
        if (byteActuallyWrite == (int)dataTobeTransmitted.length ) {
//            DebugLog(@"Total byte actually written :%lld bytes of %lu bytes", byteActuallyWrite, (unsigned long)dataTobeTransmitted.length);
            byteActuallyWrite = 0;
            startIndex = 0;
            dataTobeTransmitted = [[NSData alloc] init];
        } else {
            flag = NO;
        }
    }
}

- (void)timeoutcountingHandler:(NSTimer *)timer
{
    if (self.disableProcess) {
        [timer invalidate];
        timer = nil;
    }
    
    timeoutCountdown ++;
    //    DebugLog(@"%d",++timeoutCountdown);
    //    self.transferStatusLbl.text = [NSString stringWithFormat:@"%d", timeoutCountdown];
    if (timeoutCountdown == TIMEOUT_LIMIT) { // 15sec for timeout
        [[BonjourManager sharedInstance].outputStream close];
        [[BonjourManager sharedInstance].inputStream close];
        [[BonjourManager sharedInstance].outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [[BonjourManager sharedInstance].inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [BonjourManager sharedInstance].outputStream = nil;
        [BonjourManager sharedInstance].inputStream = nil;
        [[BonjourManager sharedInstance] setStreamOpenCount:0];
        
        [[BonjourManager sharedInstance] stopServer];
        
        [timeoutTimer invalidate]; // disable the timer
        timeoutCountdown = 0;
        
        if (processing) {
            [self searchForOriginService];
        }
    } else if (timeoutCountdown == 15) {
        self.transferStatusLbl.text = @"Connection Timeout";
    }
    
}

#pragma mark - NSNetServiceDelegate
bool waitingServiceShouldStop = false;
- (void)netServiceDidPublish:(NSNetService *)sender
{
    self.transferStatusLbl.text = @"Reconnect...";
    waitingServiceShouldStop = false;
    // Start the device browser
    if ([[BonjourManager sharedInstance] isBrowserValid]) {
        [[BonjourManager sharedInstance] stopBrowserNetworking:self];
    }
    [[BonjourManager sharedInstance] startBrowserNetworkingForTarget:self];
    
    @try {
        self.bonjourConnectionTimeOut = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(runloopForBonjourReconnet:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.bonjourConnectionTimeOut forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    } @catch (NSException *exception) {
        [self performSelectorOnMainThread:@selector(showDialogOnMainThread) withObject:nil waitUntilDone:NO];
    }
}

- (void)runloopForBonjourReconnet:(NSTimer *)timer {
    
    if (waitingServiceShouldStop) {
    
        [self.bonjourConnectionTimeOut invalidate];
        self.bonjourConnectionTimeOut = nil;
        
    } else {self.bonjourReconnectionTimeOutTimer++;
        
        if (self.bonjourReconnectionTimeOutTimer > 20) {
            
            [self performSelectorOnMainThread:@selector(showDialogOnMainThread) withObject:nil waitUntilDone:NO];
            
            [self.bonjourConnectionTimeOut invalidate];
            self.bonjourConnectionTimeOut = nil;
        }
    }
}

#pragma mark - NSNetServiceBrowserDelegate Methods
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    //    DebugLog(@"%@", service.name);
    //    DebugLog(@"target server name:%@", [[BonjourManager sharedInstance] targetServer].name);
    
    NSString *targetServerName = [BonjourManager sharedInstance].targetServer.name;
    NSString *target = @"";
    if ([[targetServerName substringFromIndex:targetServerName.length-3] isEqualToString:@"/RC"]) {
        target = targetServerName;
    } else {
        target = [NSString stringWithFormat:@"%@/RC",[BonjourManager sharedInstance].targetServer.name];
    }
    if ([target isEqualToString:service.name]) { // service name is unique
        waitingServiceShouldStop = true;
        [[BonjourManager sharedInstance] stopBrowserNetworking:self];
        self.transferStatusLbl.text = @"Device Found";
        [BonjourManager sharedInstance].targetServer = service;
        [self createConnectionForService:[BonjourManager sharedInstance].targetServer];
    } // ignore other services
}

#define WAIT_FOR_STREAMS_LIMIT 20
#define STREAM_OPEN_TRY_TIMES 3
#define RECONNECT_DELAY_TIME 10
int streamWaitingCountdown = 0;
int delayCountDown = 0;
int tryTimes = 0;

- (void)createConnectionForService:(NSNetService *)service
{
    BOOL success = NO;
    NSInputStream *inStream = nil;
    NSOutputStream *outStream = nil;
    
    self.transferStatusLbl.text = service.name;
    
    // device was chosen by user in picker view
    success = [service getInputStream:&inStream outputStream:&outStream];
    if (!success) {
        [self createConnectionFailDialogWithTitle:@"Content Transfer" andContent:@"It seems like your last connection fails, please restart it again."];
    } else {
        
        self.transferStatusLbl.text = @"Connection Opening...";
        // user tapped device: so create and open streams with that devices
        assert([BonjourManager sharedInstance].inputStream == nil);
        assert([BonjourManager sharedInstance].outputStream == nil);
        assert([NSThread isMainThread]);
        
        [BonjourManager sharedInstance].inputStream  = inStream;
        [BonjourManager sharedInstance].outputStream = outStream;
        
        // open input
        [[BonjourManager sharedInstance].inputStream  setDelegate:self];
        // open output
        [[BonjourManager sharedInstance].outputStream setDelegate:self];
        
        [NSThread detachNewThreadSelector:@selector(newThreadHandler:) toTarget:self withObject:nil];
    }
}

- (void)newThreadHandler:(NSThread *)thread
{
    // streams must exist but aren't open
    assert([BonjourManager sharedInstance].inputStream != nil);
    assert([BonjourManager sharedInstance].outputStream != nil);
    assert([BonjourManager sharedInstance].streamOpenCount == 0);
    
    streamWaitingCountdown = 0;
    NSTimer *runloopController = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(runloopLive:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:runloopController forMode:NSDefaultRunLoopMode];
    
    [[NSRunLoop currentRunLoop] run];
}

- (void)runloopLive:(NSTimer *)timer {
    //    DebugLog(@"running...");
    if (streamWaitingCountdown<=WAIT_FOR_STREAMS_LIMIT) {
        streamWaitingCountdown++;
    } else {
        delayCountDown ++;
        if (delayCountDown <= RECONNECT_DELAY_TIME) {
            [self performSelectorOnMainThread:@selector(updateTitleLabelInMainThread:) withObject:[NSString stringWithFormat:@"Try reconnect in %d sec", RECONNECT_DELAY_TIME-delayCountDown+1] waitUntilDone:NO];
        } else {
            delayCountDown = 0;
            [self performSelectorOnMainThread:@selector(restartProcessOnMainThread) withObject:nil waitUntilDone:NO];
            
            [timer invalidate];
            timer = nil;
            [NSThread exit];
        }
        
        return;
    }
    if (!self.senderStreamsOpened) {
        if (streamWaitingCountdown > WAIT_FOR_STREAMS_LIMIT) { // above 1 min, show the popup
            [[BonjourManager sharedInstance].outputStream close];
            [[BonjourManager sharedInstance].inputStream close];
            [[BonjourManager sharedInstance].outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [[BonjourManager sharedInstance].inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [BonjourManager sharedInstance].outputStream = nil;
            [BonjourManager sharedInstance].inputStream = nil;
            
            [[BonjourManager sharedInstance] stopServer];
            
            serverRestarted = NO;
            if (tryTimes == STREAM_OPEN_TRY_TIMES) {
                [self performSelectorOnMainThread:@selector(showDialogOnMainThread) withObject:nil waitUntilDone:NO];
                
                [timer invalidate];
                timer = nil;
                
                [NSThread exit];
            }
        }
        [self performSelectorOnMainThread:@selector(openStreamsInMainThread) withObject:nil waitUntilDone:NO];
    } else {
        [timer invalidate];
        timer = nil;
        
        [NSThread exit];
    }
}

- (void)openStreamsInMainThread
{
    [[BonjourManager sharedInstance].inputStream close];
    [[BonjourManager sharedInstance].outputStream close];
    [[BonjourManager sharedInstance].inputStream  removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[BonjourManager sharedInstance].outputStream  removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[BonjourManager sharedInstance].inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[BonjourManager sharedInstance].outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[BonjourManager sharedInstance].inputStream open];
    [[BonjourManager sharedInstance].outputStream open];
}

- (void)restartProcessOnMainThread
{
    [self searchForOriginService];
}

- (void)updateTitleLabelInMainThread:(NSString *)title
{
    self.transferStatusLbl.text = title;
}

- (void)showDialogOnMainThread
{
    [self createConnectionFailDialogWithTitle:@"Content Transfer" andContent:@"It seems like your last connection fails, please restart it again."];
}

- (void)createConnectionFailDialogWithTitle:(NSString *)title andContent:(NSString *)content
{
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        weakSelf.targetType = CONNECTION_FAILED;
        [weakSelf performSegueWithIdentifier:@"SenderTransferCompletedBonJour" sender:nil];
    }];
    
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:title message:content cancelAction:cancelAction otherActions:nil isGreedy:NO];
    
}

//bool reminderChanged = false;
//bool calendarChanged = false;
//bool vcardChanged = false;
//bool photoChanged = false;
//bool videoChanged = false;
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    if (!reminderChanged && CGRectContainsPoint(self.reminderBtn.bounds, [touches.anyObject locationInView:self.reminderBtn])) {
//        DebugLog(@"reminder selected");
//        reminderChanged = true;
//        [self reminderSelected:_reminderBtn];
//    } else if (!CGRectContainsPoint(self.reminderBtn.bounds, [touches.anyObject locationInView:self.reminderBtn])){
//        reminderChanged = false;
//    }
//    
//    if (!calendarChanged && CGRectContainsPoint(self.calendarBtn.bounds, [touches.anyObject locationInView:self.calendarBtn])) {
//        DebugLog(@"reminder selected");
//        calendarChanged = true;
//        [self CalendarSelected:_calendarBtn];
//    } else if (!CGRectContainsPoint(self.calendarBtn.bounds, [touches.anyObject locationInView:self.calendarBtn])){
//        calendarChanged = false;
//    }
//    
//    if (!vcardChanged && CGRectContainsPoint(self.vcardBtn.bounds, [touches.anyObject locationInView:self.vcardBtn])) {
//        DebugLog(@"reminder selected");
//        vcardChanged = true;
//        [self vcardSelected:vcardBtn];
//    } else if (!CGRectContainsPoint(self.vcardBtn.bounds, [touches.anyObject locationInView:self.vcardBtn])){
//        vcardChanged = false;
//    }
//    
//    if (!photoChanged && CGRectContainsPoint(self.photoBtn.bounds, [touches.anyObject locationInView:self.photoBtn])) {
//        DebugLog(@"reminder selected");
//        photoChanged = true;
//        [self photSelected:photoBtn];
//    } else if (!CGRectContainsPoint(self.photoBtn.bounds, [touches.anyObject locationInView:self.photoBtn])){
//        photoChanged = false;
//    }
//    
//    if (!videoChanged && CGRectContainsPoint(self.videoBtn.bounds, [touches.anyObject locationInView:self.videoBtn])) {
//        DebugLog(@"reminder selected");
//        videoChanged = true;
//        [self videoSelected:videoBtn];
//    } else if (!CGRectContainsPoint(self.videoBtn.bounds, [touches.anyObject locationInView:self.videoBtn])){
//        videoChanged = false;
//    }
//}

- (NSString*)decodeStringTo64:(NSString*)fromString{
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:fromString options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    return decodedString;
}

@end
