//
//  CTSenderBonjourManager.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTSenderBonjourManager.h"

#import "CTBonjourManager.h"
#import "NSData+CTHelper.h"
#import "NSString+CTMVMConvenience.h"
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

@interface CTSenderBonjourManager() <NSStreamDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate>

@property (nonatomic, assign) NSInteger startIndex;

@property (nonatomic, strong) NSMutableData *incompleteData;
@property (nonatomic, strong) NSData *dataTobeTransmitted;

@property (nonatomic, assign) NSInteger headerSize;

// properties for reconnect
@property (nonatomic, assign) NSInteger streamClosedCount;
@property (nonatomic, strong) NSTimer *timeoutTimer; // Timer for count timeout during transfer
@property (assign, nonatomic) NSInteger bonjourReconnectionTimeOutCount; // count down for finding the service (60 sec)
//@property (nonatomic, strong) NSTimer *bonjourConnectionTimeOut; // Timer for reconnect duration

@property (nonatomic, assign) int timeoutCountdown; // count down prameter for timeout timer
@property (nonatomic, assign) int retryTimes; // the try times for receonnection
@property (nonatomic, assign) int streamWaitingCountdown; // count down for connecting duration (20 sec)
@property (nonatomic, assign) int delayCountDown; // count down for delay timer (10 seconds)
@property (nonatomic, assign) BOOL waitingServiceShouldStop; // indicate that should stop reconnect timer (not timeout timer)

@property (nonatomic, assign) BOOL senderStreamsOpened; // indicate that streams are opened

@property (nonatomic, assign) BOOL transferStarted; // default value is NO.
@property (nonatomic, assign) NSInteger bytesWritten;
@end

@implementation CTSenderBonjourManager

#define BONJOUR_BUFFERSIZE 8192 // 8Kb buffer size for photos.
#define BONJOUR_VIDEO_BUFFERSIZE 65536 // 64Kb buffer size for videos.
#define TIMEOUT_LIMIT 30 // seconds for time out timer.
#define SERVICE_WAITING_TIMEOUT 20 // seconds for finding target service time out timer.
#define WAIT_FOR_STREAMS_LIMIT 20 // each of the reconnect try will have 20s limit.
#define STREAM_OPEN_TRY_TIMES 3 // only try 3 times reconnect after failed.
#define RECONNECT_DELAY_TIME 10 // between each of the retry, 10 times delay added for system clear the resource hold in runloop.

- (void)setServerRestarted:(BOOL)serverRestarted {
    if (!serverRestarted && _serverRestarted) {
        // Before is YES, reset to NO, in this case, only will happen when sender side received the reconnect request from receiver side (success).
        // Should hide the alert.
        [self.delegate senderTransferShouldEnableForContiue:YES];
    }
    
    _serverRestarted = serverRestarted;
}

- (instancetype)initWithDelegate:(id<CTSenderBonjourManagerDelegate>)controller {
    self = [super init];
    if (self) {
        self.delegate = controller;
        [self setBonjourDelegate];
    }
    return self;
}

- (void)setBonjourDelegate {
    // Bonjour service setup for current view
    [[CTBonjourManager sharedInstance] setServerDelegate:self];
    
    // Get all file list from interface, and send it.
    NSData *fileListData = [self.delegate getAllFileListToBeSend];
    [self.delegate senderSouldUpdateCurrentPayloadSize:fileListData.length];
    if (fileListData.length > 0) {
        [self requestSendingFileListPackage:fileListData];
    } else { // Interrupted
        [self.delegate transferWillInterrupted:TRANSFER_INTERRUPTED];
    }
}

#pragma mark - File List Method
- (void)requestSendingPackage:(NSData *)package actualSize:(long long)size {
    self.byteActuallyWrite = 0;
    self.startIndex = 0;
    self.dataTobeTransmitted = package;
    self.headerSize = package.length - (long)size;
    self.bytesWritten = 0;
    NSLog(@"========>request sending package");
    [self sendPacket:YES];
}

- (void)requestSendingFileListPackage:(NSData *)package {
    self.startIndex = 0;
    self.byteActuallyWrite = 0;
    self.dataTobeTransmitted = package;
    self.bytesWritten = 0;
    NSLog(@"request sending package with NO");
    [self sendPacket:NO];
}

- (void)requestSendingPackageFailed:(long long)failedSize shouldConsiderFail:(BOOL)fail {
    NSLog(@"Unfinished count:%lld", failedSize);    
    NSString *request = [NSString stringWithFormat:@"%@%010lld", CT_SEND_FILE_FAILURE, failedSize];
    NSData *requestData = [request dataUsingEncoding:NSUTF8StringEncoding];
    self.isVideo = 3; // Request sent and end.
    [[CTBonjourManager sharedInstance] sendStream:requestData];
    
    if (fail) {
        [self.delegate senderPhotoFileTransferDidFailed:failedSize];
    }
    [self.delegate senderShouldCreateProcessInfomation:failedSize];
}

- (void)requestSendLargeFilePacket {
    
    if (self.videoFirstPacket) { // first package of the file
        NSData *videoDatainit = [NSData dataWithContentsOfFile:self.currentVideoURL.URL atOffset:0 withSize:BONJOUR_VIDEO_BUFFERSIZE];
        
        // header
        NSString *requestStr = [[NSString alloc] initWithFormat:@"%@%010llu", CT_SEND_FILE_VIDEO_HEADER, self.videoFileSize];
        NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
        
        // merge the data
        NSMutableData *finaldata = [[NSMutableData alloc] init];
        [finaldata appendData:requestData];
        [finaldata appendData:videoDatainit];
        
        // transfer
        uint8_t *bytes1 = (uint8_t*)[finaldata bytes];
        
        [self checkConnectionTimeout];
        NSLog(@"> Ready to write data into stream...");
        self.bytesWritten = 0;
        self.bytesWritten = [[CTBonjourManager sharedInstance].outputStream write:bytes1 maxLength:(NSUInteger)finaldata.length];
        NSLog(@"> Byte written updated.");
    } else {
        NSData *videoData = [[NSData alloc] init];
        if ((self.byteActuallyWrite + BONJOUR_VIDEO_BUFFERSIZE) > self.videoFileSize) { // Last package of the video file
            videoData = [NSData dataWithContentsOfFile:self.currentVideoURL.URL atOffset:_byteActuallyWrite withSize:(NSInteger)(self.videoFileSize - self.byteActuallyWrite)];
        } else {
            // Rest of the video package
            videoData = [NSData dataWithContentsOfFile:self.currentVideoURL.URL atOffset:self.byteActuallyWrite withSize:BONJOUR_VIDEO_BUFFERSIZE];
        }
        
        uint8_t *bytes = ( uint8_t*)[videoData bytes];
        //            NSInteger  bytesWritten;
        [self checkConnectionTimeout];
        NSLog(@"> Ready to write data into stream...");
        self.bytesWritten = [[CTBonjourManager sharedInstance].outputStream write:bytes maxLength:(NSUInteger)videoData.length];
        NSLog(@"> Byte written updated.");
    }
}

#pragma mark - Helper Method
- (void)sendPacket:(BOOL)shouldUpdate {
    if (self.dataTobeTransmitted.length == 0) {
        DebugLog(@"Why am I receiving 0 length package?");
        return;
    }
    
    if (shouldUpdate) {
        self.isVideo = 0;
    } else {
        self.isVideo = 2;
    }
    
    NSUInteger bufferSize = 0;
//    BOOL flag = NO;
    if(self.startIndex + BONJOUR_BUFFERSIZE > self.dataTobeTransmitted.length) {
        bufferSize = self.dataTobeTransmitted.length - self.startIndex;
//        flag = YES;
    } else {
        bufferSize = BONJOUR_BUFFERSIZE;
    }
    
    NSData *packet = [self.dataTobeTransmitted subdataWithRange:NSMakeRange((NSUInteger)self.startIndex, bufferSize)];
    
    uint8_t *bytes1 = (uint8_t*)[packet bytes];
    [self checkConnectionTimeout];
    NSLog(@"Preparing to send the bytes in stream...");
    self.bytesWritten = 0;
    self.bytesWritten = [[CTBonjourManager sharedInstance].outputStream write:bytes1 maxLength:(NSUInteger)bufferSize];
    NSLog(@"Byte written updated...");
}

#pragma mark - NSStream Delegate
// Stream connection event
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) { // Streams opened
        case NSStreamEventOpenCompleted: { // Only come here when trying to reconnect the Bonjour service
            [CTBonjourManager sharedInstance].streamOpenCount += 1;
            @try {
                NSAssert([CTBonjourManager sharedInstance].streamOpenCount <= 2, @"streamCountException");
            } @catch(NSException *exception) {
                DebugLog(@"Error when open stream, count wrong:%@", exception.description);
            }
            if ([CTBonjourManager sharedInstance].streamOpenCount == 2) {
                [[CTBonjourManager sharedInstance] stopServer];
                [CTBonjourManager sharedInstance].isServerStarted = NO;
                
                DebugLog(@"Reconnecting: finish opened streams, success!\n ==========================");
                _senderStreamsOpened = YES;
            }
        }
            break;
            
        case NSStreamEventHasSpaceAvailable: { // Stream has space, writting logic
            @try {
                NSAssert(stream == [CTBonjourManager sharedInstance].outputStream, @"stream count error");
            } @catch(NSException *exception) {
                DebugLog(@"Error when writting stream, count wrong:%@", exception.description);
            }
            
            if (self.processCancelled) { // process should be stopped
                if(self.cancelRequestSent) { // cancel request already sent, clear the streams
                    [[CTBonjourManager sharedInstance] closeStreams];
                    break;
                }
                
                // send cancel request
                NSString *msg = CT_REQUEST_FILE_CANCEL;
                NSData *message = [msg dataUsingEncoding:NSUTF8StringEncoding];
                // Get pointer to NSData bytes
                const uint8_t *bytes = (const uint8_t*)[message bytes];
                NSUInteger len = (NSUInteger)[message length];
                
                NSInteger bytesWritten;
                bytesWritten = [(NSOutputStream *)stream write:bytes maxLength:len];
                if (bytesWritten) {
                    self.cancelRequestSent = YES;
                    NSLog(@"send cancel in stream");
                }
                
                break;
            } else if (self.serverRestarted) {
                DebugLog(@"Ignore all the data before receiving any reconnect request.");
                break;
            }
            
            switch (self.isVideo) {
                case 0: {
                    while (self.bytesWritten == 0) {
                        NSLog(@"> Byte written hasn't returned, waiting for the update....");
                        [NSThread sleepForTimeInterval:0.5f];
                    }
                    NSLog(@"Byte written: %lu", (long)self.bytesWritten);
                    self.byteActuallyWrite += self.bytesWritten;
                    NSLog(@"Actually written: %lu", (long)self.byteActuallyWrite);
                    self.startIndex += self.bytesWritten;
                    NSLog(@"Start index: %lu", (long)self.startIndex);
                    // Update UI
                    if (self.bytesWritten > self.headerSize) {
                        // whole header sent along with data
                        [self.delegate senderShouldCreateProcessInfomation:self.bytesWritten-self.headerSize];
                        self.headerSize = 0;
                    } else { // only sent header (may not complete sending header), don't update information
                        self.headerSize -= self.bytesWritten;
                    }
                    
                    DebugLog(@"photo sending and total data transmitted is %lu of %lu", (long)self.startIndex, (unsigned long)self.dataTobeTransmitted.length);
                    
                    if (self.dataTobeTransmitted.length != self.byteActuallyWrite) {
                        NSLog(@"======>request sending package continue 0");
                        [self sendPacket:YES];
                    } else {
                        DebugLog(@"=======================photo transfer finished========================");
                        
                        // All package send, clear the globe properties
                        self.startIndex = 0;
                        //            self.isVideo = 3;
                        self.dataTobeTransmitted = nil;
                        self.byteActuallyWrite = 0;
                        self.bytesWritten = 0;
                    }
                } break;
                    
                case 1: {
                    while (self.bytesWritten == 0) {
                        NSLog(@"> Byte written hasn't returned, waiting for the update....");
                        [NSThread sleepForTimeInterval:0.5f];
                    }
                    
                    if (self.videoFirstPacket) { // first package of the file
                        self.byteActuallyWrite = self.bytesWritten - 37;
                        if (self.bytesWritten < 0) {
                            DebugLog(@"byte write crash:%@", [CTBonjourManager sharedInstance].outputStream.streamError.localizedDescription);
                        }
                        
                        if (self.byteActuallyWrite) {
                            [self.delegate senderShouldCreateProcessInfomation:self.byteActuallyWrite];
                        }
                        
                        DebugLog(@"%ld of %lld Video bytes sent\n\n", (long)self.byteActuallyWrite, self.videoFileSize);
                        self.videoFirstPacket = NO;
                    } else {
                        self.byteActuallyWrite += self.bytesWritten;
                        DebugLog(@"%ld of %lld Video bytes sent\n\n", (long)self.byteActuallyWrite, self.videoFileSize);
                        
                        
                        if (self.bytesWritten < 0) {
                            DebugLog(@"byte write crash:%@", [CTBonjourManager sharedInstance].outputStream.streamError.localizedDescription);
                        } else {
                            [self.delegate senderShouldCreateProcessInfomation:self.bytesWritten];
                        }
                    }
                    
                    if (self.byteActuallyWrite != self.videoFileSize) {
                        [self requestSendLargeFilePacket];
                    } else if (self.byteActuallyWrite == self.videoFileSize) {
                        DebugLog(@"=======================video transfer finished========================");
                    }
                } break;
                    
                case 2: {
                    while (self.bytesWritten == 0) {
                        NSLog(@"> Byte written hasn't returned, waiting for the update....");
                        [NSThread sleepForTimeInterval:0.5f];
                    }
                    
                    NSLog(@"Byte written: %lu", (long)self.bytesWritten);
                    self.byteActuallyWrite += self.bytesWritten;
                    NSLog(@"Actually written: %lu", (long)self.byteActuallyWrite);
                    self.startIndex += self.bytesWritten;
                    NSLog(@"Start index: %lu", (long)self.startIndex);
                    
                    DebugLog(@"photo sending and total data transmitted is %lu of %lu", (long)self.startIndex, (unsigned long)self.dataTobeTransmitted.length);
                    
                    if (self.dataTobeTransmitted.length != self.byteActuallyWrite) {
                        NSLog(@"=====>request sending package continue 2");
                        [self sendPacket:NO];
                    } else {
                        DebugLog(@"=======================photo transfer finished========================");
                        
                        // All package send, clear the globe properties
                        self.startIndex = 0;
                        //            self.isVideo = 3;
                        self.dataTobeTransmitted = nil;
                        self.byteActuallyWrite = 0;
                        self.bytesWritten = 0;
                    }
                } break;
                
                case 3: {
                    NSLog(@"=====>Done");
                    if (self.dataTobeTransmitted) { 
                        NSAssert(self.dataTobeTransmitted.length == self.byteActuallyWrite, @"Unfinished file come to this. Check the code: %ld of %lu", (long)self.byteActuallyWrite, (unsigned long)self.dataTobeTransmitted.length);
                    }
                }
                default:
                    break;
            }
        }
            break;
            
        case NSStreamEventHasBytesAvailable: { // Stream has bytes to read
            
            if (_transferFinished) {
                return;
            }
        
            NSUInteger bsize = 1024;
            uint8_t buf[bsize];
            NSInteger bytesRead = 0;
            bytesRead = [[CTBonjourManager sharedInstance].inputStream read:buf maxLength:bsize];
            if (bytesRead > 0) {
                if (!_transferStarted) {
                    _transferStarted = YES;
                    [CTUserDefaults sharedInstance].transferStarted = YES;
                }
                
                DebugLog(@"debug mode:received data on in progress page:%ld", (long)bytesRead);                
                NSData *data = [NSData dataWithBytes:buf length:bytesRead];
                if (self.incompleteData.length > 0) {
                    // If has some incomplete data, append them, and clear the incomplete one.
                    [self.incompleteData appendData:data];
                    data = self.incompleteData;
                    self.incompleteData = nil;
                }
                
                NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                response = [response removeHeartBeat];
                if (response.length > 0) {
                    [self.delegate identifyReceviedBonjourRequest:response shouldStoreIncompleteHandler:^(NSUInteger length) {
                        self.incompleteData = [NSMutableData dataWithData:[data subdataWithRange:NSMakeRange(response.length - length, length)]]; // store the incomplete data
                    }];
                }
            }
        }
            
            break;
            // all others cases
        case NSStreamEventEndEncountered: {
            DebugLog(@"End of the stream.");
        }
            break;
        case NSStreamEventNone: {
            DebugLog(@"Stream event none.");
        }
            break;
        case NSStreamEventErrorOccurred: {
            DebugLog(@"Stream error occurred.");
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [CTBonjourManager sharedInstance].streamOpenCount --;
            if ([stream isKindOfClass:[NSInputStream class]]) { // if it's input stream
                [CTBonjourManager sharedInstance].inputStream = nil;
            } else {
                [CTBonjourManager sharedInstance].outputStream = nil;
            }
            
//            if (++_streamClosedCount == 2) { // when 2 streams both closed, start reconnect logic
//                _retryTimes = 0; // reset the retry times count to 0
//                [self searchForOriginService];
//            } else {
////                self.transferStatusLbl.text = @"Connection Error";
//                
//                [self shouldStopTimeoutTimer];
//                self.senderStreamsOpened = NO;
//            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Helper methods
- (void)checkConnectionTimeout {
    [self.delegate senderTransferShouldEnableForContiue:YES];
    if ([_timeoutTimer isValid]) {
        _timeoutCountdown = 0; // Once successfully write a package into the stream, reset the timer to 0.
    } else if (!_serverRestarted) { // first time comes, schedule a timer for time out.
        _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeoutCountingHandler:) userInfo:nil repeats:YES];
    }
}

- (void)timeoutCountingHandler:(NSTimer *)timer {
    if (_transferFinished) {
        [timer invalidate];
        timer = nil;
        _timeoutCountdown = 0;
        
        return;
    }
    
    _timeoutCountdown ++;
    DebugLog(@"count down: %d of %d", _timeoutCountdown, TIMEOUT_LIMIT);
    
    if (_timeoutCountdown == TIMEOUT_LIMIT) { // time out reach the timeout limit
        self.senderStreamsOpened = NO;
        
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
        timer = nil;
        _timeoutCountdown = 0;
        
        [self searchForOriginService];
    } else if (_timeoutCountdown == TIMEOUT_LIMIT/2) { // when reach the half of the time out limit, show information to user
        [self.delegate senderTransferShouldBlockForReconnect:CTLocalizedString(CT_RECONNECT_ALERT_CONTEXT, nil)];
    }
}

- (void)searchForOriginService {
    _retryTimes ++; // add one retry times
    [self.delegate senderTransferShouldBlockForReconnect:CTLocalizedString(CT_RECONNECT_ALERT_TITLE, nil)];
    if (!self.serverRestarted) {
        self.serverRestarted = [[CTBonjourManager sharedInstance] createReconnectServerForController:self];
        
        if (!self.serverRestarted) {
            // if restart failed
            DebugLog(@"Reconnecting: republish the service failed.");
            
            if (_retryTimes == STREAM_OPEN_TRY_TIMES) {
                // failed.
                [self.delegate senderTransferShouldEnableForContiue:NO];
            } else {
                // try again.
                _delayCountDown = 0;
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayHandler:) userInfo:nil repeats:YES];
            }
        }
        // if it's not failed, it will return from service delegate
    }
}

- (void)runloopForBonjourReconnet:(NSTimer *)timer {
    if (_waitingServiceShouldStop) {
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
    [self.delegate senderTransferShouldEnableForContiue:NO];
}

#pragma mark - NSNetService Delegate
- (void)netServiceDidPublish:(NSNetService *)sender {
    DebugLog(@"Reconnecting: service republished, waiting for scan the service.");
    
    _waitingServiceShouldStop = NO;
    // Start the device browser
    if ([[CTBonjourManager sharedInstance] isBrowserValid]) {
        [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
    }
    [[CTBonjourManager sharedInstance] startBrowserNetworkingForTarget:self];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(runloopForBonjourReconnet:) userInfo:nil repeats:YES];
}

#pragma mark - Service browser
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    DebugLog(@"Reconnecting: find one service, name-%@", service.name);
    
    NSString *targetServerName = [CTBonjourManager sharedInstance].targetServer.name;
    NSString *target = @"";
    if ([[targetServerName substringFromIndex:targetServerName.length-3] isEqualToString:@"/RC"]) {
        target = targetServerName;
    } else {
        target = [NSString stringWithFormat:@"%@/RC",[CTBonjourManager sharedInstance].targetServer.name];
    }
    DebugLog(@"Reconnecting: target service name:%@", target);
    
    if ([target isEqualToString:service.name]) { // service name is unique
        _waitingServiceShouldStop = YES;
        [[CTBonjourManager sharedInstance] stopBrowserNetworking:self];
        [CTBonjourManager sharedInstance].targetServer = service;
        [self createConnectionForService:[CTBonjourManager sharedInstance].targetServer];
    } // ignore other services
}

- (void)createConnectionForService:(NSNetService *)service
{
    BOOL success = NO;
    NSInputStream *inStream = nil;
    NSOutputStream *outStream = nil;
    
    // device was chosen by user in picker view
    success = [service getInputStream:&inStream outputStream:&outStream];
    if (!success) {
        if (_retryTimes == STREAM_OPEN_TRY_TIMES) {
            // failed.
            [[CTBonjourManager sharedInstance] stopServer];
            [self.delegate senderTransferShouldEnableForContiue:NO];
        } else {
            // try again.
            _delayCountDown = 0;
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayHandler:) userInfo:nil repeats:YES];
        }
    } else {
//        self.transferStatusLbl.text = @"Connection Opening...";
        
        // user tapped device: so create and open streams with that devices
        assert([CTBonjourManager sharedInstance].inputStream == nil);
        assert([CTBonjourManager sharedInstance].outputStream == nil);
        assert([NSThread isMainThread]);
        
        [CTBonjourManager sharedInstance].inputStream  = inStream;
        [CTBonjourManager sharedInstance].outputStream = outStream;
        
        // open input
        [[CTBonjourManager sharedInstance].inputStream  setDelegate:self];
        // open output
        [[CTBonjourManager sharedInstance].outputStream setDelegate:self];
        
        [NSThread detachNewThreadSelector:@selector(newThreadHandler:) toTarget:self withObject:nil];
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

- (void)newThreadHandler:(NSThread *)thread
{
    // streams must exist but aren't open
    assert([CTBonjourManager sharedInstance].inputStream != nil);
    assert([CTBonjourManager sharedInstance].outputStream != nil);
    assert([CTBonjourManager sharedInstance].streamOpenCount == 0);
    
    DebugLog(@"Reconnnecting: create new thread");
    
    _delayCountDown = 0;
    _streamWaitingCountdown = 0;
    NSTimer *runloopController = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(runloopLive:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:runloopController forMode:NSDefaultRunLoopMode];
    
    [[NSRunLoop currentRunLoop] run];
}

- (void)runloopLive:(NSTimer *)timer {
    
    if (_streamWaitingCountdown <= WAIT_FOR_STREAMS_LIMIT) { // less than 20 sec
        _streamWaitingCountdown++;
        DebugLog(@"Reconnecting: openning streams for %d of %d sec", _streamWaitingCountdown, WAIT_FOR_STREAMS_LIMIT);
    } else { // reach 20s limit, start delay count down
        _delayCountDown ++;
        if (_delayCountDown <= RECONNECT_DELAY_TIME) {
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
    
    if (!self.senderStreamsOpened) {
        if (_streamWaitingCountdown > WAIT_FOR_STREAMS_LIMIT) { // above 20 seconds, close current try
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
                [self.delegate senderTransferShouldEnableForContiue:NO];
                
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

- (void)restartProcessOnMainThread {
    [self searchForOriginService];
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

- (void)shouldStopTimeoutTimer {
    if ([_timeoutTimer isValid]) {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
        _timeoutCountdown = 0;
    }
}

@end
