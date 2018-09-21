//
//  CTSTMDevice2.m
//  contenttransfer
//
//  Created by Zhang, Yichun on 5/31/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTSTMDevice2.h"

@implementation CTSTMDevice2

@synthesize peerId;
@synthesize senderMode;
@synthesize status;
@synthesize dataSentSize;
@synthesize numOfSentFile;
@synthesize resourceName;
@synthesize freeSpace;

- (id) init:(MCPeerID *) name mode:(Boolean) mode
{
    self = [super init];
    peerId = name;
    senderMode = mode;
    status = Disconnected;
    dataSentSize  = 0;
    resourceName = nil;
    freeSpace = 0;
    numOfSentFile = 0;
    
    return self;
}

@end
