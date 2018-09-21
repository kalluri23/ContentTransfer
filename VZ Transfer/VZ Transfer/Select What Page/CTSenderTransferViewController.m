//
//  CTTransferSenderViewController.m
//  contenttransfer
//
//  Created by Development on 8/16/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTBundle.h"
#import "CTCustomTableViewCell.h"
#import "CTSenderTransferTableViewCell.h"
#import "CTSenderProgressViewController.h"
#import "CTSenderTransferViewController.h"
#import "CTTransferInProgressViewController.h"
#import "CTContactsManager.h"
#import "NSString+CTMVMConvenience.h"
#import "CTEventStoreManager.h"
#import "CTPhotosManager.h"
#import "CTProgressHUD.h"
#import "CTFileManager.h"
#import "NSMutableDictionary+CTMVMConvenience.h"
#import "UIViewController+Convenience.h"
#import "CTStartedViewController.h"
#import "CTBonjourManager.h"
#import "CTDeviceSelectionViewController.h"
#import "CTErrorViewController.h"
#import "CTStoryboardHelper.h"
#import "CTColor.h"
#import "CTNetworkUtility.h"
#import "CTAlertCreateFactory.h"
#import "CTSettingsUtility.h"
#import "CTLocalAnalysticsManager.h"
#import "CTSenderPinViewController.h"
#import "NSString+CTHelper.h"
#import "CTDataCollectionManager.h"
#import "CTCustomAlertView.h"
#import "CTMVMAlertHandler.h"
#import "CTAudiosManager.h"
#import "CTFileList.h"
#import "UILabel+CTLabelAdjust.h"
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

/*! @brief enum type for total number of items will be loaded.*/
enum CTLoadingItemNumber : int {
    /*! Total items for iOS to iOS.*/
    CTLoadingItemNumberForiOS = 5,
    /*! Total items for cross platform.*/
    CTLoadingItemNumberForAndroid = 5
};
/*! 
    @brief Mask for each type of the content.
    @discussion In total 6(000000/0x0) digits will be used; 0 represent not finish, 1 represent finished.
                Right to left either represent contacts, reminders, calendars, photos, videos and commsocket
 */
enum CTCollectingMask : NSInteger {
    /*! Represent contact, value is 0x1, 000001 in binary.*/
    CTCollectingContactMask  = 0x1,
    /*! Represent reminder, value is 0x2, 000010 in binary.*/
    CTCollectingReminderMask = CTCollectingContactMask  << 1,
    /*! Represent calendar, value is 0x4, 000100 in binary.*/
    CTCollectingCalendarMask = CTCollectingReminderMask << 1,
    /*! Represent photo, value is 0x8, 001000 in binary.*/
    CTCollectingPhotoMask    = CTCollectingCalendarMask << 1,
    /*! Represent video, value is 0x10, 010000 in binary.*/
    CTCollectingVideoMask    = CTCollectingPhotoMask    << 1,
    /*! Represent commport check, value is 0x20, 100000 in binary.*/
    CTCollectingCommPortMask = CTCollectingVideoMask    << 1,
    /*! Represent audio, value is 0x40, 1000000 in binary.*/
    CTCollectingAudioMask    = CTCollectingCommPortMask << 1,
    /*! Represent all check pass, value is 0x7F, 1111111 in binary.*/
    CTCollectingAllMask      = 0x7F,
    /*! Reset mask, value is 0x0, 0000000 in binary.*/
    CTCollectingResetMask    = 0x0
};
/*!
    @brief Mask for selection.
    @discussion In total 5(000000/0x0) digits will be used; 0 represent not selected, 1 represent selected.
                Right to left represents contacts, photos, videos, calendars, reminder/audios.
 */
enum CTSelectionMask : NSInteger {
    /*! Contact selection mask, value is 0x1, 0000001 in binary.*/
    CTSelectionContactMask         = 0x1,
    /*! Photo selection mask, value is 0x2, 000010 in binary.*/
    CTSelectionPhotoMask           = CTSelectionContactMask  << 1,
    /*! Video selection mask, value is 0x4, 000100 in binary.*/
    CTSelectionVideoMask           = CTSelectionPhotoMask    << 1,
    /*! Calendar selection mask, value is 0x8, 001000 in binary.*/
    CTSelectionCalendarMask        = CTSelectionVideoMask    << 1,
    /*! Reminder selection mask, value is 0x10, 010000 in binary.*/
    CTSelectionReminderOrAudioMask = CTSelectionCalendarMask << 1,
    /*! Select all mask, value is 0x1F, 111111 in binary.*/
    CTSelectionAllMask             = 0x1F,
    /*! Reset selection mask, value is 0x0, 000000 in binary.*/
    CTSelectionResetMask           = 0x0
};

static bool isAllSelected = NO;
static int numberOfPermissionsGiven = 0;

@interface CTSenderTransferViewController () <UITableViewDelegate, UITableViewDataSource, PhotoManagerDelegate,GCDAsyncSocketDelegate,updatePhotoAndVideoNumbersDelegate, CTCommPortSocketGeneralDelegate, UIGestureRecognizerDelegate>{
    /*! Select item list global prarmeter.*/
//    NSMutableDictionary *selectedItems;
    CTFileList *fileList;
}

/*! Mask for hide user interaction block, default value will be 0, means 00000 for cross-platform and 000000 for iOS to iOS; This will make sure every item will be count once.*/
@property (nonatomic, assign) NSInteger blockMask;
/*! Mask for check if user select all or not, default value will be 0, means 0000; This will make sure every item will be count once.*/
@property (nonatomic, assign) NSInteger selectMask;

/*! 
    @brief Indicator using for select what page.
    @see CTProgressHUD
 */
@property (nonatomic, strong) CTProgressHUD *activityIndicator;

@property (nonatomic, weak) UILabel *photoNumberLbl;
@property (nonatomic, weak) UILabel *videoNumberLbl;
@property (nonatomic, weak) UILabel *photoCloudLbl;
@property (nonatomic, weak) UILabel *videoCloudLbl;
@property (nonatomic, weak) UILabel *calendarNumberLbl;
@property (nonatomic, weak) UILabel *reminderNumberLbl;
@property (nonatomic, weak) UILabel *audioNumberLbl;
@property (nonatomic, weak) UILabel *contactsNumberLbl;
@property (nonatomic, weak) UILabel *photoDataSizeLbl;
@property (nonatomic, weak) UILabel *videoDataSizeLbl;
@property (nonatomic, weak) UILabel *calendarDataSizeLbl;
@property (nonatomic, weak) UILabel *reminderDataSizeLbl;
@property (nonatomic, weak) UILabel *audioDataSizeLbl;
@property (nonatomic, weak) UILabel *contactsDataSizeLbl;

@property (nonatomic, strong) CTErrorViewController *errorViewController;
/*! Global alert view for sender transfer what page.*/
@property (nonatomic, strong) CTCustomAlertView *alertView;
@property (nonatomic, strong) NSOperationQueue *asyncOperationQueue;

@property (nonatomic, assign) BOOL waitTillContactCompleteDataIsCollected;
@property (nonatomic, assign) BOOL waitTillPhotoCompleteDataIsCollected;
@property (nonatomic, assign) BOOL waitTillVideoCompleteDataIsCollected;
@property (nonatomic, assign) BOOL waitTillCalendarCompleteDataIsCollected;
@property (nonatomic, assign) BOOL waitTillReminderCompleteDataIsCollected;
@property (nonatomic, assign) BOOL waitTillAudioCompleteDataIsCollected;
/*! Indicate that user clicked transfer button.*/
@property (nonatomic, assign) BOOL userClickedTransferBtn;
/*! BOOL value indicate that contact selected or not. Default is NO.*/
@property (nonatomic, assign) BOOL contactSelected;
/*! BOOL value indicate that photo selected or not. Default is NO.*/
@property (nonatomic, assign) BOOL photoSelected;
/*! BOOL value indicate that video selected or not. Default is NO.*/
@property (nonatomic, assign) BOOL videoSelected;
/*! BOOL value indicate that calender selected or not. Default is NO.*/
@property (nonatomic, assign) BOOL calendarSelected;
/*! BOOL value indicate that reminder selected or not. Default is NO.*/
@property (nonatomic, assign) BOOL reminderSelected;
/*! BOOL value indicate that audio selected or not. Default is NO.*/
@property (nonatomic, assign) BOOL audioSelected;
/*! Index that indicate which cell's third label button is clicked.*/
@property (nonatomic, assign) NSInteger thirdButtonCurrentClicked;

@end

@implementation CTSenderTransferViewController

#pragma mark - Lazy loading
- (CTProgressHUD *)activityIndicator {
    if (![[self.view subviews] containsObject:_activityIndicator]) {
        _activityIndicator = [[CTProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_activityIndicator];
        [self.view bringSubviewToFront:_activityIndicator];
    }
    
    return _activityIndicator;
}

#pragma mark - UIViewController lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // clear
    [CTUserDefaults sharedInstance].tempPhotoLists = @[];
    [CTUserDefaults sharedInstance].tempVideoLists = @[];
    
    [CTUserDefaults sharedInstance].numberOfPhotosReceived = 0;
    [CTUserDefaults sharedInstance].numberOfVideosReceived = 0;
    
    // Do any additional setup after loading the view.
//    selectedItems = [NSMutableDictionary new];
    fileList = [[CTFileList alloc] initFileList];
    
    self.iCloudInfoLabel.textColor = [CTMVMColor mvmPrimaryRedColor];
    
    // Show spinner and disable the user interactions
//    [self.activityIndicator showAnimated:YES];
    
    // Initial the mask
    self.blockMask = CTCollectingResetMask;
    if ([[CTUserDevice userDevice].pairingType isEqualToString:kBonjour]) { // If it's Bonjour, there is no commport, set it to 1 as default
        self.blockMask |= CTCollectingCommPortMask;
    }
    
    self.selectMask = CTSelectionResetMask;
    
#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
#endif
    
    NSAssert(self.transferItemsTableView, @"transferItemsTableView can't be nil, check UI implementation");
    NSAssert(self.transferItemsTableView.dataSource,
             @"transferItemsTableView data source can't be nil, check UI implementation");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitContentTransfer:) name:CT_NOTIFICATION_EXIT_CONTENT_TRANSFER object:nil];
    self.asyncOperationQueue = [[NSOperationQueue alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestToCancelAllOperation) name:@"CANCEL_ALL_OPERATION" object:nil];
    
#ifdef DEBUG
    // Add observer for mask (Debug)
    [self addObserver:self forKeyPath:@"selectMask" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"blockMask"  options:NSKeyValueObservingOptionNew context:nil];
#endif
    
    [CTDataCollectionManager sharedManager].delegate = self;
    
    [self setInitialWaitingFlags];
    self.userClickedTransferBtn = NO;
    
    self.transferItemsTableView.tableFooterView = [UIView new]; // Hide extra seperator.

    [self.transferItemsTableView registerNib:[UINib nibWithNibName:@"CTSenderTransferTableViewCell" bundle:[CTBundle resourceBundle]] forCellReuseIdentifier:@"CTSenderTransferTableViewCell"];
    [self.selectionButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    // Add tap recognizer, this is for tap the button on uitableview cell.
    UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    [tap setMinimumPressDuration:0];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([CTDeviceMarco isiPhone4AndBelow]) {
        self.primaryLabelTopSpace.constant = 10.0;
        self.seperatorViewTopSpace.constant = 10.0;
        self.selectAllButtonTopSpace.constant = 10.0;
        [self.selectionButton.titleLabel setFont:[CTMVMFonts mvmBookFontOfSize:13.0]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P]) {
        self.commAsyncSocket = [[CTCommPortClientSocket alloc] initWithHost:self.readSocket.connectedHost andDelegate:self];
    }
    
    [self checkDataCollectionStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CT_NOTIFICATION_EXIT_CONTENT_TRANSFER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CANCEL_ALL_OPERATION" object:nil];
    
#ifdef DEBUG
    [self removeObserversForDebug];
#endif
}

#pragma mark - UITableView datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.frame.size.height / (CGFloat)CTTransferItemsTableBreakDown_Total;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
        return CTLoadingItemNumberForiOS;
    } else {
#if NO_LEGAL_ISSUE_WITH_MUSIC
        return CTLoadingItemNumberForAndroid;
#else
        self.selectMask |= CTSelectionReminderOrAudioMask;
        return CTLoadingItemNumberForAndroid - 1;
#endif
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CTSenderTransferTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTSenderTransferTableViewCell" forIndexPath:indexPath];
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f); // Hide last cell's seperator also.
    }
    
    __weak typeof(self) weakSelf = self;
    switch (indexPath.row) {
        case CTTransferItemsTableBreakDown_Contacts: {
            self.contactsNumberLbl = cell.primaryLabel;
            self.contactsDataSizeLbl = cell.secondaryLabel;
            
            cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_CONTACTS, nil) WithCount: -1];
            cell.secondaryLabel.text = CTLocalizedString(CT_COLLECTING_CELL_SEC_LABEL, nil);

            if ([CTContactsManager contactsAuthorizationStatus] == CTAuthorizationStatusAuthorized) {
                // Add button for contacts
                cell.thirdLabel.hidden = NO;
                cell.thirdLabel.text = CTLocalizedString(kMoreInfoButtonTitle, nil);
                [cell simulateThirdLabelAsAButton];

                numberOfPermissionsGiven++;

                if ([CTDataCollectionManager sharedManager].isCollectingContactsCompleted) {
                    cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_CONTACTS, nil) WithCount:[CTDataCollectionManager sharedManager].getNumberOfContacts];
                    cell.secondaryLabel.text = [NSString formattedDataSizeTextInTransferWhatScreen:[CTDataCollectionManager sharedManager].getSizeOfContacts];
                    [fileList initItem:METADATA_ITEMLIST_KEY_CONTACTS withCount:[CTDataCollectionManager sharedManager].getNumberOfContacts withSize:[CTDataCollectionManager sharedManager].getSizeOfContacts];
                    if([CTDataCollectionManager sharedManager].getNumberOfContacts == 0) {
                        self.selectMask |= CTSelectionContactMask; // If no contacts found, set contact bit to 1;
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_CONTACTS, nil) WithCount:0];
                    cell.secondaryLabel.textColor = [CTColor primaryRedColor];
                    cell.secondaryLabel.text = CTLocalizedString(CT_PERMISSION_NOT_GRANTED_SEC_LABEL, nil);
                    [cell enableUserInteraction:YES];

                    self.blockMask |= CTCollectingContactMask;
                    self.selectMask |= CTSelectionContactMask;

                    NSLog(@"contact no permisson check!");
                    [weakSelf stopIndicator];
                    [fileList initItem:METADATA_ITEMLIST_KEY_CONTACTS withCount:0 withSize:0];
//                    [weakSelf setItem:METADATA_ITEMLIST_KEY_CONTACTS withCount:0 withSize:0];
                });
            }


        } break;

        case CTTransferItemsTableBreakDown_Photos: {

            cell.thirdLabel.textColor = [CTColor primaryRedColor];

            if ([CTPhotosManager photoLibraryAuthorizationStatus] == CTAuthorizationStatusAuthorized) {
                numberOfPermissionsGiven++;
                self.photoNumberLbl = cell.primaryLabel;
                self.photoDataSizeLbl = cell.secondaryLabel;
                self.photoCloudLbl = cell.thirdLabel;
                cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_PHOTOS, nil) WithCount:0];
                cell.secondaryLabel.text = CTLocalizedString(CT_COLLECTING_CELL_SEC_LABEL, nil);
//                [weakSelf setItem:METADATA_ITEMLIST_KEY_PHOTOS withCount:0 withSize:0];
                [fileList initItem:METADATA_ITEMLIST_KEY_PHOTOS withCount:0 withSize:0];

                [[CTDataCollectionManager sharedManager].photoManager getCameraRollPhotosCount:^(NSInteger photoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotos) {
                    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) { // IF X-PLATFORM, SHOW LOCAL + FULLY DOWNLOADED ICLOUD PHOTOS
                        cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_PHOTOS, nil) WithCount:photoCount + streamCount];
                    } else { // IOS TO IOS, ONLY SHOW LOCAL PHOTOS
                        cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_PHOTOS, nil) WithCount:photoCount];
                    }

                    cell.secondaryLabel.text = CTLocalizedString(CT_COLLECTING_CELL_SEC_LABEL, nil);

                    if (((unavailableCount > 0) || (streamCount > 0)) && !isAllPhotos) {

                        NSInteger totalPhotoCloudNumber = 0;
                        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
                            totalPhotoCloudNumber = unavailableCount + streamCount;
                        } else {
                            totalPhotoCloudNumber = unavailableCount;
                        }

                        if (totalPhotoCloudNumber > 0) {
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"VZTRANSFER_HAS_CLOUD_PHOTO"];
                            cell.thirdLabel.text = [NSString stringWithFormat:CTLocalizedString(CT_IN_ICLOUD_TER_LABEL, nil), (long)totalPhotoCloudNumber];
                            cell.thirdLabel.hidden = NO;
                            weakSelf.iCloudInfoLabel.hidden = NO;
                        } else {
                            cell.thirdLabel.hidden = YES;
                        }
                    } else {
                        cell.thirdLabel.hidden = YES;
                    }

                    if (photoCount == 0) {
//                        self.totalNonZeroiTems++;
                        self.selectMask |= CTSelectionPhotoMask;
                    }

                    self.blockMask |= CTCollectingPhotoMask;
                    NSLog(@"photo finish check!");
                    [weakSelf stopIndicator];
                }];
            } else {
                cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_PHOTOS, nil) WithCount:0];
                cell.secondaryLabel.textColor = [CTColor primaryRedColor];
                cell.secondaryLabel.text = CTLocalizedString(CT_PERMISSION_NOT_GRANTED_SEC_LABEL, nil);
                cell.userInteractionEnabled = YES;

                self.selectMask |= CTSelectionPhotoMask;

//                [weakSelf setItem:METADATA_ITEMLIST_KEY_PHOTOS withCount:0 withSize:0];
                [fileList initItem:METADATA_ITEMLIST_KEY_PHOTOS withCount:0 withSize:0];
            }
        } break;

        case CTTransferItemsTableBreakDown_Videos: {

            cell.thirdLabel.textColor = [CTColor primaryRedColor];

            if ([CTPhotosManager photoLibraryAuthorizationStatus] == CTAuthorizationStatusAuthorized) {

                numberOfPermissionsGiven++;

                self.videoNumberLbl = cell.primaryLabel;
                self.videoDataSizeLbl = cell.secondaryLabel;
                self.videoCloudLbl = cell.thirdLabel;
                cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_VIDEOS, nil) WithCount:0];
                cell.secondaryLabel.text = CTLocalizedString(CT_COLLECTING_CELL_SEC_LABEL, nil);
//                [weakSelf setItem:METADATA_ITEMLIST_KEY_VIDEOS withCount:0 withSize:0];
                [fileList initItem:METADATA_ITEMLIST_KEY_VIDEOS withCount:0 withSize:0];

                [[CTDataCollectionManager sharedManager].photoManager getCameraRollVideoCount:^(NSInteger videoCount,NSInteger streamVideoCount,NSInteger unavailableVideoCount, BOOL isAllPhotos) {

                    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) { // IF X-PLATFORM, SHOW LOCAL + FULLY DOWNLOADED ICLOUD VIDEOS
                        cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_VIDEOS, nil) WithCount:videoCount + streamVideoCount];
                    } else { // IOS TO IOS, ONLY SHOW LOCAL VIDEOS
                        cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_VIDEOS, nil) WithCount:videoCount];
                    }
                    cell.secondaryLabel.text = CTLocalizedString(CT_COLLECTING_CELL_SEC_LABEL, nil);
                    
                    if (((unavailableVideoCount > 0) || (streamVideoCount > 0)) && !isAllPhotos) {
                        NSInteger totalPhotoCloudNumber = 0;
                        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
                            totalPhotoCloudNumber = unavailableVideoCount + streamVideoCount;
                        }else {
                            totalPhotoCloudNumber = unavailableVideoCount;
                        }

                        if (totalPhotoCloudNumber > 0) {
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"VZTRANSFER_HAS_CLOUD_VIDEO"];
                            cell.thirdLabel.text = [NSString stringWithFormat:CTLocalizedString(CT_IN_ICLOUD_TER_LABEL, nil), (long)totalPhotoCloudNumber];
                            cell.thirdLabel.hidden = NO;
                            weakSelf.iCloudInfoLabel.hidden = NO;
                        } else {
                            cell.thirdLabel.hidden = YES;
                        }
                    } else {
                        cell.thirdLabel.hidden = YES;
                    }

                    if (videoCount == 0) {
//                        self.totalNonZeroiTems++;
                        self.selectMask |= CTSelectionVideoMask;
                    }

                    self.blockMask |= CTCollectingVideoMask;
                    NSLog(@"video finish check!");
                    [weakSelf stopIndicator];
                }];
            } else {
                cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_VIDEOS, nil) WithCount:0];
                cell.secondaryLabel.textColor = [CTColor primaryRedColor];
                cell.secondaryLabel.text = CTLocalizedString(CT_PERMISSION_NOT_GRANTED_SEC_LABEL, nil);
                cell.userInteractionEnabled = YES;

                self.selectMask |= CTSelectionVideoMask;

//                [weakSelf setItem:METADATA_ITEMLIST_KEY_VIDEOS withCount:0 withSize:0];
                [fileList initItem:METADATA_ITEMLIST_KEY_VIDEOS withCount:0 withSize:0];
            }

        } break;

        case CTTransferItemsTableBreakDown_Calenders: {

            if ([CTEventStoreManager calendarAuthorizationStatus] == CTAuthorizationStatusAuthorized) {

                numberOfPermissionsGiven++;

                self.calendarNumberLbl = cell.primaryLabel;
                self.calendarDataSizeLbl = cell.secondaryLabel;

                cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_CALENDERS, nil) WithCount:-1];
                cell.secondaryLabel.text = CTLocalizedString(CT_COLLECTING_CELL_SEC_LABEL, nil);

                if ([CTDataCollectionManager sharedManager].isCollectingCalendarsCompleted) {
//                    [self setItem:METADATA_ITEMLIST_KEY_CALENDARS withCount:[CTDataCollectionManager sharedManager].getNumberOfCalendars  withSize:[CTDataCollectionManager sharedManager].getSizeOfCalendars];
                    [fileList initItem:METADATA_ITEMLIST_KEY_CALENDARS withCount:[CTDataCollectionManager sharedManager].getNumberOfCalendars withSize:[CTDataCollectionManager sharedManager].getSizeOfCalendars];
                    cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_CALENDERS, nil) WithCount:[CTDataCollectionManager sharedManager].getNumberOfCalendars];
                    cell.secondaryLabel.text = [NSString formattedDataSizeTextInTransferWhatScreen:[CTDataCollectionManager sharedManager].getSizeOfCalendars];
                    if ([CTDataCollectionManager sharedManager].getNumberOfCalendars == 0) {
//                        weakSelf.totalNonZeroiTems++;
                        self.selectMask |= CTSelectionCalendarMask;
                    }

                } else {
//                    [weakSelf setItem:METADATA_ITEMLIST_KEY_CALENDARS withCount:0  withSize:0];
                    [fileList initItem:METADATA_ITEMLIST_KEY_CALENDARS withCount:0 withSize:0];
                }
            } else {
                cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_CALENDERS, nil) WithCount:0];
                cell.secondaryLabel.textColor = [CTColor primaryRedColor];
                cell.secondaryLabel.text = CTLocalizedString(CT_PERMISSION_NOT_GRANTED_SEC_LABEL, nil);
                cell.userInteractionEnabled = YES;

                self.blockMask |= CTCollectingCalendarMask;
                self.selectMask |= CTSelectionCalendarMask;

                NSLog(@"calendar permission check!");
                [weakSelf stopIndicator];
//                [weakSelf setItem:METADATA_ITEMLIST_KEY_CALENDARS withCount:0  withSize:0];
                [fileList initItem:METADATA_ITEMLIST_KEY_CALENDARS withCount:0 withSize:0];
            }
        } break;

        case CTTransferItemsTableBreakDown_RemindersOrAudios: {

            if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
                // iOS to iOS should be reminder
                if ([CTEventStoreManager reminderAuthorizationStatus] == CTAuthorizationStatusAuthorized) {

                    numberOfPermissionsGiven++;

                    self.reminderNumberLbl = cell.primaryLabel;
                    self.reminderDataSizeLbl = cell.secondaryLabel;

                    cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_REMINDERS, nil) WithCount:-1];
                    cell.secondaryLabel.text = CTLocalizedString(CT_COLLECTING_CELL_SEC_LABEL, nil);

                    if ([CTDataCollectionManager sharedManager].isCollectingReminderCompleted) {
                        [fileList initItem:METADATA_ITEMLIST_KEY_REMINDERS withCount:[CTDataCollectionManager sharedManager].getNumberOfReminders withSize:[CTDataCollectionManager sharedManager].getSizeOfReminders];
                        cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_REMINDERS, nil) WithCount:[CTDataCollectionManager sharedManager].getNumberOfReminders];
                        cell.secondaryLabel.text = [NSString formattedDataSizeTextInTransferWhatScreen:[CTDataCollectionManager sharedManager].getSizeOfReminders];
                        if ([CTDataCollectionManager sharedManager].getNumberOfReminders == 0) {
//                            self.totalNonZeroiTems++;
                            self.selectMask |= CTSelectionReminderOrAudioMask;
                        }
                    } else {
                        [fileList initItem:METADATA_ITEMLIST_KEY_REMINDERS withCount:0 withSize:0];
                    }
                } else {
                    cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_REMINDERS, nil) WithCount:0];
                    cell.secondaryLabel.textColor = [CTColor primaryRedColor];
                    cell.secondaryLabel.text = CTLocalizedString(CT_PERMISSION_NOT_GRANTED_SEC_LABEL, nil);
                    cell.userInteractionEnabled = YES;

                    self.blockMask |= CTCollectingReminderMask;
                    self.selectMask |= CTSelectionReminderOrAudioMask;

                    NSLog(@"reminder permission check!");
                    [weakSelf stopIndicator];
//                    [weakSelf setItem:METADATA_ITEMLIST_KEY_REMINDERS withCount:0  withSize:0];
                    [fileList initItem:METADATA_ITEMLIST_KEY_REMINDERS withCount:0 withSize:0];
                }
            } else { // Cross platform should be audio
                if (SYSTEM_VERSION_LESS_THAN(@"9.3")) {
                    cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_AUDIO, nil) WithCount:-1];
                    cell.secondaryLabel.textColor = [CTColor primaryRedColor];
                    cell.secondaryLabel.text = CTLocalizedString(CT_NOT_SUPPORTED, nil);
                    cell.userInteractionEnabled = YES;

                    // Show label
                    cell.thirdLabel.hidden = NO;
                    cell.thirdLabel.text = CTLocalizedString(kMoreInfoButtonTitle, nil);
                    [cell simulateThirdLabelAsAButton];

                    // Pass selection check
                    self.selectMask |= CTSelectionReminderOrAudioMask;
                    // Set 0 item for audio
                    [fileList initItem:METADATA_ITEMLIST_KEY_AUDIOS withCount:0 withSize:0];

                    break;
                }

                if ([CTAudiosManager audioLibraryAuthorizationStatus] == CTAuthorizationStatusAuthorized) {
                    cell.thirdLabel.hidden = NO;
                    cell.thirdLabel.text = CTLocalizedString(kMoreInfoButtonTitle, nil);
                    [cell simulateThirdLabelAsAButton];

                    numberOfPermissionsGiven++;

                    self.audioNumberLbl = cell.primaryLabel;
                    self.audioDataSizeLbl = cell.secondaryLabel;

                    if ([CTDataCollectionManager sharedManager].isCollectingAudiosCompleted) {
                        cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_AUDIO, nil) WithCount:[[CTDataCollectionManager sharedManager] getNumberOfAudios]];
                        cell.secondaryLabel.text = [NSString formattedDataSizeTextInTransferWhatScreen:[[CTDataCollectionManager sharedManager] getSizeOfAudio]]; // Only show size when fetching complete.
                        [fileList initItem:METADATA_ITEMLIST_KEY_AUDIOS withCount:[[CTDataCollectionManager sharedManager] getNumberOfAudios] withSize:[[CTDataCollectionManager sharedManager] getSizeOfAudio]];

                        if ([[CTDataCollectionManager sharedManager] getNumberOfAudios] == 0) {
                            //                        self.totalNonZeroiTems++;
                            self.selectMask |= CTSelectionReminderOrAudioMask;
                        }
                    } else {
                        cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_AUDIO, nil) WithCount:-1];
                        cell.secondaryLabel.text = CTLocalizedString(CT_COLLECTING_CELL_SEC_LABEL, nil);
//                        [weakSelf setItem:METADATA_ITEMLIST_KEY_AUDIOS withCount:0 withSize:0];
                        [fileList initItem:METADATA_ITEMLIST_KEY_AUDIOS withCount:0 withSize:0];
                    }

                    self.blockMask |= CTCollectingAudioMask;
                    NSLog(@"audio finish check!");
                    [weakSelf stopIndicator];
                } else {
                    cell.primaryLabel.text = [self formattedCountText:CTLocalizedString(CT_AUDIO, nil) WithCount:0];
                    cell.secondaryLabel.textColor = [CTColor primaryRedColor];
                    cell.secondaryLabel.text = CTLocalizedString(CT_PERMISSION_NOT_GRANTED_SEC_LABEL, nil);
                    cell.userInteractionEnabled = YES;

                    self.selectMask |= CTSelectionReminderOrAudioMask;

//                    [weakSelf setItem:METADATA_ITEMLIST_KEY_AUDIOS withCount:0 withSize:0];
                    [fileList initItem:METADATA_ITEMLIST_KEY_AUDIOS withCount:0 withSize:0];
                }
            }
        } break;


        default:
            NSAssert(false, @"Unknown type should've been handled");
    }
    
    if (numberOfPermissionsGiven > 0) {
        self.selectionButton.enabled = YES;
    } else {
        self.selectionButton.enabled = NO;
    }
    
    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL isAuthorized = YES;
    BOOL hightlightSelectedRow = YES;
    switch (indexPath.row) {
        case CTTransferItemsTableBreakDown_Contacts: {
            if ([CTContactsManager contactsAuthorizationStatus] != CTAuthorizationStatusAuthorized) {
                isAuthorized = NO;
            }else if ([CTDataCollectionManager sharedManager].isCollectingContactsCompleted) {
                if (![self extractNumberFromText:self.contactsNumberLbl.text]) {
                    hightlightSelectedRow = NO;
                }else {
                    self.contactSelected = YES;
                }
            }else {
                self.contactSelected = YES;
            }
        }
            break;
            
        case CTTransferItemsTableBreakDown_Photos: {
            if ([CTPhotosManager photoLibraryAuthorizationStatus] != CTAuthorizationStatusAuthorized) {
                isAuthorized = NO;
            } else if (![self extractNumberFromText:self.photoNumberLbl.text]) {
                hightlightSelectedRow = NO;
            } else if (![CTDataCollectionManager sharedManager].isCollectingPhotoCompleted) {
                self.photoSelected = YES;
            }
        }
            break;
            
        case CTTransferItemsTableBreakDown_Videos: {
            if ([CTPhotosManager photoLibraryAuthorizationStatus] != CTAuthorizationStatusAuthorized) {
                isAuthorized = NO;
            } else if (![self extractNumberFromText:self.videoNumberLbl.text]) {
                hightlightSelectedRow = NO;
            } else if (![CTDataCollectionManager sharedManager].isCollectingVideoCompleted){
                self.videoSelected = YES;
            }
        } break;
            
        case CTTransferItemsTableBreakDown_Calenders: {
            if ([CTEventStoreManager calendarAuthorizationStatus] != CTAuthorizationStatusAuthorized) {
                isAuthorized = NO;
            }else if ([CTDataCollectionManager sharedManager].isCollectingCalendarsCompleted) {
                if (![self extractNumberFromText:self.calendarNumberLbl.text]) {
                    hightlightSelectedRow = NO;
                }else {
                    self.calendarSelected = YES;
                }
            }else {
                self.calendarSelected = YES;
            }
            
        } break;
            
        case CTTransferItemsTableBreakDown_RemindersOrAudios: {
            if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // Reminder
                if ([CTEventStoreManager reminderAuthorizationStatus] != CTAuthorizationStatusAuthorized){
                    isAuthorized = NO;
                }else if ([CTDataCollectionManager sharedManager].isCollectingReminderCompleted) {
                    if (![self extractNumberFromText:self.reminderNumberLbl.text]) {
                        hightlightSelectedRow = NO;
                    }else {
                        self.reminderSelected= YES;
                    }
                }else {
                    self.reminderSelected = YES;
                }
            } else { // Audio
                self.audioSelected = YES;
                if (SYSTEM_VERSION_LESS_THAN(@"9.3")) {
                    hightlightSelectedRow = NO;
                    self.audioSelected = NO;
                    break;
                }
                
                if ([CTAudiosManager audioLibraryAuthorizationStatus] != CTAuthorizationStatusAuthorized){
                    isAuthorized = NO;
                    self.audioSelected = NO;
                }
                
                if ([CTDataCollectionManager sharedManager].isCollectingAudiosCompleted && [[CTDataCollectionManager sharedManager] getNumberOfAudios] == 0) { // Only when audio completed and number of file available is 0, should not allow user to select.
                    hightlightSelectedRow = NO;
                    self.audioSelected = NO;
                }
            }
        } break;
            
        default: {
            NSAssert(false, @"Unknown type should've been handled");
        }  break;
    }
    
    if (isAuthorized && hightlightSelectedRow) {
        CTSenderTransferTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self setMaskForSelectCellAtIndexPath:indexPath];
        [cell highlightCell:YES];
        [self updateNextButtonState];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        if (!isAuthorized) {
            __weak typeof(self) weakSelf = self;
            if (USES_CUSTOM_VERIZON_ALERTS) {
                [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:CTLocalizedString(CT_PERMISSION_NOT_GRANTED_ALERT_CONTEXT, nil) cancelBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil) confirmBtnText:CTLocalizedString(CT_DECLINE_ALERT_BUTTON_TITLE, nil) confirmHandler:nil cancelHandler:^(CTVerizonAlertViewController *alertVC) {
                    //Send cancel Request to the other device
                    if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P]) {
                        [self.delegate ignoreSocketClosedSignal];
                        NSString *str = CT_REQUEST_FILE_CANCEL_PERMISSION;
                        [weakSelf.readSocket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:VZTagGeneral];
                        [weakSelf.readSocket readDataWithTimeout:-1.0f tag:VZTagGeneral];
                        weakSelf.readSocket = nil;
                        [weakSelf.readSocket disconnect];
                        
                    } else {
                        // send cancel response
                        NSString *str = CT_REQUEST_FILE_CANCEL_PERMISSION;
                        [[CTBonjourManager sharedInstance] sendStream:[str dataUsingEncoding:NSUTF8StringEncoding]];
                        [[CTBonjourManager sharedInstance] closeStreams];
                    }
                    [self popToRootViewController:[CTStartedViewController class]];
                    [CTSettingsUtility openRootSettings];
                    [self.asyncOperationQueue cancelAllOperations];
                } isGreedy:NO from: self];
            } else {
                [CTAlertCreateFactory showTwoButtonsAlertWithTitle:kDefaultAppTitle context:CTLocalizedString(CT_PERMISSION_NOT_GRANTED_ALERT_CONTEXT, nil) cancelBtnText:CTLocalizedString(CT_GRANT_ACCESS_ALERT_BUTTON_TITLE, nil) confirmBtnText:CTLocalizedString(CT_DECLINE_ALERT_BUTTON_TITLE, nil) confirmHandler:^(UIAlertAction *action) {
                    
                } cancelHandler:^(UIAlertAction *action) {
                    //Send cancel Request to the other device
                    if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P]) {
                        [self.delegate ignoreSocketClosedSignal];
                        NSString *str = CT_REQUEST_FILE_CANCEL_PERMISSION;
                        [weakSelf.readSocket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:VZTagGeneral];
                        [weakSelf.readSocket readDataWithTimeout:-1.0f tag:VZTagGeneral];
                        weakSelf.readSocket = nil;
                        [weakSelf.readSocket disconnect];
                        
                    } else {
                        // send cancel response
                        NSString *str = CT_REQUEST_FILE_CANCEL_PERMISSION;
                        [[CTBonjourManager sharedInstance] sendStream:[str dataUsingEncoding:NSUTF8StringEncoding]];
                        [[CTBonjourManager sharedInstance] closeStreams];
                    }
                    [self popToRootViewController:[CTStartedViewController class]];
                    [CTSettingsUtility openRootSettings];
                    [self.asyncOperationQueue cancelAllOperations];
                } isGreedy:NO];
            }
        }
    }
}

/*!
    @brief Set mask for each of type cell selected.
 */
- (void)setMaskForSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case CTTransferItemsTableBreakDown_Contacts:
            self.selectMask |= CTSelectionContactMask;
            break;
        case CTTransferItemsTableBreakDown_Photos:
            self.selectMask |= CTSelectionPhotoMask;
            break;
        case CTTransferItemsTableBreakDown_Videos:
            self.selectMask |= CTSelectionVideoMask;
            break;
        case CTTransferItemsTableBreakDown_Calenders:
            self.selectMask |= CTSelectionCalendarMask;
            break;
        case CTTransferItemsTableBreakDown_RemindersOrAudios:
            self.selectMask |= CTSelectionReminderOrAudioMask;
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger numberOfSection = 0;
    switch (indexPath.row) {
        case CTTransferItemsTableBreakDown_Contacts: {
            numberOfSection = [CTDataCollectionManager sharedManager].getNumberOfContacts;
        }
            break;
        case CTTransferItemsTableBreakDown_Videos: {
            self.videoSelected = NO;
            numberOfSection = [self extractNumberFromText:self.videoNumberLbl.text];
        }
            break;
        case CTTransferItemsTableBreakDown_Photos: {
            self.photoSelected = NO;
            numberOfSection = [self extractNumberFromText:self.photoNumberLbl.text];
        } break;
        case CTTransferItemsTableBreakDown_Calenders: {
            numberOfSection = [CTDataCollectionManager sharedManager].getNumberOfCalendars;
        }
            break;
        case CTTransferItemsTableBreakDown_RemindersOrAudios: {
            if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // reminder
                numberOfSection = [CTDataCollectionManager sharedManager].getNumberOfReminders;
            } else { // audio
                if ([CTDataCollectionManager sharedManager].isCollectingAudiosCompleted && [[CTDataCollectionManager sharedManager] getNumberOfAudios] == 0) { // ignore user click in this case.
                    return;
                } else {
                    self.audioSelected = NO;
                    numberOfSection = 1;
                }
            }
        } break;
    }
    
    CTSenderTransferTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell highlightCell:NO];
    [self setMaskForDeselectCellAtIndexPath:indexPath];
    
    [self updateNextButtonState];
}

/*!
 @brief Set mask for each of type cell deselected.
 */
- (void)setMaskForDeselectCellAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case CTTransferItemsTableBreakDown_Contacts:
            self.selectMask &= ~CTSelectionContactMask;
            break;
        case CTTransferItemsTableBreakDown_Photos:
            self.selectMask &= ~CTSelectionPhotoMask;
            break;
        case CTTransferItemsTableBreakDown_Videos:
            self.selectMask &= ~CTSelectionVideoMask;
            break;
        case CTTransferItemsTableBreakDown_Calenders:
            self.selectMask &= ~CTSelectionCalendarMask;
            break;
        case CTTransferItemsTableBreakDown_RemindersOrAudios:
            self.selectMask &= ~CTSelectionReminderOrAudioMask;
            break;
        default:
            break;
    }
}

/*! 
    @brief Update the next button and 'select all' button status based on user's choice.
 */
- (void)updateNextButtonState {
    
    if (self.transferItemsTableView.indexPathsForSelectedRows.count > 0) {
        self.nextButton.enabled = YES;
    } else {
        self.nextButton.enabled = NO;
    }
    
    if (self.selectMask == CTSelectionAllMask) { // Select all
        isAllSelected = YES;
        [self.selectionButton setTitle:CTLocalizedString(CT_DESELECT_ALL_BTN_TITLE, nil) forState:UIControlStateNormal];
    } else {
        isAllSelected = NO;
        [self.selectionButton setTitle:CTLocalizedString(CT_SELECT_ALL_BTN_TITLE, nil) forState:UIControlStateNormal];
    }
}

#pragma mark - UIGestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self.view];
    // Check audio cell
    CTSenderTransferTableViewCell *targetCell = (CTSenderTransferTableViewCell *)[self.transferItemsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:CTTransferItemsTableBreakDown_RemindersOrAudios inSection:0]];
    CGPoint convertPoint = [targetCell convertPoint:point fromView:self.view];
    CGRect covertRect = [targetCell convertRect:targetCell.moreInfoButton.frame fromView:targetCell.thirdLabel];
    if (CGRectContainsPoint(covertRect, convertPoint)) {
        _thirdButtonCurrentClicked = CTTransferItemsTableBreakDown_RemindersOrAudios;
        return YES;
    }
    // If it's not audio cell, then check contact cell
    targetCell = [self.transferItemsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:CTTransferItemsTableBreakDown_Contacts inSection:0]];
    convertPoint = [targetCell convertPoint:point fromView:self.view];
    covertRect = [targetCell convertRect:targetCell.moreInfoButton.frame fromView:targetCell.thirdLabel];
    if (CGRectContainsPoint(covertRect, convertPoint)) {
        _thirdButtonCurrentClicked = CTTransferItemsTableBreakDown_Contacts;
        return YES;
    }
    
    return NO;
}

#pragma mark - Selector methods
/*!
    @brief Check if view controller can stop and hide the indicator.
    @discussion Basically, method use CTColletingMask to check if all the necessary collection are done. So view controller will hide the indicator to enable the user interaction.
    @see CTCollectingMask
 */
-(void)stopIndicator {
    if (self.blockMask == CTCollectingAllMask) {
        self.blockMask &= CTCollectingResetMask; // reset to 0, make sure below code only run one time.
        [self.activityIndicator hideAnimated:YES];
        NSLog(@"finial photo and video count = %lu", (unsigned long)[CTDataCollectionManager sharedManager].photoManager.photoExport.hashTableUrltofileName.count);
    }
}

/*!
    @brief This method will create the primary title context for select what age.
    @discussion The format of the text will be "DATA_TYPE (FILE_NUMBER)".
    @param text NSString type represent the type of the content, like contacts, photos, videos, etc.
    @param count NSInteger value represents the number of the file. If this value is zero, it means either no file found or no permission given. If this value assigned to -1, this method will return only the data type without any number.
 */
- (nonnull NSString *)formattedCountText:(nonnull NSString *)text WithCount:(NSInteger)count {
    if (count == -1) {
        return text; // if it's -1, just return the title without any number
    }
    return [NSString stringWithFormat:@"%@ (%li)", text, (long)count];
}

- (void)closeSocketConnection {
    
    if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P]) {
        
        [self.delegate ignoreSocketClosedSignal];
        
        [self.commAsyncSocket senderSideCancelMessage]; // Send cancel message
        
        [self.readSocket disconnect];
        self.readSocket = nil;
    } else {
        // Bonjour
        
        // send cancel response
        NSString *str = CT_REQUEST_FILE_CANCEL;
        [[CTBonjourManager sharedInstance] sendStream:[str dataUsingEncoding:NSUTF8StringEncoding]];
        [[CTBonjourManager sharedInstance] closeStreams];
    }
}

/*! @brief First time check the collection status when transfer what page did appeared.*/
- (void)checkDataCollectionStatus {
    
    if ([CTDataCollectionManager sharedManager].isCollectingCalendarsCompleted) {
        //        [self calendarsFetchingIsCompleted];
        self.blockMask |= CTCollectingCalendarMask;
        NSLog(@"calendar check!");
        [self stopIndicator];
    }
    
    if ([CTDataCollectionManager sharedManager].isCollectingReminderCompleted) {
        //        [self remindersFetchingIsCompleted];
        self.blockMask |= CTCollectingReminderMask;
        NSLog(@"reminder check!");
        [self stopIndicator];
    }
    
    if ([CTDataCollectionManager sharedManager].isCollectingAudiosCompleted) {
        self.blockMask |= CTCollectingAudioMask;
        NSLog(@"audio check!");
        [self stopIndicator];
    }
    
    if ([CTDataCollectionManager sharedManager].isCollectingContactsCompleted) {
        //        [self contactFetchingIsCompleted];
        self.blockMask |= CTCollectingContactMask;
        NSLog(@"contact check!");
        [self stopIndicator];
    }
    
    if ([CTDataCollectionManager sharedManager].isCollectingPhotoCompleted) {
        [self photoFetchingIsCompleted];
        self.blockMask |= CTCollectingPhotoMask;
        NSLog(@"photo check!");
        [self stopIndicator];
    }
    
    if ([CTDataCollectionManager sharedManager].isCollectingVideoCompleted) {
        [self videoFetchingIsCompleted];
        self.blockMask |= CTCollectingVideoMask;
        NSLog(@"video check!");
        [self stopIndicator];
    }
}

/*!
 @brief If some of data types still in collection process, and transfer already considered as started, then cancel them.
 */
- (void)cancelInProcessDataCollectionIfUserNotSelected {
    
    NSArray *selectedRows = [self.transferItemsTableView indexPathsForSelectedRows];
    
    BOOL contactNotSelected = YES;
    BOOL reminderNotSelected = YES;
    BOOL calendarNotSelected = YES;
    BOOL photoNotSelected = YES;
    BOOL videoNotSelected = YES;
    BOOL audioNotSelected = YES;
    
    for (NSIndexPath *indexpath in selectedRows) {
        
        if (indexpath.row == CTTransferItemsTableBreakDown_Contacts) {
            contactNotSelected = NO;
        }
        
        if (indexpath.row == CTTransferItemsTableBreakDown_Calenders) {
            calendarNotSelected = NO;
        }
        
        if (indexpath.row == CTTransferItemsTableBreakDown_Photos) {
            photoNotSelected = NO;
        }
        
        if (indexpath.row == CTTransferItemsTableBreakDown_Videos) {
            videoNotSelected = NO;
        }
        
        if (indexpath.row == CTTransferItemsTableBreakDown_RemindersOrAudios) {
            if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
                audioNotSelected = NO;
            }else {
                reminderNotSelected = NO;
            }
        }
    }
    
    if (contactNotSelected && ![CTDataCollectionManager sharedManager].isCollectingContactsCompleted) {
        [[CTDataCollectionManager sharedManager] stopContactDataCollectionTask];
    }
    
    if (calendarNotSelected && ![CTDataCollectionManager sharedManager].isCollectingCalendarsCompleted) {
        [[CTDataCollectionManager sharedManager] stopCalendarDataCollectionTask];
    }
    
    if (reminderNotSelected && ![CTDataCollectionManager sharedManager].isCollectingReminderCompleted) {
        [[CTDataCollectionManager sharedManager] stopReminderDataCollectionTask];
    }
    
    if (photoNotSelected && ![CTDataCollectionManager sharedManager].isCollectingPhotoCompleted) {
        [[CTDataCollectionManager sharedManager] stopPhotoDataCollectionTask];
    }
    
    if (videoNotSelected && ![CTDataCollectionManager sharedManager].isCollectingVideoCompleted) {
        [[CTDataCollectionManager sharedManager] stopVideoDataCollectionTask];
    }
    
    if (audioNotSelected && ![CTDataCollectionManager sharedManager].isCollectingAudiosCompleted) {
        [[CTDataCollectionManager sharedManager] stopAudioDataCollectionTask];
    }
}

/*!
    @brief Check if user selected some data type that still in fetch process.
    @discussion For current version, these types are photos, videos and audio for cross platform. If any of these selected type still in process, return YES; otherwise return NO.
    @return Bool value represent the result.
 */
- (BOOL)checkIfUserSelectedStillInProcessMediaType {
    if ((self.photoSelected && self.waitTillPhotoCompleteDataIsCollected)    // select photo
        || (self.videoSelected && self.waitTillVideoCompleteDataIsCollected) // select video
        || ((self.selectMask & CTSelectionReminderOrAudioMask) == CTSelectionReminderOrAudioMask && ![CTDataCollectionManager sharedManager].isCollectingAudiosCompleted && [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod])
        || (self.contactSelected && self.waitTillContactCompleteDataIsCollected)
        || (self.reminderSelected && self.waitTillReminderCompleteDataIsCollected)
        || (self.calendarSelected && self.waitTillCalendarCompleteDataIsCollected)) {
        return YES;
    }
    
    return NO;
}

- (int)extractNumberFromText:(NSString *)text
{
    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [[[text componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""] intValue];
}

- (void)setInitialWaitingFlags {
    self.waitTillContactCompleteDataIsCollected = ![CTDataCollectionManager sharedManager].isCollectingContactsCompleted;
    self.waitTillPhotoCompleteDataIsCollected = ![CTDataCollectionManager sharedManager].isCollectingPhotoCompleted;
    self.waitTillVideoCompleteDataIsCollected = ![CTDataCollectionManager sharedManager].isCollectingVideoCompleted;
    self.waitTillCalendarCompleteDataIsCollected = ![CTDataCollectionManager sharedManager].isCollectingCalendarsCompleted;
    self.waitTillReminderCompleteDataIsCollected = ![CTDataCollectionManager sharedManager].isCollectingReminderCompleted;
    self.waitTillAudioCompleteDataIsCollected = ![CTDataCollectionManager sharedManager].isCollectingAudiosCompleted;
}
/*!
    @brief Selector method response for tap gesture recognizer.
    @param gesture UIGestureRecognizer object that triggered this event.
 */
- (void)viewDidTapped:(UIGestureRecognizer *)gesture {
    CTSenderTransferTableViewCell *cell = (CTSenderTransferTableViewCell *)[self.transferItemsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.thirdButtonCurrentClicked inSection:0]];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        cell.thirdLabel.textColor = [CTMVMColor blackColor];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        cell.thirdLabel.textColor = [CTMVMColor blackColor];
        
        // Show alert with important information
        if (self.thirdButtonCurrentClicked == CTTransferItemsTableBreakDown_Contacts) {
            // Show alert for contact detail for cloud content.
            if (USES_CUSTOM_VERIZON_ALERTS) {
                [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:CTLocalizedString(CTCloudContactsWarning, nil) btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil) handler:nil isGreedy:YES from:self];
            } else {
                [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:CTLocalizedString(CTCloudContactsWarning, nil) btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil) handler:nil isGreedy:YES];
            }
        } else if (self.thirdButtonCurrentClicked == CTTransferItemsTableBreakDown_RemindersOrAudios) {
            if (SYSTEM_VERSION_LESS_THAN(@"9.3")) { // Less than 9.3, show not support audio message
                if (USES_CUSTOM_VERIZON_ALERTS) {
                    [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:CTLocalizedString(CTAudioOSSupportErr, nil) btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil) handler:nil isGreedy:YES from: self];
                } else {
                    [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:CTLocalizedString(CTAudioOSSupportErr, nil) btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil) handler:nil isGreedy:YES];
                }
            } else { // Show format warning information
                if (USES_CUSTOM_VERIZON_ALERTS) {
                    [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:CTLocalizedString(CTAudioFormatWarning, nil) btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil) handler:nil isGreedy:YES from: self];
                } else {
                    [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:CTLocalizedString(CTAudioFormatWarning, nil) btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil) handler:nil isGreedy:YES];
                }
            }
        }
    } else {
        NSLog(@"Other gesture recogizer state: %ld", (long)gesture.state);
    }
}

#pragma mark - Outlet actions
- (IBAction)handleSelectAllButtonTapped:(id)sender {
    
    isAllSelected = !isAllSelected;
    
    if ([CTContactsManager contactsAuthorizationStatus] == CTAuthorizationStatusAuthorized && ([CTDataCollectionManager sharedManager].getNumberOfContacts > 0 || ![CTDataCollectionManager sharedManager].isCollectingContactsCompleted)) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:CTTransferItemsTableBreakDown_Contacts inSection:0];
        CTSenderTransferTableViewCell *cell = [self.transferItemsTableView cellForRowAtIndexPath:indexPath];
        
        if (isAllSelected && cell.isUserInteractionEnabled) {
            [self.transferItemsTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self setMaskForSelectCellAtIndexPath:indexPath];
            [cell highlightCell:YES];
            self.contactSelected = YES;
        }else {
            [self.transferItemsTableView deselectRowAtIndexPath:indexPath animated:YES];
            [self setMaskForDeselectCellAtIndexPath:indexPath];
            [cell highlightCell:NO];
            self.contactSelected = NO;
        }
    }
    
    if ([CTPhotosManager photoLibraryAuthorizationStatus] == CTAuthorizationStatusAuthorized && [self extractNumberFromText:self.photoNumberLbl.text] > 0) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:CTTransferItemsTableBreakDown_Photos inSection:0];
        CTSenderTransferTableViewCell *cell = [self.transferItemsTableView cellForRowAtIndexPath:indexPath];
        if (isAllSelected && cell.isUserInteractionEnabled) {
            [self.transferItemsTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self setMaskForSelectCellAtIndexPath:indexPath];
            [cell highlightCell:YES];
            self.photoSelected = YES;
        } else {
            [self.transferItemsTableView deselectRowAtIndexPath:indexPath animated:YES];
            [self setMaskForDeselectCellAtIndexPath:indexPath];
            [cell highlightCell:NO];
            self.photoSelected = NO;
        }
    }
    
    if ([CTPhotosManager photoLibraryAuthorizationStatus] == CTAuthorizationStatusAuthorized && [self extractNumberFromText:self.videoNumberLbl.text] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:CTTransferItemsTableBreakDown_Videos inSection:0];
        CTSenderTransferTableViewCell *cell = [self.transferItemsTableView cellForRowAtIndexPath:indexPath];
        if (isAllSelected && cell.isUserInteractionEnabled) {
            [self.transferItemsTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self setMaskForSelectCellAtIndexPath:indexPath];
            [cell highlightCell:YES];
            self.videoSelected = YES;
        } else {
            [self.transferItemsTableView deselectRowAtIndexPath:indexPath animated:YES];
            [self setMaskForDeselectCellAtIndexPath:indexPath];
            [cell highlightCell:NO];
            self.videoSelected = NO;
        }
    }
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // reminder
        if ([CTEventStoreManager reminderAuthorizationStatus] == CTAuthorizationStatusAuthorized && ([CTDataCollectionManager sharedManager].getNumberOfReminders > 0 || ![CTDataCollectionManager sharedManager].isCollectingReminderCompleted)){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:CTTransferItemsTableBreakDown_RemindersOrAudios inSection:0];
            CTSenderTransferTableViewCell *cell = [self.transferItemsTableView cellForRowAtIndexPath:indexPath];
            if (isAllSelected && cell.isUserInteractionEnabled) {
                [self.transferItemsTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                [self setMaskForSelectCellAtIndexPath:indexPath];
                [cell highlightCell:YES];
                self.reminderSelected = YES;
            }else {
                [self.transferItemsTableView deselectRowAtIndexPath:indexPath animated:YES];
                [self setMaskForDeselectCellAtIndexPath:indexPath];
                [cell highlightCell:NO];
                self.reminderSelected = NO;
            }
        }
    } else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.3")) { // audio
        if ([CTAudiosManager audioLibraryAuthorizationStatus] == CTAuthorizationStatusAuthorized && ( [CTDataCollectionManager sharedManager].getNumberOfAudios > 0 || ![CTDataCollectionManager sharedManager].isCollectingAudiosCompleted)) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:CTTransferItemsTableBreakDown_RemindersOrAudios inSection:0];
            CTSenderTransferTableViewCell *cell = [self.transferItemsTableView cellForRowAtIndexPath:indexPath];
            if (isAllSelected && cell.isUserInteractionEnabled) {
                [self.transferItemsTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                [self setMaskForSelectCellAtIndexPath:indexPath];
                [cell highlightCell:YES];
                self.audioSelected = YES;
            } else {
                [self.transferItemsTableView deselectRowAtIndexPath:indexPath animated:YES];
                [self setMaskForDeselectCellAtIndexPath:indexPath];
                [cell highlightCell:NO];
                self.audioSelected = NO;
            }
        }
    }
    
    
    if ([CTEventStoreManager calendarAuthorizationStatus] == CTAuthorizationStatusAuthorized && ([CTDataCollectionManager sharedManager].getNumberOfCalendars > 0 || ![CTDataCollectionManager sharedManager].isCollectingCalendarsCompleted)) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:CTTransferItemsTableBreakDown_Calenders inSection:0];
        CTSenderTransferTableViewCell *cell = [self.transferItemsTableView cellForRowAtIndexPath:indexPath];
        if (isAllSelected && cell.isUserInteractionEnabled) {
            [self.transferItemsTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self setMaskForSelectCellAtIndexPath:indexPath];
            [cell highlightCell:YES];
            self.calendarSelected = YES;
        } else {
            [self.transferItemsTableView deselectRowAtIndexPath:indexPath animated:YES];
            [self setMaskForDeselectCellAtIndexPath:indexPath];
            [cell highlightCell:NO];
            self.calendarSelected = NO;
        }
    }
    
    [self updateNextButtonState];
}

- (IBAction)handleCancelButtonTapped:(UIButton *)sender {
    if (USES_CUSTOM_VERIZON_ALERTS) {
        [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle:CTLocalizedString(CT_STOP_TRANSFER_ALERT_TITLE, nil) context:CTLocalizedString(CT_STOP_TRANSFER_ALERT_CONTEXT, nil) cancelBtnText:CTLocalizedString(CTAlertGeneralCancelTitle, nil) confirmBtnText:CTLocalizedString(CT_CONFIRM_ALERT_BUTTON_TITLE, nil) confirmHandler:^(CTVerizonAlertViewController *alertVC){
            // disable the button, make sure press twice not available
            [sender setEnabled:NO];
            [sender setAlpha:0.4];
            [[CTDataCollectionManager sharedManager] stopCollectDataForExit]; // Stop the collection
            [self closeSocketConnection];
            CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
            
            errorViewController.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, nil);
            errorViewController.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, nil);
            errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_TRY_AGAIN, nil);
            errorViewController.leftButtonTitle = CTLocalizedString(BUTTON_TITLE_RECAP, nil);
            errorViewController.transferStatusAnalytics = CTTransferStatus_Cancelled;
            
            // Assign recap data
            errorViewController.totalDataSentUntillInterrupted = [NSNumber numberWithInteger:0];
            errorViewController.totalDataAmount = 0; // total amount
            errorViewController.transferSpeed = @"0 Mbps";
            errorViewController.transferTime = @"";
            errorViewController.cancelInTransferWhatPage = YES;
            
            [self.navigationController pushViewController:errorViewController animated:YES];
        } cancelHandler:nil isGreedy:NO from:self];
    } else {
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CT_CONFIRM_ALERT_BUTTON_TITLE, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            // disable the button, make sure press twice not available
            [sender setEnabled:NO];
            [sender setAlpha:0.4];
            [[CTDataCollectionManager sharedManager] stopCollectDataForExit]; // Stop the collection
            [self closeSocketConnection];
            CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
            
            errorViewController.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, nil);
            errorViewController.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, nil);
            errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_TRY_AGAIN, nil);
            errorViewController.leftButtonTitle = CTLocalizedString(BUTTON_TITLE_RECAP, nil);
            errorViewController.transferStatusAnalytics = CTTransferStatus_Cancelled;
            
            // Assign recap data
            errorViewController.totalDataSentUntillInterrupted = [NSNumber numberWithInteger:0];
            errorViewController.totalDataAmount = 0; // total amount
            errorViewController.transferSpeed = @"0 Mbps";
            errorViewController.transferTime = @"";
            errorViewController.cancelInTransferWhatPage = YES;
            
            [self.navigationController pushViewController:errorViewController animated:YES];
        }];
        
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralCancelTitle, nil) style:UIAlertActionStyleCancel handler:nil];
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(CT_STOP_TRANSFER_ALERT_TITLE, nil) message:CTLocalizedString(CT_STOP_TRANSFER_ALERT_CONTEXT, nil) cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    }
}

- (void)viewShouldGoToCancelPage {
    [[CTDataCollectionManager sharedManager] stopCollectDataForExit]; // Stop the collection
    [self closeSocketConnection];
    
    // should go cancel
    CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
    
    errorViewController.primaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TITLE, nil);
    errorViewController.secondaryErrorText = CTLocalizedString(CT_USER_INTERRUPTED_TEXT, nil);
    errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_GOT_IT, nil);
    errorViewController.transferStatusAnalytics = CTTransferStatus_Cancelled;
    
    [self.navigationController pushViewController:errorViewController animated:NO];
}

- (IBAction)handleNextButtonTapped:(id)sender {
    
    self.userClickedTransferBtn = YES;
    
    if (![self checkIfUserSelectedStillInProcessMediaType]) {
        [self prepareDataForTransferProgressScreen];
    } else {
        [self startDisPlayCollectingDataDialog];
    }
    
}

#pragma mark - CTPhotoManagerDelegate
- (void)viewShouldUpdateVideoCount:(NSInteger)count {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.videoNumberLbl.text = [self formattedCountText:CTLocalizedString(CT_VIDEOS, nil) WithCount:count];
    });
}

- (void)viewShouldUpdatePhotoCount:(NSInteger)count {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.photoNumberLbl.text = [self formattedCountText:CTLocalizedString(CT_PHOTOS, nil) WithCount:count];
    });
}

#pragma mark - View controller flow methods
- (void)showMemortCrowedSCreen:(long long)totalSize {
    
    UIStoryboard *storyboard = [CTStoryboardHelper commonStoryboard];
    
    if ([self.childViewControllers containsObject:self.errorViewController] == NO) {
        self.errorViewController = [CTErrorViewController initialiseFromStoryboard:storyboard];
        self.errorViewController.primaryErrorText = CTLocalizedString(CT_NO_STORAGE_TITLE, nil);
        self.errorViewController.secondaryErrorText = [NSString stringWithFormat:CTLocalizedString(CT_FILES_OVER_LIMIT_SEC_LABEL, nil), totalSize /(1024 *1024),[[CTUserDevice userDevice].maxSpaceAvaiableForTransfer longLongValue]/(1024 *1024)];
        self.errorViewController.rightButtonTitle = CTLocalizedString(BUTTON_TITLE_GOT_IT, nil);
        self.errorViewController.transferStatusAnalytics = CTTransferStatus_Insufficient_Storage;
        self.errorViewController.bottomspace = 90.0f;
        [self addChildViewController:self.errorViewController];
        
        [self.view addSubview:self.errorViewController.view];
        
        [self.errorViewController didMoveToParentViewController:self];
        
        [self.errorViewController.rightButton removeTarget:self.errorViewController
                                                    action:@selector(handleRightButtonTapped:)
                                          forControlEvents:UIControlEventTouchUpInside];
        
        [self.errorViewController.rightButton addTarget:self
                                                 action:@selector(handleRightButtonTapped:)
                                       forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)handleRightButtonTapped:(id)sender {
    
    [self.errorViewController.view removeFromSuperview];
    [self.errorViewController removeFromParentViewController];
}

/*! 
    @brief Prepare the data before really start the transfer process.
    @discussion This method will check the selected items again to see if any item has 0 number. If anything with zero count, a dialog will show, and when dialog dismissed, user can reselect and hit transfer again to start.
 
                If all the selected items with non-zero count, initial the transfer.

    @warning For now, this logic will only work for audio file included case, other cases will directly start the transfer.
 */
- (void)prepareDataForTransferProgressScreen {
    NSArray *zeroItems = [self recheckSelectInProcessItems];
    if (zeroItems.count > 0) {
        if (USES_CUSTOM_VERIZON_ALERTS) {
            [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:CTLocalizedString(CTZeroItemTextFormat, nil) btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil) handler:^(CTVerizonAlertViewController *alertVC) {
                self.userClickedTransferBtn = NO; // Reset transfer button clicked param
            } isGreedy:NO from: self];
        } else {
            [CTAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) context:CTLocalizedString(CTZeroItemTextFormat, nil) btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil) handler:^(UIAlertAction *action) {
                self.userClickedTransferBtn = NO; // Reset transfer button clicked param
            } isGreedy:NO];
        }
    } else {
        [self initialTransferStartProcess];
    }
}

/*!
    @brief To initial the transfer. When this method called, process can be consided as start. Just do some preparation and pop to new view controller.
 
           Also will cancel all the padding task that still fetching.
 */
- (void)initialTransferStartProcess {
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSDictionary *allList = [self selectedItemsList];
        [fileList creatCompleteFileList:self.transferItemsTableView.indexPathsForSelectedRows];
        [[NSUserDefaults standardUserDefaults] setObject:fileList.listObject forKey:@"CTSenderSideList"]; // Set file list for sender side
//        long long totalSize = [self calculateTotalDataSize:allList];
        long long totalSize = fileList.totalDataSize;
        if ([[CTUserDevice userDevice].maxSpaceAvaiableForTransfer longLongValue] > totalSize) {
            
            [self cancelInProcessDataCollectionIfUserNotSelected];
            
            CTSenderProgressViewController *senderProgressViewController = [[CTSenderProgressViewController alloc] initWithNibName:NSStringFromClass([CTTransferInProgressViewController class]) bundle:[CTBundle resourceBundle]];
            senderProgressViewController.totalDataSize = totalSize;
//            senderProgressViewController.selectedItems = allList;
            senderProgressViewController.fileList      = fileList;
            senderProgressViewController.transferFlow  = CTTransferFlow_Sender;
            senderProgressViewController.readSocket    = self.readSocket;
            senderProgressViewController.commSocket    = self.commAsyncSocket;
            senderProgressViewController.mediaManager  = [CTDataCollectionManager sharedManager].photoManager;
            
            [self.navigationController pushViewController:senderProgressViewController animated:YES];

        } else {
            DebugLog(@"Not enough space to transfer data");
            [self showMemortCrowedSCreen:totalSize];
        }
    });
}

/*!
    @brief Recheck the selected in process items after process done.
    @discussion Some of items like audio (photo/video with All Photos iCloud maybe) may return 0 count value after fetch finished. Because without trying to access the data, there is no way to know that cloud content can be fetch or not.
 
                If any selected content turns out 0, should alert user and start tranfer rest of the data; If all data types are 0, should allow user to repick the content again.
 
    @return NSArray contains all the type that turns out to be 0 content.
 */
- (NSArray *)recheckSelectInProcessItems {
    if(self.audioSelected
       && [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]
       && [CTDataCollectionManager sharedManager].getNumberOfAudios == 0) {
        return @[METADATA_ITEMLIST_KEY_AUDIOS];
    }
    
    return @[];
}

/*!
    @brief Display the collecting dialog after user hit the transfer button. Text will be updated based on the collection progress.
    @see CTCustomAlertView
 */
- (void)startDisPlayCollectingDataDialog {
    
    NSMutableArray *items = [NSMutableArray new];
    if (self.contactSelected && self.waitTillContactCompleteDataIsCollected) {
        [items addObject:CTLocalizedString(CT_CONTACTS_STRING, nil)];
    }
    if (self.reminderSelected && self.waitTillReminderCompleteDataIsCollected) {
        [items addObject:CTLocalizedString(CT_REMINDERS_STRING, nil)];
    }
    if (self.calendarSelected && self.waitTillCalendarCompleteDataIsCollected) {
        [items addObject:CTLocalizedString(CT_CALANDERS_STRING, nil)];
    }
    if (self.photoSelected && self.waitTillPhotoCompleteDataIsCollected) {
        [items addObject:CTLocalizedString(CT_PHOTOS_STRING, nil)];
    }
    if (self.videoSelected && self.waitTillVideoCompleteDataIsCollected) {
        [items addObject:CTLocalizedString(CT_VIDEOS_STRING, nil)];
    }
    if ((self.selectMask & CTSelectionReminderOrAudioMask) == CTSelectionReminderOrAudioMask && ![CTDataCollectionManager sharedManager].isCollectingAudiosCompleted && [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
        [items addObject:CTLocalizedString(CT_AUDIO_STRING, nil)];
    }
    
    NSString *context = [items componentsJoinedByString:@", "];
    NSRange lastCommaRange = [context rangeOfString:@"," options:NSBackwardsSearch];
    if (lastCommaRange.location != NSNotFound) {
        context = [context stringByReplacingCharactersInRange:lastCommaRange withString:[NSString stringWithFormat:@" %@", CTLocalizedString(CT_AND, nil)]]; // replace the last comma with and for context of the alert
    }
    context = [NSString stringWithFormat:CTLocalizedString(CTSelectPromptFormat, nil), context];
    
    if (!self.alertView) {
        self.alertView = [[CTCustomAlertView alloc] initCustomAlertViewWithText:context withOritation:CTAlertViewOritation_VERTICAL];
    }
    
    if (!self.alertView.visible) {
        [self.alertView show];
    } else {
        [self.alertView updateLbelText:context oritation:CTAlertViewOritation_VERTICAL];
    }
}

- (void)stopDisplayCollectingDialog {
    if (![self checkIfUserSelectedStillInProcessMediaType]) { // Everything selected completed
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.alertView hide:^{
                [self prepareDataForTransferProgressScreen];
            }];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startDisPlayCollectingDataDialog];
        });
    }
}

#pragma mark - Observers
- (void)applicationWillTerminate:(NSNotification *)notification {
    if (self.navigationController.topViewController == self) {
        DebugLog(@"Terminate notification received test in transfer what page");
        // Send cancel msg to recevier phone to stop heart beat msg
        [self closeSocketConnection];
    }
}

- (void)exitContentTransfer:(NSNotification*)notification {
    
    [self closeSocketConnection];
    
    [fileList creatCompleteFileList:self.transferItemsTableView.indexPathsForSelectedRows];
    
    NSString *descMsg = [NSString stringWithFormat:@"MF back button,CT app exit-%@",[self class]];
    [[CTLocalAnalysticsManager sharedInstance] localAnalyticsData:@"Transfer Cancelled - Not Started"
                                              andNumberOfContacts:0
                                                andNumberOfPhotos:0
                                                andNumberOfVideos:0
                                             andNumberOfCalendars:0
                                             andNumberOfReminders:0
                                                  andNumberOfApps:0
                                                andNumberOfAudios:0
                                                  totalDownloaded:0
                                                 totalTimeElapsed:0
                                                     averageSpeed:0
                                                      description:descMsg];
}

- (void)requestToCancelAllOperation {
    [self.asyncOperationQueue cancelAllOperations];
}

#pragma mark - updatePhotoAndVideoNumbersDelegate
- (void)updateVideosCountFromDataCollectionManager:(NSInteger)count {
    DebugLog(@"Video fetched and count is %ld",(long)count);
}

- (void)updatePhotoCountFromDataCollectionManager:(NSInteger)count {
    DebugLog(@"Photo fetched and count is %ld",(long)count);
}

-(void)updateCalendarCountFromDataCollectionManager:(NSInteger)count {
    DebugLog(@"Calendar fetched and count is %ld",(long)count);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.calendarNumberLbl.text = [self formattedCountText:CTLocalizedString(CT_CALENDERS, nil) WithCount:count];
    });
}

- (void)photoFetchingIsCompleted {
    __weak typeof(self) weakSelf = self;
    
    BOOL tempPhotoCompeletionStatus = self.waitTillPhotoCompleteDataIsCollected;
    self.waitTillPhotoCompleteDataIsCollected = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.photoNumberLbl.text = [self formattedCountText:CTLocalizedString(CT_PHOTOS, nil) WithCount:[CTDataCollectionManager sharedManager].getNumbersOfPhotos];
        if ([CTDataCollectionManager sharedManager].isAllPhotos && [CTDataCollectionManager sharedManager].getNumbersOfPhotos > 0) {
            self.selectMask &= ~CTSelectionPhotoMask; // If all photo has local file, then reset the flag for photo to 0
        }
        weakSelf.photoDataSizeLbl.text = [NSString formattedDataSizeTextInTransferWhatScreen:[CTDataCollectionManager sharedManager].getSizeOfPhotos];
//        [weakSelf setItem:METADATA_ITEMLIST_KEY_PHOTOS withCount:[CTDataCollectionManager sharedManager].getNumbersOfPhotos withSize:[CTDataCollectionManager sharedManager].getSizeOfPhotos];
        [fileList initItem:METADATA_ITEMLIST_KEY_PHOTOS withCount:[CTDataCollectionManager sharedManager].getNumbersOfPhotos withSize:[CTDataCollectionManager sharedManager].getSizeOfPhotos];
        
        if ([CTDataCollectionManager sharedManager].getNumberOfUnavailableCountPhotosCount > 0 || [CTDataCollectionManager sharedManager].getNumberOfStreamPhotosCount > 0) {
            weakSelf.photoCloudLbl.hidden = NO;
            weakSelf.photoCloudLbl.textColor = [CTColor primaryRedColor];
            NSInteger totalPhotoCloudNumber = 0;
            if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
                totalPhotoCloudNumber = [CTDataCollectionManager sharedManager].getNumberOfUnavailableCountPhotosCount + [CTDataCollectionManager sharedManager].getNumberOfStreamPhotosCount;
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"VZTRANSFER_HAS_CLOUD_PHOTO"];
                weakSelf.iCloudInfoLabel.hidden = NO;
                weakSelf.photoCloudLbl.text = [NSString stringWithFormat:CTLocalizedString(CT_IN_ICLOUD_TER_LABEL, nil),(long)totalPhotoCloudNumber];
            } else {
                totalPhotoCloudNumber = [CTDataCollectionManager sharedManager].getNumberOfUnavailableCountPhotosCount;
                if (totalPhotoCloudNumber > 0) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"VZTRANSFER_HAS_CLOUD_PHOTO"];
                    weakSelf.photoCloudLbl.text = [NSString stringWithFormat:CTLocalizedString(CT_IN_ICLOUD_TER_LABEL, nil), (long)totalPhotoCloudNumber];
                    weakSelf.iCloudInfoLabel.hidden = NO;
                } else {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"VZTRANSFER_HAS_CLOUD_PHOTO"];
                    weakSelf.photoCloudLbl.hidden = YES;
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"VZTRANSFER_HAS_CLOUD_VIDEO"]) {
                        weakSelf.iCloudInfoLabel.hidden = YES;
                    }
                }
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"VZTRANSFER_HAS_CLOUD_PHOTO"];
            weakSelf.photoCloudLbl.hidden = YES;
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"VZTRANSFER_HAS_CLOUD_VIDEO"]) {
                weakSelf.iCloudInfoLabel.hidden = YES;
            }
        }
    });
    
    if (self.photoSelected && self.userClickedTransferBtn && tempPhotoCompeletionStatus) {
        [self stopDisplayCollectingDialog];
    }
}

- (void)videoFetchingIsCompleted {
    NSLog(@"video completed!");
    BOOL tempVideoCompeletionStatus = self.waitTillVideoCompleteDataIsCollected;
    self.waitTillVideoCompleteDataIsCollected = NO;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.videoNumberLbl.text = [self formattedCountText:CTLocalizedString(CT_VIDEOS, nil) WithCount:[CTDataCollectionManager sharedManager].getNumbersOfVideos];
        if ([CTDataCollectionManager sharedManager].isAllPhotos && [CTDataCollectionManager sharedManager].getNumbersOfVideos > 0) {
//            weakSelf.totalNonZeroiTems++;
            self.selectMask &= ~CTSelectionVideoMask; // reset video flag to 0 if there are any videos in All photos.
        }
        weakSelf.videoDataSizeLbl.text = [NSString formattedDataSizeTextInTransferWhatScreen:[CTDataCollectionManager sharedManager].getSizeOfVideos];
//        [weakSelf setItem:METADATA_ITEMLIST_KEY_VIDEOS withCount:[CTDataCollectionManager sharedManager].getNumbersOfVideos withSize:[CTDataCollectionManager sharedManager].getSizeOfVideos];
        [fileList initItem:METADATA_ITEMLIST_KEY_VIDEOS withCount:[CTDataCollectionManager sharedManager].getNumbersOfVideos withSize:[CTDataCollectionManager sharedManager].getSizeOfVideos];
        
        if (([CTDataCollectionManager sharedManager].getNumberOfUnavailableCountVideosCount > 0) || ([CTDataCollectionManager sharedManager].getNumberOfStreamVideosCount > 0)) {
            weakSelf.videoCloudLbl.hidden = NO;
            weakSelf.videoCloudLbl.textColor = [CTColor primaryRedColor];
            NSInteger totalPhotoCloudNumber = 0;
            if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
                totalPhotoCloudNumber = [CTDataCollectionManager sharedManager].getNumberOfUnavailableCountVideosCount + [CTDataCollectionManager sharedManager].getNumberOfStreamVideosCount;
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"VZTRANSFER_HAS_CLOUD_VIDEO"];
                weakSelf.iCloudInfoLabel.hidden = NO;
                weakSelf.videoCloudLbl.text = [NSString stringWithFormat:CTLocalizedString(CT_IN_ICLOUD_TER_LABEL, nil), (long)totalPhotoCloudNumber];
            } else {
                totalPhotoCloudNumber = [CTDataCollectionManager sharedManager].getNumberOfUnavailableCountVideosCount;
                if (totalPhotoCloudNumber > 0) {
                    weakSelf.videoCloudLbl.text = [NSString stringWithFormat:CTLocalizedString(CT_IN_ICLOUD_TER_LABEL, nil), (long)totalPhotoCloudNumber];
                    weakSelf.iCloudInfoLabel.hidden = NO;
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"VZTRANSFER_HAS_CLOUD_VIDEO"];
                } else {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"VZTRANSFER_HAS_CLOUD_VIDEO"];
                    weakSelf.photoCloudLbl.hidden = YES;
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"VZTRANSFER_HAS_CLOUD_PHOTO"]) {
                        weakSelf.iCloudInfoLabel.hidden = YES;
                    }
                }
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"VZTRANSFER_HAS_CLOUD_VIDEO"];
            weakSelf.videoCloudLbl.hidden = YES;
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"VZTRANSFER_HAS_CLOUD_PHOTO"]) {
                weakSelf.iCloudInfoLabel.hidden = YES;
            }
        }
    });
    
    if (self.videoSelected && self.userClickedTransferBtn && tempVideoCompeletionStatus) {
        [self stopDisplayCollectingDialog];
    }
}

- (void)contactFetchingIsCompleted {
    BOOL tempContactCompletionStatus = self.waitTillContactCompleteDataIsCollected;
    self.waitTillContactCompleteDataIsCollected = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.contactsNumberLbl.text = [self formattedCountText:CTLocalizedString(CT_CONTACTS, nil) WithCount:[CTDataCollectionManager sharedManager].getNumberOfContacts];
        weakSelf.contactsDataSizeLbl.text = [NSString formattedDataSizeTextInTransferWhatScreen:[CTDataCollectionManager sharedManager].getSizeOfContacts];
        [fileList initItem:METADATA_ITEMLIST_KEY_CONTACTS withCount:[CTDataCollectionManager sharedManager].getNumberOfContacts withSize:[CTDataCollectionManager sharedManager].getSizeOfContacts];
        self.blockMask |= CTCollectingContactMask;
        if ([CTDataCollectionManager sharedManager].getNumberOfContacts == 0) {
            self.contactSelected = NO;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:CTTransferItemsTableBreakDown_Contacts inSection:0];
            CTSenderTransferTableViewCell *cell = [weakSelf.transferItemsTableView cellForRowAtIndexPath:indexPath];
            [weakSelf.transferItemsTableView deselectRowAtIndexPath:indexPath animated:YES];
            [weakSelf setMaskForDeselectCellAtIndexPath:indexPath];
            [cell highlightCell:NO];
            self.selectMask |= CTSelectionContactMask; // If number of contact is 0, set contact bit to 1;
        }
        NSLog(@"contact callback check!");
        [self stopIndicator];
    });
    
    if (self.contactSelected && self.userClickedTransferBtn && tempContactCompletionStatus) {
        [self stopDisplayCollectingDialog];
    }
}

- (void)remindersFetchingIsCompleted {
    BOOL tempReminderCompletionStatus = self.waitTillReminderCompleteDataIsCollected;
    self.waitTillReminderCompleteDataIsCollected = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.reminderNumberLbl.text = [self formattedCountText:CTLocalizedString(CT_REMINDERS, nil) WithCount:[CTDataCollectionManager sharedManager].getNumberOfReminders];
        weakSelf.reminderDataSizeLbl.text = [NSString formattedDataSizeTextInTransferWhatScreen:[CTDataCollectionManager sharedManager].getSizeOfReminders];
//        [weakSelf setItem:METADATA_ITEMLIST_KEY_REMINDERS withCount:[CTDataCollectionManager sharedManager].getNumberOfReminders withSize:[CTDataCollectionManager sharedManager].getSizeOfReminders];
        [fileList initItem:METADATA_ITEMLIST_KEY_REMINDERS withCount:[CTDataCollectionManager sharedManager].getNumberOfReminders withSize:[CTDataCollectionManager sharedManager].getSizeOfReminders];
        self.blockMask |= CTCollectingReminderMask;
        NSLog(@"reminder callback check!");
        if([CTDataCollectionManager sharedManager].getNumberOfReminders == 0 && [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
            self.reminderSelected = NO;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:CTTransferItemsTableBreakDown_RemindersOrAudios inSection:0];
            CTSenderTransferTableViewCell *cell = [self.transferItemsTableView cellForRowAtIndexPath:indexPath];
            [self.transferItemsTableView deselectRowAtIndexPath:indexPath animated:YES];
            [self setMaskForDeselectCellAtIndexPath:indexPath];
            [cell highlightCell:NO];
            //        self.totalNonZeroiTems++;
            self.selectMask |= CTSelectionReminderOrAudioMask;
        }
        [self stopIndicator];
    });
    
    if (self.reminderSelected && self.userClickedTransferBtn && tempReminderCompletionStatus) {
        [self stopDisplayCollectingDialog];
    }
}

- (void)calendarsFetchingIsCompleted {
    BOOL tempCalendarCompletionStatus = self.waitTillCalendarCompleteDataIsCollected;
    self.waitTillCalendarCompleteDataIsCollected = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.calendarNumberLbl.text = [self formattedCountText:CTLocalizedString(CT_CALENDERS, nil) WithCount:[CTDataCollectionManager sharedManager].getNumberOfCalendars];
        weakSelf.calendarDataSizeLbl.text = [NSString formattedDataSizeTextInTransferWhatScreen:[CTDataCollectionManager sharedManager].getSizeOfCalendars];
//        [weakSelf setItem:METADATA_ITEMLIST_KEY_CALENDARS withCount:[CTDataCollectionManager sharedManager].getNumberOfCalendars withSize:[CTDataCollectionManager sharedManager].getSizeOfCalendars];
        [fileList initItem:METADATA_ITEMLIST_KEY_CALENDARS withCount:[CTDataCollectionManager sharedManager].getNumberOfCalendars withSize:[CTDataCollectionManager sharedManager].getSizeOfCalendars];
        self.blockMask |= CTCollectingCalendarMask;
        if ([CTDataCollectionManager sharedManager].getNumberOfCalendars == 0) {
            self.calendarSelected = NO;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:CTTransferItemsTableBreakDown_Calenders inSection:0];
            CTSenderTransferTableViewCell *cell = [self.transferItemsTableView cellForRowAtIndexPath:indexPath];
            [self.transferItemsTableView deselectRowAtIndexPath:indexPath animated:YES];
            [self setMaskForDeselectCellAtIndexPath:indexPath];
            [cell highlightCell:NO];
            self.selectMask |= CTSelectionCalendarMask;
            [self updateNextButtonState];
        }
        NSLog(@"calendar callback check!");
        [self stopIndicator];
    });
    
    if (self.calendarSelected && self.userClickedTransferBtn && tempCalendarCompletionStatus) {
        [self stopDisplayCollectingDialog];
    }
}

- (void)audioFetchingIsCompleted {
    BOOL tempAudioCompletionStatus = self.waitTillAudioCompleteDataIsCollected;
    self.waitTillAudioCompleteDataIsCollected = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.audioNumberLbl.text = [self formattedCountText:CTLocalizedString(CT_AUDIO, nil) WithCount:[[CTDataCollectionManager sharedManager] getNumberOfAudios]];
        weakSelf.audioDataSizeLbl.text = [NSString formattedDataSizeTextInTransferWhatScreen:[[CTDataCollectionManager sharedManager] getSizeOfAudio]];
//        [self setItem:METADATA_ITEMLIST_KEY_AUDIOS withCount:[[CTDataCollectionManager sharedManager] getNumberOfAudios] withSize:[[CTDataCollectionManager sharedManager] getSizeOfAudio]];
        [fileList initItem:METADATA_ITEMLIST_KEY_AUDIOS withCount:[[CTDataCollectionManager sharedManager] getNumberOfAudios] withSize:[[CTDataCollectionManager sharedManager] getSizeOfAudio]];
        self.blockMask |= CTCollectingAudioMask;
        if([CTDataCollectionManager sharedManager].getNumberOfAudios == 0 && [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
            self.selectMask |= CTSelectionReminderOrAudioMask;
            // deselect the cell if already selected
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:CTTransferItemsTableBreakDown_RemindersOrAudios inSection:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                CTSenderTransferTableViewCell *cell = [self.transferItemsTableView cellForRowAtIndexPath:indexPath];
                
                [self.transferItemsTableView deselectRowAtIndexPath:indexPath animated:YES];
                [cell highlightCell:NO];
                [self updateNextButtonState];
            });
        }
    });
    
    if (self.audioSelected && self.userClickedTransferBtn && tempAudioCompletionStatus) { // fetch complete callback called after user select transfer with current type
        [self stopDisplayCollectingDialog];
    }
}

#pragma mark - CommPort General Delegate
- (void)commPortSocketDidDisconnected {
    self.commAsyncSocket = nil;
    self.commAsyncSocket.delegate = nil;
    self.commAsyncSocket.generalDelegate = nil;
}

- (void)commPortSocketdidReceivedCancelRequest {
    
    [[CTDataCollectionManager sharedManager] stopCollectDataForExit]; // Stop the collection
    
    // disable the button, make sure press twice not available
    [self.cancelButton setEnabled:NO];
    [self.cancelButton setAlpha:0.4];
    
    [self.delegate ignoreSocketClosedSignal];
    
    [self.readSocket disconnect];
    self.readSocket = nil;
    [self.commAsyncSocket disconnect];
    self.commAsyncSocket = nil;
    
    // Push to error page with cancel analytics
    CTErrorViewController *errorViewController = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
    
    errorViewController.primaryErrorText = CT_USER_INTERRUPTED_TITLE;
    errorViewController.secondaryErrorText = CT_USER_INTERRUPTED_TEXT;
    errorViewController.rightButtonTitle = BUTTON_TITLE_TRY_AGAIN;
    errorViewController.leftButtonTitle = BUTTON_TITLE_RECAP;
    errorViewController.transferStatusAnalytics = CTTransferStatus_Cancelled;
    
    // Assign recap data
    errorViewController.totalDataSentUntillInterrupted = [NSNumber numberWithInteger:0];
    errorViewController.totalDataAmount = 0; // total amount
    errorViewController.transferSpeed = @"0 Mbps";
    errorViewController.transferTime = @"";
    errorViewController.cancelInTransferWhatPage = YES;
    
    [self.navigationController pushViewController:errorViewController animated:YES];
}

- (void)commPortSocketDidReceivedDeviceList {
    self.blockMask |= CTCollectingCommPortMask;
    
    NSLog(@"comport check!");
    [self stopIndicator];
}

#pragma mark - KvO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selectMask"]) { // For test purpose
        NSLog(@"->Select status changed:%@", [self toBinary:self.selectMask]);
    } else if ([keyPath isEqualToString:@"blockMask"]) { // For test purpose
        NSLog(@"->Block status changed: %@", [self toBinary:self.blockMask]);
    }
}
/*!
    @brief Convert integer into binary string. For test purpose, this method used to the check the mask value.
    @param input int value for the mask
    @return NSString value represent binary according to input value.
 */
- (NSString *)toBinary:(NSInteger)input {
    if (input == 1 || input == 0) {
        return [NSString stringWithFormat:@"%ld", (long)input];
    } else {
        return [NSString stringWithFormat:@"%@%ld", [self toBinary:input/2], (long)(input%2)];
    }
}
/*! 
    @brief Remove the observers added to this view controller; This method will only be called when app is running in debug mode.
 */
- (void)removeObserversForDebug {
    @try {
        [self removeObserver:self forKeyPath:@"selectMask"];
        [self removeObserver:self forKeyPath:@"blockMask"];
    } @catch (NSException *exception) {
        NSLog(@"Exception raised when removing the observers, probably no oberver attached yet:%@", exception.description);
    }
}

@end
