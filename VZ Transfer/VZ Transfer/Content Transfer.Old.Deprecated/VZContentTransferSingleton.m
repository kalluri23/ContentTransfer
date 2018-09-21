//
//  VZContentTransferSingleton.m
//  myverizon
//
//  Created by Tourani, Sanjay on 3/9/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "VZContentTransferSingleton.h"
#import "CTMVMConstants.h"

@implementation VZContentTransferSingleton

+ (instancetype)sharedGlobal
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [[self alloc] init];
                  });
    
    return sharedInstance;
}




-(void)registerWithMVM {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationContentTransferActive object:nil];
}


-(void)deregisterWithMVM {

    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationContentTransferInactive object:nil];
}

@end









