//
//  CTCommPortServerSocket.m
//  contenttransfer
//
//  Created by Sun, Xin on 5/9/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTCommPortServerSocket.h"

@interface CTCommPortServerSocket()

/*! @brief Indicate current device info already sent or not. Default value is NO, after sent set to YES and never reset.*/
@property (nonatomic, assign) BOOL deviceInfoSent;

@end

@implementation CTCommPortServerSocket

- (instancetype)initServierSocket {
    self = [super init];
    if (self) {
        [self listenOnPort];
        self.deviceInfoSent = NO;
    }
    
    return self;
}

/*! @brief Method for server commport socket accpet comming connection using commport socket port number.*/
- (void)listenOnPort {
    NSError *error = nil;
    if (![self acceptOnPort:COMM_PORT_NUMBER error:&error]) {
        DebugLog(@"No i am not able to listen on comm port");
    } else {
        DebugLog(@"Yes i am able to listen on comm port");
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (!_deviceInfoSent) {
        _deviceInfoSent = YES;
        [self writePairingInformationToCommPort];
    }
    
    [super socket:sock didReadData:data withTag:tag];
}

@end
