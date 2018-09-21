//
//  SocketManager.h
//  myverizon
//
//  Created by Sun, Xin on 3/21/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"


@interface SocketManager : NSObject

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
@property (nonatomic, strong) GCDAsyncSocket *listenOnPort;

@property (nonatomic, strong) id asyncSocketDelegate;
@property (nonatomic, strong) id listenOnPortDelegate;

+ (instancetype)sharedInstance;

@end
