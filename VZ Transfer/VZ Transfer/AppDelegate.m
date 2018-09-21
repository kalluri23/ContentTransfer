//
//  AppDelegate.m
//  VZ Transfer
//
//  Created by Hadapad, Prakash on 5/18/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "AppDelegate.h"
#import "CTBonjourManager.h"
#import "CTBonjourSenderViewController.h"
#import "CTBonjourReceiverViewController.h"
#import "EulaViewController.h"
#import "CTLocalAnalysticsManager.h"
#import "CTSenderScannerViewController.h"
#import "CTQRCodeViewController.h"
#import "CTContentTransferSetting.h"
#import "CTQRCodeSwitch.h"


@interface AppDelegate () {
    
    id lastViewController;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [CTUserDefaults sharedInstance].transferFinished = @"YES"; // Set to Yes to init the data collection. Only set when first time. Otherwise never change this value.
    
#if STANDALONE == 0
    
    CTFrameworkEntryPoint *ctStartPoint = [[CTFrameworkEntryPoint alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:(UIViewController *)[ctStartPoint launchContentTransferApp]];
    self.window.rootViewController = navController;
    
    return YES;

#else
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCurrentViewController:)
                                                 name:@"CurrentViewController"
                                               object:nil];

    
    [self listenForCrashHandling];
  
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    return YES;
    
#endif
}

- (void)handleCurrentViewController:(NSNotification *)notification {
    // Selector response the notification sent from view controller, to save last viewcontroller showed before app enter the background
    if ([notification userInfo] == nil) {
        lastViewController = [[notification userInfo] objectForKey:@"lastViewController"];
    } else if([[notification userInfo] objectForKey:@"lastViewController"]) {
        lastViewController = [[notification userInfo] objectForKey:@"lastViewController"];
    }
}


- (void)listenForCrashHandling {
    
     NSSetUncaughtExceptionHandler(&HandleException);
}


void HandleException(NSException *exception) {
    
    dispatch_async(dispatch_get_main_queue(), ^{ // Put in main thread to avoid warning.
        
        UINavigationController* temp = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        
        NSString *crashLocation = NSStringFromClass([[[temp viewControllers] lastObject] class]);
        
        UIDevice *currentDevice = [UIDevice currentDevice];
        
        CTUploadCrashReport *serverUpload = [[CTUploadCrashReport alloc] init];
        
        if (crashLocation.length == 0) {
            crashLocation = @"No Location Available";
        }
        
        
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterFullStyle];
        
        NSMutableDictionary *crashDict = [@{@"CRASH_LOCATION":crashLocation,
                                            @"CRASH_STACK":exception.callStackSymbols,
                                            @"EXCEPTION_REASON":exception.reason,
                                            @"DEVICE_MODEL":currentDevice.model,
                                            @"DEVICE_NAME_CRASH_KEY":currentDevice.systemName,
                                            @"OS_VERSION_KEY":currentDevice.systemVersion,
                                            @"CURRENT_APP_VERSION_KEY":(NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey],
                                            @"TIME_STAMP":dateString
                                            } mutableCopy];
        
        [serverUpload storeLogToLocalDatabase:crashDict];
        
        //    [[VZSharedAnalytics sharedInstance] trackState:ANALYTICS_TrackState_Key_LinkName_PhoneCrash
        //                                              data:@{ANALYTICS_TrackAction_Key_ErrorMessage:ANALYTICS_TrackState_Value_ErrorMessage_PhoneCrash}];
        
        // crashes local analytics
        [[CTLocalAnalysticsManager sharedInstance] localAnalyticsData:[NSString stringWithFormat:@"Transfer Interrupted_%@", crashLocation]
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
                                                          description:@""];
    });
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // For Data Meter
    [[NSNotificationCenter defaultCenter] postNotificationName:CTApplicationWillResignActive
                                                        object:self
                                                      userInfo:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if ([lastViewController isKindOfClass:[CTBonjourSenderViewController class]] || [lastViewController isKindOfClass:[CTBonjourReceiverViewController class]] || [lastViewController isKindOfClass:[CTSenderScannerViewController class]] || [lastViewController isKindOfClass:[CTQRCodeViewController class]]) {
        [[CTBonjourManager sharedInstance] closeStreamForController:lastViewController]; // close stream for sender or receiver only
    }
    
    if ([lastViewController isKindOfClass:[CTQRCodeViewController class]]) {
        CTQRCodeViewController *controller = (CTQRCodeViewController *)lastViewController;
        controller.backgroundMode = YES;
        [controller.socket disconnect];
        controller.socket = nil;
    }
    
    if ([lastViewController isKindOfClass:[CTSenderScannerViewController class]]) {
        CTSenderScannerViewController *controller = (CTSenderScannerViewController *)lastViewController;
        controller.backgroundMode = YES;
    }
    
    [[CTLocalAnalysticsManager sharedInstance] reachabilityCheckToUploadAnalyticsForMDN:@""];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    if (![[CTQRCodeSwitch uniqueSwitch] isOn]) { // Only for old flow, recreate service here.
        [[CTBonjourManager sharedInstance] startServerForController:lastViewController];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // For Data Meter
    [[NSNotificationCenter defaultCenter] postNotificationName:CTApplicationDidBecomeActive
                                                        object:self
                                                      userInfo:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//#pragma mark - dummy implementation as it will be used on MVM
//- (void)displayStatusChanged {
//
//}
//
//#pragma mark - dummy implementation as it will be used on MVM
//- (void)setViewControllerToPresentAlertsOnAutomatic {
//    
//}

@end
