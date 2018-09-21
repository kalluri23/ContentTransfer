//
//  CTSTMService2.m
//  contenttransfer
//
//  Created by Zhang, Yichun on 5/4/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTSTMService2.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#if STANDALONE == 0
    #import <contentTransferFramework/contenttransfer-Swift.h>
#endif

@interface CTSTMService2 ()<MCSessionDelegate,MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate>
{
    NSString * CTSTMServiceType_Main;
    
    CTSTMDevice2 * thisDevice;
    
    NSMutableArray * devices;
    
    NSMutableArray * sendResources;
    
    NSMutableArray * recvResources;
    
    NSMutableData * recvData;
    
    long long currentCompleteDataSize;
    
}
@end

@implementation CTSTMService2

@synthesize delegate;
@synthesize hostDevice;
@synthesize serviceMainBrowser;
@synthesize serviceMainAdvertiser;
@synthesize mainSession;

+ (CTSTMService2 *)sharedInstance {
    static CTSTMService2 *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id) init
{
    self = [super init];
    
    if(self)
    {
        
        devices = [[NSMutableArray alloc] initWithCapacity:0];
        sendResources = [[NSMutableArray alloc] initWithCapacity:0];
        recvResources = [[NSMutableArray alloc] initWithCapacity:0];
        recvData = [[NSMutableData alloc] initWithCapacity:0];
        
        CTSTMServiceType_Main   = @"CTSTM";
        serviceMainAdvertiser = nil;
        serviceMainBrowser = nil;
        
        MCPeerID * thisPeer = [[MCPeerID alloc] initWithDisplayName:UIDevice.currentDevice.name];
        
        thisDevice = [[CTSTMDevice2 alloc] init];
        thisDevice.peerId = thisPeer;
        thisDevice.senderMode = NO;
        
        mainSession = [[MCSession alloc] initWithPeer:thisPeer securityIdentity:nil encryptionPreference:MCEncryptionRequired];
        
        mainSession.delegate = self;
        
        
        delegate = nil;
        
    }
    
    return self;
}

- (void) startService:(BOOL)senderMode serviceType:(NSString *)serviceType
{
    currentCompleteDataSize = 0;
    thisDevice.senderMode = senderMode;
    
    CTSTMServiceType_Main = serviceType;
    
    serviceMainAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:thisDevice.peerId discoveryInfo:nil serviceType:CTSTMServiceType_Main];
    
    serviceMainBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:thisDevice.peerId serviceType:CTSTMServiceType_Main];

    serviceMainAdvertiser.delegate  = self;
    
    serviceMainBrowser.delegate = self;
    
    [serviceMainAdvertiser startAdvertisingPeer];
    
    [serviceMainBrowser startBrowsingForPeers];
}

- (void) stopService
{
    for(int i = 0; i< sendResources.count;i++)
    {
        CTSTMResourceObject * resObj = (CTSTMResourceObject *) sendResources[i];
        
        [resObj.progress removeObserver:self forKeyPath:@"fractionCompleted"];
        
    }
    
    [sendResources removeAllObjects];
    
    for(int i = 0; i< recvResources.count;i++)
    {
        CTSTMResourceObject * resObj =  (CTSTMResourceObject *) recvResources[i];

        [resObj.progress removeObserver:self forKeyPath:@"fractionCompleted"];
    }
    
    [recvResources removeAllObjects];
    
    [serviceMainAdvertiser stopAdvertisingPeer];
    [serviceMainBrowser stopBrowsingForPeers];
}

- (void) resetService
{
    [devices removeAllObjects];
    [sendResources removeAllObjects];
    [recvResources removeAllObjects];
}


- (BOOL) isConnected
{
    if(thisDevice != nil)
    {
        return (thisDevice.status != Disconnected);
    }
    else
    {
        return false;
    }
}

- (NSString *) getHostName
{
    if(hostDevice != nil)
    {
        return hostDevice.peerId.displayName;
    }
    else
    {
        return nil;
    }
}

- (CTSTMService2 *) getDevice:(NSInteger) index
{
    if(index >= devices.count)
    {
        return nil;
    }
    else
    {
        return devices[index];
    }
}

- (NSInteger) getNumOfConnectedDevice
{
    return devices.count;
}

- (NSString *) getNameOfConnectedDevice:(NSInteger) index
{
    if(mainSession.connectedPeers.count <= index || index < 0)
    {
        return nil;
    }
    else
    {
        return ((CTSTMDevice2 *)devices[index]).peerId.displayName;
    }
}

- (void) updateDeviceFreeSpace:(UInt64) size peer:(MCPeerID *) peer
{
    for(CTSTMDevice2 * device in devices)
    {
        if(device.peerId.hash == peer.hash)
        {
            device.freeSpace = size;
            
            [self.delegate groupStatusChanged];
            
        }
    }
}

- (void) setStatusofConnectedDevice:(DeviceStatus2)status  peer: (MCPeerID *) peer
{
    for(CTSTMDevice2 * device in devices)
    {
        if(peer == nil || device.peerId.hash == peer.hash)
        {
            device.status = status;
            
        }
    }
    
    thisDevice.status = status;
    
    [self.delegate groupStatusChanged];
}

- (void) addDevice:(MCPeerID *) name
{
    for (CTSTMDevice2 * device in devices)
    {
        if(device.peerId.hash == name.hash)
        {
            return;
        }
    }
    
    CTSTMDevice2 * newDevice = [[CTSTMDevice2 alloc] init];
    
    newDevice.peerId = name;
    newDevice.senderMode = NO;
    
    [devices addObject:newDevice];
}

- (void) removeDevice:(MCPeerID *)peer
{
    for(CTSTMDevice2 * device in devices)
    {
        if(device.peerId.hash == peer.hash)
        {
            [devices removeObject:device];
            return;
        }
    }
}


- (void)setupHost:(MCPeerID *)peer {
    hostDevice = [[CTSTMDevice2 alloc] init];
    hostDevice.peerId = peer;
    hostDevice.senderMode = YES;
    hostDevice.status = Connected;
}

- (void) broadcastHostMode
{
    
    if(mainSession.connectedPeers.count > 0 )
    {
        NSData * data = [CT_SEND_FILE_HOST_HEADER dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError * error = nil;
        
        [mainSession sendData:data toPeers:mainSession.connectedPeers withMode:MCSessionSendDataReliable error:&error];
        
        if(error != nil)
        {
            NSLog(@"broadcastHostMode failed %@\n",error.localizedDescription);
        }
    }
}

- (void)sendPacket:(MCPeerID *)peer data:(NSData *)data
{
    if(peer == nil) // broadcasting
    {
        if(mainSession.connectedPeers.count > 0) {
            
            NSError * error = nil;
            
            [mainSession sendData:data toPeers:mainSession.connectedPeers withMode:MCSessionSendDataReliable error:&error];
            
            if(error != nil)
            {
                NSLog(@"sendPacket failed %@\n",error.localizedDescription);
            }
        }
    }
    else
    {
        NSError * error = nil;
        
        [mainSession sendData:data toPeers:@[peer] withMode:MCSessionSendDataReliable error:&error];
        
        if(error != nil)
        {
            NSLog(@"sendPacket failed %@\n",error.localizedDescription);
        } else {
            NSLog(@"---->message delivered");
        }
    }
}

- (void) startSendResource:(NSURL *)url name:(NSString *)name peer:(MCPeerID *) peer
{
    NSLog(@"-> Start sending file");
    NSProgress * progress = [mainSession sendResourceAtURL:url withName:name toPeer:peer withCompletionHandler:^(NSError * error) {
        if(error) {
            NSLog(@"sendResource failed %@\n",error.localizedDescription);
        }
    }];
    
    if (progress != nil) {
        CTSTMResourceObject * resObj =  [[CTSTMResourceObject alloc] init];
        
        resObj.resourceUrl = url;
        
        resObj.peer = peer;
        
        resObj.isSending = true;
        
        resObj.name = name;
        
        resObj.progress = progress;
        
        [sendResources addObject:resObj];
        
        [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        NSDictionary * attr = [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:nil];
        
        if (attr != nil) {
            [self updateDataReceived:0 peer:peer name:name isInitTransfer:YES];
        }
    }
}

- (void)updateDataReceived:(UInt64)size peer: (MCPeerID *)peer name:(NSString *)name isInitTransfer:(BOOL)isStart
{
    for(CTSTMDevice2 * device in devices)
    {
        
        if(device.peerId.hash == peer.hash)
        {
            device.resourceName = name;
            
            device.dataSentSize += size;
            
            if (isStart) {
                device.numOfSentFile += 1;
            }
            
            if(self.delegate)
            {
                [self.delegate groupStatusChanged];
            }
            
            break;
        }
    }
}

#pragma mark MCNearbyServiceAdvertiserDelegate

- (void) advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler
{
 //   if(self.delegate != nil)
   // {
     //  [self.delegate connectRequestWithHost: [thisDevice.peerId displayName] confirmation: ^(BOOL success)
       //  {
             invitationHandler(true, mainSession);
             
             thisDevice.status = Connected;
         //}];

    //}
}

- (void) advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"didNotStartAdvertisingPeer\n");
}

#pragma mark MCNearbyServiceBrowserDelegate

- (void) browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    if(thisDevice.senderMode == true)
    {
        if(thisDevice.status == Connected  ||
            thisDevice.status == Connecting ||
            thisDevice.status == Disconnected)
        {
            [self removeDevice:peerID];
        }
        else
        {
            for(CTSTMDevice2 * device in devices)
            {
                if(device.peerId.hash == peerID.hash)
                {
                    device.status = Cancel;
                }
            }
        }
        
        [self.delegate groupStatusChanged];
    }
    else
    {
        if(hostDevice != nil && hostDevice.peerId.hash == peerID.hash)
        {
            for(CTSTMResourceObject * recv in recvResources)
            {
                [recv.progress removeObserver:self forKeyPath: @"fractionCompleted"];
            }
            
            [recvResources  removeAllObjects];
            
            [mainSession disconnect];
            
            
            if(thisDevice.status == Transfer || thisDevice.status == Connected)
            {
                [self.delegate recvLostHost];
            }
        }
        else if(thisDevice.peerId.hash == peerID.hash)
        {
            [self.delegate recvLostHost];
            
        }
        
    }
   
}

- (void) browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"didNotStartBrowsingForPeers\n");
}

- (void) browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info
{
    [browser invitePeer:peerID toSession:mainSession withContext: [@"mainSession" dataUsingEncoding:NSUTF8StringEncoding] timeout:100];
    
    if(thisDevice.senderMode == true)
    {
        [self addDevice:peerID];
    }

}

- (void)processRecvData:(NSData *)data peer:(MCPeerID *)peer {
    NSLog(@"-->Received data: %lu", (unsigned long)data.length);
    [recvData appendData:data];
    
    if (self.delegate) {
        [self.delegate recvData:data withPeer: peer];
    }
    
}

- (void) recvResource:(NSString *) resourceName localURL:(NSURL *)localURL
{
    if(self.delegate)
    {
        [self.delegate recvResource:resourceName localURL:localURL];

    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    
    NSLog(@"key path:%@, object:%@, change:%@ and context:%@", keyPath, object, change, context);
    if ([object isKindOfClass:NSProgress.class])
    {
        NSProgress * progressObj = (NSProgress *) object;
        if(thisDevice.senderMode == true)
        {
//            NSProgress * progressObj = (NSProgress *) object;
            
            for(CTSTMResourceObject * resObj in sendResources)
            {
                if(progressObj == resObj.progress)
                {
                    long long dataSizeSent = progressObj.completedUnitCount;
                    if (dataSizeSent >= currentCompleteDataSize) {
                        dataSizeSent -= currentCompleteDataSize;
                    }
                    
                    [self updateDataReceived:dataSizeSent peer:resObj.peer name:resObj.name isInitTransfer:NO];
                    currentCompleteDataSize = progressObj.completedUnitCount;
                    
                    if(progressObj.completedUnitCount == progressObj.totalUnitCount)
                    {
                        [resObj.progress removeObserver:self forKeyPath: @"fractionCompleted"];
                    
                        [sendResources removeObject:resObj];
                    }
                }
                
                break;
            }
        }
        else
        {
                
//            NSProgress * progressObj = (NSProgress *) object;
            
            for(CTSTMResourceObject * resObj in recvResources)
            {
                if(progressObj == resObj.progress)
                {
                    if(self.delegate)
                    {
                        [self.delegate recvResourceDidUpdateProgressInfo:resObj.progress resourcename:resObj.name];
                    }
                    
                    if(progressObj.completedUnitCount == progressObj.totalUnitCount)
                    {
                        [resObj.progress removeObserver:self forKeyPath: @"fractionCompleted"];
                    }
                }
                
                break;
            }
        }
    }
   
}

#pragma mark MCSessionDelegate

- (void) session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{

    if(thisDevice.senderMode == true)
    {
        for(CTSTMDevice2 * device in devices)
        {
            if(device.peerId.hash == peerID.hash)
            {
                if(state == MCSessionStateNotConnected)
                {
                    if(device.status != Cancel)
                    {
                        device.status = Disconnected;
                    }
                }
                else if (state == MCSessionStateConnecting)
                {
                    device.status = Connecting;
                }
                else if (state == MCSessionStateConnected)
                {
                    if(device.status != Transfer)
                    {
                        device.status = Connected;
                    }
                }
                break;
            }
        }
        
        if(state == MCSessionStateConnected)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self broadcastHostMode];
            
            });
        }
    }
    else
    {
        if(state ==  MCSessionStateNotConnected)
        {
            if(hostDevice != nil && hostDevice.peerId.hash == peerID.hash)
            {
                // we lost hostDevice
                
                for(CTSTMResourceObject * recv in recvResources)
                {
                    [recv.progress removeObserver:self forKeyPath:@"fractionCompleted"];
                }
                
                [recvResources removeAllObjects];
            }
        }
    }
    
    if(self.delegate)
    {
        [self.delegate groupStatusChanged];
    }

}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    [self processRecvData:data peer:peerID];
}


- (void) session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    // not support yet
}

- (void) session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    NSLog(@"->Receiver start receiving file");
    
    CTSTMResourceObject * resObj = [[CTSTMResourceObject alloc] init];
    
    resObj.peer = peerID;
    resObj.isSending = false;
    resObj.name = resourceName;
    resObj.progress = progress;
    
    [recvResources addObject:resObj];
    
    [resObj.progress addObserver:self forKeyPath: @"fractionCompleted" options: NSKeyValueObservingOptionNew context: nil];
    
    if(self.delegate) {
        [self.delegate recvResourceStart:resourceName];
    }
}

- (void) session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"->Receiver did received whole file");
    if(hostDevice.status != Cancel)
    {
        for(CTSTMResourceObject * resObj in recvResources)
        {
            if([resObj.name isEqualToString:resourceName])
            {
                [recvResources removeObject:resObj];
            }
        }
        
        
        [self recvResource: resourceName localURL: localURL];
        
    }
}


@end
