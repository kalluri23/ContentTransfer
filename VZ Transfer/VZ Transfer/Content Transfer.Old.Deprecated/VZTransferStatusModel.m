//
//  VZTransferStatusModel.m
//  VZTransferSocket
//
//  Created by Prakash Mac on 12/8/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "VZTransferStatusModel.h"

@implementation VZTransferStatusModel
static VZTransferStatusModel * sharedSingletonTransferModel = nil;
@synthesize callBackHandler;
@synthesize globalAsyncSocket;
@synthesize globallistenrSocket;


+ (id) SharedSingletonInstance {
    static dispatch_once_t pred = 0;
    __strong static id sharedSingletonTransferModel = nil;
    dispatch_once(&pred, ^{
        sharedSingletonTransferModel = [[self alloc] init];
    });
    return sharedSingletonTransferModel;
}

+(id)allocWithZone:(NSZone *)zone {
    return [self SharedSingletonInstance];
}

-(void)updateSenderViewController:(NSString *)statusMsg {
   
    DebugLog(@"StatusMsg Received %@",statusMsg);
//    callBackHandler(statusMsg);
}



@end
