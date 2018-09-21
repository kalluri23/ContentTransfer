//
//  EKEventManager.m
//  remindersApp
//
//  Created by Tourani, Sanjay on 3/29/16.
//  Copyright © 2016 Tourani, Sanjay. All rights reserved.
//

#import "VZEventManager.h"

@interface VZEventManager()

@end


@implementation VZEventManager

#pragma mark - Initialization
- (void)_initEventStore {
    self.eventStore = [[EKEventStore alloc] init];
}

+ (instancetype)sharedEvent {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance _initEventStore];
    });
    
    return sharedInstance;
}

@end
