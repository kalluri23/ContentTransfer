//
//  MVMOperation.m
//  myverizon
//
//  Created by Scott Pfeil on 9/28/15.
//  Copyright © 2015 Verizon Wireless. All rights reserved.
//

#import "CTMVMOperation.h"
#import "CTMVMConstants.h"

@interface CTMVMOperation () {
    BOOL executing;
    BOOL finished;
}

@end

@implementation CTMVMOperation

- (instancetype)init {
    
    self = [super init];
    if (self) {
        executing = NO;
        finished = NO;
    }
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

- (BOOL)checkAndHandleForCancellation {
    
    // Must move the operation to the finished state if it is canceled.
    if ([self isCancelled]) {
        [self markAsFinished];
        return YES;
    } else {
        return NO;
    }
}

- (void)markAsFinished {
    
    if (executing) {
        [self willChangeValueForKey:@"isExecuting"];
        executing = NO;
        [self didChangeValueForKey:@"isExecuting"];
    }
    if (!finished) {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
    }
}

- (void)start {

    // Always check for cancellation before launching the task.
    if ([self checkAndHandleForCancellation]) {
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    if (!executing) {
        [self willChangeValueForKey:@"isExecuting"];
        executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self main];
    });
}

@end
