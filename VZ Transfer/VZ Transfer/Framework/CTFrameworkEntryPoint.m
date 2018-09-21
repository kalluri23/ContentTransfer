//
//  CTFrameworkEntryPoint.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/30/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <contentTransferFramework/CTFrameworkEntryPoint.h>
#import "CTStoryboardHelper.h"
#import "CTStartupViewController.h"
#import "UIViewController+Convenience.h"
#import "CTLocalAnalysticsManager.h"
#import "CTBonjourManager.h"

@implementation CTFrameworkEntryPoint

- (CTStartupViewController *)launchContentTransferApp {
    
//    NSString *filePath;
//
//#if STORE_BUILD == 1
//
//    filePath = [[NSBundle mainBundle] pathForResource:@"ADBMobileConfig" ofType:@"json"];
//
//#else
//
//    filePath = [[NSBundle mainBundle] pathForResource:@"ADBMobileConfig_Test" ofType:@"json"];
//
//#endif
//
//    [ADBMobile overrideConfigPath:filePath];
//
//    [ADBMobile setDebugLogging:YES];
//
//    [ADBMobile collectLifecycleData];
    
    // TODO : Remove from MVM code
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [CTUserDefaults  sharedInstance].transferFinished = @"YES"; // Set to Yes to init the data collection. Only set when first time. Otherwise never change this value.
    
    UIStoryboard *storyboard = [CTStoryboardHelper devicesStoryboard];
    return [CTStartupViewController initialiseFromStoryboard:storyboard];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    
    [[CTLocalAnalysticsManager sharedInstance] uploadLocalAnalytics];
}

@end

