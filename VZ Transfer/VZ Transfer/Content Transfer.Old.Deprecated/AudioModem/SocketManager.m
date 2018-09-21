//
//  SocketManager.m
//  myverizon
//
//  Created by Sun, Xin on 3/21/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "SocketManager.h"

static SocketManager *managerSharedInstance = nil;

@implementation SocketManager

@synthesize asyncSocket;
@synthesize listenOnPort;

+ (instancetype)sharedInstance {
    
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        managerSharedInstance = [[SocketManager alloc] init];
    });
    
    return managerSharedInstance;
}

@end
