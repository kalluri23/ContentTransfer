//
//  CTGetStartedViewController.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/1/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTGetStartedViewController.h"
#import "CTDeviceStatusUtility.h"
#import "CTDeviceSelectionViewController.h"
#import "CTStoryboardHelper.h"
#import "CTAlertCreateFactory.h"
#import "CTContentTransferSetting.h"
#import "CTErrorViewController.h"
#import "CTDeviceMarco.h"
#import "NSString+CTHelper.h"
#import "CTQRCodeSwitch.h"
#import "CTBundle.h"
#import "CTCustomAlertView.h"
#import "NSString+CTRootDocument.h"
#import "VZRemindersImport.h"
#import "VZCalenderEventsImport.h"
#import "CTContactsImport.h"
#import "PhotoStoreHelper.h"
#import "CTDuplicateLists.h"
#import "UITapGestureRecognizer+CTGestureHelper.h"

#import "CTQRCodeSwitch.h"

#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

@interface CTGetStartedViewController ()<UITextFieldDelegate, CalendarImportDelegate, PhotoStoreDelegate, CTAppListDelegate> {
    
    BOOL hasUnsavedVcard;
    BOOL hasUnsavedPhoto;
    BOOL hasUnsavedVideo;
    BOOL hasUnsavedApps;
    BOOL hasUnsavedCalendar;
    BOOL hasUnsavedReminder;
    
    NSString *vcardURL;
    NSString *photoURL;
    NSString *videoURL;
    NSString *calendarURL;
    NSString *reminderURL;
    NSString *appURL;
    
    NSInteger unsavedVcardNum;
    NSInteger unsavedPhotoNum;
    NSInteger unsavedVideoNum;
    NSInteger unsavedCalendarNum;
    NSInteger unsavedReminderNum;
    NSInteger unsavedReminderListNum;
    
    NSArray *unsavedPhotos;
    NSArray *unsavedVideos;
    NSArray *unsavedCalendars;
    NSArray *unsavedApps;
}

@property (nonatomic, strong) CTCustomAlertView *alertView;

@property (atomic, strong) NSMutableDictionary *localDuplicatePhotoList;
@property (atomic, strong) NSMutableDictionary *localDuplicateVideoList;

@property (nonatomic, assign) NSInteger calendarSavedCount;

@property (assign, atomic) NSInteger totalNumber;

@property (assign, nonatomic) BOOL completelyInBackground;

@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, assign) NSRange termsConditionLinkRange;
@property (nonatomic, assign) NSRange privacyPolicyLinkRange;
@property (nonatomic, assign) NSRange aboutLinkRange;

/*! Constraints for the leading margin of rounded icon. Use to adapt the UI for different screen size.*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundIconLeadingConstraints;
@property (weak, nonatomic) IBOutlet CTCommonRedButton *startButton;

@end

// Dummy URL for attributed String
static NSString *kTermsConditionUrl = @"CTDummyAppLink://TermsOfConditions";
static NSString *kPrivacyPolicyUrl  = @"CTDummyAppLink://PrivacyPolicy";
static NSString *kAboutAppUrl       = @"CTDummyAppLink://About";

@implementation CTGetStartedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [CTUserDefaults sharedInstance].batteryAlertSent = [NSNumber numberWithBool:NO];
    
    self.title = NSLocalizedString(CT_GET_STARTED_NAV_TITLE, nil);
    [self.startButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    if ([CTDeviceStatusUtility isDeviceUsingSpanish]) {
        // If it's using spanish, then add 3 extra pixel smaller than system auto adjustment.
        self.startButton.titleLabel.font = [UIFont fontWithName:self.startButton.titleLabel.font.fontName size:self.startButton.titleLabel.font.pointSize - 4];
    }
    self.progressView.hidden = YES;
    self.completelyInBackground = NO;
    
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
    
    if (STANDALONE == 1) { // Setup for standalone
        self.clickableLabel.hidden = NO;
        
        [self setNavigationControllerMode:CTNavigationControllerMode_None];
        
        self.secondaryTextLabel.text = NSLocalizedString(CT_GET_STRATED_PRIMARY_MESSGE, nil);
        // Attributed link
        NSMutableAttributedString *attiStr = [[NSMutableAttributedString alloc] initWithString:self.clickableLabel.text];
        NSString *tncString = NSLocalizedString(CT_TNC_LINK, nil);
        self.termsConditionLinkRange = NSMakeRange(self.clickableLabel.text.length - tncString.length, tncString.length);
        [attiStr addAttribute:NSLinkAttributeName value:kTermsConditionUrl range:self.termsConditionLinkRange];
        [attiStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:self.termsConditionLinkRange];
        [attiStr addAttribute:NSUnderlineColorAttributeName value:[UIColor clearColor] range:self.termsConditionLinkRange];
        if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0")) {
            [attiStr addAttribute:NSFontAttributeName value:[CTMVMFonts mvmBookFontOfSize:10.5f] range:NSMakeRange(0, attiStr.length)];
        }
        
        [attiStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:75/255.0 green:145/255.0 blue:222/255.0 alpha:1.0] range:self.termsConditionLinkRange];

        self.clickableLabel.attributedText = attiStr;
        
        // Add User interaction for hyper link
        self.clickableLabel.userInteractionEnabled = YES;
        [self.clickableLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(termsAndConditionClicked:)]];
        
        // PP & About attributed link
        attiStr = [[NSMutableAttributedString alloc] initWithString:self.ppAndAboutLbl.text];
        // Privacy Policy Link
        NSString *privacyPolicyText = NSLocalizedString(CT_PRIVACY_POLICY_HYPERLINK, nil);
//        NSString *seperatorText = @"   |   ";
        NSString *aboutText = NSLocalizedString(CT_ABOUT_HPERLINK, nil);
        self.privacyPolicyLinkRange = NSMakeRange(0, privacyPolicyText.length);
        [attiStr addAttribute:NSLinkAttributeName value:kPrivacyPolicyUrl range:self.privacyPolicyLinkRange];
        [attiStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:self.privacyPolicyLinkRange];
        [attiStr addAttribute:NSUnderlineColorAttributeName value:[UIColor clearColor] range:self.privacyPolicyLinkRange];
        
        // About Link
        self.aboutLinkRange = NSMakeRange(attiStr.length - aboutText.length, aboutText.length);
        [attiStr addAttribute:NSLinkAttributeName value:kAboutAppUrl range:self.aboutLinkRange];
        [attiStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:self.aboutLinkRange];
        [attiStr addAttribute:NSUnderlineColorAttributeName value:[UIColor clearColor] range:self.aboutLinkRange];
        
        [attiStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:75/255.0 green:145/255.0 blue:222/255.0 alpha:1.0] range:self.privacyPolicyLinkRange];
        [attiStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:75/255.0 green:145/255.0 blue:222/255.0 alpha:1.0] range:self.aboutLinkRange];
        
        if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0")) {
            [attiStr addAttribute:NSFontAttributeName value:[CTMVMFonts mvmBookFontOfSize:10.5f] range:NSMakeRange(0, attiStr.length)];
        }
        
        self.ppAndAboutLbl.attributedText = attiStr;
        
        // Add User interaction for hyper link
        self.ppAndAboutLbl.userInteractionEnabled = YES;
        [self.ppAndAboutLbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLabelClicked:)]];
        
        // Adapt UI
        if (IS_STANDARD_IPHONE_4_OR_LESS) {
            self.bottomMargin.constant /= 2;
            self.secondaryLabelTopMarginConstaint.constant = 0.0;
            self.clickableLabelTopMarginConstraint.constant = 0.0;
            self.roundIconLeadingConstraints.constant += 42.0;
        } else if (IS_STANDARD_IPHONE_5) {
            self.roundIconLeadingConstraints.constant += 20.0;
        } else if (IS_STANDARD_IPHONE_6_PLUS == 1 || IS_STANDARD_IPHONE_6 == 1) {
            self.bottomMargin.constant = 20.0;
            if (IS_STANDARD_IPHONE_6) {
                self.roundIconLeadingConstraints.constant += 20.0;
            }
        } else if ([CTDeviceMarco isiPhoneX]) {
            self.titleTopMarginConstraint.constant *= 2;
            self.bottomMargin.constant = 20.0;
        }
    } else { // Setup for framework
        self.clickableLabel.hidden = YES;
        
        [self setNavigationControllerMode:CTNavigationControllerMode_QuitAndHamburgar];
        
        // PP & About attributed link
        NSMutableAttributedString *attiStr = [[NSMutableAttributedString alloc] initWithString:@" About "];
        // About Link
        self.aboutLinkRange = NSMakeRange(1, 5);
        [attiStr addAttribute:NSLinkAttributeName value:kAboutAppUrl range:self.aboutLinkRange];
        [attiStr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:self.aboutLinkRange];
        [attiStr addAttribute:NSUnderlineColorAttributeName value:[UIColor clearColor] range:self.aboutLinkRange];
        [attiStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:75/255.0 green:145/255.0 blue:222/255.0 alpha:1.0] range:self.aboutLinkRange];
        
        self.ppAndAboutLbl.attributedText = attiStr;
        
        // Add User interaction for hyper link
        self.ppAndAboutLbl.userInteractionEnabled = YES;
        [self.ppAndAboutLbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLabelClicked:)]];
        
        self.secondaryTextLabel.textAlignment = NSTextAlignmentCenter;
        
        // Update UI
        if (IS_STANDARD_IPHONE_4_OR_LESS) {
            self.bottomMargin.constant /= 2;
            self.secondaryLabelTopMarginConstaint.constant = 0.0;
            self.clickableLabelTopMarginConstraint.constant = 0.0;
            self.roundIconLeadingConstraints.constant += 30.0;
        } else if ([CTDeviceMarco isiPhoneX]) {
            self.titleTopMarginConstraint.constant *= 2;
            self.bottomMargin.constant = 20.0;
        }
    }
    
    if (IS_IPAD) {
        if (IS_IPAD_PRO) {
            self.titleTopMarginConstraint.constant *= 2;
            self.bottomMargin.constant = 75.0;
            self.roundIconLeadingConstraints.constant *= 20;
            self.labelLeading.constant *= 20;
        } else {
            self.titleTopMarginConstraint.constant *= 2;
            self.bottomMargin.constant = 75.0;
            self.roundIconLeadingConstraints.constant *= 15;
            self.labelLeading.constant *= 10;
        }
    }
    
    // Check unsaved data here...
    [self checkUnsavedDataForDevice];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.textContainer.size = self.clickableLabel.bounds.size;
    if (STANDALONE && IS_STANDARD_IPHONE_4_OR_LESS) {
        // Change size of title in standalone iphone 4 to fit screen size, no need to change in framework because framework doesn't have clickable label.
        self.primaryMessageLabel.font = [self.primaryMessageLabel.font fontWithSize:19.f];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Local DB Analytics
    NSString *udid = [NSString generateUDID];
    [[CTUserDevice userDevice] setGlobalUDID:[udid lowerUDIDString]];
    [[CTUserDevice userDevice] setDeviceUDID:[udid lowerUDIDString]];
    NSLog(@"UDID %@",[CTUserDevice userDevice].deviceUDID);
    
    // Clear local storage for analytics
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
    [userDefaults removeObjectForKey:USER_DEFAULTS_PAIRING_MODEL];
    [userDefaults removeObjectForKey:USER_DEFAULTS_PAIRING_OS_VERSION];
    [userDefaults removeObjectForKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
    
    // Newly added for failure handshake
    [userDefaults removeObjectForKey:@"transferFailureCounts"];
    [userDefaults removeObjectForKey:@"transferFailureSize"];
    [userDefaults setObject:[NSNumber numberWithLongLong:0] forKey:@"totalFailureSize"];
    
    [CTUserDevice userDevice].pairingType = kNotDecided;
    [CTUserDevice userDevice].connectedNetworkName = kNotDecided;
    [CTUserDevice userDevice].deviceCount = -1;
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"transferIsOneToMany"]; // Default value is NO.
    
    if ([[CTQRCodeSwitch uniqueSwitch] isOn]) {
        [CTUserDefaults sharedInstance].scanType = CTScanQR;
    } else {
        [CTUserDefaults sharedInstance].scanType = CTScanManual;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceBatteryStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceBatteryLevelDidChangeNotification
                                                  object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)termsAndConditionClicked:(UITapGestureRecognizer *)tapGesture {
    BOOL didClickedURL = [tapGesture didTapAttributedTextInLabel:self.clickableLabel inRange:self.termsConditionLinkRange alignment:self.clickableLabel.textAlignment];
    if (didClickedURL) {
        // Open terms & condition page
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *vc = [[CTStoryboardHelper devicesStoryboard] instantiateViewControllerWithIdentifier:@"eulaScreen"];
            vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self.navigationController pushViewController:vc animated:YES];
        });
    }
}

- (void)buttonLabelClicked:(UITapGestureRecognizer *)tapGesture {
#if STANDALONE
    BOOL didClickedURL = [tapGesture didTapAttributedTextInLabel:self.ppAndAboutLbl inRange:self.privacyPolicyLinkRange alignment:self.ppAndAboutLbl.textAlignment];
    if (didClickedURL) {
        // Open privacy policy
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handlePrivacyPolicyButtonTapped:self];
        });
    } else {
        didClickedURL = [tapGesture didTapAttributedTextInLabel:self.ppAndAboutLbl inRange:self.aboutLinkRange alignment:self.ppAndAboutLbl.textAlignment];
        if (didClickedURL) {
            // Open about prompt
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleInfoButtonTapped:self];
            });
        }
    }
#else
    BOOL didClickedURL = [tapGesture didTapAttributedTextInLabel:self.ppAndAboutLbl inRange:self.aboutLinkRange alignment:self.ppAndAboutLbl.textAlignment];
    if (didClickedURL) {
        // Open privacy policy
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleInfoButtonTapped:self];
        });
    }
#endif
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    self.completelyInBackground = YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (self.completelyInBackground) {
        self.completelyInBackground = NO;
        [self checkUnsavedDataForDevice];
    }
}

#pragma mark UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.text.length>=10 && range.length==0) {
        return NO;
    }
    
    return YES;
    
}

- (void)showLowBatteryScreen {
    
    CTErrorViewController *batteryErrorScreen = [CTErrorViewController initialiseFromStoryboard:[CTStoryboardHelper commonStoryboard]];
    
    batteryErrorScreen.primaryErrorText = NSLocalizedString(ALERT_TITLE_PLUG_IN_AND_CHARGE_UP, nil);
    batteryErrorScreen.secondaryErrorText = NSLocalizedString(ALERT_MESSAGE_BATTERY_WARNING_MESSAGE, nil);
    batteryErrorScreen.rightButtonTitle = NSLocalizedString(BUTTON_TITLE_GOT_IT, nil);
    batteryErrorScreen.transferStatusAnalytics = CTTransferStatus_Battery_Check;
    
    [self.navigationController pushViewController:batteryErrorScreen animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [batteryErrorScreen.rightButton removeTarget:batteryErrorScreen action:@selector(handleRightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [batteryErrorScreen.rightButton addTarget:self action:@selector(handleRightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    });
}

- (void)showDeviceSelectionScreen {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        CTDeviceSelectionViewController *deviceSelectionViewController = (CTDeviceSelectionViewController *)[CTDeviceSelectionViewController initialiseFromStoryboard:[CTStoryboardHelper devicesStoryboard]];
        [self.navigationController pushViewController:deviceSelectionViewController animated:YES];
    }else {
        [self performSegueWithIdentifier:NSStringFromClass([CTDeviceSelectionViewController class]) sender:nil];
    }
}

- (IBAction)handleRightButtonTapped:(id)sender {
    
    if ([CTDeviceStatusUtility isLowBattery]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self showDeviceSelectionScreen];
    }
}

- (IBAction)handleGetStartedTapped:(id)sender {
    [self navigateToNextScreen];
}

-(void)onKeyboardHide:(NSNotification*)notification{
    
    [self navigateToNextScreen];

}

-(void)navigateToNextScreen{
    if ([CTDeviceStatusUtility isLowBattery]) {
        // Show low battery screen
        [self showLowBatteryScreen];
    }else {
        [self showDeviceSelectionScreen];
    }
}

- (IBAction)handlePrivacyPolicyButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:@"http://www.verizon.com/about/privacy/privacy-policy-summary"]];
}

- (IBAction)handleInfoButtonTapped:(id)sender {
    // Date
    NSString *stringDate = @"";
#if STANDALONE
    stringDate = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CTBuildDate"];
#else
    stringDate = FRAMEWORK_BUILD_DATE;
#endif
    
    // Build version
    NSString *stringVer = @"";
#ifdef DEBUG // Debug build & QA-Release build
    stringVer = [NSString stringWithFormat:NSLocalizedString(CT_GET_STARTED_INFO_ALERT_CONTEXT, nil), BUILD_VERSION_FULL, stringDate];
#else // Store-Release build
    stringVer = [NSString stringWithFormat:NSLocalizedString(CT_GET_STARTED_INFO_ALERT_CONTEXT, nil), BUILD_VERSION, stringDate];
#endif
    
    // Show alert
    if (USES_CUSTOM_VERIZON_ALERTS) {
        [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:kDefaultAppTitle
                                                             context:stringVer
                                                             btnText:NSLocalizedString(CT_OK_ALERT_BUTTON_TITLE, nil)
                                                             handler:nil
                                                            isGreedy:NO from:self];
    } else {
        [CTAlertCreateFactory showSingleButtonsAlertWithTitle:kDefaultAppTitle
                                                      context:stringVer
                                                      btnText:NSLocalizedString(CT_OK_ALERT_BUTTON_TITLE, nil)
                                                      handler:nil
                                                     isGreedy:NO];
    }
}

- (void)pushToAppListView {
    CTAppListViewController *targetViewController = [[CTAppListViewController alloc] initWithNibName:@"AppListViewController" bundle:[CTBundle resourceBundle]];
    targetViewController.normalProcess = false;
    targetViewController.delegate = self;
    [self.navigationController pushViewController:targetViewController animated:YES];
}

#pragma mark - Continue Save Logic
- (void)checkUnsavedDataForDevice {
    // Check unsaved data (photos & videos) from last transfer
    __weak typeof(self) weakSelf = self;
    [self displayUnsavedDataRequestDialogSaving:^{
        // should save unsaved data
        _alertView = [[CTCustomAlertView alloc] initCustomAlertViewWithText:NSLocalizedString(CT_SAVING_DATA, nil) withOritation:CTAlertViewOritation_VERTICAL];
        [_alertView show:^{
            [weakSelf saveFiles];
        }];
    } delete:^{
        // should delete unsaved data
        _alertView = [[CTCustomAlertView alloc] initCustomAlertViewWithText:NSLocalizedString(CT_DELETE_DATA, nil) withOritation:CTAlertViewOritation_VERTICAL];
        [_alertView show:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [weakSelf deleteFiles];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_alertView becomeFinishView:NO];
                    [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(shouldDismissProgressView) userInfo:nil repeats:NO];
                });
            });
        }];
    }];
}

- (void)shouldDismissProgressView {
    [_alertView hide:nil];
}

- (void)displayUnsavedDataRequestDialogSaving:(void(^)(void))save
                                       delete:(void(^)(void))delete {
    // Check the vcard file existence
    vcardURL = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZAllContactBackup.vcf"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:vcardURL]) {
        hasUnsavedVcard = YES;
        unsavedVcardNum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CONTACTS_TOTAL_COUNT"] integerValue];
    }
    
    // Check the reminder file existence
    reminderURL = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"reminderLogFile.txt"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:reminderURL]) {
        hasUnsavedReminder = YES;
        
        NSArray *reminderCounts = [VZRemindersImport getTotalReminderCountForSpecificFile:reminderURL];
        unsavedReminderListNum = [reminderCounts[0] integerValue];
        unsavedReminderNum = [reminderCounts[1] integerValue];
    }
    
    // Check the calendar file existence
    calendarURL = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"ReceivedCal"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:calendarURL]) {
        unsavedCalendars = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:calendarURL error:nil];
        DebugLog(@"has calendars:%lu", (unsigned long)unsavedCalendars.count);
        //        unsavedCalendarNum = unsavedCalendars.count;
        if (unsavedCalendars.count > 0) {
            hasUnsavedCalendar = YES;
        }
    }
    
    // Check the photo folder existence
    photoURL = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferPhoto"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:photoURL]) {
        unsavedPhotos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:photoURL error:nil];
        DebugLog(@"has photos:%lu", (unsigned long)unsavedPhotos.count);
        unsavedPhotoNum = unsavedPhotos.count;
        if (unsavedPhotoNum > 0) {
            hasUnsavedPhoto = YES;
        }
    }
    
    // Check the video folder existence
    videoURL = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferVideo"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoURL]) {
        unsavedVideos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:videoURL error:nil];
        DebugLog(@"has videos:%lu", (unsigned long)unsavedVideos.count);
        unsavedVideoNum = unsavedVideos.count;
        if (unsavedVideoNum > 0) {
            hasUnsavedVideo = YES;
        }
    }
    
    // Check the apps folder existence
    appURL = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"ReceivedAppIcons"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:appURL]) {
        unsavedApps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appURL error:nil];
        DebugLog(@"has apps icon:%lu", (unsigned long)unsavedApps.count);
        if (unsavedApps.count > 0) {
            hasUnsavedApps = YES;
        }
    }
    
    if (hasUnsavedVcard || hasUnsavedReminder || hasUnsavedPhoto || hasUnsavedVideo || hasUnsavedApps) { // if has any unsaved data
    
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] init];
        
        NSMutableParagraphStyle *leftParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        [leftParagraphStyle setAlignment:NSTextAlignmentLeft];
        
        NSString *dialogTitle = NSLocalizedString(kDefaultAppTitle, nil);
        
        NSString *title = NSLocalizedString(CT_DETECTED_UNSAVED_DATA_ALERT_CONTEXT, nil);
        [attributedStr appendAttributedString:[self makeAttributed:title withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];
        [attributedStr appendAttributedString:[self makeAttributed:@"\n" withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];
        
        if (hasUnsavedVcard) {
            [attributedStr appendAttributedString:[self makeAttributed:[NSString stringWithFormat:@"\n•  %@: %ld", NSLocalizedString(CT_CONTACTS, nil), (long)unsavedVcardNum] withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];
        }
        
        if (hasUnsavedPhoto) {
            [attributedStr appendAttributedString:[self makeAttributed:[NSString stringWithFormat:@"\n•  %@: %ld",NSLocalizedString(CT_PHOTOS, nil), (long)unsavedPhotoNum] withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];
        }
        
        if (hasUnsavedVideo) {
            [attributedStr appendAttributedString:[self makeAttributed:[NSString stringWithFormat:@"\n•  %@: %ld", NSLocalizedString(CT_VIDEOS, nil), (long)unsavedVideoNum] withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];
        }
        
        if (hasUnsavedReminder) {
            [attributedStr appendAttributedString:[self makeAttributed:[NSString stringWithFormat:@"\n•  %@: %ld", NSLocalizedString(CT_REMINDERS, nil), (long)unsavedReminderListNum] withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];
        }
        
        if (hasUnsavedCalendar) {
            [[[VZCalenderEventsImport alloc] init] getTotalCalendarEventCount:^(NSInteger eventCount) { // get the event count, not the file number
                unsavedCalendarNum = eventCount;
                [attributedStr appendAttributedString:[self makeAttributed:[NSString stringWithFormat:@"\n•  %@: %ld",NSLocalizedString(CT_CALENDERS, nil), (long)unsavedCalendarNum] withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];
                
                if (hasUnsavedApps) {
                    [attributedStr appendAttributedString:[self makeAttributed:[NSString stringWithFormat:@"\n•  %@",NSLocalizedString(CT_APPS_LIST, nil)] withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];
                }
                
                [attributedStr appendAttributedString:[self makeAttributed:@"\n" withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];
                
                [self buildAlertWithAttributedTitle:[self makeAttributed:dialogTitle withFont:[CTMVMFonts mvmBoldFontOfSize:16.f] style:nil] andAttributedText:attributedStr saving:save delete:delete];
            }];
        } else {
            if (hasUnsavedApps) {
                [attributedStr appendAttributedString:[self makeAttributed:[NSString stringWithFormat:@"\n•  %@",NSLocalizedString(CT_APPS_LIST, nil)] withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];
            }
            
            [attributedStr appendAttributedString:[self makeAttributed:@"\n" withFont:[CTMVMFonts mvmBookFontOfSize:14.f] style:leftParagraphStyle]];
            
            [self buildAlertWithAttributedTitle:[self makeAttributed:dialogTitle withFont:[CTMVMFonts mvmBoldFontOfSize:16.f] style:nil] andAttributedText:attributedStr saving:save delete:delete];
        }
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

- (void)buildAlertWithAttributedTitle:(NSAttributedString *)title andAttributedText:(NSAttributedString *)text saving:(void(^)(void))save delete:(void(^)(void))delete  {
    
    if (USES_CUSTOM_VERIZON_ALERTS)  {
        [CTVerizonAlertCreateFactory showTwoButtonsAlertWithAttributedTitle:title attributedContext:text cancelBtnText:NSLocalizedString(CT_DELETE_ALERT_BUTTON_TITLE, nil) confirmBtnText:NSLocalizedString(CT_SAVE_ALERT_BUTTON_TITLE, nil) confirmHandler:^(CTVerizonAlertViewController *alertVC){
            save();
        }cancelHandler:^(CTVerizonAlertViewController *alertVC){
            delete();
        } isGreedy:NO from:self];
    }else {
        if ([UIAlertController class] != nil) { // only iOS 8 and above can be receiver side, so no UIAlertView, only UIAlertController
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            [alert setValue:title forKey:@"attributedTitle"];
            [alert setValue:text forKey:@"attributedMessage"];
            
            UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(CT_SAVE_ALERT_BUTTON_TITLE, nil)
                                                                 style:UIAlertActionStyleDestructive
                                                               handler:^(UIAlertAction * _Nonnull action) {
                                                                   save();
                                                               }];
            UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(CT_DELETE_ALERT_BUTTON_TITLE, nil)
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     delete();
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
    }
}

- (void)saveFiles {
    if (hasUnsavedVcard) {
        [self startSavingContacts];
        return;
    }
    
    if (hasUnsavedReminder) {
        [self startUnsavedReminders];
        return;
    }
    
    if (hasUnsavedCalendar) {
        [self startSavingCalendars];
        return;
    }
    
    if (hasUnsavedPhoto) {
        [self startSavingPhotos];
        return;
    } else {
        // Clear the photo list in local
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"photoFilteredFileList"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"photoFileList"];
    }
    
    if (hasUnsavedVideo) {
        [self startSavingVideos];
        return;
    } else {
        // Clear the video list in local
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"videoFilteredFileList"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"videoFileList"];
    }
    
    if (hasUnsavedApps) {
        hasUnsavedApps = NO;
        [_alertView hide:^{ // Push to app list
            [self pushToAppListView];
        }];
        
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_alertView becomeFinishView:YES];
        [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(shouldDismissProgressView) userInfo:nil repeats:NO];
    });
}

#pragma mark - Delete all unsaved data
- (void)deleteFiles {
    
    // Clear file list
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"photoFileList"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"photoFilteredFileList"];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"videoFilteredFileList"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"videoFileList"];
    
    // Delete physical files
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    if (hasUnsavedVcard) { // Contacts
        BOOL success = [fm removeItemAtPath:vcardURL error:nil];
        if (!success) {
            // Don't need to handle the delete fail, because next time user transfer, folder will be clear
            DebugLog(@"delete failed! Error:%@", error.localizedDescription);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_alertView updateLbelText:[NSString stringWithFormat:@"%@ : %ld / %ld", NSLocalizedString(CT_DELETED_CONTACTS_MESSAGE, nil), (long)unsavedVcardNum, (long)unsavedVcardNum] oritation:CTAlertViewOritation_VERTICAL];
            });
        }
        
        hasUnsavedVcard = NO;
    }
    
    if (hasUnsavedReminder) { // Reminders
        BOOL success = [fm removeItemAtPath:reminderURL error:nil];
        if (!success) {
            // Don't need to handle the delete fail, because next time user transfer, folder will be clear
            DebugLog(@"delete failed! Error:%@", error.localizedDescription);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_alertView updateLbelText:[NSString stringWithFormat:@"%@ : %ld / %ld", NSLocalizedString(CT_DELETED_REMINDERS_MESSAGE, nil), (long)unsavedReminderNum, (long)unsavedReminderNum] oritation:CTAlertViewOritation_VERTICAL];
            });
        }
        
        hasUnsavedReminder = NO;
    }
    
    if (hasUnsavedCalendar) {
        __block int calendarDeleteCount = 0;
        for (NSString *file in unsavedCalendars) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", calendarURL, file] error:&error];
            if (!success) {
                // Don't need to handle the delete fail, because next time user transfer, folder will be clear
                DebugLog(@"delete failed! Error:%@", error.localizedDescription);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_alertView updateLbelText:[NSString stringWithFormat:@"%@ : %d / %lu", NSLocalizedString(CT_DELETED_CALANDERS_MESSAGE, nil), ++calendarDeleteCount, (unsigned long)unsavedCalendars.count] oritation:CTAlertViewOritation_VERTICAL];
                });
            }
        }
        
        hasUnsavedCalendar = NO;
    }
    
    if (hasUnsavedPhoto) {
        __block int photoDeleteCount = 0;
        for (NSString *file in unsavedPhotos) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", photoURL, file] error:&error];
            if (!success) {
                // Don't need to handle the delete fail, because next time user transfer, folder will be clear
                DebugLog(@"delete failed! Error:%@", error.localizedDescription);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_alertView updateLbelText:[NSString stringWithFormat:@"%@ : %d / %lu", NSLocalizedString(CT_DELETED_PHOTOS_MESSAGE, nil), ++photoDeleteCount, (unsigned long)unsavedPhotos.count] oritation:CTAlertViewOritation_VERTICAL];
                });
            }
        }
        
        hasUnsavedPhoto = NO;
    }
    
    if (hasUnsavedVideo) {
        __block int videoDeleteCount = 0;
        for (NSString *file in unsavedVideos) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", videoURL, file] error:&error];
            if (!success) {
                // Don't need to handle the delete fail, because next time user transfer, folder will be clear
                DebugLog(@"delete failed! Error:%@", error.localizedDescription);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_alertView updateLbelText:[NSString stringWithFormat:@"%@ : %d / %lu", NSLocalizedString(CT_DELETE_VIDEOS, nil), ++videoDeleteCount, (unsigned long)unsavedVideos.count] oritation:CTAlertViewOritation_VERTICAL];
                });
            }
        }
        
        hasUnsavedVideo = NO;
    }
    
    if (hasUnsavedApps) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertView updateLbelText:NSLocalizedString(CT_DELETE_APPS_LIST, nil) oritation:CTAlertViewOritation_VERTICAL];
        });
        
        for (NSString *file in unsavedApps) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", appURL, file] error:&error];
            if (!success) {
                // Don't need to handle the delete fail, because next time user transfer, folder will be clear
                DebugLog(@"delete failed! Error:%@", error.localizedDescription);
            }
        }
        
        hasUnsavedApps = NO;
    }
}

#pragma mark - Save contacts
- (void)startSavingContacts {
    NSData *vcardData = [[NSFileManager defaultManager] contentsAtPath:vcardURL];
    if (vcardData && vcardData.length > 0) {
        NSInvocationOperation *newoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(importVcardData:) object:vcardData];
        [[[NSOperationQueue alloc] init] addOperation:newoperation];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:vcardURL error:nil]; // Remove the contact file
        hasUnsavedVcard = NO;
        [self saveFiles];
    }
}

- (void)importVcardData:(NSData *)vcardData {
    __block int updateNumber = 0;
    // Should Update UI
    CTContactsImport *vCardImport = [[CTContactsImport alloc] init];
    
    __weak typeof(self) weakSelf = self;
    vCardImport.completionHandler = ^(NSInteger contactNumber) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertView updateLbelText:[NSString stringWithFormat:@"%@: %ld / %ld", NSLocalizedString(CT_SAVING_CONTACTS, nil), (long)contactNumber, (long)unsavedVcardNum] oritation:CTAlertViewOritation_VERTICAL];
        });
        
        // If success, remove the contact file
        [[NSFileManager defaultManager] removeItemAtPath:vcardURL error:nil];
        
        hasUnsavedVcard = NO;
        [weakSelf saveFiles];
    };
    
    vCardImport.updateHandler = ^(NSInteger updateCount) {
        updateNumber += updateCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertView updateLbelText:[NSString stringWithFormat:@"%@: %d / %ld", NSLocalizedString(CT_SAVING_CONTACTS, nil), updateNumber, (long)unsavedVcardNum] oritation:CTAlertViewOritation_VERTICAL];
        });
    };
    
    [vCardImport importAllVcard:vcardData];
}

#pragma mark - Save reminders
- (void)startUnsavedReminders {
    NSInvocationOperation *newoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(importReminder) object:nil];
    [[[NSOperationQueue alloc] init] addOperation:newoperation];
}

- (void)importReminder {
    __weak typeof(self) weakSelf = self;
    VZRemindersImport *reminderImport = [[VZRemindersImport alloc] init];
    reminderImport.completionHandler = ^(NSInteger totalReminderEventSaved, NSInteger totalReminderEventCount, NSInteger actualSavedListCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertView updateLbelText:[NSString stringWithFormat:@"%@: %ld / %ld", NSLocalizedString(CT_SAVING_REMINDERS, nil), (long)totalReminderEventSaved, (long)unsavedReminderNum] oritation:CTAlertViewOritation_VERTICAL];
        });
        
        // If success, remove the reminder file
        [[NSFileManager defaultManager] removeItemAtPath:reminderURL error:nil];
        
        hasUnsavedReminder = NO;
        [weakSelf saveFiles];
        
    };
    
    reminderImport.updateHandler = ^(NSInteger reminderUpdateCount, NSInteger totalReminderEventCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertView updateLbelText:[NSString stringWithFormat:@"%@: %ld / %ld", NSLocalizedString(CT_SAVING_REMINDERS, nil), (long)reminderUpdateCount, (long)unsavedReminderNum] oritation:CTAlertViewOritation_VERTICAL];
        });
    };
    
    [reminderImport importAllReminder:YES];
}

#pragma mark - Save Calendars
- (void)startSavingCalendars {
    NSInvocationOperation *newoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(importCalendar) object:nil];
    [[[NSOperationQueue alloc] init] addOperation:newoperation];
}

- (void)importCalendar {
    VZCalenderEventsImport *calendarImport = [[VZCalenderEventsImport alloc] init];
    calendarImport.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    [calendarImport createCalendarsSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertView updateLbelText:[NSString stringWithFormat:@"%@: %ld / %ld", NSLocalizedString(CT_SAVING_CALENDERS, nil), (long)unsavedCalendarNum, (long)unsavedCalendarNum] oritation:CTAlertViewOritation_VERTICAL];
        });
        
        hasUnsavedCalendar = NO;
        [weakSelf saveFiles];
    } failure:^{
        DebugLog(@"saving calendar failed");
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertView updateLbelText:[NSString stringWithFormat:@"%@: %ld / %ld", NSLocalizedString(CT_SAVING_CALENDERS, nil), (long)unsavedCalendarNum, (long)unsavedCalendarNum] oritation:CTAlertViewOritation_VERTICAL];
        });
        
        hasUnsavedCalendar = NO;
        [weakSelf saveFiles];
    }];
}

- (void)shouldUpdateCalendarNumber:(NSInteger)eventCount {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.calendarSavedCount += eventCount;
        [_alertView updateLbelText:[NSString stringWithFormat:@"%@: %ld / %ld", NSLocalizedString(CT_SAVING_CALENDERS, nil), (long)_calendarSavedCount, (long)unsavedCalendarNum] oritation:CTAlertViewOritation_VERTICAL];
    });
}

#pragma mark - Save Photos
- (void)startSavingPhotos {
    _totalNumber = unsavedPhotoNum;
    
    NSDictionary *photoDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"photoFileList"];
    
    NSMutableArray *photoList = [[NSMutableArray alloc] init];
    for (NSString *fileName in unsavedPhotos) {
        NSMutableDictionary *photoInfo = [(NSDictionary *)[photoDic valueForKey:fileName] mutableCopy];
        if (photoInfo) {
            [photoInfo setObject:fileName forKey:@"Path"];
            [photoList addObject:photoInfo];
        }
    }
    
    NSArray *dataSet = @[photoList];
    // should save photos
    PhotoStoreHelper *helper = [[PhotoStoreHelper alloc] initWithOperationDelegate:self andRootPath:photoURL andDataSets:dataSet];
    helper.isCrossPlatform = NO;
    [helper startSavingPhotos];
}

- (void)updateDuplicatePhoto:(NSString *)URL withPhotoInfo:(NSDictionary *)photoInfo withLocalIdentifier:(NSString *)localIdentifier success:(BOOL)success orError:(NSError *)error {
    DebugLog(@"->saved:%@", [photoInfo objectForKey:@"Path"]);
    
    // Clear the temp file in the folder for successfully saved photo
    if (URL)
        [[NSFileManager defaultManager] removeItemAtPath:URL error:nil];
    
    @synchronized (self) {
        unsavedPhotoNum --;
    }
    
    // If save success, add local identifier for duplicate logic
    if (success && localIdentifier) {
        if (!self.localDuplicatePhotoList) {
            self.localDuplicatePhotoList = [[NSMutableDictionary alloc] init];
        }
        
        [self.localDuplicatePhotoList setObject:localIdentifier forKey:[URL lastPathComponent]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_alertView updateLbelText:[NSString stringWithFormat:@"%@: %ld / %ld", NSLocalizedString(CT_SAVING_PHOTOS, nil), (long)_totalNumber-(long)unsavedPhotoNum, (long)_totalNumber] oritation:CTAlertViewOritation_VERTICAL];
    });
    
    if (unsavedPhotoNum == 0) {
        [[CTDuplicateLists uniqueList] updatePhotos:self.localDuplicatePhotoList];
        hasUnsavedPhoto = NO;
        [self saveFiles];
    }
}

#pragma mark - Save videos
- (void)startSavingVideos {
    // should save videos
    _totalNumber = unsavedVideoNum;
    
    NSDictionary *videoDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"videoFileList"];
    
    NSMutableArray *videoList = [[NSMutableArray alloc] init];
    for (NSString *fileName in unsavedVideos) {
        NSMutableDictionary *videoInfo = [(NSDictionary *)[videoDic valueForKey:fileName] mutableCopy];
        if (videoInfo) {
            [videoInfo setObject:fileName forKey:@"Path"];
            [videoList addObject:videoInfo];
        }
    }
    
    NSArray *dataSet = @[videoList];
    // should save photos
    PhotoStoreHelper *helper = [[PhotoStoreHelper alloc] initWithOperationDelegate:self andRootPath:videoURL andDataSets:dataSet];
    helper.isCrossPlatform = NO;
    [helper startSavingVideos];
}

- (void)updateDuplicateVideo:(NSString *)URL withVideoInfo:(NSDictionary *)videoInfo withLocalIdentifier:(NSString *)localIdentifier success:(BOOL)success orError:(NSError *)error {
    DebugLog(@"->saved:%@", [videoInfo objectForKey:@"Path"]);
    
    // Clear the temp file in the folder for successfully saved photo
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (URL)
            [[NSFileManager defaultManager] removeItemAtPath:URL error:nil];
    });
    
    @synchronized (self) {
        unsavedVideoNum --;
    }
    
    if ((success || (!success && error && error.code != 502)) && localIdentifier) {
        if (!self.localDuplicateVideoList) {
            self.localDuplicateVideoList = [[NSMutableDictionary alloc] init];
        }
        
        [self.localDuplicateVideoList setObject:localIdentifier forKey:[URL lastPathComponent]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_alertView updateLbelText:[NSString stringWithFormat:@"%@: %ld / %ld", NSLocalizedString(CT_SAVING_VIDEOS, nil), (long)_totalNumber-(long)unsavedVideoNum, (long)_totalNumber] oritation:CTAlertViewOritation_VERTICAL];
    });
    
    if (unsavedVideoNum == 0) {
        // Save duplicate list for video
        [[CTDuplicateLists uniqueList] updateVideos:self.localDuplicateVideoList];
        hasUnsavedVideo = NO;
        [self saveFiles];
    }
}

- (void)CTAppListWillPopBack {
    [_alertView show:^{
        [self saveFiles];
    }];
}



@end
