//
//  VZCTViewController.m
//  myverizon
//
//  Created by Tourani, Sanjay on 3/16/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VZCTViewController.h"
#import "CTNoInternetViewController.h"
#import "CTMVMAlertAction.h"
#import "CTColor.h"
#import "CTContentTransferConstant.h"
#import "CTMVMAlertHandler.h"
#import "CTMVMAlertObject.h"
#import "CTMVMFonts.h"
#import "CTErrorViewController.h"
#import "CTStoryboardHelper.h"
#import "UIViewController+Convenience.h"
#import "CTSenderTransferViewController.h"
#import "CTTransferInProgressViewController.h"
#import "CTLocalAnalysticsManager.h"
#import "CTDataSavingViewController.h"
#import "CTReceiverProgressViewController.h"
#import "CTSenderProgressViewController.h"
#import "CTDataCollectionManager.h"
#import "CTSenderTransferViewController.h"
#import "CTReceiverReadyViewController.h"
#import "CTMVMSessionSingleton.h"

#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

@interface VZCTViewController()

@property (nonatomic, strong) CTErrorViewController *errorViewController;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation VZCTViewController

@synthesize uuid_string = _uuid_string;
@synthesize pageName = _pageName;


#pragma mark - Getters & Setters
- (NSString *)uuid_string {
    if (!_uuid_string)
        _uuid_string = [CTUserDevice userDevice].deviceUDID;
    return _uuid_string;
}

- (void)setPageName:(NSString *)pageName {
    _pageName = pageName;
}

- (NSString *)pageName {
    if (_pageName) {
        return [NSString stringWithFormat:@"%@",_pageName];
    }else {
        return nil;
    }
}

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Add shrink label for navigation title
    [self viewControllerConfigNavigationTitleView];
    
    // Setup status bar
    #if STANDALONE == 1
    [self setupStatusBarForContentTransfer];
    #endif
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    UIDeviceBatteryState currentState = [[UIDevice currentDevice] batteryState];
    if (currentState != UIDeviceBatteryStateCharging && currentState != UIDeviceBatteryStateFull) {
        self.charging = NO;
    } else {
        self.charging = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterForeground)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    // Add observer to capture if navigation bar title has been setup.
    [self addObserver:self forKeyPath:kNavigationTitle options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self.navigationController navigationBar] setBarTintColor:[UIColor whiteColor]];
    [self addObserver:self forKeyPath:kPageName options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Add notifications for battery status & level
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateDidChange:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelDidChange:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // remove notifications for battery status & level
    @try {
        [self removeObserver:self forKeyPath:kPageName context:nil];
        [self removeObserver:self forKeyPath:kNavigationTitle context:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    } @catch(id anException) {
        //do nothing, obviously it wasn't attached because an exception was thrown
        DebugLog(@"Observer not attached");
    }
}

#pragma mark - KvO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kNavigationTitle]) {
        self.titleLabel.text = change[@"new"]; // Set the value to customer title label
    }
}

#pragma mark - Convenients
- (void)setupStatusBarForContentTransfer {
    // Set black status bar
    UIView *statusBarView = nil;
    if ([CTDeviceMarco isiPhoneX]) {
        // Status bar height will be 44 pixel based on Apple's document.
        statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -44, [UIScreen mainScreen].bounds.size.width, 44.0)];
    } else {
        // Rest of the devices status bar height will be 20 pixel.
        statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 20.0)];
    }
    statusBarView.backgroundColor = [UIColor blackColor];
    [self.navigationController.navigationBar addSubview:statusBarView];
}

- (void)didEnterForeground {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationContentTransferActive
                                                        object:nil];
}

- (void)handleBackButtonTapped {
    if ([self.navigationController respondsToSelector:@selector(popViewControllerAnimated:)]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)backButtonPressed {
    
    if (USES_CUSTOM_VERIZON_ALERTS) {
        [CTVerizonAlertCreateFactory showTwoButtonsAlertWithTitle: CTLocalizedString(kDefaultAppTitle, nil) context:CTLocalizedString(CT_APP_QUIT_ALERT_CONTEXT, nil) cancelBtnText:CTLocalizedString(CT_NO_ALERT_BUTTON_TITLE, nil) confirmBtnText:CTLocalizedString(CT_YES_ALERT_BUTTON_TITLE, nil) confirmHandler:^(CTVerizonAlertViewController *alertVC){
            
            //        [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
            
            if([[[[self navigationController]viewControllers]objectAtIndex:0] isKindOfClass:[CTNoInternetViewController class]]) {
                [self.navigationController setNavigationBarHidden:YES animated:NO];
            }
            
            if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            }
            
            
#if STANDALONE == 1
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            
#else
            UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
            
            if ([nav isKindOfClass:[UINavigationController class]]) {
                
                NSArray *arr = nav.viewControllers;
                
                UIViewController *viewcontroller = [arr lastObject];
                
                DebugLog(@"top view controller is %@",NSStringFromClass(viewcontroller.class));
                
                NSString *screenName = [self getScreenName:NSStringFromClass(viewcontroller.class)];
                
                NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
                
                [infoDict setObject:[screenName stringByAppendingString:@"_Application exited by user"] forKey:@"dataTransferStatusMsg"];
                [infoDict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
                
                [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_EXITAPP withExtraInfo:infoDict isEncryptedExtras:false];
                
            }
            
            [self exitContentTransfer];
            
#endif
            
            
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            
            //        id appDelegate = [[UIApplication sharedApplication] delegate];
            //        [appDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
            //        [appDelegate setViewControllerToPresentAlertsOnAutomatic];
            //        [appDelegate displayStatusChanged];
//            [NSObject dismissAppdelegate];
            
        } cancelHandler:nil isGreedy:NO from:self];
    } else {
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CT_YES_ALERT_BUTTON_TITLE, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            //        [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
            
            if([[[[self navigationController]viewControllers]objectAtIndex:0] isKindOfClass:[CTNoInternetViewController class]]) {
                [self.navigationController setNavigationBarHidden:YES animated:NO];
            }
            
            if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            }
            
            
#if STANDALONE == 1
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            
#else
            UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
            
            if ([nav isKindOfClass:[UINavigationController class]]) {
                
                NSArray *arr = nav.viewControllers;
                
                UIViewController *viewcontroller = [arr lastObject];
                
                DebugLog(@"top view controller is %@",NSStringFromClass(viewcontroller.class));
                
                NSString *screenName = [self getScreenName:NSStringFromClass(viewcontroller.class)];
                
                NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
                
                [infoDict setObject:[screenName stringByAppendingString:@"_Application exited by user"] forKey:@"dataTransferStatusMsg"];
                [infoDict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
                
                [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_EXITAPP withExtraInfo:infoDict isEncryptedExtras:false];
                
            }
            
            [self exitContentTransfer];
            
#endif
            
            
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            
            //        id appDelegate = [[UIApplication sharedApplication] delegate];
            //        [appDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
            //        [appDelegate setViewControllerToPresentAlertsOnAutomatic];
            //        [appDelegate displayStatusChanged];
//            [NSObject dismissAppdelegate];
            
        }];
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CT_NO_ALERT_BUTTON_TITLE, nil) style:UIAlertActionStyleCancel handler:nil];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil) message:CTLocalizedString(CT_APP_QUIT_ALERT_CONTEXT, nil) cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    }
}


#if STANDALONE == 0
- (void)exitContentTransfer {

    [[CTDataCollectionManager sharedManager] stopCollectDataForExit];
    [CTUserDefaults sharedInstance].transferFinished = @"YES";
    
    [self exitContentTransfer_MFMVM];
    
    NSArray *arr = [[self navigationController] viewControllers];
    UIViewController *viewcontroller = [arr lastObject];
    if ([viewcontroller isKindOfClass:[CTSenderProgressViewController class]] || [viewcontroller isKindOfClass:[CTReceiverProgressViewController class]] ||[viewcontroller isKindOfClass:[CTDataSavingViewController class]] || [viewcontroller isKindOfClass:[CTSenderTransferViewController class]] || [viewcontroller isKindOfClass:[CTReceiverReadyViewController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CT_NOTIFICATION_EXIT_CONTENT_TRANSFER object:self.navigationController];
    } else {
        NSString *descMsg = [NSString stringWithFormat:@"MF back button -> CT app exit -> %@",[viewcontroller class]];
            [[CTLocalAnalysticsManager sharedInstance] localAnalyticsData:@"Transfer Cancelled"
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
}
#endif

- (NSString *)getScreenName:(NSString *)viewcontrollerName {
    
    NSString *screenName;
    
    DebugLog(@"ScreenName : %@",viewcontrollerName);
    
    if ([viewcontrollerName isEqualToString:@"VZDeviceSelectionVC"]) {
        
        screenName = @"PhoneSelectionScreen";
        
    }else if ([viewcontrollerName isEqualToString:@"VZPhoneCombinationVC"]) {
        
        screenName =  @"SelectPhoneCombinationScreen";
        
    }else if ([viewcontrollerName isEqualToString:@"VZBumpActionReceiver"]) {
        
        screenName =  @"PairingScreen_Receiver_Bonjour";
        
    }else if ([viewcontrollerName isEqualToString:@"VZBumpActionSender"]) {
        
        screenName =  @"PairingScreen_Sender_Bonjour";
        
    }else if ([viewcontrollerName isEqualToString:@"VZSenderViewController"]) {
        
        screenName =  @"EnterPinScreen_Sender_P2P";
        
    }else if ([viewcontrollerName isEqualToString:@"VZReceiverViewController"]) {
        
        screenName =  @"DisplayPinScreen_Receiver_P2P";
        
    }else if ([viewcontrollerName isEqualToString:@"VZBonjourReceiveDataVC"]) {
        
        screenName =  @"ReceiveDataScreen_Bonjour";
        
    }else if ([viewcontrollerName isEqualToString:@"VZBonjourTransferDataVC"]) {
        
        screenName =  @"TransferScreen_Bonjour";
        
    }else if ([viewcontrollerName isEqualToString:@"VZReceiveDataViewController"]) {
        
        screenName =  @"ReceiveDataScreen_P2P";
        
    }else if ([viewcontrollerName isEqualToString:@"VZTransferDataViewController"]) {
        
        screenName =  @"TransferScreen_P2P";
        
    }else if ([viewcontrollerName isEqualToString:@"VZTransferFinishViewController"]) {
        
        screenName =  @"TransferSummaryScreen";
        
    }else if ([viewcontrollerName isEqualToString:@"VZRecevierWifiSetupViewController"]) {
        
        screenName =  @"WifiSetupScreen_Receiver_P2P";
        
    }else if ([viewcontrollerName isEqualToString:@"VZSenderWifiSetupViewController"]) {
        
        screenName =  @"WifiSetupScreen_Sender_P2P";
        
    } else if ([viewcontrollerName isEqualToString:@"VZAnDReceiverWifiSetupVC"]) {
        
        screenName =  @"SoftAccessScreen_Sender_AnD";
        
    } else if ([viewcontrollerName isEqualToString:@"VZAnDSenderWifiSetupVC"]) {
        
        screenName =  @"SoftAccessScreen_Receiver_AnD";
        
    } else {
        
        screenName =  @"Application exited by user";
    }
    
    return screenName;
    
    
}

//-(void)powerStateDidChange {
//
//    if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
//
//        MVMAlertAction *cancelAction = [MVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
//        [[AlertHandler sharedAlertHandler] showAlertWithTitle:@"Content transfer" message:@"Please disable power saving mode and try again" cancelAction:cancelAction otherActions:nil isGreedy:NO];
//    }
//}

- (BOOL)isTabBarInitiallyAccessible {
    return NO;
}

- (BOOL)canCancelCurrentTransaction {
    return NO;
}

- (BOOL)isNavigationBarItemAvailableFor:(CTMVMNavigationBarItem)item {
    return NO;
}

#pragma mark - Observer For All Content transfer View Controller
- (void)batteryStateDidChange:(NSNotification *)notification
{
    UIDeviceBatteryState currentState = [[UIDevice currentDevice] batteryState];
    
    
    if (currentState != UIDeviceBatteryStateCharging && currentState != UIDeviceBatteryStateFull) {
        
        self.charging = NO;
        
        float percentage = [[UIDevice currentDevice] batteryLevel]; // Get battery level of the device, max:1.0f
        if (percentage <= 0.25f) {
            // unplugged
            self.batteryWarning = YES;
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"batteryAlertSent"] boolValue]) {
                return;
            }
            
            [self showLowbattery];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"batteryAlertSent"];
        } else {
            self.batteryWarning = NO;
        }
    } else {
        self.charging = YES;
    }
}

- (void)batteryLevelDidChange:(NSNotification *)notification
{
    float percentage = [[UIDevice currentDevice] batteryLevel]; // Get battery level of the device, max:1.0f
    if (percentage <= 0.25f) {
        self.batteryWarning = YES;
        
        if (self.charging || [[[NSUserDefaults standardUserDefaults] objectForKey:@"batteryAlertSent"] boolValue]) {
            return;
        }
        
        [self showLowbattery];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"batteryAlertSent"];
    } else {
        self.batteryWarning = NO;
    }
}

- (void)showLowbattery {
    UIStoryboard *storyboard = [CTStoryboardHelper commonStoryboard];
    
    if ([self.childViewControllers containsObject:self.errorViewController] == NO) {
        self.errorViewController = [CTErrorViewController initialiseFromStoryboard:storyboard];
        self.errorViewController.primaryErrorText = ALERT_TITLE_PLUG_IN_AND_CHARGE_UP;
        self.errorViewController.secondaryErrorText = ALERT_MESSAGE_BATTERY_WARNING_MESSAGE;
        self.errorViewController.rightButtonTitle = BUTTON_TITLE_GOT_IT;
        self.errorViewController.bottomspace = 90.0f;
        self.errorViewController.transferStatusAnalytics = CTTransferStatus_Battery_Check;
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

- (void)displayAlter:(NSString *)content {
    
    if (USES_CUSTOM_VERIZON_ALERTS){
        [CTVerizonAlertCreateFactory showSingleButtonsAlertWithTitle:CTLocalizedString(kDefaultAppTitle, nil)
                                                             context:content
                                                             btnText:CTLocalizedString(CTAlertGeneralOKTitle, nil)
                                                             handler:nil
                                                            isGreedy:YES from:self];
    }else{
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralOKTitle, nil) style:UIAlertActionStyleCancel handler:nil];
        
        CTMVMAlertObject* alertObject = [[CTMVMAlertObject alloc] initWithTitle:CTLocalizedString(kDefaultAppTitle, nil)
                                                                        message:content
                                                                   cancelAction:cancelAction
                                                                   otherActions:nil
                                                                       isGreedy:YES];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
    }
}

- (void)exitContentTransfer_MFMVM {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitContentTransfer" object:self.navigationController];
}
/*!
 * @brief Create a custom view to show the title of navigation bar. This change made for future localization.
 * @discussion Text for title will be shrink based on the size of the title view.
 */
- (void)viewControllerConfigNavigationTitleView {
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[CTMVMFonts mvmBoldFontOfSize:[CTDeviceMarco isiPhone6AndAbove] ? 13.0 : 15.0]}];
}

#pragma mark - Public API
- (void)setNavigationControllerMode:(CTNavigationControllerMode)navigationControllerMode {
    
    NSAssert(self.navigationController, @"navigation controller can't be nil, check implementation");
    
    switch (navigationControllerMode) {
        case CTNavigationControllerMode_OnlyBack:
        {
            self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage getImageFromBundleWithImageName:@"back"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(handleBackButtonTapped)];
            [self.navigationItem setLeftBarButtonItem:self.backButton animated:NO];
            [[self.navigationItem leftBarButtonItem] setTintColor:[CTColor blackColor]];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
            break;
        case CTNavigationControllerMode_BackAndHamburgar:
        {
            self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage getImageFromBundleWithImageName:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
            
            self.hamburgarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage getImageFromBundleWithImageName:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
            
            self.hamburgarButton.imageInsets = UIEdgeInsetsMake(0, -25, 0, 0);
            self.searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage getImageFromBundleWithImageName:@"support_default"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
            
            [self.navigationItem setLeftBarButtonItems:@[self.backButton,self.hamburgarButton]];
            [self.navigationItem setRightBarButtonItem:self.searchButton];
            
            [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj setTintColor:[CTColor blackColor]];
            }];
            
            [self.navigationItem.rightBarButtonItem setTintColor:[CTColor blackColor]];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
            break;
        case CTNavigationControllerMode_QuitAndHamburgar:
        {
            self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage getImageFromBundleWithImageName:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
            
            self.hamburgarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage getImageFromBundleWithImageName:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
            
            self.hamburgarButton.imageInsets = UIEdgeInsetsMake(0, -25, 0, 0);
            self.searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage getImageFromBundleWithImageName:@"support_default"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
            
            [self.navigationItem setLeftBarButtonItems:@[self.backButton,self.hamburgarButton]];
            [self.navigationItem setRightBarButtonItem:self.searchButton];
            
            [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj setTintColor:[CTColor blackColor]];
            }];
            
            [self.navigationItem.rightBarButtonItem setTintColor:[CTColor blackColor]];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
            break;
        case CTNavigationControllerMode_None:
        {
            self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage getImageFromBundleWithImageName:@"back"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(handleBackButtonTapped)];
            [self.navigationItem setLeftBarButtonItem:self.backButton animated:NO];
            
            self.navigationItem.leftBarButtonItems = @[self.backButton];
            
            [self.navigationItem setHidesBackButton:YES animated:NO];
            [self.navigationItem setLeftBarButtonItem:nil animated:NO];
            [self.navigationItem setRightBarButtonItem:nil animated:NO];
        }
            break;
        case CTNavigationControllerMode_QuitBack: {
            self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage getImageFromBundleWithImageName:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
            [self.navigationItem setLeftBarButtonItem:self.backButton animated:NO];
            [[self.navigationItem leftBarButtonItem] setTintColor:[CTColor blackColor]];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
            break;
        default:
            NSAssert(false, @"CTNavigationControllerMode is unknown !!! check implementation");
            break;
    }
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
}

@end

