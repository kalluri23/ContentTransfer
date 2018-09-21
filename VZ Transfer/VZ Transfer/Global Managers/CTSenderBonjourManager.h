//
//  CTSenderBonjourManager.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//
/*!
    @header CTSenderBonjourManager.h
    @discussion This is the header of CTSenderBonjourManager.
 */
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/*!@brief Delegate for sender bonjour manager.*/
@protocol CTSenderBonjourManagerDelegate <NSObject>
/*!
 Once bonjour manager received the package, call this method to identify the request type.
 @param requestString Request text message.
 @param handler Callback if requestString does't match any record. This callback will save the current bytes in memory for futher use.
 */
- (void)identifyReceviedBonjourRequest:(NSString *)requestString shouldStoreIncompleteHandler:(void(^)(NSUInteger))handler;
/*!
 Once manager init done, should request all file list using this method.
 @return NSData object represents the file list to be sent to receiver side.
 */
- (NSData *)getAllFileListToBeSend;
/*!
 Once transfer stopped due to user cancel or other issus, call this method to notify the higher level.
 @param reason Integer number represents the error type.
 */
- (void)transferWillInterrupted:(NSInteger)reason;
/*!
 Call this method when sender side should create progress object to update UI.
 @param byteSent long long value represents the bytes sent during the transfer.
 */
- (void)senderShouldCreateProcessInfomation:(long long)byteSent;
/*!
 Delegate to update the payload size information for UI.
 @param payload Total downloadable data size.
 */
- (void)senderSouldUpdateCurrentPayloadSize:(NSUInteger)payload;
/*!
 Call this method when sender should block the reconnect request from receiver.
 @param warningText Warning text message.
 */
- (void)senderTransferShouldBlockForReconnect:(NSString *)warningText;
/*!
 Call this method when transfer should accept reconnect request and continue sending.
 @param success YES if success; otherwise NO.
 */
- (void)senderTransferShouldEnableForContiue:(BOOL)success;
/*!
 Call this method when transfer photo file failed using Bonjour.
 @param failedSize long long value indicate the size of failed file.
 */
- (void)senderPhotoFileTransferDidFailed:(long long)failedSize;

@end

/*! 
    @brief Bonjour manager class for sender side.
    @discussion This class will contain all the sending logic when use Bonjour as connection type, like delegate, save temp file, etc. 
 
                All the sending logic should be implemented inside this class, instead of expose code into viewcontroller.
 */
@interface CTSenderBonjourManager : NSObject
/*! Bool type to track if current deivce transfer process is done.*/
@property (nonatomic, assign) BOOL transferFinished;
/*! Delegate parameter.*/
@property (nonatomic, weak) id <CTSenderBonjourManagerDelegate> delegate;
/*! isVideo avaliable value is 0,1,2 and 3. 0 means is not video, 1 means video sent, 2 means send normal file without UI updated, 3 means file end.*/
@property (nonatomic, assign) NSInteger isVideo;
/*!Bool indicate that video first package sent.*/
@property (nonatomic, assign) BOOL videoFirstPacket;
/*!Total size of the video in long long.*/
@property (nonatomic, assign) long long videoFileSize;
/*!Current URL for video needs to be sent.*/
@property (nonatomic, strong) AVURLAsset *currentVideoURL;
/*! 
    @brief Indicate that cancel request already been sent to other device. 
    @warning Only work when processCancelled is YES, otherwise never use this value.
 */
@property (nonatomic, assign) BOOL cancelRequestSent;
/*! Bool type to track if current device start cancel process. Default value is NO, when transfer stop by user, this will assign to Yes from higher level, never set to NO.*/
@property (nonatomic, assign) BOOL processCancelled;
/*!Indicate that server has been restarted or not. Default value is NO. Only set to YES when server republished. When start sending the first package after reconnect, reset to NO.*/
@property (nonatomic, assign) BOOL serverRestarted;
/*!Total byte that actually written to socket/stream.*/
@property (nonatomic, assign) NSInteger byteActuallyWrite;

/*!
    @brief Sender bonjour manager initializer
    @param controller Delegate object for CTSenderBonjourManagerDelegate
    @return CTSenderBonjourManager object.
    @see CTSenderBonjourManagerDelegate
 */
- (instancetype)initWithDelegate:(id<CTSenderBonjourManagerDelegate>)controller;
/*!
 Request sending data package through socket/stream.
 @param package NSData needs to be sent.
 @param size actualSize needs to be sent.
 */
- (void)requestSendingPackage:(NSData *)package actualSize:(long long)size;
/*!
 Request sending file list data.
 @param package NSData contains file list information.
 */
- (void)requestSendingFileListPackage:(NSData *)package;
/*!Request send large file in chunk. Buffer size is setup in manager file.*/
- (void)requestSendLargeFilePacket;
/*!Manager should stop timeout timer. This method is Bonjour only. Timeout time is used for reconnect.*/
- (void)shouldStopTimeoutTimer;
/*!
 Request sending notification to receiver when fetching failed for single file.
 @param failedSize Size failed for file.
 @param fail BOOL value indicate that this file should be considered as fail in final analytics report or not.
 */
- (void)requestSendingPackageFailed:(long long)failedSize shouldConsiderFail:(BOOL)fail;

@end
