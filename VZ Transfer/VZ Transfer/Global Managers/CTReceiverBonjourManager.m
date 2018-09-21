//
//  CTReceiverBonjourManager.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTReceiverBonjourManager.h"
#import "CTBonjourManager.h"
#import "CTUserDefaults.h"
#import "CTUserDevice.h"
#import "CTContentTransferConstant.h"

@interface CTReceiverBonjourManager() <NSStreamDelegate, ReceiveHelperManager, NSNetServiceDelegate>
/** 
 *  This perameter is for checking if this package is the first package from sender side or not, so we can jump the UI from ready view to receive view.
 *  Default value of this property is YES. And in this object, there is nowhere to assign this to YES, only will be assigned to NO manually.
 */
@property (nonatomic, assign) BOOL isFirstPackage;
@property (nonatomic, assign) BOOL transferStart; // flag to track transfer is start or not, only set YES at one place, and never reset it to NO, default value is NO

@property (nonatomic, assign) BOOL transferFinished;
@property (nonatomic, assign) BOOL transferCompleted;

@property (nonatomic, assign) NSInteger streamClosed;

// Reconnect properties
@property (nonatomic, assign) BOOL serverRestarted;            // indicate that server is republished or not, default value is NO, set YES if service published, reset to NO when start transfer after reconnect
@property (nonatomic, assign) BOOL receiverStreamReopened;     // indicate that receiver streams are reopened or not, default value is NO
@property (nonatomic, assign) BOOL reconnectResponseSent;      // indicate that reconnect request is sent or not. Default value is NO.
@property (nonatomic, assign) BOOL waitingInvitationShouldStop;// indicate that receiver should stop waiting for invitation.

@property (nonatomic, strong) NSTimer *timeoutCountingTimer; // connection time out timer
//@property (nonatomic, strong) NSTimer *bonjourConnectionTimeOut;
@property (nonatomic, assign) NSInteger timeoutTimerCountdown;
@property (nonatomic, assign) NSInteger receiverStreamWaitingCountdown; // count down number for waiting the invitation and open stream for reconnection.
@property (nonatomic, assign) int delayCountDown; // count down for delay between different retry
@property (nonatomic, assign) int retryTimes;
@property (nonatomic, assign) int bonjourReconnectionTimeOutCount;

@property (nonatomic, assign) long long actualReceived;
@property (nonatomic, assign) long long lastTotalReceived;

@end

#define kBonjourReceiveNormalSize 16384
#define kBonjourReceiveVideoSize 131072

#define TIMEOUT_LIMIT 30

@implementation CTReceiverBonjourManager

- (instancetype)initWithDelegate:(id<CTReceiverBonjourManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _isFirstPackage = YES;
        _helper = [[CTReceiveManagerHelper alloc] initWithDelegate:self];
        
        [self setBonjourDelegate];
    }
    
    return self;
}

- (void)setBonjourDelegate {
    // Bonjour service setup for current view
    [[CTBonjourManager sharedInstance] setServerDelegate:self];
    
    [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(sendHeartBeat:) userInfo:nil repeats:YES]; // manually send keep alive request every 2 sec for whenever you want.
}

- (void)sendHeartBeat:(NSTimer *)timer {
    if (!self.transferStart && !self.transferFinished) { // only send keep alive request before user start the transfer
        NSString *message = @"VZTRANSFER_KEEP_ALIVE_HEARTBEAT";
        NSData *data =[message dataUsingEncoding:NSUTF8StringEncoding];
        [[CTBonjourManager sharedInstance] sendFileStream:data];
        DebugLog(@"did send heart beat");
    } else {
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark - NSStream delegate
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) { // streams opened
        case NSStreamEventOpenCompleted: { // only reconnect will run this code
            [CTBonjourManager sharedInstance].streamOpenCount += 1;
            @try {
                NSAssert([CTBonjourManager sharedInstance].streamOpenCount <= 2, @"StreamCountException");
            } @catch(NSException *exception) {
                DebugLog(@"Error when open stream, count wrong:%@", exception.description);
            }
            // once both streams are open we hide the picker
            if ([CTBonjourManager sharedInstance].streamOpenCount == 2) {
                DebugLog(@"Reconnecting: finish opened streams, success!\n ==========================");
                // DebugLog(@"Close server");
                [[CTBonjourManager sharedInstance] stopServer];
                [CTBonjourManager sharedInstance].isServerStarted = NO;
                
                self.receiverStreamReopened = YES;
            }
        } break;
        case NSStreamEventHasSpaceAvailable: {
            DebugLog(@"Stream event has space available.");
            if (_serverRestarted) {
                DebugLog(@"Reconnecting: should send reconnect request to Sender side");
                [self performSelectorOnMainThread:@selector(buildingResponseInMainThread) withObject:nil waitUntilDone:NO];
            }
            
        }
            break;
            
        case NSStreamEventHasBytesAvailable: {
            
            if (self.transferFinished) { // ignore all data before reconnect request sent.
                break;
            }
            
            if (self.serverRestarted && !self.reconnectResponseSent) {
                break;
            }
            
            if (![_timeoutCountingTimer isValid]) { // reset the timeout timer
                [self.delegate senderTransferShouldEnableForContiue:YES];
                _timeoutCountingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeoutcountingHandler:) userInfo:nil repeats:YES];
            }
            _timeoutTimerCountdown = 0;
            
            // stream has data
            // (in a real app you have gather up multiple data packets into the sent data)
            NSUInteger bsize;
            if ([self.helper type] == RECEIVE_VIDEO_FILE) {
                // Only change the buffer size of receiving videos
                bsize = kBonjourReceiveVideoSize;
            } else {
                bsize = kBonjourReceiveNormalSize;
            }
            
            uint8_t buf[bsize];
            NSInteger bytesRead = [(NSInputStream *)stream read:buf maxLength:bsize];
            if (bytesRead > 0) {
//                // received remote data
                BOOL isCancelRequest = NO;
                BOOL shouldHandleDuplicate = NO;
                
                // if any package comes from sender side, means the transfer started
                if (!self.transferStart) {
                    self.transferStart = YES;
                    DebugLog(@"heart beat should stop");
                }
                
                NSData *data = [NSData dataWithBytes:buf length:bytesRead];
                NSLog(@"data received:%lu", (unsigned long)data.length);
                if (data.length == 17) { // cancel on the sender side
                    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if ([response isEqualToString:CT_REQUEST_FILE_CANCEL]) {
                        response = nil;
                        isCancelRequest = YES;
                    }
                } else if (data.length > 17) {
                    if (data.length == 28) {
                        NSString *response1 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        if ([response1 isEqualToString:CT_REQUEST_FILE_CANCEL_PERMISSION]) {
                            self.transferFinished = YES;
                            [[CTBonjourManager sharedInstance] closeStreams];
                            [self.delegate RequestToPopToRootViewController];
                            
                            return;
                        }
                    } else if (data.length == 29) {
                        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        if ([response isEqualToString:CT_SEND_FILE_DUPLICATE_RECEIVED]) {
                            shouldHandleDuplicate = YES;
                        }
                    } else {
                        NSData *tmpData = [data subdataWithRange:NSMakeRange(data.length-17, 17)];
                        NSString *response = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
                        
                        if ([response isEqualToString:CT_REQUEST_FILE_CANCEL]) {
                            response = nil;
                            isCancelRequest = YES;
                        }
                    }
                }
                
                if (isCancelRequest) { // receiver cancel connection
                    [self startCancelProcess];
                } else if (shouldHandleDuplicate) { // it's duplicate response
                    if (self.helper.currentStat == RECEIVE_PHOTO_FILE) {
                        [self.helper didFinishReceivedPhotoFile];
                    } else if (self.helper.currentStat == RECEIVE_VIDEO_FILE) {
                        [self.helper didFinishReceivedVideoFile];
                    }
                } else { // it is not cancel
                    if (self.isFirstPackage) {
                        [CTUserDefaults sharedInstance].transferStarted = YES;
                        [self.delegate transferWillStart];
                        self.isFirstPackage = NO;
                    }
                    
                    [self.helper receiverDidRecvDataPackage:data];
                }
            }
        } break;
            // all others cases
        case NSStreamEventEndEncountered: {
            DebugLog(@"Stream event end");
            [self startCancelProcess];
        } break;
            
        case NSStreamEventNone:
            DebugLog(@"Stream event none.");
            break;
            
        case NSStreamEventErrorOccurred:{
            DebugLog(@"Stream event error");
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [CTBonjourManager sharedInstance].streamOpenCount --;
            _streamClosed ++;
            
            if ([stream isKindOfClass:[NSInputStream class]]) {
                [CTBonjourManager sharedInstance].inputStream = nil;
            } else {
                [CTBonjourManager sharedInstance].outputStream = nil;
            }
            
            if (_streamClosed == 2){
                if (!_transferStart) { // No timer on this side yet, let user retry.
                    _transferFinished = YES;
                    
                    [self.delegate tansferFailedBeforeStarted];
                }
            }
        } break;
            
        default:
            break;
    }
}

- (void)startCancelProcess {
    if ([_timeoutCountingTimer isValid]) { // disable the timer
        [_timeoutCountingTimer invalidate];
        _timeoutCountingTimer = nil;
    }
    _timeoutTimerCountdown = 0;
    
    if (self.isFirstPackage) {
        [CTUserDevice userDevice].transferStatus = CTTransferStatus_Cancelled;
        [self.delegate transferShouldCancel];
    } else {
        [CTUserDefaults sharedInstance].isCancel = YES;
        [CTUserDevice userDevice].transferStatus = CTTransferStatus_Cancelled;
        [self.delegate transferDidCancelled];
        [self.helper notifyProcessCancelled];
    }
    [[CTBonjourManager sharedInstance] closeStreams];
}

- (void)timeoutcountingHandler:(NSTimer *)timer {
    if (self.transferFinished) {
        [timer invalidate];
        timer = nil;
        _timeoutTimerCountdown = 0;
        
        return;
    }
    
    _timeoutTimerCountdown++;
    DebugLog(@"count down: %ld of %d", (long)_timeoutTimerCountdown, TIMEOUT_LIMIT);
    
    if (_timeoutTimerCountdown == TIMEOUT_LIMIT) { // 30s for timeout
        
        _receiverStreamReopened = NO;
        _reconnectResponseSent = NO;
        
        // close current output stream
        [[CTBonjourManager sharedInstance].outputStream close];
        [[CTBonjourManager sharedInstance].outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [CTBonjourManager sharedInstance].outputStream = nil;
        
        // close current input stream
        [[CTBonjourManager sharedInstance].inputStream close];
        [[CTBonjourManager sharedInstance].inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [CTBonjourManager sharedInstance].inputStream = nil;
        
        
        [[CTBonjourManager sharedInstance] setStreamOpenCount:0];
        [[CTBonjourManager sharedInstance] stopServer];
        
        [timer invalidate]; // disable the timer
        timer = 0;
        _timeoutTimerCountdown = 0;
        
        [self searchForOriginService];
    } else if (_timeoutTimerCountdown == TIMEOUT_LIMIT/2) {
        [self.delegate senderTransferShouldBlockForReconnect:CTLocalizedString(CT_RECONNECT_ALERT_CONTEXT, nil)];
    }
}

- (void)sendNotEnoughStorageResponse {
    // send stream
    NSString *str = CT_REQUEST_FILE_NOT_ENOUGH_STORAGE;
    [[CTBonjourManager sharedInstance] sendStream:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - Manager helper delegate
- (void)transferDidFinished:(BOOL)lastIsDuplicate {
    // Send back the finish header
//    NSString *ackMsg = CT_REQUEST_FILE_COMPLETED;
    NSData *requestData = [CT_REQUEST_FILE_COMPLETED dataUsingEncoding:NSUTF8StringEncoding];
    [[CTBonjourManager sharedInstance] sendFileStream:requestData];
    
    self.transferFinished = YES;
    self.transferCompleted = YES;
//    self.transferFinishRequestSent = YES;
    
    [[CTBonjourManager sharedInstance] closeStreams];
    
    if (lastIsDuplicate) {
        [self.delegate transferDidFinished];
    }
}

- (void)transferShouldAllowSaving {
    [self.delegate transferShouldAllowSaving];
}

- (void)inSufficentStorageAvailalbe:(NSNumber *)availalbeSpace {
//    [self sendNotEnoughStorageResponse];
    [self.delegate inSufficentStorageAvailalbe:availalbeSpace];
}

- (void)totalPayLoadRecevied:(NSNumber*)totalPayload {
    [self.delegate totalPayLoadRecevied:totalPayload];
}

- (void)updateCurrentFileTransferToProgressManager:(BOOL)isDuplicate packageSize:(long long)pkgSize {
    
    NSMutableDictionary *mediaInfo = [[NSMutableDictionary alloc] init];
    NSString *mediaType = [self identifyMediaType:self.helper.currentStat];
    long long totalSectionSize = [self getTotalSizeForSection:self.helper.currentStat];
    [mediaInfo setObject:[NSNumber numberWithLongLong:totalSectionSize] forKey:@"sectionSize"];
    [mediaInfo setObject:[NSNumber numberWithLongLong:self.helper.dataSizeSection] forKey:@"sectionTransferred"];
    [mediaInfo setObject:mediaType forKey:@"MEDIATYPE"];
    if ([mediaType isEqualToString:@"photo"]) {
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.numberOfPhotosStartReceiving] forKey:@"TOTALFILERECEVIED"];
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.storeHelper.totalNumberOfPhotos] forKey:@"TOTALFILECOUNT"];
    } else if ([mediaType isEqualToString:@"video"]) {
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.numberOfVideosStartReceiving] forKey:@"TOTALFILERECEVIED"];
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.storeHelper.totalNumberOfVideos] forKey:@"TOTALFILECOUNT"];
    } else if ([mediaType isEqualToString:@"calendar"]) {
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.numberOfCalStartReceiving] forKey:@"TOTALFILERECEVIED"];
        [mediaInfo setObject:[NSString stringWithFormat:@"%ld",(long)self.helper.numberOfCalendar] forKey:@"TOTALFILECOUNT"];
    } else {
        [mediaInfo setObject:[NSString stringWithFormat:@"1"] forKey:@"TOTALFILERECEVIED"];
        [mediaInfo setObject:[NSString stringWithFormat:@"1"] forKey:@"TOTALFILECOUNT"];
    }
    [mediaInfo setObject:[NSNumber numberWithLongLong:self.helper.totalSizeReceived] forKey:@"totalSizeReceived"];
    [mediaInfo setObject:[NSNumber numberWithBool:isDuplicate] forKey:@"isDuplicate"];
    if (!isDuplicate) {
        // if it's duplicate, then received size if dummy size, should not consider when calulate the speed.
//        self.actualReceived += self.helper.totalSizeReceived - self.lastTotalReceived;
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


- (NSString *)identifyMediaType:(enum ReceiveState)mediType {
    
    switch (mediType) {
        case RECEIVE_ALL_FILE_LOG:
//            DebugLog(@"receive file list:");
            return @"file list";
            break;
        case RECEIVE_VCARD_FILE:
//            DebugLog(@"receive contacts:");
            return @"contacts";
            break;
        case RECEIVE_PHOTO_FILE:
//            DebugLog(@"receive photos:");
            return @"photo";
            break;
        case RECEIVE_VIDEO_FILE:
//            DebugLog(@"receive videos:");
            return @"video";
            break;
        case RECEIVE_CALENDAR_FILE:
//            DebugLog(@"receive calendar:");
            return @"calendar";
            break;
        case RECEVIE_REMINDER_FILE:
//            DebugLog(@"receive reminder:");
            return @"reminder";
            break;
        default:
            return @"unknown";
            break;
    }
}

- (void)processDidPressCancel {
    self.processCancelled = YES;
    self.transferFinished = YES;
    
    [CTUserDefaults sharedInstance].isCancel = YES;
    [self.helper notifyProcessCancelled];
}

- (void)receiverShouldUpdateInfo:(BOOL)isDuplicate packageSize:(long long)pkgSize {
    [self updateCurrentFileTransferToProgressManager:isDuplicate packageSize:pkgSize]; // package size is not required property, never use it.
}

#pragma mark - NSNetService Delegate

#define WAIT_FOR_STREAMS_LIMIT 20
#define STREAM_OPEN_TRY_TIMES 3 // only try 3 times reconnect after failed.
#define RECONNECT_DELAY_TIME 10 // between each of the retry, 10 times delay added for system clear the resource hold in runloop.
#define SERVICE_WAITING_TIMEOUT 20 // seconds for finding target service time out timer.

- (void)netServiceDidPublish:(NSNetService *)sender {
    DebugLog(@"Reconnecting: service republished, need to wait for invitation from sender side.");
    
    _waitingInvitationShouldStop = NO;
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(runloopForBonjourReconnet:) userInfo:nil repeats:YES];
}

- (void)runloopForBonjourReconnet:(NSTimer *)timer {
    if (_waitingInvitationShouldStop) {
        [timer invalidate];
        timer = nil;
        self.bonjourReconnectionTimeOutCount = 0;
    } else {
        self.bonjourReconnectionTimeOutCount++;
        DebugLog(@"count down: %ld of %d", (long)_bonjourReconnectionTimeOutCount, SERVICE_WAITING_TIMEOUT);
        if (self.bonjourReconnectionTimeOutCount > SERVICE_WAITING_TIMEOUT) { // reach the time out limit
            [[CTBonjourManager sharedInstance] stopServer];
            [self performSelectorOnMainThread:@selector(showDialogOnMainThread) withObject:nil waitUntilDone:NO];
            
            [timer invalidate];
            timer = nil;
        }
    }
}

- (void)showDialogOnMainThread {
    DebugLog(@"Reconnecting failed");
    [CTUserDevice userDevice].transferStatus = CTTransferStatus_Interrupted;
    [self.delegate senderTransferShouldEnableForContiue:NO];
    [self processDidPressCancel];
}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    
    _waitingInvitationShouldStop = YES;
    DebugLog(@"Reconnecting: invitation received, trying to open the streams");
    
    [CTBonjourManager sharedInstance].inputStream = nil;
    [CTBonjourManager sharedInstance].outputStream = nil;
    [CTBonjourManager sharedInstance].streamOpenCount = 0;
    
    // user tapped device: so create and open streams with that devices
    assert([CTBonjourManager sharedInstance].inputStream == nil);
    assert([CTBonjourManager sharedInstance].outputStream == nil);
    assert([CTBonjourManager sharedInstance].streamOpenCount == 0);
    
    // streams must exist but aren't open
    assert([NSThread isMainThread]);
    
    // we accepted connection to another device so open in/out connection streams
    [CTBonjourManager sharedInstance].inputStream  = inputStream;
    [CTBonjourManager sharedInstance].outputStream = outputStream;
    
    [[CTBonjourManager sharedInstance].outputStream setDelegate:self];
    [[CTBonjourManager sharedInstance].inputStream  setDelegate:self];
    
    [NSThread detachNewThreadSelector:@selector(newThreadHandler:) toTarget:self withObject:nil]; // create new thread to handle the reconnect request.
}

- (void)newThreadHandler:(NSThread *)thread {
    // streams must exist but aren't open
    assert(![NSThread isMainThread]);
    
    _receiverStreamWaitingCountdown = 0; // reset the count down
    NSTimer *runloopController = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(runloopLive:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:runloopController forMode:NSDefaultRunLoopMode];
    
    [[NSRunLoop currentRunLoop] run];
}

- (void)runloopLive:(NSTimer *)timer {
    if (_receiverStreamWaitingCountdown <= WAIT_FOR_STREAMS_LIMIT) { // less than 20 sec
        _receiverStreamWaitingCountdown++;
        DebugLog(@"Reconnecting: openning streams for %ld of %d sec", (long)_receiverStreamWaitingCountdown, WAIT_FOR_STREAMS_LIMIT);
    } else { // reach 20s limit, start delay count down
        _delayCountDown ++;
        if (_delayCountDown <= RECONNECT_DELAY_TIME) {
            DebugLog(@"Reconnnecting: delay %ds to try again.", RECONNECT_DELAY_TIME - _delayCountDown + 1);
            [self.delegate senderTransferShouldBlockForReconnect:[NSString stringWithFormat:CTLocalizedString(CT_RECONNECT_FAILED_ALERT_CONTEXT, nil), RECONNECT_DELAY_TIME - _delayCountDown + 1]];
        } else { // reach 10s delay limit
            _delayCountDown = 0;
            [self performSelectorOnMainThread:@selector(restartProcessOnMainThread) withObject:nil waitUntilDone:NO];
            
            [timer invalidate];
            timer = nil;
            [NSThread exit];
        }
        return;
    }
    
    if (!_receiverStreamReopened) { // streams still close
        if (_receiverStreamWaitingCountdown > WAIT_FOR_STREAMS_LIMIT) { // above 20 seconds, close current try
            [[CTBonjourManager sharedInstance].outputStream close];
            [[CTBonjourManager sharedInstance].outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [CTBonjourManager sharedInstance].outputStream = nil;
            
            [[CTBonjourManager sharedInstance].inputStream close];
            [[CTBonjourManager sharedInstance].inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [CTBonjourManager sharedInstance].inputStream = nil;
            
            [[CTBonjourManager sharedInstance] stopServer];
            
            DebugLog(@"Reconnecting: stop current reconnect. current retry time:%d", _retryTimes);
            
            _serverRestarted = NO;
            if (_retryTimes == STREAM_OPEN_TRY_TIMES) { // reach 3 times
                [[CTBonjourManager sharedInstance] stopServer];
                [CTUserDevice userDevice].transferStatus = CTTransferStatus_Interrupted;
                [self.delegate senderTransferShouldEnableForContiue:NO];
                [self processDidPressCancel];
                
                _retryTimes = 0;
                
                [timer invalidate];
                timer = nil;
                [NSThread exit];
            }
            
            return;
        }
        
        [self performSelectorOnMainThread:@selector(openStreamsInMainThread) withObject:nil waitUntilDone:NO];
    } else {
        _retryTimes = 0;
        [timer invalidate];
        timer = nil;
        
        [NSThread exit];
    }
}

- (void)openStreamsInMainThread {
    DebugLog(@"Reconnecting: trying to open the streams");
    [[CTBonjourManager sharedInstance].inputStream close];
    [[CTBonjourManager sharedInstance].outputStream close];
    [[CTBonjourManager sharedInstance].inputStream  removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[CTBonjourManager sharedInstance].outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[CTBonjourManager sharedInstance].inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[CTBonjourManager sharedInstance].outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[CTBonjourManager sharedInstance].inputStream open];
    [[CTBonjourManager sharedInstance].outputStream open];
}

- (void)restartProcessOnMainThread {
    [self searchForOriginService];
}

- (void)searchForOriginService {
    _retryTimes ++; // add one retry times
    [self.delegate senderTransferShouldBlockForReconnect:CTLocalizedString(CT_RECONNECT_ALERT_TITLE, nil)];
    if (!self.serverRestarted) {
        self.serverRestarted = [[CTBonjourManager sharedInstance] createReconnectServerForController:self];
        
        if (!self.serverRestarted && self.transferStart) {
            // if restart failed
            DebugLog(@"Reconnecting: republish the service failed.");
            
            if (_retryTimes == STREAM_OPEN_TRY_TIMES) {
                // failed.
                [CTUserDevice userDevice].transferStatus = CTTransferStatus_Interrupted;
                [self.delegate senderTransferShouldEnableForContiue:NO];
                [self processDidPressCancel];
            } else {
                // try again.
                _delayCountDown = 0;
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayHandler:) userInfo:nil repeats:YES];
            }
        }
        // if it's not failed, it will return from service delegate
    }
}

- (void)delayHandler:(NSTimer *)timer {
    _delayCountDown ++;
    if (_delayCountDown <= RECONNECT_DELAY_TIME) {
        [self.delegate senderTransferShouldBlockForReconnect:[NSString stringWithFormat:CTLocalizedString(CT_RECONNECT_FAILED_ALERT_CONTEXT, nil), RECONNECT_DELAY_TIME - _delayCountDown + 1]];
    } else { // reach 10s delay limit
        _delayCountDown = 0;
        [self performSelectorOnMainThread:@selector(restartProcessOnMainThread) withObject:nil waitUntilDone:NO];
        
        [timer invalidate];
        timer = nil;
    }
}

- (void)buildingResponseInMainThread {
    NSAssert([NSThread mainThread], @"Current thread is not the main thread");
    
    // Create response
    [self.helper createReconnectRequestHeader];
    _reconnectResponseSent = YES;
    _serverRestarted = NO;
    
    [self updateCurrentFileTransferToProgressManager:0 packageSize:0];
    [self.delegate senderTransferShouldEnableForContiue:YES];
}

- (void)stopTransferDueToPermission {
    self.transferFinished = YES;
    NSString *str1 = CT_REQUEST_FILE_CANCEL_PERMISSION;
    NSData * data1 = [str1 dataUsingEncoding:NSUTF8StringEncoding];
    [[CTBonjourManager sharedInstance] sendFileStream:data1];
    
    [[CTBonjourManager sharedInstance] closeStreams];
}

@end
