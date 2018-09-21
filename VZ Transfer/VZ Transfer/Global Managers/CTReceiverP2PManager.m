//
//  CTReceiverP2PManager.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTReceiverP2PManager.h"
#import "NSString+CTRootDocument.h"
#import "CTDeviceMarco.h"
#import "CTContentTransferConstant.h"
#import "NSString+CTHelper.h"
#import "NSString+CTHelper.h"
#import "CTSettingsUtility.h"

#import "CTCommPortClientSocket.h"
#import "CTCommPortServerSocket.h"

@interface CTReceiverP2PManager() <ReceiveHelperManager, CTCommPortSocketGeneralDelegate>

@property (nonatomic, assign) BOOL isFirstPackage;
@property (nonatomic, assign) BOOL isItHotSpotConnection_firstPacket;
@property (nonatomic, assign) BOOL isItHotSpotConnection;
@property (nonatomic ,assign) BOOL needVersionCheckForAndriod;

@property (nonatomic, assign) BOOL userCancelled;
@property (nonatomic, assign) BOOL transferBegins;

@property (nonatomic, assign) BOOL transferFinished;
@property (nonatomic, assign) BOOL transferCompleted;
@property (nonatomic, assign) NSTimeInterval readTimeOut;

@property (nonatomic, assign) long long actualReceived;
@property (nonatomic, assign) long long lastTotalReceived;

@end

@implementation CTReceiverP2PManager


- (instancetype)init {
    self = [super init];
    if (self) {
//        self.writeAsyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
         _helper = [[CTReceiveManagerHelper alloc] initWithDelegate:self];
        _helper.delegate = self;
         _isFirstPackage = YES;
        _isItHotSpotConnection_firstPacket = YES;
        _isItHotSpotConnection = NO;
        _needVersionCheckForAndriod = NO;
        _transferFinishRequestSent = NO;
        _readTimeOut = -1.0f;
    }
    return self;
}

- (void)setsocketDelegate:(GCDAsyncSocket *)socket {
    
    self.writeAsyncSocket = socket;
    self.writeAsyncSocket.delegate = self;
    
    // For Comm port, Only start server socket as long as verison check passed. Not for client socket because client need to connect after other side server started listening.
    if ((![[CTUserDevice userDevice].softAccessPoint isEqualToString:@"TRUE"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"transferIsOneToMany"]) || [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
        self.asyncSocketCommPort = [[CTCommPortServerSocket alloc] initServierSocket];
        self.asyncSocketCommPort.generalDelegate = self;
    }
}

- (void)createClientCommPortSocket {
    NSLog(@"client commport socket create.");
    if ([[CTUserDevice userDevice].softAccessPoint isEqualToString:@"TRUE"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"transferIsOneToMany"]) {
        self.asyncSocketCommPort = [[CTCommPortClientSocket alloc] initWithHost:[self.writeAsyncSocket connectedHost] andDelegate:self];
    }
}

- (void)commPortSocketdidReceivedCancelRequest {
    
//    [self.delegate test];
    
    self.userCancelled = YES;
    if (self.isFirstPackage) {
        [CTUserDevice userDevice].transferStatus = CTTransferStatus_Cancelled;
        [self.delegate transferShouldCancel];
        [self cleanupSocketConnectionOnUserCancelRequest];
    } else {
        [CTUserDefaults sharedInstance].isCancel = YES;
        [CTUserDevice userDevice].transferStatus = CTTransferStatus_Cancelled;
        [self.delegate transferDidCancelled];
        [self.helper notifyProcessCancelled];
        [self cleanupSocketConnectionOnUserCancelRequest];
    }
}

#pragma mark GCDAsyncSocket Delegates

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    DebugLog(@"Successfully connected");
    
}

#define GCDAsyncSocketClosedByRemotePeer 7
#define GCDSocketNotConnected 57
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (!err || !sock || _transferFinished) {
        return;
    }
    DebugLog(@"socketDidDisconnect:withError: \"%@\"", err.localizedDescription);

    DebugLog(@"Socked closed P2P manager");
    
//    if (sock == self.asyncSocketCommPort) {
//        DebugLog(@"Comm Socket clsoed");
//    } else {
    DebugLog(@"Regular Socket clsoed");
//    }
    
    [self cleanUpAllSocketConnection];
    
    // it means socket close exception receveid after VZCONTENTTRANSFER_FINISHED sent
    if (self.transferFinishRequestSent){
        return;
    }
    
    if (self.userCancelled) {
        return;
    }
    
    if (err.code == GCDAsyncSocketClosedByRemotePeer) { // close by remote peer means user close it
        [CTUserDevice userDevice].transferStatus = CTTransferStatus_Cancelled;
    } else if (err.code == GCDSocketNotConnected) { // socket not connected means failed
        if ([CTUserDefaults sharedInstance].transferStarted) { // If transfer already start
            [CTUserDevice userDevice].transferStatus = CTTransferStatus_Interrupted;
        } else { // Not start, should be "Cancel - Not started"
            [CTUserDevice userDevice].transferStatus = CTTransferStatus_Cancelled;
        }
    }

    [CTUserDefaults sharedInstance].isCancel = YES;
    [self.delegate transferDidCancelled];
    [self.helper notifyProcessCancelled];
    [self cleanupSocketConnectionOnUserCancelRequest];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    DebugLog(@"socket:didWriteDataWithTag: %ld",tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
   
    BOOL isCancelRequest = NO;
    BOOL shouldHandleDuplicate = NO;
    
    // Check for user cancel request
    DebugLog(@"data received P2P:%lu", (unsigned long)data.length);
    if (data.length == 17) { // cancel on the sender side
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([response isEqualToString:CT_REQUEST_FILE_CANCEL]) {
            response = nil;
            isCancelRequest = YES;
        }
    } else if (data.length > 17) {
        if (data.length == CT_SEND_FILE_DUPLICATE_RECEIVED.length) {
            NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([response isEqualToString:CT_SEND_FILE_DUPLICATE_RECEIVED]) {
                shouldHandleDuplicate = YES;
            }
        }
        
        NSData *tmpData = [data subdataWithRange:NSMakeRange(data.length-17, 17)];
        NSString *response = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
        
        if ([response isEqualToString:CT_REQUEST_FILE_CANCEL]) {
            response = nil;
            isCancelRequest = YES;
        }
        NSString *response1 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([response1 isEqualToString:CT_REQUEST_FILE_CANCEL_PERMISSION]) {
            [self cleanupSocketConnectionOnUserCancelRequest];
            [self.delegate RequestToPopToRootViewController];
            return;
        }
    }
    
    if (isCancelRequest) {
        self.userCancelled = YES;
        if (self.isFirstPackage) {
            [CTUserDevice userDevice].transferStatus = CTTransferStatus_Cancelled;
            [self.delegate transferShouldCancel];
            [self cleanupSocketConnectionOnUserCancelRequest];
        } else {
            [CTUserDefaults sharedInstance].isCancel = YES;
            [CTUserDevice userDevice].transferStatus = CTTransferStatus_Cancelled;
            [self.delegate transferDidCancelled];
            [self.helper notifyProcessCancelled];
            [self cleanupSocketConnectionOnUserCancelRequest];
        }
    } else if (shouldHandleDuplicate) { // it's duplicate response
        if (self.helper.currentStat == RECEIVE_PHOTO_FILE) {
            [self.helper didFinishReceivedPhotoFile];
        } else if (self.helper.currentStat == RECEIVE_VIDEO_FILE) {
            [self.helper didFinishReceivedVideoFile];
        }
    } else {
        if (self.isFirstPackage) {
            self.isFirstPackage = NO;
            self.transferBegins = YES; // never assign to NO
            [CTUserDefaults sharedInstance].transferStarted = YES;
            [self.delegate transferWillStart];
        }
        
        [self.helper receiverDidRecvDataPackage:data];
        [self.writeAsyncSocket readDataWithTimeout:self.readTimeOut tag:0];
    }
}

//- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
//    
//    if (_isItHotSpotConnection & self.isItHotSpotConnection_firstPacket) {
//        
//        self.writeAsyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//        
//        self.writeAsyncSocket = newSocket;
//        self.writeAsyncSocket.delegate = self;
//        
//        [self.writeAsyncSocket readDataWithTimeout:self.readTimeOut tag:0];
//        
//        self.isItHotSpotConnection_firstPacket = NO;
//        
//        return;
//    }
//}

- (void)updateCurrentFileTransferToProgressManager:(BOOL)isDuplicate packageSize:(long long)pkgSize {
    NSLog(@"update UI for duplicate?:%i", isDuplicate);
    NSMutableDictionary *mediaInfo = [[NSMutableDictionary alloc] init];
    NSString *mediaType = [self identifyMediaType:self.helper.currentStat];
    long long totalSectionSize = [self getTotalSizeForSection:self.helper.currentStat];
    [mediaInfo setObject:[NSNumber numberWithLongLong:totalSectionSize] forKey:@"sectionSize"];
    [mediaInfo setObject:[NSNumber numberWithLongLong:self.helper.dataSizeSection] forKey:@"sectionTransferred"];
    [mediaInfo setObject:mediaType forKey:@"MEDIATYPE"];
    if ([mediaType isEqualToString:@"photo"]) {
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.numberOfPhotosStartReceiving] forKey:@"TOTALFILERECEVIED"];
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.totalNumberOfPhotos] forKey:@"TOTALFILECOUNT"];
    } else if ([mediaType isEqualToString:@"video"]) {
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.numberOfVideosStartReceiving] forKey:@"TOTALFILERECEVIED"];
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.totalNumberOfVideos] forKey:@"TOTALFILECOUNT"];
    } else if ([mediaType isEqualToString:@"calendar"]) {
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.numberOfCalStartReceiving] forKey:@"TOTALFILERECEVIED"];
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.numberOfCalendar] forKey:@"TOTALFILECOUNT"];
    } else if ([mediaType isEqualToString:@"apps"]) {
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.numberOfAppsStartReceiving] forKey:@"TOTALFILERECEVIED"];
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.numberOfApps] forKey:@"TOTALFILECOUNT"];
    } else {
        [mediaInfo setObject:[NSString stringWithFormat:@"1"] forKey:@"TOTALFILERECEVIED"];
        [mediaInfo setObject:[NSString stringWithFormat:@"1"] forKey:@"TOTALFILECOUNT"];
    }
    [mediaInfo setObject:[NSNumber numberWithLongLong:self.helper.totalSizeReceived] forKey:@"totalSizeReceived"];
    [mediaInfo setObject:[NSNumber numberWithBool:isDuplicate] forKey:@"isDuplicate"];
    if (!isDuplicate) {
        // if it's duplicate, then received size if dummy size, should not consider when calulate the speed.
        self.actualReceived += pkgSize;
    }
//    self.lastTotalReceived = self.helper.totalSizeReceived;
    [mediaInfo setObject:[NSNumber numberWithLongLong:self.actualReceived] forKey:@"actualReceived"];
    
    // New change for failure handshake, only for P2P cross platform
    [mediaInfo setObject:self.helper.transferFailureCounts forKey:@"transferFailureCounts"];
    [mediaInfo setObject:self.helper.transferFailureSize forKey:@"transferFailureSize"];
    
    [self.delegate dataPacketRecevied:0 mediaInfo:mediaInfo];
}

- (long long)getTotalSizeForSection:(enum ReceiveState)mediType {
    switch (mediType) {
        case RECEIVE_ALL_FILE_LOG:
            return self.helper.totalSizeOfFileList;
            break;
        case RECEIVE_VCARD_FILE:
            return self.helper.totalSizeOfVcard;
            break;
        case RECEIVE_PHOTO_FILE:
            return self.helper.totalSizeOfPhoto;
            break;
        case RECEIVE_VIDEO_FILE:
            return self.helper.totalSizeOfVideo;
            break;
        case RECEIVE_CALENDAR_FILE:
            return self.helper.totalSizeOfCalendar;
            break;
        case RECEVIE_REMINDER_FILE:
            return self.helper.totalSizeOfReminder;
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *) identifyMediaType:(enum ReceiveState)mediType {
    
    switch (mediType) {
        case RECEIVE_ALL_FILE_LOG:
            return @"file list";
            break;
        case RECEIVE_VCARD_FILE:
            return @"contacts";
            break;
        case RECEIVE_PHOTO_FILE:
            return @"photo";
            break;
        case RECEIVE_VIDEO_FILE:
            return @"video";
            break;
        case RECEIVE_CALENDAR_FILE:
            return @"calendar";
            break;
        case RECEVIE_REMINDER_FILE:
            return @"reminder";
            break;
        case RECEIVE_APP_LIST_FILE:
            return @"apps";
            break;
        default:
            return @"unknown";
            break;
    }
}

#pragma mark - Manager helper delegate
- (void)transferDidFinished:(BOOL)lastIsDuplicate {
    // Send back the finish header
//    NSString *ackMsg = [NSString stringWithFormat:CT_REQUEST_FILE_COMPLETED];
    NSData *requestData = [CT_REQUEST_FILE_COMPLETED dataUsingEncoding:NSUTF8StringEncoding];
    [self writeDataToTheSocket:requestData];
    
    self.transferCompleted = YES;
    self.transferFinishRequestSent = YES;
    [self cleanUpAllSocketConnection];
    
    if (lastIsDuplicate) {
        [self.delegate transferDidFinished];
    }
}

- (void)transferShouldAllowSaving {
    [self.delegate transferShouldAllowSaving];
}


- (void)writeDataToTheSocket:(NSData *)dataPacket {
#if DEBUG
    NSString *response1 = [[NSString alloc] initWithData:dataPacket encoding:NSUTF8StringEncoding];
    NSLog(@"Request Sent %@",response1);
#endif
    
    [self.writeAsyncSocket writeData:dataPacket withTimeout:-1 tag:0];
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
        
        [self.writeAsyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
        [self.writeAsyncSocket readDataWithTimeout:self.readTimeOut tag:0];
    }
    
    [self.writeAsyncSocket readDataWithTimeout:self.readTimeOut tag:0];
}

- (void)totalPayLoadRecevied:(NSNumber*)totalPayload {
    
    [self.delegate totalPayLoadRecevied:totalPayload];
}

- (void)inSufficentStorageAvailalbe:(NSNumber *)availalbeSpace {
    
    [self.delegate inSufficentStorageAvailalbe:availalbeSpace];
}

- (void)receiverShouldUpdateInfo:(BOOL)isDuplicate packageSize:(long long)pkgSize {
    [self updateCurrentFileTransferToProgressManager:isDuplicate packageSize:pkgSize]; // package size is not required property, never use it.
}

#pragma mark to Close regular and comm socket

- (void)cleanupSocketConnectionOnUserCancelRequest {
    [self cleanUpAllSocketConnection];
}

- (void)cleanUpAllSocketConnection {
    self.writeAsyncSocket.delegate = nil;
    [self.writeAsyncSocket disconnect];
    self.asyncSocketCommPort.delegate = nil;
    [self.asyncSocketCommPort disconnect];
    self.writeAsyncSocket = nil;
    self.asyncSocketCommPort = nil;
    
    self.transferFinished = YES;
}

- (void)writeDataToSocket:(NSData *)dataToBeWritten {
    
    if (dataToBeWritten.length > 0) {
        
        [self.writeAsyncSocket writeData:dataToBeWritten withTimeout: -1.0 tag:0];
        [self.writeAsyncSocket readDataWithTimeout:self.readTimeOut tag:0];
        
    }
}


- (void)writeDataToSocketCommSocket:(NSData *)dataToBeWritten {
    
    if (dataToBeWritten.length > 0) {
        [self.asyncSocketCommPort writeData:dataToBeWritten];
    }
}


- (void)processDidPressCancel {
    self.userCancelled = YES;
    [CTUserDefaults sharedInstance].isCancel = YES;
    [self.helper notifyProcessCancelled];
    [self cleanupSocketConnectionOnUserCancelRequest];
}

- (void)processDidPressCancelFromMVM {
    self.userCancelled = YES;
    [CTUserDefaults sharedInstance].isCancel = YES;
    [self cleanupSocketConnectionOnUserCancelRequest];
}

//- (void)commPortSocketDidDisconnected {
//    [self.delegate test];
//}

@end
