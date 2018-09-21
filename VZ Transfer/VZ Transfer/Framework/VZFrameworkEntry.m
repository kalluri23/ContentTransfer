//
//  VZFrameworkEntry.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/16/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "VZFrameworkEntry.h"

@implementation VZFrameworkEntry

- ( VZDeviceSelectionVC *) LaunchContentTransfer {
    
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
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"VZContentTransfer"
                                                         bundle:[NSBundle bundleForClass:[VZFrameworkEntry class]]];
    return (VZDeviceSelectionVC *)[storyboard instantiateViewControllerWithIdentifier:@"VZDeviceSelectionVC"];
}






@end
