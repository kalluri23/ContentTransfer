//
//  VZConcurrentWritingHelper.m
//  VZTransferSocket
//
//  Created by Sun, Xin on 3/6/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import "VZConcurrentWritingHelper.h"

@implementation VZConcurrentWritingHelper

@synthesize currentLock;
@synthesize packagesWaitingForWriting;

- (id)initWithID:(NSString *)concurrentID andSize:(long long)size andInfo:(NSDictionary *)info andPackage:(NSData *)data
{
    self = [super init];
    if (self) {
        self.concurrentID = concurrentID;
        self.videoInfo = info;
        self.videoSize = size;
        self.currentLock = NO;
        self.totalSaved = 0;
        self.packagesWaitingForWriting = [[NSMutableArray alloc] initWithObjects:data, nil];
    }
    
    return self;
}

@end
