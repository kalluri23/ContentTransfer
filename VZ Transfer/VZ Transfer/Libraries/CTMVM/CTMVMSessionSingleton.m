//
//  SessionSingleton.m
//  VZ Transfer
//
//  Created by Hadapad, Prakash on 5/19/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "CTMVMSessionSingleton.h"

@implementation CTMVMSessionSingleton

@synthesize vzctAnalyticsObject;

+ (instancetype)sharedGlobal {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [[self alloc] init];
                  });
    
    return sharedInstance;
}



@end
