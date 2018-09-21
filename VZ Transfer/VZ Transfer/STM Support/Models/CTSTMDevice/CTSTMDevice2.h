//
//  CTSTMDevice2.h
//  contenttransfer
//
//  Created by Zhang, Yichun on 5/31/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

typedef NS_ENUM(NSInteger, DeviceStatus2)
{
    Disconnected,
    Connecting,
    Connected,
    Transfer,
    Finished,
    Cancel,
    Nospace
};


@interface CTSTMDevice2 : NSObject

@property(nonatomic, strong) MCPeerID * peerId;
@property(nonatomic) Boolean senderMode;
@property(nonatomic) DeviceStatus2 status;
@property(nonatomic) unsigned long long dataSentSize;
@property(nonatomic) NSInteger numOfSentFile;
@property(nonatomic, strong) NSString * resourceName;
@property(nonatomic) unsigned long long freeSpace;

- (id) init:(MCPeerID *) name mode:(Boolean) mode;

@end
