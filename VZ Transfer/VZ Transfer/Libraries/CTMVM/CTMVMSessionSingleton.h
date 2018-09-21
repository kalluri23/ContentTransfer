//
//  SessionSingleton.h
//  VZ Transfer
//
//  Created by Hadapad, Prakash on 5/19/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTMVMVZAnalytics.h"

@class UIViewController;
@class UIView;

typedef enum {
    vzTouch,
    vzSwipe,
    vzClick,
    vzLongclick,
    vzOther
} NSEventType;

@interface CTMVMSessionSingleton : NSObject

@property (strong,nonatomic)CTMVMVZAnalytics  *vzctAnalyticsObject;

@property(nonatomic)  BOOL contentTransferActive;

+ (instancetype)sharedGlobal;


@end
