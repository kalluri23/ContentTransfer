//
//  AlertOperation.h
//  myverizon
//
//  Created by Scott Pfeil on 9/28/15.
//  Copyright © 2015 Verizon Wireless. All rights reserved.
//
//  Operation for handling an alert.

#import <Foundation/Foundation.h>
#import "CTMVMOperation.h"

@class CTMVMAlertAction;

@interface CTMVMAlertOperation : CTMVMOperation <UIAlertViewDelegate>

// If this operation is temporarily paused.
@property (readonly, getter=isPaused) BOOL paused;

// If this alert is a greedy alert (See AlertHandler).
@property (readonly, getter=isGreedy) BOOL greedy;

// Initializes the operation with the alert to display and if it is greedy or not.
- (instancetype)initWithAlert:(id)alert isGreedy:(BOOL)isGreedy;

// Pauses the operation. Temporarily removes any alert.
- (void)pause;

// Unpauses the operation, resuming any alert.
- (void)unpause;

@end
