//
//  CTCommPortClientSocket.m
//  contenttransfer
//
//  Created by Sun, Xin on 5/9/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTCommPortClientSocket.h"

@implementation CTCommPortClientSocket

- (instancetype)initWithHost:(NSString *)host andDelegate:(id)aDelegate {
    self = [super init];
    if (self) {
        self.generalDelegate = aDelegate;
        [self connectToHost:host];
    }
    
    return self;
}

/*!
    @brief Method to connect to specific host.
    @discussion This method will try to connect to host using commport number with 30sec timeout. After connection established, socketDidConnectToHost:port: will automatically called.
    @param host NSString that represent the host.
 */
- (void)connectToHost:(NSString *)host {
    NSError *error = nil;
    [self connectToHost:host onPort:COMM_PORT_NUMBER withTimeout:30 error:&error];
    
    if (error) {
        NSLog(@"CTCommPortClientSocket Error(%ld): %@", (long)error.code, error.localizedDescription);
    }
}

#pragma mark - Override Methods
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self writePairingInformationToCommPort];
}

@end
