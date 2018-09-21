//
//  VZDeviceSelectionVC.m
//  VZTransferSocket
//
//  Created by Prakash Mac on 12/15/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "VZDeviceSelectionVC.h"
#import "CTMVMFonts.h"
#import "VZBumpActionSender.h"
#import "VZBumpActionReceiver.h"
#import "CTMVMDataMeterConstants.h"

#import <ifaddrs.h>
#import <net/if.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "CTNoInternetViewController.h"
#import "VZDeviceMarco.h"
#import "CTMVMLoggingHandler.h"
#import "VZContentTrasnferConstant.h"
#import "CTMVMColor.h"
#import "CTMVMReachability.h"
#import "VZCTProgressView.h"

#import "VZLocalAnalysticsManager.h"
#import "PhotoStoreHelper.h"
#import "NSString+CTContentTransferRootDocuments.h"
#import "CTContentTransferSetting.h"

@import CoreGraphics;

@interface VZDeviceSelectionVC () <UIAlertViewDelegate, ProgressEventDelegate, PhotoStoreDelegate>

@property (nonatomic, assign) BOOL ignoreChecking;
@property (nonatomic, assign) BOOL wifiDisabled;
@property (nonatomic, assign) BOOL alertSent;
@property (nonatomic, assign) BOOL firstLoad;

//@property (strong, nonatomic) NSTimer *timer;
//@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleWidth;

@property (nonatomic, strong) VZCTProgressView *progressView;
@property (nonatomic, strong) UIView *backgroundView;

@property (assign, atomic) NSInteger targetPhotoNumber;
@property (assign, atomic) NSInteger targetVideoNumber;
@property (assign, atomic) NSInteger totalNumber;

@property (nonatomic, strong) PhotoStoreHelper *helper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTop;

@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyBtn;
@property (assign, nonatomic) BOOL firstLayout;
@end

@implementation VZDeviceSelectionVC
@synthesize oldDeviceBtn,notOldDeviceBtn;
@synthesize app;
@synthesize wifiStatus;
@synthesize bluetoothStatus;
@synthesize centralManager;

@synthesize NotOldPhoneLbl,OldPhoneLbl;

@synthesize targetPhotoNumber;
@synthesize targetVideoNumber;
@synthesize totalNumber;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.firstLayout = YES;
        
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kBatteryAlertSent]; // reset alert showed flag when launch content transfer app.
    
    self.NotOldPhoneLbl.font = self.OldPhoneLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
    
#if STANDALONE
    self.whichPhoneLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
    self.whichPhoneLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
#else
    
    self.whichPhoneLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
    self.whichPhoneLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    
#endif
    
    [CTMVMButtons primaryRedButton:self.oldDeviceBtn constrainHeight:YES];
    [CTMVMButtons primaryRedButton:self.notOldDeviceBtn constrainHeight:YES];
    
    self.oldDeviceBtn.alpha = 1.0f;
    
    self.notOldDeviceBtn.alpha = 1.0f;
    
    self.navigationItem.title = kDefaultAppTitle;
    
//    if (![CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject) {
        [CTMVMLoggingHandler setupContentTransferVZAnalytics];
//    }
    
     [self uploadDeviceInfo];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackController:self withName:@"VZDeviceSelectionVC" withExtraInfo:@{} isEncryptedExtras:false];
    
    [self isNetworkAvailable];
    
    // To register with MVM
    [[VZContentTransferSingleton sharedGlobal] registerWithMVM];
    
    self.firstLoad = YES;

    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) { // only iOS version 8 & above support receiver
        // Check unsaved data (photos & videos) from last transfer
        __weak typeof(self) weakSelf = self;
        [self displayUnsavedDataRequestDialogSaving:^(NSString *photoFolder, NSString *videoFolder) {
            // should save unsaved data
            [weakSelf createProgressView:YES completion:^{
                [weakSelf saveFiles:photoFolder videos:videoFolder];
            }];
        } delete:^(NSString *photoFolder, NSString *videoFolder) {
            // should delete unsaved data
            [weakSelf createProgressView:NO completion:^{
                
                [weakSelf deleteFiles:photoFolder videos:videoFolder];
                
                [_progressView becomeFinishView:NO];
                [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(shouldDismissProgressView) userInfo:nil repeats:NO];
            }];
        } noData:^{
            // no unsaved data detected
            [weakSelf checkingAppConditions];
        }];
    } else {
        [self checkingAppConditions];
    }
    
    [self.privacyPolicyBtn setTitle:@"© Privacy Policy" forState:UIControlStateNormal];
    
    [self.privacyPolicyBtn addTarget:self action:@selector(gotoPrivacyPolicy) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_TOTALDOWNLOADEDDATA];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_STARTTIME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_ENDTIME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_isAndriodPlatform];
    
    self.uuid_string = [NSString stringWithFormat:@"%@",[[NSUUID UUID] UUIDString]];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
    self.analyticsData = @{ANALYTICS_TrackAction_Key_TransactionId:self.uuid_string};// Order is important, set this first
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneSelect;
    
    if (!_firstLoad && centralManager == nil) {
        centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                              queue:nil
                                                            options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                                                                forKey:CBCentralManagerOptionShowPowerAlertKey]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkWifiConnectionAgain:) name:CTApplicationDidBecomeActive object:nil];
    
    _firstLoad = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.firstLayout) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) { // UI adaption for iPhones
            CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
            if (screenHeight <= 480) { // IPhone 4 UI resolution.
                self.titleTop.constant = -5.f;
                self.circleTop.constant /= 4;
                
                [self.view layoutIfNeeded];
            }
//
            self.firstLayout = NO;
        }
    }
}

- (void)shouldDismissProgressView {
    [self destoryProgressView:^{
        [self checkingAppConditions];
    }];
}

- (void)createProgressView:(BOOL)saving completion:(void (^)(void))completion
{
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    _backgroundView.backgroundColor = [UIColor darkGrayColor];
    _backgroundView.alpha = 0.4f;
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:_backgroundView];
    
    NSString *text;
    if (saving) {
        text = @"Preparing to save unsaved data.";
    } else {
        text = @"Preparing to delete unsaved data.";
    }
    
    _progressView = [[VZCTProgressView alloc] initWithText:text isSaving:saving];
    if (saving) {
        _progressView.delegate = self;
    }
    _progressView.center = self.view.center;
    
    _progressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:_progressView];
//    [self.view bringSubviewToFront:_progressView];
    
    [UIView animateWithDuration:.25f animations:^{
        _progressView.alpha = 1;
        _progressView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        completion();
    }];
}

- (void)destoryProgressView:(void (^)(void))completion
{
    [UIView animateWithDuration:.25f animations:^{
        _progressView.alpha = 0;
        _backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [_progressView removeFromSuperview];
        [_backgroundView removeFromSuperview];
        
        completion();
    }];
}

- (void)deleteFiles:(NSString *)photoURL videos:(NSString *)videoURL
{
    // Clear file list
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"photoFilteredFileList"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"videoFilteredFileList"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"photoFileList"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"videoFileList"];
    
    // Delete physical files
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSArray *photos = [fm contentsOfDirectoryAtPath:photoURL error:nil];
    NSArray *videos = [fm contentsOfDirectoryAtPath:videoURL error:nil];
    
    int photoDeleteCount = 0;
    for (NSString *file in photos) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", photoURL, file] error:&error];
        if (!success) {
            // Don't need to handle the delete fail, because next time user transfer, folder will be clear
            DebugLog(@"delete failed! Error:%@", error.localizedDescription);
        } else {
            [_progressView updateLbelText:[NSString stringWithFormat:@"Deleted photos : %d / %lu", ++photoDeleteCount, (unsigned long)photos.count] isSaving:NO];
        }
    }
    
    int videoDeleteCount = 0;
    for (NSString *file in videos) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", videoURL, file] error:&error];
        if (!success) {
            // Don't need to handle the delete fail, because next time user transfer, folder will be clear
            DebugLog(@"delete failed! Error:%@", error.localizedDescription);
        } else {
//            DebugLog(@"delete videos:%d/%lu", ++videoDeleteCount, (unsigned long)videos.count);
            [_progressView updateLbelText:[NSString stringWithFormat:@"Delete videos : %d / %lu", ++videoDeleteCount, (unsigned long)videos.count] isSaving:NO];
        }
    }
}

- (void)saveFiles:(NSString *)photoURL videos:(NSString *)videoURL
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray *photos = [fm contentsOfDirectoryAtPath:photoURL error:nil];
    targetPhotoNumber = photos.count;
    
    NSArray *videos = [fm contentsOfDirectoryAtPath:videoURL error:nil];
    targetVideoNumber = videos.count;
    
    if (targetPhotoNumber > 0) {
        totalNumber = targetPhotoNumber;
        
        NSDictionary *photoDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"photoFileList"];
        
        NSMutableArray *photoList = [[NSMutableArray alloc] init];
        for (NSString *fileName in photos) {
            NSMutableDictionary *photoInfo = [(NSDictionary *)[photoDic valueForKey:fileName] mutableCopy];
            if (photoInfo) {
                [photoInfo setObject:fileName forKey:@"Path"];
                [photoList addObject:photoInfo];
            }
        }
        
        // should save photos
//        self.helper = [[PhotoStoreHelper alloc] initWithOperationDelegate:self andRootPath:photoURL andDataSets:photoList, nil];
        self.helper.isCrossPlatform = NO;
        [self.helper startSavingPhotos];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"photoFilteredFileList"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"photoFileList"];
        
        // should save videos
        totalNumber = targetVideoNumber;
        
        NSDictionary *videoDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"videoFileList"];
        
        NSMutableArray *videoList = [[NSMutableArray alloc] init];
        for (NSString *fileName in videos) {
            NSMutableDictionary *videoInfo = [(NSDictionary *)[videoDic valueForKey:fileName] mutableCopy];
            if (videoInfo) {
                [videoInfo setObject:fileName forKey:@"Path"];
                [videoList addObject:videoInfo];
            }
        }
        
        // should save photos
//        self.helper = [[PhotoStoreHelper alloc] initWithOperationDelegate:self andRootPath:videoURL andDataSets:videoList, nil];
        self.helper.isCrossPlatform = NO;
        [self.helper startSavingVideos];
    }
}

- (void)updateDuplicatePhoto:(NSString *)URL withPhotoInfo:(NSDictionary *)photoInfo success:(BOOL)success orError:(NSError *)error
{
    DebugLog(@"->saved:%@", [photoInfo objectForKey:@"Path"]);
    
    // Clear the temp file in the folder for successfully saved photo
    [[NSFileManager defaultManager] removeItemAtPath:URL error:nil];
    
#warning TODO: Should add failed case for continue saving.
    
    @synchronized (self) {
        targetPhotoNumber --;
    }
        
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressView updateLbelText:[NSString stringWithFormat:@"Saving photos: %ld / %ld", totalNumber-targetPhotoNumber, (long)totalNumber] isSaving:YES];
    });
    
    if (targetPhotoNumber == 0) {
        
        // Clear the photo list in local
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"photoFilteredFileList"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"photoFileList"];
        
        if (targetVideoNumber > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *photoFolderPath = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferPhoto"];
                NSString *videoFolderPath = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferVideo"];
                
                [self saveFiles:photoFolderPath videos:videoFolderPath];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_progressView becomeFinishView:YES];
                [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(shouldDismissProgressView) userInfo:nil repeats:NO];
            });
        }
    }
}

- (void)updateDuplicateVideo:(NSString *)URL withVideoInfo:(NSDictionary *)videoInfo success:(BOOL)success orError:(NSError *)error
{
    DebugLog(@"->saved:%@", [videoInfo objectForKey:@"Path"]);
    
    // Clear the temp file in the folder for successfully saved photo
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[NSFileManager defaultManager] removeItemAtPath:URL error:nil];
    });
    
#warning TODO: Should add failed case for continue saving.
    
    @synchronized (self) {
        targetVideoNumber --;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressView updateLbelText:[NSString stringWithFormat:@"Saving videos: %ld / %ld", totalNumber-targetVideoNumber, (long)totalNumber] isSaving:YES];
    });
    
    if (targetVideoNumber == 0) {
        
        // Clear the photo list in local
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"videoFilteredFileList"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"videoFileList"];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_progressView becomeFinishView:YES];
            [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(shouldDismissProgressView) userInfo:nil repeats:NO];
        });
    }
}
- (void)cancelButtonDidClicked
{
    [self.helper stopSaving];
}

- (void)checkingAppConditions
{
    
#if TARGET_OS_SIMULATOR
    //Simulator, Do nothing...
    DebugLog(@"This run in simulator, don't check battery, bluetooth and wifi condition.");
#else
    // Check battery level at the first time load content transfer app.
    [self checkBatteryLow];
    if (self.batteryWarning && !self.charging) { // receive battery warning at beginning, quit the app.
        self.ignoreChecking = YES;
#if STANDALONE
        [self displayAlter:[NSString stringWithFormat:@"Battery level is less than %d%%. Please connect phone to power source.", VZBatteryLimit] withCancelHandler:nil withOtherHandler:0];
#else
        [self displayAlter:[NSString stringWithFormat:@"Battery level is less than %d%%. Please connect phone to power source.", VZBatteryLimit] withCancelHandler:^{
            // close the app
            [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
            
            if([[[[self navigationController]viewControllers]objectAtIndex:0] isKindOfClass:[CTNoInternetViewController class]]) {
                [self.navigationController setNavigationBarHidden:YES animated:NO];
            }
            
            if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            }
            
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
            
        } withOtherHandler:0];
        
#endif
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"batteryAlertSent"];
        self.alertSent = YES;
    }
    
    // battery check pass, should check wifi for both and bluetooth for iphone 5(iOS 8) and above
    if (([VZDeviceMarco isiPhone5Serial] && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        || [VZDeviceMarco isiPhone6AndAbove]) { // Device is iPhone 5(iOS ver 8 and above) and above, check wifi condition
        
        if (![self isWiFiEnabled]) { // if wifi is disable
            self.wifiDisabled = YES;
        }
    } else {
        self.ignoreChecking = YES;
    }
    
    centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                          queue:nil
                                                        options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                                                            forKey:CBCentralManagerOptionShowPowerAlertKey]];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isAndriodPlatform"];
    
#endif
    
}

- (void)checkWifiConnectionAgain:(NSNotification *)notification
{
    if (self.ignoreChecking) {
        return;
    }
    if ([self isWiFiEnabled]) {
        self.wifiDisabled = NO;
        
    } else if (![self isWiFiEnabled]) {
        self.wifiDisabled = YES;
    }
    
    if ([self.bluetoothStatus isEqualToString:@"ON"]) {
        self.bluetoothStatus = @"ON";

    } else {
        self.bluetoothStatus = @"OFF";
    }
}

- (void) uploadDeviceInfo {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    [dict setValue:currSysVer forKey:CONTENT_TRANSFER_OS_VERSION];
    
    VZDeviceMarco *deviceMacro = [[VZDeviceMarco alloc] init];
    
    NSString *deviceModel = [deviceMacro.models objectForKey:[deviceMacro getDeviceModel]];
    
    [dict setValue:deviceModel forKey:CONTENT_TRANSFER_PHONE_MODEL];
    
    [dict setValue:self.uuid_string forKey:@"DeviceUUID"];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_PHONE_HOME_SCREEN withExtraInfo:dict isEncryptedExtras:false];

}

- (BOOL)isWiFiEnabled {
    
    NSCountedSet * cset = [NSCountedSet new];
    
    struct ifaddrs *interfaces;
    
    if(!getifaddrs(&interfaces)) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ((interface->ifa_flags & IFF_UP) == IFF_UP) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    
    BOOL result = [cset countForObject:@"awdl0"] > 1 ? YES : NO;
    freeifaddrs(interfaces);
    
    return result;
}

- (void)displayUnsavedDataRequestDialogSaving:(void(^)(NSString *photoFolder, NSString *videoFolder))save delete:(void(^)(NSString *photoFolder, NSString *videoFolder))delete noData:(void(^)(void))noData {
    
    NSInteger unsavedPhotoNum = 0;
    NSInteger unsavedVideoNum = 0;
    
    NSError *error = nil;
    
    // Check the photo folder
    NSString *photoFolderPath = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferPhoto"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:photoFolderPath]) {
        NSArray * photos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:photoFolderPath error:&error];
        DebugLog(@"has photos:%lu", (unsigned long)photos.count);
        unsavedPhotoNum = photos.count;
    }
    
    // Check the video folder
    NSString *videoFolderPath = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferVideo"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoFolderPath]) {
        NSArray * videos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:videoFolderPath error:&error];
        DebugLog(@"has videos:%lu", (unsigned long)videos.count);
        unsavedVideoNum = videos.count;
    }
    
    if (unsavedPhotoNum > 0 || unsavedVideoNum > 0) {
        
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] init];
        
        NSMutableParagraphStyle *leftParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        [leftParagraphStyle setAlignment:NSTextAlignmentLeft];
        
        NSString *dialogTitle = @"\nContent Transfer";
        
        NSString *title = @"\nDetected unsaved Content from the last transaction. Do you want to save it?";
        [attributedStr appendAttributedString:[self makeAttributed:title withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];
        
        [attributedStr appendAttributedString:[self makeAttributed:[NSString stringWithFormat:@"\n\n•  Photos: %ld", (long)unsavedPhotoNum] withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];
        [attributedStr appendAttributedString:[self makeAttributed:[NSString stringWithFormat:@"\n•  Videos: %ld\n ", (long)unsavedVideoNum] withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];

        if ([UIAlertController class] != nil) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            [alert setValue:[self makeAttributed:dialogTitle withFont:[CTMVMFonts mvmBoldFontOfSize:16.f] style:nil] forKey:@"attributedTitle"];
            [alert setValue:attributedStr forKey:@"attributedMessage"];
            
            UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDestructive
                                                               handler:^(UIAlertAction * _Nonnull action) {
                                                                   save(photoFolderPath, videoFolderPath);
                                                               }];
            UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     delete (photoFolderPath, videoFolderPath);
                                                                 }];
            
            [alert addAction:saveAction];
            [alert addAction:deleteAction];
            [alert setModalPresentationStyle:UIModalPresentationPopover];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { // only setup for iPad
                alert.popoverPresentationController.sourceView = self.view;
                alert.popoverPresentationController.sourceRect = CGRectMake(self.view.center.x, [[UIScreen mainScreen] bounds].size.height - 50, 1, 1);
                alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
            }
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        noData();
    }
}

- (NSAttributedString *)makeAttributed:(NSString *)message withFont:(UIFont *)font style:(NSParagraphStyle *)style {
    
    NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc]initWithString:message];
    if (style) {
        [attribString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [message length])];
    }
    [attribString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [message length])];
    
    return attribString;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTApplicationDidBecomeActive object:nil];
    
    self.centralManager = nil;
//    self.ignoreBluetoothChecking = YES;
}

- (void)checkBatteryLow
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO]; // DON'T ASK ME WHY
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    float percentage = [[UIDevice currentDevice] batteryLevel]; // Get battery level of the device, max:1.0f
    if (percentage <= 0.25f) {
        self.batteryWarning = YES;
    } else {
        self.batteryWarning = NO;
    }
    
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) { // using battery
        self.charging = NO;
    } else {
        self.charging = YES;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)oldDeviceSelected:(id)sender {
    
    NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneSelect, ANALYTICS_TrackAction_Name_Button_Old);
    [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Name_Button_Old
                                 data:@{ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Name_Button_Old,ANALYTICS_TrackAction_Key_SenderReceiver:ANALYTICS_TrackAction_Value_SenderReceiver_Sender,
                                        ANALYTICS_TrackAction_Key_PageLink:pageLink}];
    
#if STANDALONE
    if (self.batteryWarning && !self.charging) {
        [self displayAlter:[NSString stringWithFormat:@"Battery level is less than %d%%. Please connect phone to power source.", VZBatteryLimit] withCancelHandler:nil withOtherHandler:0];
        return;
    } else
#endif
    if ([self.bluetoothStatus isEqualToString:@"ON"] && self.wifiDisabled) {
        
        [self displayAlter:@"Please turn on the WiFi and turn off the bluetooth." withCancelHandler:nil withOtherHandler:3];
        return;
    } else if ([self.bluetoothStatus isEqualToString:@"ON"]) {
        
        [self displayAlter:@"Please turn off the bluetooth." withCancelHandler:nil withOtherHandler:2];
        return;
    } else if (self.wifiDisabled) {
        
        [self displayAlter:@"Please turn on the WiFi and turn off the airplane mode." withCancelHandler:nil withOtherHandler:1];
        return;
    }
    
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
    
    [infoDict setValue:self.wifiStatus forKey:@"WifiStatus"];
    [infoDict setValue:self.bluetoothStatus forKey:@"BluetoothStatus"];
    [infoDict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
    [infoDict setValue:@"Sender" forKey:@"TransferType"];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"PhoneSelectionScreen" withExtraInfo:infoDict isEncryptedExtras:false];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault setValue:@"OldDevice" forKey:@"DeviceType"];
    
    [[VZLocalAnalysticsManager sharedInstance] sender];
    
    [self performSegueWithIdentifier:@"goto_next_segue" sender:sender];
}

- (IBAction)newDeviceSelected:(id)sender {
    
    NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneSelect, ANALYTICS_TrackAction_Name_Button_New);

    [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Name_Button_New
                                 data:@{ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Name_Button_New,ANALYTICS_TrackAction_Key_SenderReceiver:ANALYTICS_TrackAction_Value_SenderReceiver_Receiver,
                                        ANALYTICS_TrackAction_Key_PageLink:pageLink}];


    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        [self displayAlter:@"This device cannot receive content." withCancelHandler:nil withOtherHandler:0];
        return;
    }
    
#if STANDALONE
    if (self.batteryWarning && !self.charging) {
        [self displayAlter:[NSString stringWithFormat:@"Battery level is less than %d%%. Please connect phone to power source.", VZBatteryLimit] withCancelHandler:nil withOtherHandler:0];
        return;
    } else
#endif
    if ([self.bluetoothStatus isEqualToString:@"ON"] && self.wifiDisabled) {
        
        [self displayAlter:@"Please turn on the WiFi and turn off the bluetooth." withCancelHandler:nil withOtherHandler:3];
        return;
    } else if ([self.bluetoothStatus isEqualToString:@"ON"]) {
        
        [self displayAlter:@"Please turn off the bluetooth." withCancelHandler:nil withOtherHandler:2];
        return;
    } else if (self.wifiDisabled) {
        
        [self displayAlter:@"Please turn on the WiFi or turn off the airplane mode." withCancelHandler:nil withOtherHandler:1];
        return;
    }
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_NEWDDEVICE];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault setValue:@"NewDevice" forKey:@"DeviceType"];
    
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
    
    [infoDict setValue:self.wifiStatus forKey:@"WifiStatus"];
    [infoDict setValue:self.bluetoothStatus forKey:@"BluetoothStatus"];
    [infoDict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
    [infoDict setValue:@"Receiver" forKey:@"TransferType"];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"PhoneSelectionScreen" withExtraInfo:infoDict isEncryptedExtras:false];
    
    [[VZLocalAnalysticsManager sharedInstance] receiver];
    
    [self performSegueWithIdentifier:@"goto_next_segue" sender:sender];
}


- (BOOL)isNetworkAvailable
{
     self.wifiStatus = @"OFF";
    
    if ([[CTMVMReachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi) {
        
        self.wifiStatus = @"ON";
    }
    
    return NO ;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central { // Blue tooth check delegate
    if (self.ignoreChecking && self) {
        return;
    }
    
    if (self.alertSent) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            self.bluetoothStatus = @"ON";
            
        } else if(central.state == CBCentralManagerStatePoweredOff) {
            self.bluetoothStatus = @"OFF";
        }
        
        return;
    }
    
    self.alertSent = YES; // first check in viewDidLoad
    if (central.state == CBCentralManagerStatePoweredOn) {
        if (self.wifiDisabled) {
            // alert for wifi & bluetooth setting
            [self displayAlter:@"Please turn on the WiFi and turn off the bluetooth." withCancelHandler:nil withOtherHandler:3];
        } else {
            // bluetooth setting
            [self displayAlter:@"Please turn off the bluetooth." withCancelHandler:nil withOtherHandler:2];
        }
        
        self.bluetoothStatus = @"ON";
    } else if(central.state == CBCentralManagerStatePoweredOff) {
        self.bluetoothStatus = @"OFF";
        
        if (self.wifiDisabled) {
            // wifi setting
            [self displayAlter:@"Please turn on the WiFi and turn off the airplane mode." withCancelHandler:nil withOtherHandler:1];
        }

    }
}

- (IBAction)checkAppVersion:(UIButton *)sender {

    [self displayAlter:[NSString stringWithFormat:@"Build Version: %@\n Date: 08/30/2016",BUILD_VERSION] withCancelHandler:nil withOtherHandler:0];
}

- (void)displayAlter:(NSString *)str withCancelHandler:(void (^)())handler withOtherHandler:(NSInteger)flag
{
    if ([UIAlertController class] != nil) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Content Transfer"
                                                                       message:str
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        __weak typeof(self) weakSelf = self;
        UIAlertAction *okAction = nil;
        if (flag == 1) { // turn on wifi
            okAction = [UIAlertAction actionWithTitle:@"Turn on" style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action) {
                                                  [weakSelf openWifiSettings];
                                              }];

        } else if (flag == 2) { // turn on bluetooth
            okAction = [UIAlertAction actionWithTitle:@"Turn off" style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action) {
                                                  [weakSelf openBluetoothSettings];
                                              }];
        } else if (flag == 3) { // turn on both
            okAction = [UIAlertAction actionWithTitle:@"Go to Setting" style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action) {
                                                  [weakSelf openRootSettings];
                                              }];
        }
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * action) {
                                                                  if (handler != nil) {
                                                                      handler();
                                                                  }
                                                              }];
        
        
        if (okAction != nil) {
            [alert addAction:okAction];
        }
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertView *alert;
        if (flag == 0) {
            alert = [[UIAlertView alloc] initWithTitle:@"Content Transfer"
                                               message:str
                                              delegate:self
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            alert.tag = 0;
        } else if (flag == 1) { // turn on wifi
            alert = [[UIAlertView alloc] initWithTitle:@"Content Transfer"
                                               message:str
                                              delegate:self
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:@"Turn on", nil];
            alert.tag = 1;
        } else if (flag == 2) { // turn on bluetooth
            alert = [[UIAlertView alloc] initWithTitle:@"Content Transfer"
                                               message:str
                                              delegate:self
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:@"Turn off", nil];
            alert.tag = 2;
        } else if (flag == 3) { // turn on both
            alert = [[UIAlertView alloc] initWithTitle:@"Content Transfer"
                                               message:str
                                              delegate:self
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:@"Go to Setting", nil];
            alert.tag = 3;
        }
        
        if (handler != nil) {
            alert.restorationIdentifier = @"CancelHandler";
        }
        
        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 0) {
        if ([alertView.restorationIdentifier isEqualToString:@"CancelHandler"]) {
            // close the app
            [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
            
            if([[[[self navigationController]viewControllers]objectAtIndex:0] isKindOfClass:[CTNoInternetViewController class]]) {
                [self.navigationController setNavigationBarHidden:YES animated:NO];
            }
            
            if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            }
            
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
        }
    } else {
        if (alertView.tag == 1) { // turn on wifi
            [self openWifiSettings];
        } else if (alertView.tag == 2) { // turn on bluetooth
            [self openBluetoothSettings];
        } else if (alertView.tag == 3) { // turn on both
            [self openRootSettings];
        }
    }
}

- (void)openWifiSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
}

- (void)openBluetoothSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
}

- (void)openRootSettings
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Settings"]];
}

- (void) gotoPrivacyPolicy{

    [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:@"http://www.verizon.com/about/privacy/privacy-policy-summary"]];
}


@end
