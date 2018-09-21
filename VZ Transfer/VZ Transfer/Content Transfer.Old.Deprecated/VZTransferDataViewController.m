//
//  VZTransferViewController.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/30/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "VZTransferDataViewController.h"
#import "VZTransferFinishViewController.h"
#import "VZDeviceMarco.h"
#import "CTMVMFonts.h"
#import "CTMVMColor.h"
#import "VZContentTrasnferConstant.h"
#import "VZRemindersExport.h"
#import "VZCircularView.h"

#import "NSData+CTHelper.h"
#import "NSMutableDictionary+CTMVMConvenience.h"
#import "NSString+CTMVMConvenience.h"
#import "NSString+CTContentTransferRootDocuments.h"

#ifdef __IPHONE_8_0
#import <Photos/Photos.h>
#endif

#define RGB(r, g, b) \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface VZTransferDataViewController () <PhotoUpdateUIDelegate, CalendarUpdateUIDelegate> {
    NSMutableString *mediaTypePiped;
}
@property (nonatomic, assign) BOOL viewDisappear;

@property (nonatomic, assign) NSInteger prepareProcessFinishCount;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectalldistance;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendingTitleTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendingCircularTopConstaints;
@property (weak, nonatomic) IBOutlet UILabel *keepAppOpenLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keepAppLblTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelBtnDownConstraints;

@property (assign, nonatomic) BOOL processDone;

@property (assign, nonatomic) BOOL hasContactPermissionErr;
@property (assign, nonatomic) BOOL hasAlbumPermissionErr;

@property (assign, nonatomic) NSInteger packageSize;

@property (assign, nonatomic) NSString *modelStr;

@property (weak, nonatomic) IBOutlet UIButton *vcardBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *vcardBackBtnCrossplatform;
@property (weak, nonatomic) IBOutlet UIButton *photoBackBTN;
@property (weak, nonatomic) IBOutlet UIButton *photoBackBtnCross;
@property (weak, nonatomic) IBOutlet UIButton *videoBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoBackCrossBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectallBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectAllBackBtnCrossPlatform;
@property (weak, nonatomic) IBOutlet UIView *selectionView;
@property (weak, nonatomic) IBOutlet UILabel *permissionVcardCrossplatformLbl;
@property (weak, nonatomic) IBOutlet UILabel *permissionVcardLbl;
@property (weak, nonatomic) IBOutlet UILabel *permissionPhotoLbl;
@property (weak, nonatomic) IBOutlet UILabel *permissionPhotoCrossLbl;
@property (weak, nonatomic) IBOutlet UILabel *permissionVideoLbl;
@property (weak, nonatomic) IBOutlet UILabel *permissionVideoCrossLbl;

@property (weak, nonatomic) IBOutlet UIImageView *vcardIcon;

@property (weak, nonatomic) IBOutlet UIImageView *vcardIconCrossplatform;
@property (weak, nonatomic) IBOutlet UIImageView *photoIcon;
@property (weak, nonatomic) IBOutlet UIImageView *photoIconCrossPlatform;
@property (weak, nonatomic) IBOutlet UIImageView *videoIcon;
@property (weak, nonatomic) IBOutlet UIImageView *videoIconCross;
@property (assign, nonatomic) BOOL transfercanceled;
@property (weak, nonatomic) IBOutlet UILabel *cloudWarningLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *warningTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectionTitleTopConstaints;
@property (weak, nonatomic) IBOutlet UILabel *localPhotoTitleLbl;
@property (weak, nonatomic) IBOutlet UILabel *cloudPhotoTitleLbl;
@property (weak, nonatomic) IBOutlet UILabel *localVideoTitleLbl;
@property (weak, nonatomic) IBOutlet UILabel *cloudVideoTitleLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *crossViewTopConstraints;
@property (nonatomic, strong) VZContactsExport *vcardexport;
@property (assign, nonatomic) BOOL keyreceived;

// Calendar properties
@property (nonatomic, strong) VZCalenderEventsExport *calenderExport;

@property (assign, nonatomic) BOOL hasCalendarPermissionErr;

// Calendar outlets
@property (weak, nonatomic) IBOutlet UIImageView *calendarIcon;
@property (weak, nonatomic) IBOutlet UILabel *calendarTitle;
@property (weak, nonatomic) IBOutlet UILabel *calendarPermissionLbl;
@property (weak, nonatomic) IBOutlet UILabel *numberOfCalendarLbl;
@property (weak, nonatomic) IBOutlet UIButton *calendarBtn;
@property (weak, nonatomic) IBOutlet UIButton *calendarBackBtn;

// reminder outlets
@property (weak, nonatomic) IBOutlet UIImageView *reminderIcon;
@property (weak, nonatomic) IBOutlet UILabel *reminderTitle;
@property (weak, nonatomic) IBOutlet UILabel *reminderPermissionLbl;
@property (weak, nonatomic) IBOutlet UILabel *numberOfReminderLbl;
@property (weak, nonatomic) IBOutlet UIButton *reminderBtn;
@property (weak, nonatomic) IBOutlet UIButton *reminderBackBtn;

// Reminder properties
@property (nonatomic, strong) VZRemindersExport *exportReminder;

@property (assign, nonatomic) BOOL hasReminderPermissionErr;

@property (nonatomic, assign) NSInteger numberOfCalendar;
@property (nonatomic, assign) NSInteger numberOfReminder;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelBottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cloudLblBottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectAllTopConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listbodydistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listBodyDisX;

@property (strong, nonatomic) AVURLAsset *currentVideoAsset;
@property (assign, nonatomic) long long currentVideoSize;
@property (weak, nonatomic) IBOutlet VZCircularView *circularView;

@property (assign, nonatomic) BOOL firstLayout;
@property (assign, nonatomic) NSInteger targetType;

@property (strong, nonatomic) NSMutableData *incompleteData;
@property (assign, nonatomic) BOOL reachPackageLimit;

@property (weak, nonatomic) IBOutlet UIImageView *calIconX;
@property (weak, nonatomic) IBOutlet UILabel *calTitleX;
@property (weak, nonatomic) IBOutlet UILabel *permissionErrCalX;
@property (weak, nonatomic) IBOutlet UIButton *calBtnX;
@property (weak, nonatomic) IBOutlet UILabel *numberOfCalX;
@property (weak, nonatomic) IBOutlet UIButton *calBackBtnX;

@property (strong, nonatomic) UIView *backgroundView;

@property (assign, nonatomic) BOOL hasPhotoFetchErr;
@property (assign, nonatomic) BOOL hasVideoFetchErr;
@end

@implementation VZTransferDataViewController
@synthesize reachPackageLimit;
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
@synthesize isMemoryWarningReceived;
@synthesize selectAllBtn;
@synthesize cancelBtn;
@synthesize leftCancelBtn;
@synthesize currentALAseetRep;
@synthesize sentVideoDataSize;
@synthesize videoFormatInfoLbl;
@synthesize viewDisappear;
@synthesize prepareProcessFinishCount;
@synthesize countOfContacts;
@synthesize countOfPhotos;
@synthesize countOfVideo;

@synthesize packageSize;
@synthesize app;
@synthesize asyncSocket;
@synthesize listenOnPort;
@synthesize asyncSocketCOMMPort;
@synthesize listenOnPortCOMMPort;

@synthesize backgroundView;

#define UNCHECKED 20
#define CHECKED 10

#define VZTagGeneral 0
#define VZTagAllFileList 1
#define VZTagVcardFiles 2
#define VZTagPhotoFiles 3
#define VZTagVideoFiles 4
#define VZTagCalendars 5
#define VZTagReminders 6

- (void)viewDidLoad {
    
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneTransfer;
    self.analyticsData = @{ANALYTICS_TrackState_Key_Param_PageName:ANALYTICS_TrackState_Value_PageName_PhoneTransfer,
                           ANALYTICS_TrackAction_Key_FlowCompleted:ANALYTICS_TrackAction_Param_Value_FlowInitiated_1,
                           ANALYTICS_TrackAction_Param_Key_FlowName:ANALYTICS_TrackAction_Param_Value_FlowInitiated_PairingOfSenderAndReceiver,
                           ANALYTICS_TrackAction_Key_TransactionId:self.uuid_string,
                           ANALYTICS_TrackAction_Key_SenderReceiver:ANALYTICS_TrackAction_Value_SenderReceiver_Sender
                           };
    
    [super viewDidLoad];
    
    self.firstLayout = YES;
    
    // Build selection list UI adaption
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    if ([VZDeviceMarco isiPhone4AndBelow]) {
        packageSize = 50; // set for each of the package size for video receiving
        self.modelStr = @"4";
    } else if ([VZDeviceMarco isiPhone5Serial]) {
        packageSize = 100;
        self.modelStr = @"5";
    } else if ([VZDeviceMarco isiPhone6AndAbove]) {
        packageSize = 150;
        self.modelStr = @"6";
    }
    
    [self.selectionView bringSubviewToFront:self.photoBackBTN];
    [self.photoBackBTN setEnabled:YES];
    
    [self.selectionView bringSubviewToFront:self.vcardBackBtn];
    [self.vcardBackBtn setEnabled:YES];
    [self.selectionView bringSubviewToFront:self.videoBackBtn];
    [self.videoBackBtn setEnabled:YES];
    [self.selectionView bringSubviewToFront:self.calendarBackBtn];
    [self.calendarBackBtn setEnabled:YES];
    [self.selectionView bringSubviewToFront:self.reminderBackBtn];
    [self.reminderBackBtn setEnabled:YES];
    
    // Do any additional setup after loading the view.
    
    self.keepAppOpenLbl.font = [CTMVMFonts mvmBookFontOfSize:13];
    self.keepAppOpenLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    
    self.trasnferAnimationImgView.image = [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_08" ];
    
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"VZTransferDataViewController" withExtraInfo:@{} isEncryptedExtras:false];
    
    transferBtn.enabled = NO;
    
    self.navigationItem.title = @"Content Transfer";
    
//    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.view setUserInteractionEnabled:NO];
    
    listenOnPort.delegate = self;
    asyncSocket.delegate = self;
    
    listenOnPortCOMMPort = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    uint16_t port = REGULAR_PORT;
    
    if (![listenOnPort acceptOnPort:port error:&error]) {
        DebugLog(@"Yes i am able to listen on this port");
    } else {
        DebugLog(@"No i am not able to listen on this port");
    }
    
    if (![listenOnPortCOMMPort acceptOnPort:COMM_PORT_NUMBER error:&error]) {
        DebugLog(@"Yes i am able to listen on this port");
    } else {
        DebugLog(@"No i am not able to listen on this port");
    }
    
    // to export contacts
    __weak typeof(self) weakSelf = self;
    self.vcardexport = [[VZContactsExport alloc] init];
    photolist = [[VZPhotosExport alloc] init];
    self.calenderExport = [[VZCalenderEventsExport alloc] init];
    self.calenderExport.delegate = self;
    self.exportReminder = [[VZRemindersExport alloc] init];
    
    photolist.delegate = self;
    
    // photo collect hander
    photolist.photocallBackHandler = ^(NSInteger photocount, NSInteger streamCount, NSInteger unavailableCount) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) { // crossplatform
                
                [weakSelf.crossPlatformListView bringSubviewToFront:weakSelf.photoBackBtnCross];
                [weakSelf.photoBackBtnCross setEnabled:YES];
                [weakSelf.crossPlatformListView bringSubviewToFront:weakSelf.cloudPhotoBackBtnCross];
                [weakSelf.cloudPhotoBackBtnCross setEnabled:YES];

                [weakSelf.numberOfLocalPhotos setText:[NSString stringWithFormat:@"%ld",(long)photocount]];
                if (photocount == 0) {
                    weakSelf.localPhotoBtn.tag = CHECKED;
                }
                
                if (streamCount > 0) {
                    [weakSelf.numberOfCloudPhotos setText:[NSString stringWithFormat:@"%ld",(long)streamCount]];
                } else {
                    weakSelf.cloudPhotoBtn.tag = CHECKED;
                }
            } else { // iOS to iOS
                [weakSelf.selectionView bringSubviewToFront:weakSelf.photoBackBTN];
                [weakSelf.photoBackBTN setEnabled:YES];
                
                [weakSelf.numberOfPhotos setText:[NSString stringWithFormat:@"%ld",(long)photocount]];
                if (photocount == 0) {
                    weakSelf.photoBtn.tag = CHECKED;
                }
                
                if (streamCount > 0 || unavailableCount > 0) {
                    [weakSelf.permissionPhotoLbl setHidden:NO];
                    [weakSelf.permissionPhotoLbl setText:[NSString stringWithFormat:@"%ld photos backed up to iCloud *", (long)streamCount + unavailableCount]];
                    [weakSelf.cloudWarningLbl setHidden:NO];
                }
            }
            
//            DebugLog(@"photo done.");
            [weakSelf stopSpinner]; // #2
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                // video
                [weakSelf.photolist createvideoLogfile];
            });
        });
    };
    photolist.fetchfailure = ^(NSString *errMsg, BOOL isPermissionErr) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                [weakSelf.numberOfLocalPhotos setText:@"-"];
                [weakSelf.numberOfCloudPhotos setText:@"-"];
                
                weakSelf.localPhotoBtn.tag = CHECKED;
                weakSelf.cloudPhotoBtn.tag = CHECKED;
            } else {
                [weakSelf.numberOfPhotos setText:@"-"];
                
                weakSelf.photoBtn.tag = CHECKED;
            }
            
            if (isPermissionErr) {
                weakSelf.hasAlbumPermissionErr = YES;
            } else {
                weakSelf.hasPhotoFetchErr = YES;
            }
            
            [weakSelf stopSpinner]; // #2
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                // video
                [weakSelf.photolist createvideoLogfile];
            });
        });
    };
    
    // video collect handler
    photolist.videocallBackHandler = ^(NSInteger videocount, NSInteger streamCount, NSInteger unavailableCount) {
        
//        DebugLog(@"Number of Video found %ld", (long)videocount);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) { // crossplatform
                [weakSelf.crossPlatformListView bringSubviewToFront:weakSelf.videoBackCrossBtn];
                [weakSelf.videoBackCrossBtn setEnabled:YES];
                [weakSelf.crossPlatformListView bringSubviewToFront:weakSelf.cloudVideoBackBtnCross];
                [weakSelf.cloudVideoBackBtnCross setEnabled:YES];
                
                [weakSelf.numberOfLocalVideo setText:[NSString stringWithFormat:@"%ld",(long)videocount]];
                if (videocount == 0) {
                    weakSelf.localVideoBtn.tag = CHECKED;
                }
                
                if (streamCount > 0) {
                    [weakSelf.numberOfCloudVideo setText:[NSString stringWithFormat:@"%ld", streamCount]];
                } else {
                    weakSelf.cloudVideoBtn.tag = CHECKED;
                }
                
//                DebugLog(@"video done!");
                [weakSelf stopSpinner]; // #3
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [weakSelf exportCalendars];
                });
            } else { // iOS to iOS
                [weakSelf.selectionView bringSubviewToFront:weakSelf.videoBackBtn];
                [weakSelf.videoBackBtn setEnabled:YES];
                
                [weakSelf.numberOfVideo setText:[NSString stringWithFormat:@"%ld",(long)videocount]];
                if (videocount == 0) {
                    weakSelf.videoBtn.tag = CHECKED;
                }
                
                if (streamCount > 0 || unavailableCount > 0) {
                    [weakSelf.permissionVideoLbl setHidden:NO];
                    [weakSelf.permissionVideoLbl setText:[NSString stringWithFormat:@"%ld videos backed up to iCloud *", streamCount + unavailableCount]];
                    [weakSelf.cloudWarningLbl setHidden:NO];
                }
                
//                DebugLog(@"video done!");
                [weakSelf stopSpinner]; // #3
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [weakSelf exportCalendars];
                });
            }
        });
    };
    
    photolist.videofetchfailure = ^(NSString *errMsg, BOOL isPermissionErr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                [weakSelf.numberOfLocalVideo setText:@"-"];
                [weakSelf.numberOfCloudVideo setText:@"-"];
                
                weakSelf.localVideoBtn.tag = CHECKED;
                weakSelf.cloudVideoBtn.tag = CHECKED;
            } else {
                [weakSelf.numberOfVideo setText:@"-"];
                weakSelf.videoBtn.tag = CHECKED;
            }
            
            if (isPermissionErr) {
                weakSelf.hasAlbumPermissionErr = YES;
            } else {
                weakSelf.hasVideoFetchErr = YES;
            }
            
            [weakSelf stopSpinner];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [weakSelf exportCalendars];
            });
        });
    };
    
    
    self.exportReminder.remindercallBackHandler = ^(int reminderCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.numberOfReminderLbl.text = [NSString stringWithFormat:@"%d", reminderCount];
            
        });
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{ // create background thread for contacts retrieve
        [weakSelf getContacts];
    });
    
    transfer_state = HAND_SHAKE;
    
    presentState = TRANSFER_ALL_FILE;
    nextState = TRANSFER_VCARD_FILE;
    
    photoCount = 0;
    videoCount = 0;
    photoTransferCount = 0;
    videoTransferCount = 0;
    
    sendingStatusView.hidden = YES;
    itemListView.hidden = NO;
    
    BUFFERSIZE = 1024 * 1;
    
    itemlist = [[NSMutableDictionary alloc] init];
    
    
    [itemlist setObject:@"false" forKey:@"contacts"];
    [itemlist setObject:@"false" forKey:@"photos"];
    [itemlist setObject:@"false" forKey:@"videos"];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
        [itemlist setObject:@"false" forKey:@"cloudPhotos"];
        [itemlist setObject:@"false" forKey:@"cloudVideos"];
        [itemlist setObject:@"false" forKey:@"calendar"];
    } else {
        [itemlist setObject:@"false" forKey:@"calendar"];
        [itemlist setObject:@"false" forKey:@"reminder"];
    }
    
    totalNoOfFilesTransfered = 0;
    
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",totalNoOfFilesTransfered] forKey:@"TOTALFILETRANSFERED"];
    
    isMemoryWarningReceived = NO;
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
        
        _crossPlatformListView.hidden = NO;
        _selectionView.hidden = YES;
        
        self.videoFormatInfoLbl.text = @"\"Only *.m4v, *.mp4,  and *.mov video formats will be received from Andriod device(s) and others will be ignored\"";
        
    } else {
        
        _selectionView.hidden = NO;
        _crossPlatformListView.hidden = YES;
        
    }
    
    viewDisappear = NO;
    
    [CTMVMButtons primaryRedButton:self.cancelBtn constrainHeight:YES];
    [CTMVMButtons primaryGreyButton:self.leftCancelBtn constrainHeight:YES];
    [CTMVMButtons primaryRedButton:self.transferBtn constrainHeight:YES];
    
#if STANDALONE
    
    if (screenHeight <=480) {
        self.transferWhtLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
        self.transferWhtLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:20];
    }else {
        
        self.transferWhtLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
        self.transferWhtLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    }
    
    self.sendingLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.sendingLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
#else
    
    if (screenHeight <=480) {
        self.transferWhtLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
        self.transferWhtLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:20];
    }else {
        
        self.transferWhtLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
        self.transferWhtLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    }
    
    self.sendingLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.sendingLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
#endif
   
    
    self.transferStatusLbl.font = [CTMVMFonts mvmBookFontOfSize:13];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
        self.numberOfLocalPhotos.font = [CTMVMFonts mvmBookFontOfSize:14];
        self.numberOfCloudPhotos.font = [CTMVMFonts mvmBookFontOfSize:14];
        self.numberOfCloudVideo.font = [CTMVMFonts mvmBookFontOfSize:14];
        self.numberOfLocalVideo.font = [CTMVMFonts mvmBookFontOfSize:14];
        self.numberOfContactCrossplatform.font = [CTMVMFonts mvmBookFontOfSize:14];
        self.numberOfCalX.font = [CTMVMFonts mvmBookFontOfSize:14];
        self.selectAllCrossPlatform.font = [CTMVMFonts mvmBookFontOfSize:16];
        
        self.numberOfLocalPhotos.textColor = [CTMVMColor darkGrayColor];
        self.numberOfCloudPhotos.textColor = [CTMVMColor darkGrayColor];
        self.numberOfCloudVideo.textColor =  [CTMVMColor darkGrayColor];
        self.numberOfLocalVideo.textColor =  [CTMVMColor darkGrayColor];
        self.numberOfCalX.textColor =  [CTMVMColor darkGrayColor];
        self.numberOfContactCrossplatform.textColor = [CTMVMColor darkGrayColor];
        
        self.photoCrossLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
        self.videoCrossLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
        self.contactCrossplatformLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
        self.calTitleX.font = [CTMVMFonts mvmBookFontOfSize:18];
        
        self.photoCrossLbl.textColor = [CTMVMColor darkGrayColor];
        self.videoCrossLbl.textColor =  [CTMVMColor darkGrayColor];
        self.calTitleX.textColor =  [CTMVMColor darkGrayColor];
        self.contactCrossplatformLbl.textColor = [CTMVMColor darkGrayColor];
        self.selectAllCrossPlatform.textColor= [CTMVMColor mvmPrimaryRedColor];
        
        self.permissionPhotoCrossLbl.font = [CTMVMFonts mvmBookFontOfSize:9];
        [self.permissionPhotoCrossLbl setTextColor:[UIColor redColor]];
        self.permissionVideoCrossLbl.font = [CTMVMFonts mvmBookFontOfSize:9];
        [self.permissionVideoCrossLbl setTextColor:[UIColor redColor]];
        self.permissionVcardCrossplatformLbl.font = [CTMVMFonts mvmBookFontOfSize:9];
        [self.permissionVcardCrossplatformLbl setTextColor:[UIColor redColor]];
        self.permissionErrCalX.font = [CTMVMFonts mvmBookFontOfSize:9];
        [self.permissionErrCalX setTextColor:[UIColor redColor]];
        
        self.localPhotoTitleLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
        [self.localPhotoTitleLbl setTextColor:[UIColor darkGrayColor]];
        self.cloudPhotoTitleLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
        [self.cloudPhotoTitleLbl setTextColor:[UIColor darkGrayColor]];
        self.localVideoTitleLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
        [self.localVideoTitleLbl setTextColor:[UIColor darkGrayColor]];
        self.cloudVideoTitleLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
        [self.cloudVideoTitleLbl setTextColor:[UIColor darkGrayColor]];
        
        self.vcardIconCrossplatform.image = [self.vcardIconCrossplatform.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.vcardIconCrossplatform setTintColor:[UIColor colorWithRed:167/255.0 green:169/255.0 blue:172/255.0 alpha:1.0]];
        self.photoIconCrossPlatform.image = [self.photoIconCrossPlatform.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.photoIconCrossPlatform setTintColor:[UIColor colorWithRed:167/255.0 green:169/255.0 blue:172/255.0 alpha:1.0]];
        self.videoIconCross.image = [self.videoIconCross.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.videoIconCross setTintColor:[UIColor colorWithRed:167/255.0 green:169/255.0 blue:172/255.0 alpha:1.0]];
        self.calIconX.image = [self.calIconX.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.calIconX setTintColor:[UIColor colorWithRed:167/255.0 green:169/255.0 blue:172/255.0 alpha:1.0]];
        
    } else {
        self.numberOfPhotos.font = [CTMVMFonts mvmBookFontOfSize:14];
        self.numberOfVideo.font = [CTMVMFonts mvmBookFontOfSize:14];
        self.numberOfContacts.font = [CTMVMFonts mvmBookFontOfSize:14];
        self.numberOfCalendarLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
        self.numberOfReminderLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
        
        self.selectAllLbl.font = [CTMVMFonts mvmBookFontOfSize:16];
        
        self.numberOfPhotos.textColor = [CTMVMColor darkGrayColor];
        self.numberOfVideo.textColor =  [CTMVMColor darkGrayColor];
        self.numberOfContacts.textColor = [CTMVMColor darkGrayColor];
        self.numberOfCalendarLbl.textColor = [CTMVMColor darkGrayColor];
        self.numberOfReminderLbl.textColor = [CTMVMColor darkGrayColor];
        
        self.photosLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
        self.videosLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
        self.contactsLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
        self.calendarTitle.font = [CTMVMFonts mvmBookFontOfSize:18];
        self.reminderTitle.font = [CTMVMFonts mvmBookFontOfSize:18];
        
        self.photosLbl.textColor = [CTMVMColor darkGrayColor];
        self.videosLbl.textColor =  [CTMVMColor darkGrayColor];
        self.contactsLbl.textColor = [CTMVMColor darkGrayColor];
        self.calendarTitle.textColor = [CTMVMColor darkGrayColor];
        self.reminderTitle.textColor = [CTMVMColor darkGrayColor];
        self.selectAllLbl.textColor= [CTMVMColor mvmPrimaryRedColor];
        
        self.permissionVcardLbl.font = [CTMVMFonts mvmBookFontOfSize:9];
        [self.permissionVcardLbl setTextColor:[UIColor redColor]];
        self.permissionPhotoLbl.font = [CTMVMFonts mvmBookFontOfSize:9];
        [self.permissionPhotoLbl setTextColor:[UIColor redColor]];
        self.permissionVideoLbl.font = [CTMVMFonts mvmBookFontOfSize:9];
        [self.permissionVideoLbl setTextColor:[UIColor redColor]];
        self.calendarPermissionLbl.font = [CTMVMFonts mvmBookFontOfSize:9];
        [self.reminderPermissionLbl setTextColor:[UIColor redColor]];
        self.reminderPermissionLbl.font = [CTMVMFonts mvmBookFontOfSize:9];
        [self.calendarPermissionLbl setTextColor:[UIColor redColor]];
        
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

    }
    
    self.videoFormatInfoLbl.font = [CTMVMFonts mvmBookFontOfSize:14];

    self.processDone = NO;
    
    self.transfercanceled = false;
    self.cloudWarningLbl.font = [CTMVMFonts mvmBookFontOfSize:13];
    
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
    
    // Disable transfer & cancel button
    [self.transferBtn setAlpha:0.4f];
}

- (void)AppWillTerminateByUser:(NSNotification *)notification
{
    if ([notification.name isEqualToString:CTApplicationWillTerminate]) {
        DebugLog(@"Terminate notification received test");
        if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
            [self sendForceQuitRequest];
        }
    }
}

- (void)shouldUpdateCalendarNumber:(NSInteger)number
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.numberOfCalendarLbl.text = [NSString stringWithFormat:@"%ld", (long)number];
        weakSelf.numberOfCalX.text = [NSString stringWithFormat:@"%ld", (long)number];
    });
}

- (void)sendForceQuitRequest {
    NSData *requestData = [@"VZTRANSFER_FORCE_QUIT" dataUsingEncoding:NSUTF8StringEncoding];
    if (self.asyncSocketCOMMPort != nil) {
        [self.asyncSocketCOMMPort writeData:requestData withTimeout: -1.0 tag:VZTagGeneral];
    } else {
        [self.asyncSocket writeData:requestData withTimeout: -1.0 tag:VZTagGeneral];
    }
}

- (void)exportCalendars
{
    // calendar permission check
    [self.calenderExport checkAuthorizationStatusToAccessEventStoreSuccess:^{
        //                    DebugLog(@"calender permission granted, should fetch the calendar enties");
        [self.calenderExport fetchLocalCalendarsWithSuccessHandler:^(NSInteger numberOfEvents) {
            
            [self.selectionView bringSubviewToFront:self.calendarBackBtn];
            [self.calendarBackBtn setEnabled:YES];
            
            [self.crossPlatformListView bringSubviewToFront:self.calBackBtnX];
            [self.calBackBtnX setEnabled:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.numberOfCalendarLbl.text = [NSString stringWithFormat:@"%ld", (long)numberOfEvents];
                self.numberOfCalX.text = [NSString stringWithFormat:@"%ld", (long)numberOfEvents];
            });
            if (numberOfEvents == 0) {
                self.calendarBtn.tag = CHECKED;
                self.calBtnX.tag = CHECKED;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopSpinner]; // #4
            });
            
            if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                [self ReminderSelected];
            }
        } andFailureHandler:^(NSError *err) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DebugLog(@"events failed:%@", err.localizedDescription);
                self.numberOfCalendarLbl.text = @"0";
                self.numberOfCalX.text = @"0";
            });
            self.calendarBtn.tag = CHECKED;
            self.calBtnX.tag = CHECKED;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopSpinner]; // #4
            });
            
            if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                [self ReminderSelected];
            }
        }];
    } andFailureHandler:^(EKAuthorizationStatus status) {
        self.hasCalendarPermissionErr = YES;
        self.calendarBtn.tag = CHECKED;
        self.calBtnX.tag = CHECKED;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopSpinner]; // #4
        });
        
        if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
            [self ReminderSelected];
        }
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.firstLayout) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) { // UI adaption for iPhones
//            self.circleWidth.constant = 236.0f;
            self.sendingCircularTopConstaints.constant = 44.f;
            self.keepAppLblTopConstaints.constant = 74.f;
            
//            [self.circularView setNeedsLayout];
            // Build selection list UI adaption
            CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
            if (screenHeight <= 480) { // IPhone 4 UI resolution.
                self.selectTopConstaints.constant = -6.f;
                self.cloudLblBottomConstraints.constant = 8.f;
                self.cancelBottomConstraints.constant /= 2;
                self.selectionTitleTopConstaints.constant /= 4;
                self.selectAllTopConstraints.constant = 0.f;
                self.listbodydistance.constant = 3.f;
                self.listBodyDisX.constant = 4.5f;
                
                self.sendingCircularTopConstaints.constant = 15.f;
                self.keepAppLblTopConstaints.constant = 15.f;
            } else if (screenHeight <= 568) { // Iphone 5 UI resolution
                self.selectTopConstaints.constant = 0.f;
                self.cloudLblBottomConstraints.constant /= 2;
                
                self.keepAppLblTopConstaints.constant = 74.f;
            } else {
                self.keepAppLblTopConstaints.constant = 74.f;
            }
            
            self.firstLayout = NO;
        } else {
            self.keepAppOpenLbl.textAlignment = NSTextAlignmentCenter;
        }
    }
}

- (void)getContacts {
    // contact
    __weak typeof(self) weakSelf = self;
    [self.vcardexport exportContactsAsVcard:^(int result) {
        dispatch_async(dispatch_get_main_queue(), ^{ // main queue make sure title will be updated once the process done.
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                [weakSelf.crossPlatformListView bringSubviewToFront:weakSelf.vcardBackBtnCrossplatform];
                [weakSelf.vcardBackBtnCrossplatform setEnabled:YES];
                
                [weakSelf.numberOfContactCrossplatform setText:[NSString stringWithFormat:@"%d",result]];
            } else {
                [weakSelf.selectionView bringSubviewToFront:weakSelf.vcardBackBtn];
                [weakSelf.vcardBackBtn setEnabled:YES];
                
                [weakSelf.numberOfContacts setText:[NSString stringWithFormat:@"%d",result]];
            }
            
            if (result == 0) {
                _vcardBtn.tag = CHECKED;
                _vcardBtnCrossPlatform.tag = CHECKED;
            }
            
            [weakSelf stopSpinner]; // #1
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [weakSelf.photolist createphotoLogfile];
            });
        });
    } andFailure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{ // main queue make sure title will be updated once the process done.
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                [weakSelf.numberOfContactCrossplatform setText:@"-"];
            } else {
                [weakSelf.numberOfContacts setText:@"-"];
            }
            
            weakSelf.hasContactPermissionErr = YES;

            _vcardBtn.tag = CHECKED;
            _vcardBtnCrossPlatform.tag = CHECKED;
            
            [weakSelf stopSpinner]; // #1
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [weakSelf.photolist createphotoLogfile];
            });
        });
    }];
}

- (void)ReminderSelected {
    // reminder
    __weak typeof(self) weakSelf = self;
    [VZRemindersExport updateAuthorizationStatusToAccessEventStoreSuccess:^{
        [weakSelf.exportReminder fetchLocalReminderLists:^(int reminderCount) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.selectionView bringSubviewToFront:weakSelf.reminderBackBtn];
                [weakSelf.reminderBackBtn setEnabled:YES];
                
                weakSelf.numberOfReminderLbl.text = [NSString stringWithFormat:@"%lu", (unsigned long)reminderCount];
                if (reminderCount == 0) {
                    weakSelf.reminderBtn.tag = CHECKED;
                }
                
//                DebugLog(@"reminder done!");
                [weakSelf stopSpinner]; // #5
            });
        }];
    } failed:^(EKAuthorizationStatus status) {
        
        weakSelf.hasReminderPermissionErr = YES;
        weakSelf.reminderBtn.tag = CHECKED;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf stopSpinner]; // #5
        });
    }];
}

- (void)stopSpinner {
    
    int count = 5;
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
        count = 4;
    }
    
//    DebugLog(@"check point:%ld", (long)++prepareProcessFinishCount);
    if (++prepareProcessFinishCount == count) {
        
        [self.view setUserInteractionEnabled:YES];
        
        transferBtn.enabled = YES;
        [self.transferBtn setAlpha:1.f];
        
        overlayActivity.hidden = YES;
        [overlayActivity stopAnimating];
        
        [self.backgroundView removeFromSuperview];
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        [self disableUnavailableItems];
        if (self.hasContactPermissionErr || self.hasAlbumPermissionErr || self.hasReminderPermissionErr || self.hasCalendarPermissionErr) {
            // show permission alert
            [self showPermissionAlert];
        }
    }
}

- (void)shouldUpdatePhotoNumber:(NSInteger)number {
    
    __weak typeof(self) weakSelf = self;
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.numberOfLocalPhotos setText:[NSString stringWithFormat:@"%ld",(long)number]];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.numberOfPhotos setText:[NSString stringWithFormat:@"%ld",(long)number]];
        });
    }
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
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:nil];
    
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
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
        if (self.hasAlbumPermissionErr && self.hasContactPermissionErr && self.hasCalendarPermissionErr && self.hasReminderPermissionErr) {
            [self.selectAllCrossPlatform setTintColor:[UIColor lightGrayColor]];
            [self.selectAllBtnCrossPlatform setEnabled:NO];
            
            [self.crossPlatformListView bringSubviewToFront:self.selectAllBackBtnCrossPlatform];
            [self.selectAllBackBtnCrossPlatform setEnabled:YES];
        }
        
        if (self.hasContactPermissionErr) {
            [self.vcardBtnCrossPlatform setTintColor:[UIColor lightGrayColor]];
            [self.vcardBtnCrossPlatform setEnabled:NO];
            
            self.numberOfContactCrossplatform.text = @"-";
            [self.numberOfContactCrossplatform setTextColor:[UIColor lightGrayColor]];
            
            [self.contactCrossplatformLbl setTextColor:[UIColor lightGrayColor]];
            
            self.vcardIconCrossplatform.image = [self.vcardIconCrossplatform.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.vcardIconCrossplatform setTintColor:[UIColor lightGrayColor]];
            
//            [self.crossPlatformListView bringSubviewToFront:self.vcardBackBtnCrossplatform];
//            [self.vcardBackBtnCrossplatform setEnabled:YES];
            
            [self.permissionVcardCrossplatformLbl setHidden:NO];
        }
        
        if (self.hasPhotoFetchErr) {
            [self.localPhotoBtn setTintColor:[UIColor lightGrayColor]];
            [self.cloudPhotoBtn setTintColor:[UIColor lightGrayColor]];
            [self.localPhotoBtn setEnabled:NO];
            [self.cloudPhotoBtn setEnabled:NO];
            
            self.numberOfCloudPhotos.text = @"-";
            [self.numberOfCloudPhotos setTextColor:[UIColor lightGrayColor]];
            self.numberOfLocalPhotos.text = @"-";
            [self.numberOfLocalPhotos setTextColor:[UIColor lightGrayColor]];
            
            [self.photoCrossLbl setTextColor:[UIColor lightGrayColor]];
            
            self.photoIconCrossPlatform.image = [self.photoIconCrossPlatform.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.photoIconCrossPlatform setTintColor:[UIColor lightGrayColor]];
            
            [self.permissionPhotoCrossLbl setHidden:NO];
            self.permissionPhotoCrossLbl.text = @"Error when fetching photos";
        }
        
        if (self.hasVideoFetchErr) {
            [self.localVideoBtn setTintColor:[UIColor lightGrayColor]];
            [self.localVideoBtn setEnabled:NO];
            [self.cloudVideoBtn setTintColor:[UIColor lightGrayColor]];
            [self.cloudVideoBtn setEnabled:NO];
            
            self.numberOfLocalVideo.text = @"-";
            [self.numberOfLocalVideo setTextColor:[UIColor lightGrayColor]];
            self.numberOfCloudVideo.text = @"-";
            [self.numberOfCloudVideo setTextColor:[UIColor lightGrayColor]];
            
            [self.videoCrossLbl setTextColor:[UIColor lightGrayColor]];
            
            self.videoIconCross.image = [self.videoIconCross.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.videoIconCross setTintColor:[UIColor lightGrayColor]];
            
            [self.permissionVideoCrossLbl setHidden:NO];
            self.permissionVideoCrossLbl.text = @"Error when fetching videos";
        }
        
        if (self.hasAlbumPermissionErr) {
            [self.localPhotoBtn setTintColor:[UIColor lightGrayColor]];
            [self.cloudPhotoBtn setTintColor:[UIColor lightGrayColor]];
            [self.localPhotoBtn setEnabled:NO];
            [self.cloudPhotoBtn setEnabled:NO];
            
            self.numberOfCloudPhotos.text = @"-";
            [self.numberOfCloudPhotos setTextColor:[UIColor lightGrayColor]];
            self.numberOfLocalPhotos.text = @"-";
            [self.numberOfLocalPhotos setTextColor:[UIColor lightGrayColor]];
            
            [self.photoCrossLbl setTextColor:[UIColor lightGrayColor]];
            
            self.photoIconCrossPlatform.image = [self.photoIconCrossPlatform.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.photoIconCrossPlatform setTintColor:[UIColor lightGrayColor]];
            
//            [self.crossPlatformListView bringSubviewToFront:self.photoBackBtnCross];
//            [self.photoBackBtnCross setEnabled:YES];
            
            
            [self.localVideoBtn setTintColor:[UIColor lightGrayColor]];
            [self.localVideoBtn setEnabled:NO];
            [self.cloudVideoBtn setTintColor:[UIColor lightGrayColor]];
            [self.cloudVideoBtn setEnabled:NO];
            
            self.numberOfLocalVideo.text = @"-";
            [self.numberOfLocalVideo setTextColor:[UIColor lightGrayColor]];
            self.numberOfCloudVideo.text = @"-";
            [self.numberOfCloudVideo setTextColor:[UIColor lightGrayColor]];
            
            [self.videoCrossLbl setTextColor:[UIColor lightGrayColor]];
            
            self.videoIconCross.image = [self.videoIconCross.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.videoIconCross setTintColor:[UIColor lightGrayColor]];
            
//            [self.crossPlatformListView bringSubviewToFront:self.videoBackCrossBtn];
//            [self.videoBackCrossBtn setEnabled:YES];
            
            [self.permissionVideoCrossLbl setHidden:NO];
            [self.permissionPhotoCrossLbl setHidden:NO];
        }
        
        if (self.hasCalendarPermissionErr) {
            [self.calBtnX setTintColor:[UIColor lightGrayColor]];
            [self.calBtnX setEnabled:NO];
            
            self.numberOfCalX.text = @"-";
            [self.numberOfCalX setTextColor:[UIColor lightGrayColor]];
            
            [self.calTitleX setTextColor:[UIColor lightGrayColor]];
            
            self.calIconX.image = [self.calIconX.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.calIconX setTintColor:[UIColor lightGrayColor]];
            
            [self.permissionErrCalX setHidden:NO];
        }
    } else {
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
            
//            [self.selectionView bringSubviewToFront:self.vcardBackBtn];
//            [self.vcardBackBtn setEnabled:YES];
            
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
            
//            [self.selectionView bringSubviewToFront:self.photoBackBTN];
//            [self.photoBackBTN setEnabled:YES];
            
            
            [self.videoBtn setTintColor:[UIColor lightGrayColor]];
            [self.videoBtn setEnabled:NO];
            
            self.numberOfVideo.text = @"-";
            [self.numberOfVideo setTextColor:[UIColor lightGrayColor]];
            
            [self.videosLbl setTextColor:[UIColor lightGrayColor]];
            
            self.videoIcon.image = [self.videoIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.videoIcon setTintColor:[UIColor lightGrayColor]];
            
//            [self.selectionView bringSubviewToFront:self.videoBackBtn];
//            [self.videoBackBtn setEnabled:YES];
            
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
        
        if (self.hasCalendarPermissionErr) {
            [self.calendarBtn setTintColor:[UIColor lightGrayColor]];
            [self.calendarBtn setEnabled:NO];
            
            self.numberOfCalendarLbl.text = @"-";
            [self.numberOfCalendarLbl setTextColor:[UIColor lightGrayColor]];
            
            [self.calendarTitle setTextColor:[UIColor lightGrayColor]];
            
            self.calendarIcon.image = [self.calendarIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.calendarIcon setTintColor:[UIColor lightGrayColor]];
            
            [self.calendarPermissionLbl setHidden:NO];
        }
        
        if (self.hasReminderPermissionErr) {
            [self.reminderBtn setTintColor:[UIColor lightGrayColor]];
            [self.reminderBtn setEnabled:NO];
            
            self.numberOfReminderLbl.text = @"-";
            [self.numberOfReminderLbl setTextColor:[UIColor lightGrayColor]];
            
            [self.reminderTitle setTextColor:[UIColor lightGrayColor]];
            
            self.reminderIcon.image = [self.reminderIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.reminderIcon setTintColor:[UIColor lightGrayColor]];
            
            [self.reminderPermissionLbl setHidden:NO];
        }
    }
}

- (void)openSettings
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    isMemoryWarningReceived = YES;
    
    DebugLog(@"VZContentTrasnfer Received Memory warning ..");
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleAppWillTerminate)
//                                                 name:NMApplicationWillTerminate
//                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    viewDisappear = YES;
    
    
}

#pragma mark - GCDAsyncSocket Delegate methods

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
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
        
        NSError *error;
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:dict
                                                              options:kNilOptions
                                                                error:&error];
        
        [asyncSocketCOMMPort writeData:requestData withTimeout: -1.0 tag:100];
        [asyncSocketCOMMPort writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:100];
        
        [asyncSocketCOMMPort readDataWithTimeout:-1 tag:100];

    }
    
    DebugLog(@"socket:didConnectToHost:%@ port:%hu", host, port);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    DebugLog(@"did write delegate called, tag:%ld", tag);
    
    if (tag == VZTagGeneral) {
        return;
    } else if (tag != VZTagVideoFiles) {
        [asyncSocket readDataWithTimeout:-1 tag:VZTagGeneral];
    } else {
        
        // Checking if transfered package size, avoid crash casued by memory issue
        if (sentVideoDataSize - 1024 > 0 && (sentVideoDataSize - 1024) % (packageSize * 1024 * 1024) == 0) {
            [asyncSocket readDataWithTimeout:-1 tag:VZTagGeneral];
            return;
        }
        
        if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
            if (sentVideoDataSize != self.currentVideoSize) {
                [self transferChunkofVideo:self.currentVideoAsset withSize:self.currentVideoSize];
            } else {
                [asyncSocket readDataWithTimeout:-1 tag:VZTagGeneral];
            }
        } else {
            if (sentVideoDataSize != currentALAseetRep.size) {
                [self transferChunkofVideo];
            } else {
                [asyncSocket readDataWithTimeout:-1 tag:VZTagGeneral];
            }
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    
    if (sock == asyncSocketCOMMPort) {
        
        NSError *errorJson=nil;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
        // read COMM port information
        DebugLog(@"read comm port information : %@",responseDict);
        
        return;
    }
    
    if (data.length <= 0) {
        DebugLog(@"0 byte package received, should check why!");
        [asyncSocket readDataWithTimeout:-1 tag:VZTagGeneral]; // keep reading
        return;
    }

    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DebugLog(@"NSdata to String2 : %@", response);
    response = [response formatRequestForXPlatform];
    if (response.length == 0) {
        [asyncSocket readDataWithTimeout:-1 tag:VZTagGeneral]; // keep reading
    }
    
    
    // if globle pending data exist, complete, clear globle one
    if (incompleteData.length > 0) {
        [incompleteData appendData:data];
        data = incompleteData;
        incompleteData = nil; // keep globle pending data length always be 0;
    }
    
    nextState = [self identifyRequest:&response];
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
            
        case TRANSFER_NEXT_VIDEO_PART : {
            [self transferSelecteditem:TRANSFER_NEXT_VIDEO_PART receivedData:response];
        }
            break;
        case TRANSFER_REMINDER_LOG_FILE : {
            [self transferSelecteditem:TRANSFER_REMINDER_LOG_FILE receivedData:response];
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
            
        case TRANSFER_COMPLETED: {
            
            self.processDone = YES;
            
            asyncSocket.delegate = nil;
            listenOnPort.delegate = nil;
            
            [asyncSocket disconnect];
            [listenOnPort disconnect];
            [asyncSocketCOMMPort disconnect];
            [listenOnPortCOMMPort disconnect];
            
            asyncSocketCOMMPort= nil;
            listenOnPortCOMMPort = nil;
            
            asyncSocket = nil;
            listenOnPort = nil;
            
            [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",totalNoOfFilesTransfered] forKey:@"TOTALFILETRANSFERED"];
            
            NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
            
            [infoDict setObjectIfValid:[NSString stringWithFormat:@"%d",countOfContacts] forKey:@"Contacts Transferred" defaultObject:@0];
            [infoDict setObjectIfValid:[NSString stringWithFormat:@"%d",countOfPhotos] forKey:@"Photos Transferred" defaultObject:@0];
            [infoDict setObjectIfValid:[NSString stringWithFormat:@"%d",countOfVideo] forKey:@"Videos Transferred" defaultObject:@0];
            [infoDict setObjectIfValid:[NSString stringWithFormat:@"%ld",(long)_numberOfCalendar] forKey:@"Calendar Transferred" defaultObject:@0];
            [infoDict setObjectIfValid:[NSString stringWithFormat:@"%ld",(long)_numberOfReminder] forKey:@"Reminder Transferred" defaultObject:@0];
            
            [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_ITEMS_P2P_TRANSFERRED  withExtraInfo:infoDict isEncryptedExtras:false];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.targetType = TRANSFER_SUCCESS;
                
                [self stopAnimationReceiverImageVIew];
                [self performSegueWithIdentifier:@"SenderTransferCompleted" sender:nil];
            });
        }
            break;
            
        default:
            // store the incomplete data
            incompleteData = [data mutableCopy];
            [asyncSocket readDataWithTimeout:-1 tag:VZTagGeneral]; // keep reading
            
            break;
    }
}

#define GCDAsyncSocketClosedByRemotePeer 7
#define GCDSocketNotConnected 57
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    
    if (err.code == GCDAsyncSocketClosedByRemotePeer && !viewDisappear && !self.processDone) { // process cancel
        asyncSocket.delegate = nil;
        listenOnPort.delegate = nil;
        
        [asyncSocket disconnect];
        [listenOnPort disconnect];
        [asyncSocketCOMMPort disconnect];
        [listenOnPortCOMMPort disconnect];
        
        asyncSocketCOMMPort= nil;
        listenOnPortCOMMPort = nil;

        
        
        asyncSocket = nil;
        listenOnPort = nil;
        
        self.transfercanceled = YES;
        
//        [[self navigationController] popToRootViewControllerAnimated:YES];
//        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//        [appDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
        
        [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",totalNoOfFilesTransfered] forKey:@"TOTALFILETRANSFERED"];
        
        self.targetType = TRANSFER_CANCELLED;
        [self performSegueWithIdentifier:@"SenderTransferCompleted" sender:nil];
        
    } else if (err.code == GCDSocketNotConnected) {
        asyncSocket.delegate = nil;
        listenOnPort.delegate = nil;
        
        [asyncSocket disconnect];
        [listenOnPort disconnect];
        [asyncSocketCOMMPort disconnect];
        [listenOnPortCOMMPort disconnect];
        
        asyncSocketCOMMPort= nil;
        listenOnPortCOMMPort = nil;

        
        asyncSocket = nil;
        listenOnPort = nil;
        
        self.transfercanceled = YES;
        
        [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",totalNoOfFilesTransfered] forKey:@"TOTALFILETRANSFERED"];
        
        self.targetType = TRANSFER_INTERRUPTED;
        [self performSegueWithIdentifier:@"SenderTransferCompleted" sender:nil];
        
    } else {
        DebugLog(@"Error on 8988 port");
    }
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
    asyncSocket = newSocket;
    asyncSocket.delegate = self;
    
    [asyncSocket readDataWithTimeout:-1 tag:0];
}

#pragma mark - Cancel Operations
- (IBAction)clickedOnSendCancel:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [weakSelf closeSocket];
        
        weakSelf.targetType = TRANSFER_CANCELLED;
		
		NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneTransfer, ANALYTICS_TrackAction__Param_Value_LinkName_CancelTransferBeforeBegin);
    [self.sharedAnalytics trackAction:ANALYTICS_TrackAction__Param_Value_LinkName_CancelTransferBeforeBegin
                                 data:@{ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction__Param_Value_LinkName_CancelTransferBeforeBegin,
                                        ANALYTICS_TrackAction_Key_PageLink:pageLink
                                        ,
                                        ANALYTICS_TrackAction_Key_SenderReceiver:ANALYTICS_TrackAction_Value_SenderReceiver_Sender}];
        [weakSelf performSegueWithIdentifier:@"SenderTransferCompleted" sender:nil];
    }];
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:@"Are you sure want to cancel the transfer" cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    
    
}

- (void)closeSocket
{
    // Close the socket
    self.transfercanceled = true;
    
    [self.asyncSocket disconnect];
    [self.listenOnPort disconnect];
    
    self.asyncSocket = nil;
    self.listenOnPort = nil;
    
    [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
    
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",totalNoOfFilesTransfered] forKey:@"TOTALFILETRANSFERED"];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([[segue identifier] isEqualToString:@"SenderTransferCompleted"]) {
        
        VZTransferFinishViewController *destination = segue.destinationViewController;
        destination.summaryDisplayFlag = 1;
        destination.processEnd = YES;
        destination.numberOfContacts = countOfContacts;
        destination.numberOfPhotos = countOfPhotos;
        destination.numberOfVideos = countOfVideo;
        destination.numberOfReminder = _numberOfReminder;
        destination.numberOfCalendar = _numberOfCalendar;
        destination.isSender = YES;
        destination.analyticsTypeID = self.targetType;
        destination.transferInterrupted = self.transfercanceled;
//        destination.mediaTypePiped = mediaTypePiped;
        
    }
}

- (IBAction)ClickedSelectAll:(UIButton *)sender {
    
    // Update select all UI
    if ([sender isSelected]) { // Selected
//        if((sender != self.selectAllBtn) && (sender!= self.selectAllBtnCrossPlatform)) { // Not select all, uncheck it
//            [sender setImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_red_uncheck"] forState:UIControlStateNormal];
//        }
        [sender setSelected:NO];
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) { // Is cross platform
            _vcardBtnCrossPlatform.tag = CHECKED;
            _localPhotoBtn.tag = CHECKED;
            _cloudPhotoBtn.tag = CHECKED;
            _localVideoBtn.tag = CHECKED;
            _cloudVideoBtn.tag = CHECKED;
            _calBtnX.tag = CHECKED;
            
            [_selectAllCrossPlatform setText:@"Select All"];
        } else { // iOS to iOS
            _vcardBtn.tag = CHECKED;
            _photoBtn.tag = CHECKED;
            _videoBtn.tag = CHECKED;
            _calendarBtn.tag = CHECKED;
            _reminderBtn.tag = CHECKED;
            
            [_selectAllLbl setText:@"Select All"];
        }
        
        [self.selectAllLbl setNeedsLayout];
        
    } else { // Not selected
//        if((sender!= self.selectAllBtn) && (sender!= self.selectAllBtnCrossPlatform)) {
//            [sender setImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_red_check"] forState:UIControlStateSelected];
//        }
        [sender setSelected:YES];
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
            if (_numberOfContactCrossplatform.text.integerValue > 0) _vcardBtnCrossPlatform.tag = UNCHECKED;
            if (_numberOfLocalPhotos.text.integerValue > 0) _localPhotoBtn.tag = UNCHECKED;
            if (_numberOfCloudPhotos.text.integerValue > 0) _cloudPhotoBtn.tag = UNCHECKED;
            if (_numberOfLocalVideo.text.integerValue > 0) _localVideoBtn.tag = UNCHECKED;
            if (_numberOfCloudVideo.text.integerValue > 0) _cloudVideoBtn.tag = UNCHECKED;
            if (_numberOfCalX.text.integerValue > 0) _calBtnX.tag = UNCHECKED;
            [_selectAllCrossPlatform setText:@"Deselect All"];
        } else {
            if (numberOfContacts.text.integerValue > 0) _vcardBtn.tag = UNCHECKED;
            if (numberOfPhotos.text.integerValue > 0) _photoBtn.tag = UNCHECKED;
            if (numberOfVideo.text.integerValue > 0) _videoBtn.tag = UNCHECKED;
            if (_numberOfCalendarLbl.text.integerValue > 0) _calendarBtn.tag = UNCHECKED;
            if (_numberOfReminderLbl.text.integerValue > 0) _reminderBtn.tag = UNCHECKED;
            
            [_selectAllLbl setText:@"Deselect All"];
        }
        
        [self.selectAllLbl setNeedsLayout];
    }
    
    if (!self.hasContactPermissionErr) {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
            [self vcardSelected:_vcardBtnCrossPlatform];
        } else {
            [self vcardSelected:_vcardBtn];
        }
    }
    
    if (!self.hasAlbumPermissionErr) {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
            [self photSelected:_localPhotoBtn];
            [self cloudPhotSelected:_cloudPhotoBtn];
            [self videoSelected:_localVideoBtn];
            [self cloudVideoSelected:_cloudVideoBtn];
        } else {
            [self photSelected:_photoBtn];
            [self videoSelected:_videoBtn];
        }
    }
    
    if (!self.hasCalendarPermissionErr) {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
            [self calendarXSelected:_calBtnX];
        } else {
            [self calendarSelected:_calendarBtn];
        }
    }
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) { // Not x-platform
        if (!self.hasReminderPermissionErr) {
            [self reminderSelected:_reminderBtn];
        }
    }
}

- (IBAction)clickedOnTransfer:(id)sender {
    
    NSArray *itemsValue = [self.itemlist allValues];
    
    if ([itemsValue containsObject:@"true"]) {
        [self transferSelecteditem:presentState receivedData:nil];
        
        itemListView.hidden = YES;
        sendingStatusView.hidden = NO;
        
        self.analyticsData = nil;
        self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneProcessing;
        
        [self startAnimationSenderImageView];
        
        [self captureAnalyticsPart];
    } else {
        [self displayAlter:@"Please select any items"];
    }
    
}

- (void)captureAnalyticsPart {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:self.itemlist];
    
    [dict setValue:@"UNKNOWN" forKey:@"Music"];
    [dict setValue:@"UNKNOWN" forKey:@"CallLogs"];
    [dict setValue:@"UNKNOWN" forKey:@"Sms"];
    [dict setValue:@"P2P" forKey:@"ConnectionType"];
    [dict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"Onclicktransfer"  withExtraInfo:dict isEncryptedExtras:false];
}


- (void) transferSelecteditem:(enum state_machine) item receivedData:(NSString *)response{
    
    switch (item) {
        case HAND_SHAKE:
            break;
            
        case TRANSFER_ALL_FILE: {
            [self sendAllFileList];
        } break;
            
        case TRANSFER_VCARD_FILE:
        {
            if(![self.numberOfContacts.text isEqual:@"0"] || ![[[self numberOfContactCrossplatform] text] isEqual:@"0"] ) {
                ++totalNoOfFilesTransfered;
            }
            [self sendContacts_Vcard];
        }  break;
            
        case TRANSFER_PHOTO_LOG_FILE:
        {
            [self sendPhotoLogfile];
        }
            break;
        case TRANSFER_PHOTO_FILE:
        {
            ++ totalNoOfFilesTransfered;
            
            [self sendRequestedPhoto:response];
        }
            break;
        case TRANSFER_VIDEO_LOG_FILE:
        {
            [self sendVideoLogfile];
        }
            break;
        case TRANSFER_VIDEO_FILE:
        {
            ++ totalNoOfFilesTransfered;
            
            [self sendRequestedVideo:response];
        }
            break;
            
        case TRANSFER_NEXT_VIDEO_PART: {
            if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
                [self transferChunkofVideo:_currentVideoAsset withSize:_currentVideoSize];
            } else {
                [self transferChunkofVideo];
            }
        }
            break;
            
        case TRANSFER_REMINDER_LOG_FILE:
        {
            ++ totalNoOfFilesTransfered;
            [self transferReminderLogFile];
        }
            break;
        case TRANSFER_CALENDAR_FILE_START:
        {
            ++ totalNoOfFilesTransfered;
            [self sendRequestCalendar:[self parseCalendarFromData:response needUpdateUI:YES]];
        } break;
            
        case TRANSFER_CALENDAR_FILE:
        {
            ++ totalNoOfFilesTransfered;
            [self sendRequestCalendar:[self parseCalendarFromData:response needUpdateUI:NO]];
        } break;
            
        case TRANSFER_CALENDAR_FILE_END:
        {
            ++ totalNoOfFilesTransfered;
            [self sendRequestCalendar:[self parseCalendarFromData:response needUpdateUI:NO]];
        } break;
            
        default:
            break;
            
    }
}

- (NSString *)parseCalendarFromData:(NSString *)response needUpdateUI:(BOOL)flag {
    
    if (flag) {
        [self performSelectorOnMainThread:@selector(updateTitleLabelInMainThread:) withObject:@"Sending Calendar" waitUntilDone:NO];
    }
    
    // Ignore VZCONTENTTRANSFER_START_REQUEST_FOR_CALENDAR_
    NSString *calInfo = nil;
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
        //VZCONTENTTRANSFER_REQUEST_FOR_CALENDAR_
        calInfo = [response substringWithRange:NSMakeRange(39, response.length - 39)];
    } else {
        calInfo = [response substringWithRange:NSMakeRange(45, response.length - 45)];
    }
    
    return calInfo;
}

- (void)updateTitleLabelInMainThread:(NSString *)title
{
    self.transferStatusLbl.text = title;
}

- (void)sendRequestCalendar:(NSString *)calName
{
    NSString *calURL = [self.calenderExport getEventURL:calName];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:calURL];
    
    NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERCALENSTART"];
    
    NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%d",(int)data.length];
    
    
    int gap = 10 - (int)tempstr.length;
    for (int i = 0; i < gap ; i++) {
        [tempstr insertString:@"0" atIndex:0];
    }
    
    [tempstr insertString:requestStr atIndex:0];
    
    NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    
    [finaldata appendData:requestData];
    
    
    if (data.length > 0) {
        [finaldata appendData:data];
    }
    
    self.numberOfCalendar += 1;
    
    [asyncSocket writeData:finaldata withTimeout:-1.0 tag:VZTagCalendars];
}

- (void) sendAllFileList {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    
    // Send package size for P2P (fix large video memory issue)
    [dict setObjectIfValid:[NSString stringWithFormat:@"%ld", (long)packageSize] forKey:@"videoPkgSize" defaultObject:@0];
    
    NSData *fileList = nil;
    // Photos
    if ([[self.itemlist valueForKey:@"photos"] isEqualToString:@"true"]) {
        
        fileList = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/VZPhotoLogfile.txt",basePath]];
        if (fileList != nil) {
            NSError *err = nil;
            
            @try {
                NSMutableArray *photofilelist = [[NSJSONSerialization JSONObjectWithData:fileList options:0 error:&err] mutableCopy];
                
                if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && [[self.itemlist valueForKey:@"cloudPhotos"] isEqualToString:@"true"] && ![self.numberOfCloudPhotos.text isEqualToString:@"0"]) {
                    // merge all photos
                    [photofilelist addObjectsFromArray:photolist.photoStreamSet];
                }
                
                [dict setObjectIfValid:photofilelist forKey:@"photoFileList" defaultObject:@[]];
            } @catch (NSException *exception) {
                [dict setObject:[NSArray new] forKey:@"photoFileList"];
            }
            
        } else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && [[self.itemlist valueForKey:@"cloudPhotos"] isEqualToString:@"true"] && ![self.numberOfCloudPhotos.text isEqualToString:@"0"]) {
            [dict setObjectIfValid:photolist.photoStreamSet forKey:@"photoFileList" defaultObject:@[]];
        }
        
    } else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && [[self.itemlist valueForKey:@"cloudPhotos"] isEqualToString:@"true"] && ![self.numberOfCloudPhotos.text isEqualToString:@"0"]) {
        [dict setObjectIfValid:photolist.photoStreamSet forKey:@"photoFileList" defaultObject:@[]];
        [self.itemlist setValue:@"true" forKey:@"photos"];
    } else {
        [dict setObject:[NSArray new] forKey:@"photoFileList"];
    }
    
    // To calculate total size of All photo key Size
    NSArray *photoList = (NSArray *)[dict valueForKey:@"photoFileList"];
    
    long long photoTotalSize = 0;
    if (photoList && photoList.count > 0) {
         photoTotalSize  = [[photoList valueForKeyPath:@"@sum.Size"] longLongValue];
    } else {
        [self.itemlist setValue:@"false" forKey:@"photos"];
    }

    // Video
    if ([[self.itemlist valueForKey:@"videos"] isEqualToString:@"true"]) {
        
        fileList = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/VZVideoLogfile.txt",basePath]];
        if (fileList != nil) {
            NSError *err = nil;
            
            @try {
                NSMutableArray *videofilelist = [[NSJSONSerialization JSONObjectWithData:fileList options:0 error:&err] mutableCopy];
                if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && [[self.itemlist valueForKey:@"cloudVideos"] isEqualToString:@"true"] && ![self.numberOfCloudVideo.text isEqualToString:@"0"]) {
                    // merge all videos
                    [videofilelist addObjectsFromArray:photolist.videoStreamSet];
                }
                
                [dict setObjectIfValid:videofilelist forKey:@"videoFileList" defaultObject:@[]];
            } @catch (NSException *exception) {
                [dict setObject:[NSArray new] forKey:@"videoFileList"];
            }
            
        } else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && [[self.itemlist valueForKey:@"cloudVideos"] isEqualToString:@"true"] && ![self.numberOfCloudVideo.text isEqualToString:@"0"]) {
            [dict setObjectIfValid:photolist.videoStreamSet forKey:@"videoFileList" defaultObject:@[]];
        }
        
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && [[self.itemlist valueForKey:@"cloudVideos"] isEqualToString:@"true"] && ![self.numberOfCloudVideo.text isEqualToString:@"0"]) {
        [dict setObjectIfValid:photolist.videoStreamSet forKey:@"videoFileList" defaultObject:@[]];
        [self.itemlist setValue:@"true" forKey:@"videos"];
    } else {
        [dict setObject:[NSArray new] forKey:@"videoFileList"];
    }
    
    
    // To calculate total size of All Video key Size
    NSArray *videoList = [dict valueForKey:@"videoFileList"];
    
    long long videoTotalSize = 0;
    if (videoList && videoList.count > 0) {
        videoTotalSize  = [[videoList valueForKeyPath:@"@sum.Size"] longLongValue];
    } else {
        [self.itemlist setValue:@"false" forKey:@"videos"];
    }
    
    if ([[self.itemlist valueForKey:@"photos"] isEqualToString:@"true"]) {
        
        NSMutableDictionary *photoStatus = [[NSMutableDictionary alloc] init];
        
        [photoStatus setValue:@"true" forKey:@"status"];
        [photoStatus setValue:[NSString stringWithFormat:@"%lld",photoTotalSize] forKey:@"totalSize"];
        [photoStatus setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[photoList count]] forKey:@"totalCount"];
        
        [self.itemlist setValue:photoStatus forKey:@"photos"];
    } else {
        
        NSMutableDictionary *photoStatus = [[NSMutableDictionary alloc] init];
        
        [photoStatus setValue:@"false" forKey:@"status"];
        [photoStatus setValue:@"0" forKey:@"totalSize"];
        [photoStatus setValue:@"0" forKey:@"totalCount"];
        
        [self.itemlist setValue:photoStatus forKey:@"photos"];
        
    }
    
    
    if ([[self.itemlist valueForKey:@"videos"] isEqualToString:@"true"]) {
        
        NSMutableDictionary *videoStatus = [[NSMutableDictionary alloc] init];
        
        [videoStatus setValue:@"true" forKey:@"status"];
        [videoStatus setValue:[NSString stringWithFormat:@"%lld",videoTotalSize] forKey:@"totalSize"];
        [videoStatus setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[videoList count]] forKey:@"totalCount"];
        
        [self.itemlist setValue:videoStatus forKey:@"videos"];
        
    } else {
        
        NSMutableDictionary *videoStatus = [[NSMutableDictionary alloc] init];
        
        [videoStatus setValue:@"false" forKey:@"status"];
        [videoStatus setValue:@"0" forKey:@"totalSize"];
        [videoStatus setValue:@"0" forKey:@"totalCount"];
        
        [self.itemlist setValue:videoStatus forKey:@"videos"];

    }
    
    // Contacts
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
        if (![_numberOfContactCrossplatform.text isEqualToString:@"0"]) {
            if ([[self.itemlist valueForKey:@"contacts"] isEqualToString:@"true"]) {
                [dict setObjectIfValid:_numberOfContactCrossplatform.text forKey:@"contactsize" defaultObject:@0];
            }
        } else {
            [self.itemlist setValue:@"false" forKey:@"contacts"];
        }
    } else {
        if (![numberOfContacts.text isEqualToString:@"0"]) {
            if ([[self.itemlist valueForKey:@"contacts"] isEqualToString:@"true"]) {
                [dict setObjectIfValid:numberOfContacts.text forKey:@"contactsize" defaultObject:@0];
            }
        } else {
            [self.itemlist setValue:@"false" forKey:@"contacts"];
        }
    }
    
    // Calculate Contacts total size
    if ([[self.itemlist valueForKey:@"contacts"] isEqualToString:@"true"]) {
        
        NSMutableDictionary *contactStatus = [[NSMutableDictionary alloc] init];
        
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        
        [contactStatus setValue:@"true" forKey:@"status"];
        [contactStatus setValue:[userdefault valueForKey:@"CONTACTTOTALSIZE"] forKey:@"totalSize"];
        [contactStatus setValue:[dict valueForKey:@"contactsize"] forKey:@"totalCount"];
        
        [self.itemlist setValue:contactStatus forKey:@"contacts"];
        
    } else {
        
        NSMutableDictionary *contactStatus = [[NSMutableDictionary alloc] init];
        
        [contactStatus setValue:@"false" forKey:@"status"];
        [contactStatus setValue:@"0" forKey:@"totalSize"];
        [contactStatus setValue:@"0" forKey:@"totalCount"];
        
        [self.itemlist setValue:contactStatus forKey:@"contacts"];
    }
    
    // Reminder
    if ([[self.itemlist valueForKey:@"reminder"] isEqualToString:@"true"]) {
        
        NSMutableDictionary *reminderStatus = [[NSMutableDictionary alloc] init];
        
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        
        [reminderStatus setValue:@"true" forKey:@"status"];
        [reminderStatus setValue:[userdefault valueForKey:@"REMINDERLOGSIZE"] forKey:@"totalSize"];
        [reminderStatus setValue:@"1" forKey:@"totalCount"];
        
        [self.itemlist setValue:reminderStatus forKey:@"reminder"];

    } else {
        
        NSMutableDictionary *reminderStatus = [[NSMutableDictionary alloc] init];
        
        [reminderStatus setValue:@"false" forKey:@"status"];
        [reminderStatus setValue:@"0" forKey:@"totalSize"];
        [reminderStatus setValue:@"0" forKey:@"totalCount"];
        
        [self.itemlist setValue:reminderStatus forKey:@"reminder"];
    }
    
    // Calendar events
    if ([[self.itemlist valueForKey:@"calendar"] isEqualToString:@"true"]) {
        fileList = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/VZCalenderLogoFile.txt",basePath]];
        
        if (fileList != nil) {
            NSError *err = nil;
            
            @try {
                NSArray *calFilelist = [NSJSONSerialization JSONObjectWithData:fileList options:0 error:&err];
                if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                    [dict setObjectIfValid:calFilelist forKey:@"calendarFileList" defaultObject:@[]];
                } else {
                    [dict setObjectIfValid:calFilelist forKey:@"calFileList" defaultObject:@[]];
                }
                
                NSMutableDictionary *calenderStatus = [[NSMutableDictionary alloc] init];
                
                NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
                
                [calenderStatus setValue:@"true" forKey:@"status"];
                [calenderStatus setValue:[userdefault valueForKey:@"CALENDARTOTALSIZE"] forKey:@"totalSize"];
                if ([calFilelist count] > 0) {
                    [calenderStatus setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[calFilelist count]] forKey:@"totalCount"];
                } else {
                    [calenderStatus setValue:@"0" forKey:@"totalCount"];
                }
                
                [self.itemlist setValue:calenderStatus forKey:@"calendar"];
            } @catch (NSException *exception) {
                DebugLog(@"Json Parsing failed:%@", err.localizedDescription);
                NSMutableDictionary *calendarStatus = [[NSMutableDictionary alloc] init];
                
                [calendarStatus setValue:@"false" forKey:@"status"];
                [calendarStatus setValue:@"0" forKey:@"totalSize"];
                [calendarStatus setValue:@"0" forKey:@"totalCount"];
                
                [self.itemlist setValue:calendarStatus forKey:@"calendar"];
            }
        }
    } else {
        
        NSMutableDictionary *calendarStatus = [[NSMutableDictionary alloc] init];
        
        [calendarStatus setValue:@"false" forKey:@"status"];
        [calendarStatus setValue:@"0" forKey:@"totalSize"];
        [calendarStatus setValue:@"0" forKey:@"totalCount"];
        
        [self.itemlist setValue:calendarStatus forKey:@"calendar"];
    }
    
    [dict setObjectIfValid:self.itemlist forKey:@"itemList" defaultObject:@{}];
    
    NSError *err = nil;
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    @try {
        NSData *fileListData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
        NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERALLFLSTART"];
        
        NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%d",(int)fileListData.length];
        
        //    DebugLog(@"file len %d", (int)tempstr.length);
        
        int gap = 10 - (int)tempstr.length;
        for (int i = 0; i < gap ; i++) {
            [tempstr insertString:@"0" atIndex:0];
        }
        
        [tempstr insertString:requestStr atIndex:0];
        NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
        
        [finaldata appendData:requestData];
        [finaldata appendData:fileListData];
        
        [self.transferStatusLbl setText:@"Sending File List"];
        
        [asyncSocket writeData:finaldata withTimeout:-1.0 tag:VZTagAllFileList];
        
        
        [self connectToOtherDevice:COMM_PORT_NUMBER];
        
 
    } @catch (NSException *exception) {

        DebugLog(@"Json create failed:%@", err.debugDescription);
        // If error happened, should go to data transfer interrupted page
        [self closeSocket];
        
        self.targetType = TRANSFER_INTERRUPTED;
        [self performSegueWithIdentifier:@"SenderTransferCompleted" sender:nil];
        
    }
}


- (void)sendContacts_Vcard {
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
        countOfContacts = (int)_numberOfContactCrossplatform.text.integerValue;
    } else {
        countOfContacts = (int)numberOfContacts.text.integerValue;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.transferStatusLbl setText:@"Sending VCard"];
    });
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    
    /*
     * We are assigning our filePath variable with our application's document path appended with our file's name.
     */
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/VZAllContactBackup.vcf",basePath]];
    
    NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERVCARDSTART"];
    
    NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%d",(int)data.length];
    
    int gap = 10 - (int)tempstr.length;
    for (int i = 0; i < gap ; i++) {
        [tempstr insertString:@"0" atIndex:0];
    }
    
    [tempstr insertString:requestStr atIndex:0];
    
    NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    
    [finaldata appendData:requestData];
    
    if (data.length > 0) {
        [finaldata appendData:data];
    }
    
    [asyncSocket writeData:finaldata withTimeout:-1.0 tag:VZTagVcardFiles];
    
//    [asyncSocket readDataWithTimeout:-1.0 tag:0];
}

- (void)sendPhotoLogfile {
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/VZPhotoLogfile.txt",basePath]];
    
    NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERPHOTOLOGAND"];

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
    
    [self.transferStatusLbl setText:@"Sending Photo List"];
    
    [asyncSocket writeData:finaldata withTimeout:-1.0 tag:10];
    
    presentState = TRANSFER_PHOTO_LOG_FILE;
    nextState = TRANSFER_PHOTO_FILE;
    
}


- (void)transferReminderLogFile {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.transferStatusLbl setText:@"Sending Reminder"];
    });
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    
    NSData *reminderdata = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/Reminder/ReminderLogoFile.txt",basePath]];
    
    NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERREMINDERLO"];

    NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%d",(int)reminderdata.length];
    
    int gap = 10 - (int)tempstr.length;
    
    for (int i = 0; i < gap ; i++) {
        
        [tempstr insertString:@"0" atIndex:0];
    }
    
    [tempstr insertString:requestStr atIndex:0];
    
    NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    
    [finaldata appendData:requestData];
    
    if (reminderdata.length > 0) {
        [finaldata appendData:reminderdata];
    }
    
    _numberOfReminder += 1;
    
    [asyncSocket writeData:finaldata withTimeout:-1.0 tag:VZTagReminders];
    
}

- (void)sendVideoLogfile {
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/VZVideoLogfile.txt",basePath]];
    
    NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERVIDEOLOGAND"];
    
    
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
    
    [self.transferStatusLbl setText:@"Sending Video List"];
    
    [asyncSocket writeData:finaldata withTimeout:-1.0 tag:10];
    
    presentState = TRANSFER_PHOTO_LOG_FILE;
    nextState = TRANSFER_PHOTO_FILE;
    
}



- (enum state_machine) identifyRequest:(NSString **)response {
    
    DebugLog(@"identify request %@",*response);
        
    if ((*response).length > 0) {
        
        if ([*response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_VCARD"].location != NSNotFound) {
            
            return TRANSFER_VCARD_FILE;
            
        } else if ( [*response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_LOG_FILE"].location != NSNotFound) {
            
            return TRANSFER_PHOTO_LOG_FILE;
            
        } else if ( [*response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_DUPLICATE"].location != NSNotFound) {
            
            return TRASNFER_FILE_DUPLICATE;
            
        } else if ( [*response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_DUPLICATE"].location != NSNotFound) {
            
            return TRASNFER_FILE_DUPLICATE;
            
        }else if ([*response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_RFVQTElDQVRF"].location != NSNotFound) {
            // photo duplicate from Android side
            *response = [*response stringByReplacingOccurrencesOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_RFVQTElDQVRF" withString:@""];
            
        } else if ([*response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_RFVQTElDQVRF"].location != NSNotFound) {
            // video duplicate from Android side
            *response = [*response stringByReplacingOccurrencesOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_RFVQTElDQVRF" withString:@""];
            
        }else if ( [*response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_"].location != NSNotFound) {
            
            return TRANSFER_PHOTO_FILE;
            
        } else if ( [*response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_LOG_FILE"].location != NSNotFound) {
            
            return TRANSFER_VIDEO_LOG_FILE;
            
        } else if ( [*response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_"].location != NSNotFound) {
            
            return TRANSFER_VIDEO_FILE;
            
        } else if ( [*response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_VPART_"].location != NSNotFound) {
            
            return TRANSFER_NEXT_VIDEO_PART;
            
        } else if ( [*response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_REMIN"].location != NSNotFound) {
            
            return TRANSFER_REMINDER_LOG_FILE;
            
        } else if ([*response rangeOfString:@"VZCONTENTTRANSFER_FINISHED"].location != NSNotFound) {
            
            return TRANSFER_COMPLETED;
        } else if ([*response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEY"].location != NSNotFound) {
            
//            DebugLog(@"Yes i was here");
            if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && !self.keyreceived) {
                self.keyreceived = YES;
                
//                DebugLog(@"security key done!");
                [self stopSpinner];
            }
        } else if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && [*response rangeOfString:@"VZCONTENTTRANSFER_START_REQUEST_FOR_CALENDAR_"].location != NSNotFound) {
            
            return TRANSFER_CALENDAR_FILE_START;
        } else if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && [*response rangeOfString:@"VZCONTENTTRANSFER_ORIGI_REQUEST_FOR_CALENDAR_"].location != NSNotFound) {
            
            return TRANSFER_CALENDAR_FILE;
        } else if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && [*response rangeOfString:@"VZCONTENTTRANSFER_FINAL_REQUEST_FOR_CALENDAR_"].location != NSNotFound) {
            
            return TRANSFER_CALENDAR_FILE_END;
        } else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && [*response rangeOfString:@"VZCONTENTTRANSFER_REQUEST_FOR_CALENDAR_"].location != NSNotFound) {
            
            return TRANSFER_CALENDAR_FILE_END;
        }
    }
    
    return HAND_SHAKE;
}


- (void)readSocketRepeated {
    
    [asyncSocket readDataWithTimeout:-1 tag:0];
    
    //    dispatch_queue_t alwaysReadQueue = dispatch_queue_create([GCD_ALWAYS_READ_QUEUE UTF8String], NULL);
    //
    //    dispatch_async(alwaysReadQueue, ^{
    //        while(![asyncSocket isDisconnected]) {
    //            [NSThread sleepForTimeInterval:0.25];
    //            [asyncSocket readDataWithTimeout:-1 tag:0];
    //        }
    //    });
    
}


- (void)sendRequestedPhoto:(NSString *)response {
    
    
    DebugLog(@"Photo before is %@",response);
    
    countOfPhotos++;
    
    [self.transferStatusLbl setText:[NSString stringWithFormat:@"%d Photo(s) Sent ",++photoTransferCount]];
    
    // Skip VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_ number of characters
    NSString *imgname = [response substringWithRange:NSMakeRange(36, response.length - 36)];
    
    imgname = [self decodeStringTo64:imgname];
    
     DebugLog(@"Photo After is %@",imgname);
    
    if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        [self requestPhotoUsingNewLibrary:imgname];
    } else {
        [self requestPhotoUsingOldLibrary:imgname];
    }
}

- (void)requestPhotoUsingNewLibrary:(NSString *)imgname
{
    __weak typeof(self) weakSelf = self;
    [photolist getPhotoData:imgname Sucess:^(id myasset) {
        PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.synchronous = YES;
        
        [[PHImageManager defaultManager] requestImageDataForAsset:myasset options:imageRequestOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            @autoreleasepool {
                long long totalPhotoSize = imageData.length;
                
                NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERPHOTOSTART"];
                NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%llu",totalPhotoSize];
                
                DebugLog(@"Photo header: %llu",totalPhotoSize);
                
                int gap = 10 - (int)tempstr.length;
                
                for (int i = 0; i < gap ; i++) {
                    [tempstr insertString:@"0" atIndex:0];
                }
                
                [tempstr insertString:requestStr atIndex:0];
                NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
                
                 DebugLog(@"Photo header 10 digit: %@",tempstr);
                
                NSMutableData *finaldata = [[NSMutableData alloc] init];
                [finaldata appendData:requestData];
                if (imageData.length > 0) {
                    [finaldata appendData:imageData];
                }
                
                [weakSelf.asyncSocket writeData:finaldata withTimeout: -1.0 tag:VZTagPhotoFiles];
            }
        }];
    }];
}

- (void)requestPhotoUsingOldLibrary:(NSString *)imgname
{
    __weak typeof(self) weakSelf = self;
    [photolist getPhotoData:imgname Sucess:^(ALAsset *myasset) {
        
        //        DebugLog(@"->GET NEXT IMAGE");
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        
        //        long long  totalVideoSize = rep.size;
        long long sentDataSize = (rep.size > 1048576) ? rep.size : 1048576;
        
        Byte *bufferInit = (Byte*)malloc(sentDataSize);
        NSUInteger buffered = [rep getBytes:bufferInit fromOffset:0 length:sentDataSize error:nil];
        NSData *videoDatainit = [NSData dataWithBytesNoCopy:bufferInit length:buffered freeWhenDone:YES];
        
        
        NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERPHOTOSTART"];
        
        NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%llu",rep.size];
        
        int gap = 10 - (int)tempstr.length;
        
        for (int i = 0; i < gap ; i++) {
            
            [tempstr insertString:@"0" atIndex:0];
        }
        
        [tempstr insertString:requestStr atIndex:0];
        
        NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *finaldata = [[NSMutableData alloc] init];
        
        [finaldata appendData:requestData];
        if (videoDatainit.length > 0) {
            [finaldata appendData:videoDatainit];
        }
        
        [weakSelf.asyncSocket writeData:finaldata withTimeout: -1.0 tag:VZTagPhotoFiles];
        
    }];
}

- (void)sendRequestedVideo:(NSString *)response {
    
    countOfVideo++;
    
    [self.transferStatusLbl setText:[NSString stringWithFormat:@"%d Video(s) Sent ", ++videoTransferCount]];
    
    // Skip VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_ number of characters
    NSString *videoName = [response substringWithRange:NSMakeRange(36, response.length - 36)];
    
    videoName = [self decodeStringTo64:videoName];
    
    if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        [self requestVideoUsingNewLibrary:videoName];
    } else {
        [self requestVideoUsingOldLibrary:videoName];
    }
    
}

- (void)requestVideoUsingNewLibrary:(NSString *)videoName
{
    __weak typeof(self) weakSelf = self;
    [photolist getVideoData:videoName Sucess:^(AVURLAsset *asset) {
        
        NSNumber *size;
        [asset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
        long long totalVideoSize = [size longLongValue];
//        DebugLog(@"size is %lld", totalVideoSize);
        
        weakSelf.videofileize = totalVideoSize;
        
        weakSelf.sentVideoDataSize = 1024;
    
        NSData *videoDatainit = [NSData dataWithContentsOfFile:asset.URL atOffset:0 withSize:weakSelf.sentVideoDataSize];
        
        NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERVIDEOSTART"];
        NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%llu",totalVideoSize];
        
        int gap = 10 - (int)tempstr.length;
        for (int i = 0; i < gap ; i++) {
            [tempstr insertString:@"0" atIndex:0];
        }
        
        [tempstr insertString:requestStr atIndex:0];
        
        NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *finaldata = [[NSMutableData alloc] init];
        [finaldata appendData:requestData];
        if (videoDatainit.length > 0) {
            [finaldata appendData:videoDatainit];
        }
        
        [asyncSocket writeData:finaldata withTimeout: -1.0 tag:VZTagVideoFiles];
        
        self.currentVideoAsset = asset;
        self.currentVideoSize = totalVideoSize;
        
//        [self transferChunkofVideo:asset withSize:totalVideoSize];
        
    }];
}

- (void)transferChunkofVideo:(AVURLAsset *)asset withSize:(long long)totalVideoSize
{
    long bufferSize = 1024 * 1024;
    NSData *videoData = nil;
    
    if (sentVideoDataSize + bufferSize > totalVideoSize) { // last chunk
        
        bufferSize = (long)(totalVideoSize - sentVideoDataSize);
        
        //            bufferSize = (long)(sentVideoDataSize - currentALAseetRep.size);
        videoData = [NSData dataWithContentsOfFile:asset.URL atOffset:sentVideoDataSize withSize:bufferSize];
        
        sentVideoDataSize += bufferSize;
        
        [asyncSocket writeData:videoData withTimeout: -1.0 tag:VZTagVideoFiles];
        
        return;
    }
    
    videoData = [NSData dataWithContentsOfFile:asset.URL atOffset:sentVideoDataSize withSize:bufferSize];
    
    [asyncSocket writeData:videoData withTimeout: -1.0 tag:VZTagVideoFiles];
    
    sentVideoDataSize += bufferSize;
}

- (void)requestVideoUsingOldLibrary:(NSString *)imgname
{
    __weak typeof(self) weakSelf = self;
    [photolist getVideoData:imgname Sucess:^(ALAsset *myasset) {
        
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        
        long long  totalVideoSize = rep.size;
        weakSelf.sentVideoDataSize = 1024;
        
        Byte *bufferInit = (Byte*)malloc(weakSelf.sentVideoDataSize);
        NSUInteger buffered = [rep getBytes:bufferInit fromOffset:0 length:weakSelf.sentVideoDataSize error:nil];
        NSData *videoDatainit = [NSData dataWithBytesNoCopy:bufferInit length:buffered freeWhenDone:YES];
        
        
        NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERVIDEOSTART"];
        
        NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%llu",totalVideoSize];
        
        int gap = 10 - (int)tempstr.length;
        
        for (int i = 0; i < gap ; i++) {
            
            [tempstr insertString:@"0" atIndex:0];
        }
        
        [tempstr insertString:requestStr atIndex:0];
        
        NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *finaldata = [[NSMutableData alloc] init];
        
        [finaldata appendData:requestData];
        
        if (videoDatainit.length > 0) {
            [finaldata appendData:videoDatainit];
        }
        
        [asyncSocket writeData:finaldata withTimeout: -1.0 tag:VZTagVideoFiles];
        
        currentALAseetRep = rep;
        
//        [self transferChunkofVideo];
    }];
}


- (void)transferChunkofVideo {
    
    long bufferSize = 1024 * 1024;
    NSData *videoData = nil;
    
    while (sentVideoDataSize != currentALAseetRep.size) {
        
        if (sentVideoDataSize + bufferSize > currentALAseetRep.size) {
            
            bufferSize = (long)(currentALAseetRep.size - sentVideoDataSize);
            
            Byte *buffer = (Byte*)malloc(bufferSize);
            NSUInteger buffered = [currentALAseetRep getBytes:buffer fromOffset:sentVideoDataSize length:bufferSize error:nil];
            videoData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            
            sentVideoDataSize += bufferSize;
            
            [asyncSocket writeData:videoData withTimeout: -1.0 tag:VZTagVideoFiles];
            
            break;
        }
        
        Byte *buffer = (Byte*)malloc(bufferSize);
        NSUInteger buffered = [currentALAseetRep getBytes:buffer fromOffset:sentVideoDataSize length:bufferSize error:nil];
        videoData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        
        sentVideoDataSize +=bufferSize;
        
        [asyncSocket writeData:videoData withTimeout: -1.0 tag:VZTagVideoFiles];
        
        // Checking if transfered 300 MB
        if ((sentVideoDataSize - 1024) % (packageSize * 1024 * 1024) == 0) {
            [asyncSocket readDataWithTimeout:-1 tag:VZTagGeneral];
            break;
        }
    }
}

- (void) startAnimationSenderImageView {
    
    self.trasnferAnimationImgView.animationImages = [NSArray arrayWithObjects:
                                [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_00" ],
                                [ UIImage getImageFromBundleWithImageName:@"anim_right_1x_01" ],
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

- (IBAction)vcardSelected:(UIButton *)sender {
    
    if ((numberOfContacts.text.integerValue > 0 && ![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) || ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && _numberOfContactCrossplatform.text.integerValue > 0)) { // contacts exists
        
        if (sender.tag == UNCHECKED) {
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_check" ] forState:UIControlStateNormal];
            
            [self.itemlist setObject:@"true" forKey:@"contacts"];
            
            self.vcardIcon.tintColor = RGB(205, 4, 11);
            self.vcardIconCrossplatform.tintColor = RGB(205, 4, 11);
            
            if (self.videoBtn.tag == CHECKED && self.photoBtn.tag == CHECKED && self.calendarBtn.tag == CHECKED && self.reminderBtn.tag == CHECKED) {
                [self.selectAllBtn setSelected:YES];
                [self.selectAllLbl setText:@"Deselect All"];
            }
            
            if (self.localPhotoBtn.tag == CHECKED && self.cloudPhotoBtn.tag == CHECKED && self.localVideoBtn.tag == CHECKED && self.cloudVideoBtn.tag == CHECKED && self.calBtnX.tag == CHECKED) {
                
                [self.selectAllBtnCrossPlatform setSelected:YES];
                [self.selectAllCrossPlatform setText:@"Deselect All"];
            }
            
            sender.tag = CHECKED;
            
        } else {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_uncheck" ] forState:UIControlStateNormal];
            
            [self.itemlist setObject:@"false" forKey:@"contacts"];
            
            self.vcardIcon.tintColor = RGB(167,169,172);
            self.vcardIconCrossplatform.tintColor = RGB(167,169,172);
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                [_selectAllBtnCrossPlatform setSelected:NO];
                [self.selectAllCrossPlatform setText:@"Select All"];
            } else {
                [selectAllBtn setSelected:NO];
                [self.selectAllLbl setText:@"Select All"];
            }
            
            sender.tag = UNCHECKED;
        }
    }
}

- (IBAction)photSelected:(UIButton *)sender {
    
    if ((numberOfPhotos.text.integerValue > 0 && ![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) || ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && _numberOfLocalPhotos.text.integerValue > 0)) {
        
        if (sender.tag == UNCHECKED) {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_check" ] forState:UIControlStateNormal];
            
            [self.itemlist setObject:@"true" forKey:@"photos"];
            
            self.photoIcon.tintColor = RGB(205, 4, 11);
            self.photoIconCrossPlatform.tintColor = RGB(205, 4, 11);
            
            if (self.vcardBtn.tag == CHECKED && self.videoBtn.tag == CHECKED && self.calendarBtn.tag == CHECKED && self.reminderBtn.tag == CHECKED) {
                
                [selectAllBtn setSelected:YES];
                [[self selectAllLbl] setText:@"Deselect All"];
            }
            
            if (self.vcardBtnCrossPlatform.tag == CHECKED && self.cloudPhotoBtn.tag == CHECKED && self.localVideoBtn.tag == CHECKED && self.cloudVideoBtn.tag == CHECKED && self.calBtnX.tag == CHECKED) {
                
                [[self selectAllBtnCrossPlatform] setSelected:YES];
                [[self selectAllCrossPlatform] setText:@"Deselect All"];
            }
            
            sender.tag = CHECKED;
            
        } else {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_uncheck" ] forState:UIControlStateNormal];
            
            [self.itemlist setObject:@"false" forKey:@"photos"];
            self.photoIcon.tintColor = RGB(167,169,172);
            self.photoIconCrossPlatform.tintColor = RGB(167,169,172);
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                [_selectAllBtnCrossPlatform setSelected:NO];
                [[self selectAllCrossPlatform] setText:@"Select All"];
                
            } else {
                [selectAllBtn setSelected:NO];
                [[self selectAllLbl] setText:@"Select All"];
            }
            
            sender.tag = UNCHECKED;
        }
    }
}

- (IBAction)cloudPhotSelected:(UIButton *)sender {
    
    if (([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && _numberOfCloudPhotos.text.integerValue > 0) ) {
        
        if (sender.tag == UNCHECKED) {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_check" ] forState:UIControlStateNormal];
            
            
            [itemlist setObject:@"true" forKey:@"cloudPhotos"];
            self.photoIconCrossPlatform.tintColor = RGB(205, 4, 11);
            
            if (self.vcardBtnCrossPlatform.tag == CHECKED && self.localPhotoBtn.tag == CHECKED && self.localVideoBtn.tag == CHECKED && self.cloudVideoBtn.tag == CHECKED && self.calBtnX.tag == CHECKED) {
                
                [[self selectAllBtnCrossPlatform] setSelected:YES];
                [[self selectAllCrossPlatform] setText:@"Deselect All"]; }

            
            sender.tag = CHECKED;
            
        } else {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_uncheck" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"false" forKey:@"cloudPhotos"];
            self.photoIconCrossPlatform.tintColor = RGB(167,169,172);
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                [_selectAllBtnCrossPlatform setSelected:NO];
                [[self selectAllCrossPlatform] setText:@"Select All"];
            } else {
                [selectAllBtn setSelected:NO];
                [[self selectAllLbl] setText:@"Select All"];
            }
            
            sender.tag = UNCHECKED;
        }
    }
}

- (IBAction)videoSelected:(UIButton *)sender {
    
    if ((numberOfVideo.text.integerValue > 0 && ![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) || ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && _numberOfLocalVideo.text.integerValue > 0)) {
        
        if (sender.tag == UNCHECKED) {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_check" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"true" forKey:@"videos"];
            self.videoIcon.tintColor = RGB(205, 4, 11);
            self.videoIconCross.tintColor = RGB(205, 4, 11);
            
            if (self.vcardBtn.tag == CHECKED && self.photoBtn.tag == CHECKED && self.calendarBtn.tag == CHECKED && self.reminderBtn.tag == CHECKED) {
                [selectAllBtn setSelected:YES];
                [[self selectAllLbl] setText:@"Deselect All"];
            }
            
            if (self.localPhotoBtn.tag == CHECKED && self.cloudPhotoBtn.tag == CHECKED && self.vcardBtnCrossPlatform.tag == CHECKED && self.cloudVideoBtn.tag == CHECKED && self.calBtnX.tag == CHECKED) {
                
                [[self selectAllBtnCrossPlatform] setSelected:YES];
                [[self selectAllCrossPlatform] setText:@"Deselect All"];
            }
            
            sender.tag = CHECKED;
            
        } else {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_uncheck" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"false" forKey:@"videos"];
            self.videoIcon.tintColor = RGB(167,169,172);
            self.videoIconCross.tintColor = RGB(167,169,172);
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                [_selectAllBtnCrossPlatform setSelected:NO];
                [[self selectAllCrossPlatform] setText:@"Select All"];
            } else {
                [selectAllBtn setSelected:NO];
                [[self selectAllLbl] setText:@"Select All"];
            }
            
            sender.tag = UNCHECKED;
        }
    }
}

- (IBAction)reminderSelected:(UIButton *)sender {
    
    if (_numberOfReminderLbl.text.integerValue > 0 && ![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
        
        if (sender.tag == UNCHECKED) {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_check" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"true" forKey:@"reminder"];
             self.reminderIcon.tintColor = RGB(205, 4, 11);
            
            if (self.videoBtn.tag == CHECKED && self.photoBtn.tag == CHECKED && self.vcardBtn.tag == CHECKED && self.calendarBtn.tag == CHECKED) {
                [selectAllBtn setSelected:YES];
                [[self selectAllLbl] setText:@"Deselect All"];
            }
            
            sender.tag = CHECKED;
            
        } else {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_uncheck" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"false" forKey:@"reminder"];
            self.reminderIcon.tintColor = RGB(167,169,172);
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                [_selectAllBtnCrossPlatform setSelected:NO];
                [[self selectAllCrossPlatform] setText:@"Select All"];
            } else {
                [selectAllBtn setSelected:NO];
                [[self selectAllLbl] setText:@"Select All"];
            }
            
            sender.tag = UNCHECKED;
        }
    }
}

- (IBAction)cloudVideoSelected:(UIButton *)sender {
    
    if (([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"] && _numberOfCloudVideo.text.integerValue > 0)) {
        
        if (sender.tag == UNCHECKED) {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_check" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"true" forKey:@"cloudVideos"];
             self.videoIconCross.tintColor = RGB(205, 4, 11);
            
            if (self.localPhotoBtn.tag == CHECKED && self.cloudPhotoBtn.tag == CHECKED && self.vcardBtnCrossPlatform.tag == CHECKED && self.localVideoBtn.tag == CHECKED && self.calBtnX.tag == CHECKED) {
                
                [[self selectAllBtnCrossPlatform] setSelected:YES];
                [[self selectAllCrossPlatform] setText:@"Deselect All"];
            }

            
            sender.tag = CHECKED;
            
        } else {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_uncheck" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"false" forKey:@"cloudVideos"];
            self.videoIconCross.tintColor = RGB(167,169,172);
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                [_selectAllBtnCrossPlatform setSelected:NO];
                [[self selectAllCrossPlatform] setText:@"Select All"];
            } else {
                [selectAllBtn setSelected:NO];
                [[self selectAllLbl] setText:@"Select All"];
            }
            
            sender.tag = UNCHECKED;
        }
    }
}

- (IBAction)calendarXSelected:(UIButton *)sender {
    if (self.numberOfCalX.text.integerValue > 0) {
        if (sender.tag == UNCHECKED) {
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_check" ] forState:UIControlStateNormal];
            [itemlist setObject:@"true" forKey:@"calendar"];
            self.calIconX.tintColor = RGB(205, 4, 11);
            
            if (self.localVideoBtn.tag == CHECKED && self.cloudVideoBtn.tag == CHECKED && self.localPhotoBtn.tag == CHECKED && self.cloudVideoBtn.tag == CHECKED && self.vcardBtnCrossPlatform.tag == CHECKED) {
                [_selectAllBtnCrossPlatform setSelected:YES];
                [[self selectAllCrossPlatform] setText:@"Deselect All"];
            }
            
            sender.tag = CHECKED;
            
        } else {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_uncheck" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"false" forKey:@"calendar"];
            self.calIconX.tintColor = RGB(167,169,172);
            
            [_selectAllBtnCrossPlatform setSelected:NO];
            [[self selectAllCrossPlatform] setText:@"Select All"];
            
            sender.tag = UNCHECKED;
        }
    }
}

- (IBAction)calendarSelected:(UIButton *)sender {
    if (_numberOfCalendarLbl.text.integerValue > 0 && ![[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
        
        if (sender.tag == UNCHECKED) {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_check" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"true" forKey:@"calendar"];
            self.calendarIcon.tintColor = RGB(205, 4, 11);
            
            if (self.videoBtn.tag == CHECKED && self.photoBtn.tag == CHECKED && self.vcardBtn.tag == CHECKED && self.reminderBtn.tag == CHECKED) {
                [selectAllBtn setSelected:YES];
                [[self selectAllLbl] setText:@"Deselect All"];
            }
            
            sender.tag = CHECKED;
            
        } else {
            
            [sender setBackgroundImage:[ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_uncheck" ] forState:UIControlStateNormal];
            
            [itemlist setObject:@"false" forKey:@"calendar"];
            self.calendarIcon.tintColor = RGB(167,169,172);
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                [_selectAllBtnCrossPlatform setSelected:NO];
                [[self selectAllCrossPlatform] setText:@"Select All"];
            } else {
                [selectAllBtn setSelected:NO];
                [[self selectAllLbl] setText:@"Select All"];
            }
            
            sender.tag = UNCHECKED;
        }
    }
}

- (void) displayAlter:(NSString *)str {
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:str cancelAction:cancelAction otherActions:nil isGreedy:NO];
    
    
    
    //- (void) readingVideoFromAlAssetURL {
    //
    //    NSArray *hashTable = photolist.hashTableUrltofileName;
    //
    //    NSURL *url = [[hashTable objectAtIndex:0] valueForKey:@""];
    //}
    
}

- (IBAction)vcardAskForPermission:(UIButton *)sender {

    if(self.hasContactPermissionErr) {
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [weakSelf openSettings];
    }];
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:nil];
    
    NSString *message = @"Unable to read contacts. Please give permission for contacts.";
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    } else {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
            [self vcardSelected:self.vcardBtnCrossPlatform];
        } else {
            [self vcardSelected:_vcardBtn];
        }
        
        
    }
}

- (IBAction)photoAskForPermission:(UIButton *)sender {
    
    if (self.hasAlbumPermissionErr)  {
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [weakSelf openSettings];
    }];
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:nil];
    
    NSString *message = @"Unable to read photos. Please give permission for photos.";
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    } else {
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
            [self photSelected:self.localPhotoBtn];
//            [self cloudPhotSelected:self.cloudPhotoBtn];
        } else {
            [self photSelected:_photoBtn];
        }
        
    }
}

- (IBAction)selectallAskForPermission:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [weakSelf openSettings];
    }];
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:nil];
    
    NSString *message = @"Unable to read photos, videos, contacts, calendars and reminders. Please give permission for them";
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
}

- (IBAction)reminderAskForPermission:(id)sender {
    if (self.hasReminderPermissionErr) {
        
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [weakSelf openSettings];
        }];
        
        
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:nil];
        
        NSString *message = @"Unable to read reminders. Please give permission for reminders.";
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
        
    } else {
        [self reminderSelected:_reminderBtn];
    }
}

- (IBAction)videoAskForPermission:(UIButton *)sender {
    
    if (self.hasAlbumPermissionErr) {
        
    
    __weak typeof(self) weakSelf = self;
    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [weakSelf openSettings];
    }];
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:nil];
    
    NSString *message = @"Unable to read videos. Please give permission for videos.";
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    
    } else {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
            [self videoSelected:self.localVideoBtn];
//            [self cloudVideoSelected:self.cloudVideoBtn];
        } else {
            [self videoSelected:_videoBtn];
        }
        
    }
}

- (IBAction)calendarXAskForPermission:(id)sender {
    if (self.hasCalendarPermissionErr)  {
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [weakSelf openSettings];
        }];
        
        
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:nil];
        
        NSString *message = @"Unable to read calendars. Please give permission for calendars.";
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    } else {
        [self calendarXSelected:self.calBtnX];
    }
}

- (IBAction)calendarAskForPermission:(id)sender {
    if (self.hasCalendarPermissionErr)  {
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [weakSelf openSettings];
        }];
        
        
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:nil];
        
        NSString *message = @"Unable to read calendars. Please give permission for calendars.";
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    } else {
        [self calendarSelected:_calendarBtn];
    }
}

- (IBAction)cloudPhotoCrossAskForPermissions:(id)sender {
    
    
    if (self.hasAlbumPermissionErr)  {
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [weakSelf openSettings];
        }];
        
        
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:nil];
        
        NSString *message = @"Unable to read photos. Please give permission for photos.";
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    } else {
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
            [self cloudPhotSelected:self.cloudPhotoBtn];
        } else {
            [self photSelected:_photoBtn];
        }
        
    }
}
- (IBAction)cloudVideoBackBtnCross:(id)sender {
    
    if (self.hasAlbumPermissionErr) {
        
        
        __weak typeof(self) weakSelf = self;
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Grant Access" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [weakSelf openSettings];
        }];
        
        
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:nil];
        
        NSString *message = @"Unable to read videos. Please give permission for videos.";
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
        
    } else {
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
            [self cloudVideoSelected:self.cloudVideoBtn];
        } else {
            [self videoSelected:_videoBtn];
        }
        
    }

 }

- (NSString*)decodeStringTo64:(NSString*)fromString{
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:fromString options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    return decodedString;
}

//#pragma MARK app terminate handle 
//
//- (void) handleAppWillTerminate {
//    
//    NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERUSERFORCECLOSEEDAPP"];
//    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
//    
//    [asyncSocket writeData:requestData withTimeout:-1.0 tag:VZTagGeneral];
//}


- (void)connectToOtherDevice:(int)portNumber {
    
    NSError *error = nil;
    uint16_t port = portNumber;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    DebugLog(@"IP address is %@",[userDefaults valueForKey:@"RECEIVERIPADDRESS"]);
    
    asyncSocketCOMMPort = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    if ([asyncSocketCOMMPort connectToHost:[userDefaults valueForKey:@"RECEIVERIPADDRESS"] onPort:port withTimeout:20 error:&error])
    {
        DebugLog(@"Unable to connect to due to invalid configuration: %@", error);
    } else {
        DebugLog(@"Connecting...");
    }
}





@end
