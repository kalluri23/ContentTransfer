//
//  CTCommPortSocket.m
//  contenttransfer
//
//  Created by Sun, Xin on 5/9/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTCommPortSocket.h"
#import "NSString+CTMVMConvenience.h"
@interface CTCommPortSocket() {
    GCDAsyncSocket *_tmpServerSocket;
}
@end

@implementation CTCommPortSocket

- (instancetype)init {
    return [self initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (instancetype)initWithDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)dq {
    return [super initWithDelegate:aDelegate delegateQueue:dq];
}

#pragma mark GcdAsyncSocket delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    DebugLog(@"Comm socket created");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    DebugLog(@"Comm socket disconnected:%@", err.localizedDescription);
    // Need to handle commSocket close message here
//    if ([self.generalDelegate respondsToSelector:@selector(commPortSocketDidDisconnected)]) {
//        [self.generalDelegate commPortSocketDidDisconnected];
//    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    DebugLog(@"Comm socket read data");
    [self readCommPortData:data];
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == 200) {
        // If this indicate that write CRLF done, ignore
        return;
    }
    DebugLog(@"wrote data on comm socket");
    [self readData];
    
    if (tag == 100) { // Only when sending cancel request, tag will be 100, after that clean all openning socket.
        [self disconnect];
        if ([self.generalDelegate respondsToSelector:@selector(commPortSocketDidDisconnected)]) {
            [self.generalDelegate commPortSocketDidDisconnected];
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    _tmpServerSocket = newSocket;
    [self readData];
}

#pragma mark - Universal Abstract Methods
- (void)writePairingInformationToCommPort {
    
    // Parpare the device infomation set for server socket
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    CTDeviceMarco *deviceMacro = [[CTDeviceMarco alloc] init];
    NSString *modelCode = [deviceMacro getDeviceModel];
    NSString *model = [deviceMacro.models objectForKey:modelCode];
    if (model.length == 0) {
        model = modelCode;
    }
    
    [dict setValue:model forKey:USER_DEFAULTS_PAIRING_MODEL];
    [dict setValue:[CTUserDevice userDevice].pairingType forKey:USER_DEFAULTS_PAIRING_TYPE];
    
    [dict setValue:[[UIDevice currentDevice] systemVersion] forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
    [dict setValue:@"iOS" forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
    [dict setValue:[CTUserDevice userDevice].deviceUDID forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
    
    NSError *error = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    if (error) {
        NSLog(@"Error Happened: %@", error.localizedDescription);
    }
    
    // Send information
    [self writeData:requestData];
}

- (void)readCommPortData:(NSData *)data {
    if (data.length > 0) {
        // Check string first.
        NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        responseStr = [responseStr formatRequestForXPlatform];
        if ([responseStr rangeOfString:CT_REQUEST_FILE_CANCEL_CLICKED].location != NSNotFound) {
            NSLog(@"User cancelled on transfer progress page on AnD side.");
            if ([self.generalDelegate respondsToSelector:@selector(commPortSocketdidReceivedCancelRequest)]) {
                [self.generalDelegate commPortSocketdidReceivedCancelRequest];
            }
        } else if ([responseStr rangeOfString:CT_REQUEST_FILE_CANCEL].location != NSNotFound) {
            NSLog(@"User cancelled on transfer what page on AnD side.");
            if ([self.generalDelegate respondsToSelector:@selector(commPortSocketdidReceivedCancelRequest)]) {
                [self.generalDelegate commPortSocketdidReceivedCancelRequest];
            }
            
            // Send back close comm message to the other side
//            [self sendCloseCommMessage];
        } else {
            // Try to parse the json data
            NSError *error = nil;
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (error) {
                NSLog(@"Json parse error: %@", error.localizedDescription);
            }
            
            // read COMM port information
            DebugLog(@"read comm port information : %@",responseDict);
            if (responseDict && [responseDict objectForKey:USER_DEFAULTS_PAIRING_DEVICE_ID]) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[responseDict objectForKey:USER_DEFAULTS_PAIRING_DEVICE_ID] forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
                [userDefaults setObject:[responseDict objectForKey:USER_DEFAULTS_PAIRING_OS_VERSION] forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
                [userDefaults setObject:[responseDict objectForKey:USER_DEFAULTS_PAIRING_MODEL] forKey:USER_DEFAULTS_PAIRING_MODEL];
                [userDefaults setObject:[responseDict objectForKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE] forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
            }
            
            if ([self.generalDelegate respondsToSelector:@selector(commPortSocketDidReceivedDeviceList)]) {
                [self.generalDelegate commPortSocketDidReceivedDeviceList];
            }
        }
    }
    
    [self readData];
}


#pragma mark - Univeral Operations
- (void)writeData:(NSData *)requestData {
    if (_tmpServerSocket) {
        [_tmpServerSocket writeData:requestData withTimeout:-1.0f tag:0];
    } else {
        [super writeData:requestData withTimeout:-1.0f tag:0];
    }
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) { // if is cross platform, need to write an extra CRLF into socket
        if (_tmpServerSocket) {
            [_tmpServerSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0f tag:200]; // tag == 200 only for CRLF for cross-platform
        } else {
            [super writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0f tag:200]; // tag == 200 only for CRLF for cross-platform
        }
    }
}

/*!
    @brief Write specific data into commport soket with specific tag number
    @param requestData The target data that need to be sent. If this is nil, then nothing will happen, but we should be responsible for checking the empty case.
    @param tag Tag number that use to identify the writing process.
 */
- (void)writeData:(NSData *)requestData withTag:(NSInteger)tag {
    if (_tmpServerSocket) {
        [_tmpServerSocket writeData:requestData withTimeout:-1.0f tag:tag];
    } else {
        [super writeData:requestData withTimeout:-1.0f tag:tag];
    }
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) { // if is cross platform, need to write an extra CRLF into socket
        if (_tmpServerSocket) {
            [_tmpServerSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0f tag:200];
        } else {
            [super writeData:[GCDAsyncSocket CRLFData] withTimeout:-1.0f tag:200];
        }
    }
}

- (void)readData {
    if (_tmpServerSocket) {
        [_tmpServerSocket readDataWithTimeout:-1.0f tag:0];
    } else {
        [super readDataWithTimeout:-1.0f tag:0];
    }
}

- (void)senderSideCancelMessage {
    NSString *cancelRequest = CT_REQUEST_FILE_CANCEL;
    [self writeData:[cancelRequest dataUsingEncoding:NSUTF8StringEncoding] withTag:100];
    NSLog(@"try to write cancel message");
}

/*!
    @brief This method will send "Close Comm" message to other side, so the other side will know when to close the commport socket.
 */
- (void)sendCloseCommMessage {
    NSString *closeCommMessage = @"Close Comm";
    NSData *targetData = [closeCommMessage dataUsingEncoding:NSUTF8StringEncoding];
    [self writeData:targetData];
}

@end
