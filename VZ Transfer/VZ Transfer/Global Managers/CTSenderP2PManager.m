//
//  CTSenderP2PManager.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTSenderP2PManager.h"
#import "NSString+CTMVMConvenience.h"
#import "CTPhotosManager.h"
#import <Photos/Photos.h>
#import "CTDeviceMarco.h"

@interface CTSenderP2PManager() <CTCommPortSocketGeneralDelegate>

@property (nonatomic, strong) CTPhotosManager *photoManager;
@property(nonatomic,assign) long long videofileize;
/*! Total audio file size need to be sent.*/
@property(nonatomic, assign) long long audioFileSize;
/*! Current path for audio file.*/
@property(nonatomic, strong) NSURL *currentAudioURL;

@property(nonatomic,assign)long long sentVideoDataSize;
@property (strong, nonatomic) AVURLAsset *currentVideoAsset;
@property (assign, nonatomic) long long currentVideoSize;
@property(nonatomic,strong) ALAssetRepresentation *currentALAseetRep;
@property (assign, nonatomic) NSInteger packageSize;

@property (nonatomic, assign) BOOL transferStarted;

@end

@implementation CTSenderP2PManager

- (instancetype)init {
    self = [super init];
    if (self) {
//        self.readAsyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//        self.commPortAysncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)setsocketDelegate:(GCDAsyncSocket *)socket commSocket:(CTCommPortClientSocket *)commSocket{
    
    self.readAsyncSocket = socket;
    self.commPortAysncSocket = commSocket;
    
    self.readAsyncSocket.delegate = self;
    self.commPortAysncSocket.generalDelegate = self;
    
    NSData *allfileNSdata = [self.p2pManagerDelegate getAllFileListToBeSend];
    [self.p2pManagerDelegate senderSouldUpdateCurrentPayloadSize:allfileNSdata.length];
    [self writeDataToSocket:allfileNSdata];
    // write comm port Informatopn
//    [self createCommportASyncSocket];
    
    if ([CTDeviceMarco isiPhone4AndBelow]) {
        self.packageSize = 50; // set for each of the package size for video receiving
    } else if ([CTDeviceMarco isiPhone5Serial]) {
        self.packageSize = 100;
    } else {
        self.packageSize = 150;
    }
}

- (void) requestToReadNextPacketfromSocket {
 
    [self.readAsyncSocket readDataWithTimeout:-1 tag:0];
}

- (void) closeAllSocketConnectionOnTransferCompletionRequest {
    
    self.readAsyncSocket.delegate = nil;
    
    [self.readAsyncSocket disconnect];
//    [asyncSocketCOMMPort disconnect];
    
    self.readAsyncSocket= nil;
//    listenOnPortCOMMPort = nil;
    
    self.readAsyncSocket = nil;
//    listenOnPort = nil;

}

#pragma mark - GCDAsyncSocket Delegates

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    DebugLog(@"SUCCessfully connected");
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    DebugLog(@"socketDidDisconnect:withError: \"%@\"", err.localizedDescription);
    if (!sock || !err || _transferFinished) {
        return;
    }
    
#warning TODO: Should handle "Socket is not connected" error case for P2P reconnct, right now, it will go to interrupted, leave receiver side on the receive progress page.
    
    [self.p2pManagerDelegate senderRecevieSocketClose];
    [self cleanUpAllSocketConnection];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    if (!_transferStarted) {
        _transferStarted = YES;
        [CTUserDefaults sharedInstance].transferStarted = YES;
    }
    
    NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *receiveddata = [responseStr formatRequestForXPlatform];
    
    DebugLog(@"Response recevied %@", receiveddata);
    
    if (self.incompleteData.length > 0) {
        // If has some incomplete data, append them, and clear the incomplete one.
        [self.incompleteData appendData:data];
        data = self.incompleteData;
        self.incompleteData = nil;
    }
    
    if (receiveddata.length == 0) {
        [self requestToReadNextPacketfromSocket];
    } else {
        [self.p2pManagerDelegate identifyReceviedP2pRequest:receiveddata shouldStoreIncompleteHandler:^(NSUInteger length) {
            self.incompleteData = [NSMutableData dataWithData:[data subdataWithRange:NSMakeRange(data.length - length, length)]];
        }];
    }
    
//    [self.commPortAysncSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    DebugLog(@"data written successfully");
    
//    if (tag == VZTagGeneral) {
//        return;
//    } else
    if (tag == VZTagCancel) {
        [self cleanUpAllSocketConnection];
        return;
    } else if (tag == VZTagVideoFiles) {
        // Checking if transfered package size, avoid crash casued by memory issue
        if (self.sentVideoDataSize - 1024 > 0 && (self.sentVideoDataSize - 1024) % (self.packageSize * 1024 * 1024) == 0) {
            [self.readAsyncSocket readDataWithTimeout:-1 tag:VZTagGeneral];
            return;
        }
        
        if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
            if (self.sentVideoDataSize != self.currentVideoSize) {
                [self transferChunkofVideo:self.currentVideoAsset withSize:self.currentVideoSize];
            } else {
                [self.readAsyncSocket readDataWithTimeout:-1 tag:VZTagGeneral];
            }
        } else {
            if (self.sentVideoDataSize != self.currentALAseetRep.size) {
                [self transferChunkofVideo];
            } else {
                [self.readAsyncSocket readDataWithTimeout:-1 tag:VZTagGeneral];
            }
        }
    } else if (tag == VZTagAudio) {
        NSLog(@"Audio sent:%lld/%lld", self.sentVideoDataSize, self.audioFileSize);
        // Checking if transfered package size, avoid crash casued by memory issue
        if (self.sentVideoDataSize - 1024 > 0 && (self.sentVideoDataSize - 1024) % (self.packageSize * 1024 * 1024) == 0) {
            if (self.sentVideoDataSize == self.audioFileSize) {
                NSLog(@"Audio sent");
                self.sentVideoDataSize = 0;
                [self removeLastAudioLocalFile];
            }
            [self.readAsyncSocket readDataWithTimeout:-1 tag:VZTagGeneral];
            
            return;
        }
        
        if (self.sentVideoDataSize != self.audioFileSize) {
            [self transferChunkofAudio]; // Send next chunk of audio data
        } else {
            NSLog(@"Audio sent");
            self.sentVideoDataSize = 0;
            [self removeLastAudioLocalFile];
            [self.readAsyncSocket readDataWithTimeout:-1 tag:VZTagGeneral];
        }
    } else {
        [self.readAsyncSocket readDataWithTimeout:-1 tag:VZTagGeneral];
    }
}

#pragma mark - Public API For Socket Operation
- (void)writeDataToSocket:(NSData *)dataToBeWritten actualSize:(long long)size {
    if (dataToBeWritten.length > 0) {
        [self.readAsyncSocket writeData:dataToBeWritten withTimeout: -1.0 tag:0];
        [self.p2pManagerDelegate senderShouldCreateProcessInfomation:size];
        [self.readAsyncSocket readDataWithTimeout:-1 tag:0];
    }
}

- (void)writeDataToSocket:(NSData *)dataToBeWritten {
    if (dataToBeWritten.length > 0) {
        [self.readAsyncSocket writeData:dataToBeWritten withTimeout: -1.0 tag:0];
        [self.readAsyncSocket readDataWithTimeout:-1 tag:0];
    }
}

- (void)writeCancelData:(NSData *)dataToBeWritten {
    if (dataToBeWritten.length > 0) {
        [self.commPortAysncSocket senderSideCancelMessage];
    }
}

#pragma mark - Video Chunck Logic
- (void)transferChunkofVideo:(AVURLAsset *)asset withSize:(long long)totalVideoSize
{
    long bufferSize = 1024 * 1024;
    NSData *videoData = nil;
    
    if (self.sentVideoDataSize + bufferSize > totalVideoSize) { // last chunk
        
        bufferSize = (long)(totalVideoSize - self.sentVideoDataSize);
        
        videoData = [NSData dataWithContentsOfFile:asset.URL atOffset:self.sentVideoDataSize withSize:bufferSize];
        
        self.sentVideoDataSize += bufferSize;
        
        [self.readAsyncSocket writeData:videoData withTimeout: -1.0 tag:VZTagVideoFiles];
        
        [self.p2pManagerDelegate senderShouldCreateProcessInfomation:videoData.length];
        
        return;
    }
    
    videoData = [NSData dataWithContentsOfFile:asset.URL atOffset:self.sentVideoDataSize withSize:bufferSize];
    
    [self.readAsyncSocket writeData:videoData withTimeout: -1.0 tag:VZTagVideoFiles];
    
    [self.p2pManagerDelegate senderShouldCreateProcessInfomation:videoData.length];
    
    self.sentVideoDataSize += bufferSize;
    NSLog(@"->sent video size:%lld of %lld", self.sentVideoDataSize, totalVideoSize);
}


- (void)transferChunkofVideo {
    
    long bufferSize = 1024 * 1024;
    NSData *videoData = nil;
    
    while (self.sentVideoDataSize != self.currentALAseetRep.size) {
        
        if (self.sentVideoDataSize + bufferSize > self.currentALAseetRep.size) {
            
            bufferSize = (long)(self.currentALAseetRep.size - self.sentVideoDataSize);
            
            Byte *buffer = (Byte*)malloc(bufferSize);
            NSUInteger buffered = [self.currentALAseetRep getBytes:buffer fromOffset:self.sentVideoDataSize length:bufferSize error:nil];
            videoData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            
            self.sentVideoDataSize += bufferSize;
            
            [self.readAsyncSocket writeData:videoData withTimeout: -1.0 tag:VZTagVideoFiles];
            
            [self.p2pManagerDelegate senderShouldCreateProcessInfomation:videoData.length];
            
            break;
        }
        
        Byte *buffer = (Byte*)malloc(bufferSize);
        NSUInteger buffered = [self.currentALAseetRep getBytes:buffer fromOffset:self.sentVideoDataSize length:bufferSize error:nil];
        videoData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        
        self.sentVideoDataSize +=bufferSize;
        
        [self.readAsyncSocket writeData:videoData withTimeout: -1.0 tag:VZTagVideoFiles];
        [self.p2pManagerDelegate senderShouldCreateProcessInfomation:videoData.length];
        
        // Checking if transfered 300 MB
        if ((self.sentVideoDataSize - 1024) % (self.packageSize * 1024 * 1024) == 0) {
            [self.readAsyncSocket readDataWithTimeout:-1 tag:VZTagGeneral];
            break;
        }
    }
}

- (void)sendRequestVideo:(id )asset {
    
    if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        [self requestVideoUsingNewLibrary:asset];
    } else {
        [self requestVideoUsingOldLibrary:asset];
    }
}

- (void)requestVideoUsingNewLibrary:(id)asset {
    NSLog(@"asset:%@", asset);
    AVURLAsset *myasset = (AVURLAsset *)asset;
    
    NSNumber *size;
    [myasset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
    long long totalVideoSize = [size longLongValue];
    DebugLog(@"==>video size is %lld", totalVideoSize);
    
    self.videofileize = totalVideoSize;
    
    self.sentVideoDataSize = 1024;
    
    NSData *videoDatainit = [NSData dataWithContentsOfFile:myasset.URL atOffset:0 withSize:(size_t)self.sentVideoDataSize];
    
    NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERVIDEOSTART"];
    NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%llu",totalVideoSize];
    
    int gap = 10 - (int)tempstr.length;
    for (int i = 0; i < gap ; i++) {
        [tempstr insertString:@"0" atIndex:0];
    }
    
    [tempstr insertString:requestStr atIndex:0];
    
    NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    [finaldata appendData:requestData];
    if (videoDatainit.length > 0) {
        [finaldata appendData:videoDatainit];
    }
    
    [self.readAsyncSocket writeData:finaldata withTimeout: -1.0 tag:VZTagVideoFiles];
    
    [self.p2pManagerDelegate senderShouldCreateProcessInfomation:videoDatainit.length];
    
    self.currentVideoAsset = asset;
    self.currentVideoSize = totalVideoSize;
    
}

- (void)requestVideoUsingOldLibrary:(id)asset {
    
    ALAsset *myasset = (ALAsset *)asset;
    
    ALAssetRepresentation *rep = [myasset defaultRepresentation];
    
    long long  totalVideoSize = rep.size;
    self.sentVideoDataSize = 1024;
    
    Byte *bufferInit = (Byte*)malloc((unsigned long)self.sentVideoDataSize);
    NSUInteger buffered = [rep getBytes:bufferInit fromOffset:0 length:(unsigned long)self.sentVideoDataSize error:nil];
    NSData *videoDatainit = [NSData dataWithBytesNoCopy:bufferInit length:buffered freeWhenDone:YES];
    
    
    NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERVIDEOSTART"];
    
    NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%llu",totalVideoSize];
    
    int gap = 10 - (int)tempstr.length;
    
    for (int i = 0; i < gap ; i++) {
        
        [tempstr insertString:@"0" atIndex:0];
    }
    
    [tempstr insertString:requestStr atIndex:0];
    
    NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    
    [finaldata appendData:requestData];
    
    if (videoDatainit.length > 0) {
        [finaldata appendData:videoDatainit];
    }
    
    [self.readAsyncSocket writeData:finaldata withTimeout: -1.0 tag:VZTagVideoFiles];
    
    [self.p2pManagerDelegate senderShouldCreateProcessInfomation:videoDatainit.length];
    
    self.currentALAseetRep = rep;
}

- (void)sendRequestedVideoPart {
    if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        [self transferChunkofVideo:_currentVideoAsset withSize:_currentVideoSize];
    } else {
        [self transferChunkofVideo];
    }
}

#pragma mark - Audio File Chunck Logic
- (void)sendRequestAudioFile:(NSString *)path {
    NSLog(@"Requested audio file path: %@", path);
    self.currentAudioURL = [NSURL fileURLWithPath:path];
    
    // Get File Size
    NSError *attributesError = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&attributesError];
    if (attributesError) {
        NSDictionary *fileList = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"CTSenderSideList"];
        NSArray *audioFileList = [fileList objectForKey:METADATA_DICT_KEY_AUDIOS];
        // Filter the info with specific file name
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Path = %@", [[path lastPathComponent] encodeStringTo64]];
        NSArray *filteredArray = [audioFileList filteredArrayUsingPredicate:predicate];
        // Should always be greadter than 0
        long long audioSizeFromList = [[((NSDictionary *)filteredArray[0]) objectForKey:@"Size"] longLongValue];
        [self sendAudioRequestFailure:audioSizeFromList outOfFileSize:audioSizeFromList];
        
        return;
    }
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    self.audioFileSize = [fileSizeNumber longLongValue];
    
    // Audio data init
    NSData *audioDataInit = [NSData dataWithContentsOfFile:self.currentAudioURL atOffset:0 withSize:1024]; // Get first 1024 bytes
    if (!audioDataInit) {
        [self sendAudioRequestFailure:self.audioFileSize outOfFileSize:self.audioFileSize];
        return;
    }
    self.sentVideoDataSize = audioDataInit.length;
    
    // Header
    NSData *requestData = [self createDataPackageHeader:CT_SEND_FILE_AUDIO_HEADER withSize:self.audioFileSize];
    
    // Merge data
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    [finaldata appendData:requestData];
    [finaldata appendData:audioDataInit];
    
    [self.readAsyncSocket writeData:finaldata withTimeout:-1.0 tag:VZTagAudio];
    [self.p2pManagerDelegate senderShouldCreateProcessInfomation:audioDataInit.length];
}

- (void)transferChunkofAudio {
    NSLog(@"Sending audio chunk...");
    NSData *chunckData = [self getChunkOfAudioData];
    if (!chunckData) {
        NSLog(@"Something wrong when trying to read audio chunk");
        [self sendAudioRequestFailure:self.audioFileSize - self.sentVideoDataSize outOfFileSize:self.audioFileSize];
        return;
    }
    
    [self.readAsyncSocket writeData:chunckData withTimeout:-1.0 tag:VZTagAudio];
    [self.p2pManagerDelegate senderShouldCreateProcessInfomation:chunckData.length];
    
    self.sentVideoDataSize += chunckData.length;
}
/*!
    @brief Try to get the chunk for audio file.
    @discussion Each of the audio file will be splited by buffer size in the method. Default if 4MB for each chunk. This is to prevent the memory issue for large audio file.
 
                According to document, standard audio file size might be reach 10MB per minute.
    @return NSData for specific chunck of the audio. If reading failed, will return nil.
 */
- (NSData *)getChunkOfAudioData {
    long long bufferSize = 4 * 1024 * 1024; // 4MB Everytime
    NSData *audioData = nil;
    
    NSInteger availablePackage = (self.sentVideoDataSize - 1024) % (self.packageSize * 1024 * 1024);
    if (availablePackage < bufferSize && availablePackage > 0) {
        bufferSize = availablePackage;
    }
    
    if (self.sentVideoDataSize + bufferSize > self.audioFileSize) { // Last chunk
        bufferSize = (long long)(self.audioFileSize - self.sentVideoDataSize);
        audioData = [NSData dataWithContentsOfFile:self.currentAudioURL atOffset:self.sentVideoDataSize withSize:(size_t)bufferSize];
    } else { // Normal chunk
        audioData = [NSData dataWithContentsOfFile:self.currentAudioURL atOffset:self.sentVideoDataSize withSize:(size_t)bufferSize];
    }

    return audioData;
}

#pragma mark - Sending Error Logic
- (void)sendAudioRequestFailure:(long long)unfinishedSize outOfFileSize:(long long)fileSize {
    
    NSLog(@"Unfinished count:%lld", unfinishedSize);
    // Header
    NSData *requestData = [self createDataPackageHeader:CT_SEND_FILE_FAILURE withSize:unfinishedSize];
    
    self.sentVideoDataSize += unfinishedSize;
    self.audioFileSize = fileSize;
    
    [self.readAsyncSocket writeData:requestData withTimeout:-1.0 tag:VZTagAudio];
    
    [self.p2pManagerDelegate senderAudioFileTransferDidFailed:self.audioFileSize];
    [self.p2pManagerDelegate senderShouldCreateProcessInfomation:unfinishedSize]; // Immedially update the unfinished data.
}

- (void)sendRequestFailure:(long long)unfinishedSize outOfFileSize:(long long)fileSize shouldConsiderFail:(BOOL)fail {
    NSLog(@"Unfinished count:%lld of %lld", unfinishedSize, fileSize);
    // Header
    NSData *requestData = [self createDataPackageHeader:CT_SEND_FILE_FAILURE withSize:unfinishedSize];
    [self.readAsyncSocket writeData:requestData withTimeout:-1.0 tag:VZTagGeneral];
    
    if (fail) {
        [self.p2pManagerDelegate senderPhotoFileTransferDidFailed:unfinishedSize];
    }
    [self.p2pManagerDelegate senderShouldCreateProcessInfomation:unfinishedSize]; // Immedially update the unfinished data.
}
/*!
    @brief Try to remove the last sent audio file from device local storage.
    @discussion This method will create a default priority queue to run the remove operation. If failed, just output the error, but leave the file there for now.
 */
- (void)removeLastAudioLocalFile {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.currentAudioURL.path]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *removeError = nil;
            [[NSFileManager defaultManager] removeItemAtURL:self.currentAudioURL error:&removeError];
            if (removeError) {
                NSLog(@"->Error when trying to remove the last sent audio file from local:%@", removeError.localizedDescription);
            } else {
                NSLog(@"->Audio file removed.");
            }
        });
    }
}

#pragma mark - General Helper Methods
/*!
    @brief Create the data package header for specific type of transfer and size.
    @param headerString NSString value for header string.
    @param size Size of the heaader attached. long long value.
    @return NSData contains the header will be used in transfer.
 */
- (NSData *)createDataPackageHeader:(NSString *)headerString withSize:(long long)size {
    NSString *requestStr = [[NSString alloc] initWithFormat:@"%@%010lld", headerString, size];
    NSLog(@"Package header: %@", requestStr);
    return [requestStr dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Clean Socket Connections
- (void)cleanUpAllSocketConnection {
    
    self.readAsyncSocket.delegate = nil;
    [self.readAsyncSocket disconnect];
    self.readAsyncSocket= nil;
    
    self.commPortAysncSocket.delegate = nil;
    [self.commPortAysncSocket disconnect];
    self.commPortAysncSocket = nil;
    
    self.transferFinished = YES;
}

#pragma mark - CTCommPortGeneralDelegate
- (void)commPortSocketdidReceivedCancelRequest {
    // Received "Cancel Clicked";
    NSLog(@"Cancel Clicked!");
    
    [self.p2pManagerDelegate identifyReceviedP2pRequest:CT_REQUEST_FILE_CANCEL shouldStoreIncompleteHandler:nil];
    
    [self cleanUpAllSocketConnection];
}

- (void)commPortSocketDidDisconnected {
    [self cleanUpAllSocketConnection];
}

@end
