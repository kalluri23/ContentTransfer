//
//  CTSTMService2.h
//  contenttransfer
//
//  Created by Zhang, Yichun on 5/4/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "CTSTMDevice2.h"
@class CTSTMService2;

@protocol CTSTMServiceDelegate2

- (void) startServiceError:(CTSTMService2 *)service error:(NSError *)error;
- (void) startBrowseError:(CTSTMService2 *) service error:(NSError *)error;
- (void) connectRequest:(NSString *) host confirmation:(void (^)(Boolean success))confirmHandler;
- (void) groupStatusChanged;
    
    
    // recv status update
- (void) recvData:(NSData *) data withPeer:(MCPeerID *)peer;
- (void) recvResourceStart:(NSString *)resourcename;

@optional
- (void) recvLostHost;
- (void) recvResource:(NSString *) resourcename localURL: (NSURL *) localURL;
- (void) recvResourceDidUpdateProgressInfo:(NSProgress *) progress resourcename:(NSString *) resourcename;
    
@end

@interface CTSTMService2 : NSObject
{

}

@property (nonatomic,strong)     CTSTMDevice2 * hostDevice;

@property (nonatomic,strong) MCNearbyServiceAdvertiser * serviceMainAdvertiser;
@property (nonatomic,strong) MCNearbyServiceBrowser * serviceMainBrowser;
@property (nonatomic,strong) MCSession * mainSession;

@property (nonatomic, weak) id<CTSTMServiceDelegate2> delegate;

+ (CTSTMService2 *)sharedInstance;

- (void) startService:(BOOL)senderMode serviceType:(NSString *)serviceType;
- (void) stopService;
- (void) resetService;
- (BOOL) isConnected;
- (NSString *) getHostName;
- (CTSTMDevice2 *) getDevice:(NSInteger) index;
- (NSInteger) getNumOfConnectedDevice;
- (NSString *) getNameOfConnectedDevice:(NSInteger) index;
- (void) setupHost:(MCPeerID *)peer;
- (void) broadcastHostMode;
- (void) sendPacket:(MCPeerID *) peer data:(NSData *) data;
- (void) setStatusofConnectedDevice:(DeviceStatus2)status  peer: (MCPeerID *) peer;
- (void) updateDataReceived:(UInt64)size peer:(MCPeerID *)peer name:(NSString *)name isInitTransfer:(BOOL)isStart;
- (void) updateDeviceFreeSpace:(UInt64) size peer:(MCPeerID *) peer;
- (void) startSendResource:(NSURL *)url name:(NSString *)name peer:(MCPeerID *) peer;
@end
