//
//  MVMOperation.h
//  myverizon
//
//  Created by Scott Pfeil on 9/28/15.
//  Copyright © 2015 Verizon Wireless. All rights reserved.
//
//  Base operation that runs main on the main queue. It is concurrent/asyncronous.

#import <Foundation/Foundation.h>

@interface CTMVMOperation : NSOperation

// Checks for cancellation and then marks as finished if so.
- (BOOL)checkAndHandleForCancellation;

// Does the proper KVO finished stuff.
- (void)markAsFinished;

@end
