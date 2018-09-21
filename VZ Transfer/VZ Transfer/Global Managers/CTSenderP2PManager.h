//
//  CTSenderP2PManager.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//
/*!
    @header CTSenderP2PManager.h
    @discussion This is the header of CTSenderP2PManager class.
 */
#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "CTContentTransferSetting.h"
#import "NSData+CTHelper.h"
#import "CTCommPortClientSocket.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define VZTagGeneral     0
#define VZTagAllFileList 1
#define VZTagVcardFiles  2
#define VZTagPhotoFiles  3
#define VZTagVideoFiles  4
#define VZTagCalendars   5
#define VZTagReminders   6
#define VZTagCancel      7
#define VZTagAudio       8

/*!
    @brief CTSenderP2PManagerDelegate
    @discussion This delegate will be used to communicate with general sender manager class.
 */
@protocol CTSenderP2PManagerDelegate <NSObject>

@optional
/*!
 Once p2p manager received the package, call this method to identify the request type.
 @param requestString Request text message.
 @param handler Callback if requestString does't match any record. This callback will save the current bytes in memory for futher use.
 */
- (void)identifyReceviedP2pRequest:(NSString *)requestString shouldStoreIncompleteHandler:(void(^)(NSUInteger))handler;
/*!
 Call this method when sender should update UI for sender.
 @param totalDataSent Total bytes sent during transfer.
 */
- (void)updateFileTransferUIProgress:(long)totalDataSent;
/*!
 Call this method when sender finished transfer request file.
 @param success YES if every is done. otherwise NO.
 */
- (void)finishedTransferRequestedFile:(BOOL)success;
/*!
 Call this method when transfer received cancel request from receiver.
 @param requestForCancel YES when cancel; otherwise NO.
 */
- (void)transferCancelRequestRecevied:(BOOL)requestForCancel;
/*!
 Call this method when transfer received socket close exception from receiver.
 @param socketCloseExption YES when close; otherwise NO.
 */
- (void)socketCloseExceptionRecevied:(BOOL)socketCloseExption;
/*!
 Call this method to process the data received from receiver side via commport.
 @param data NSData receiver from commport
 */
- (void)processingCommPortData:(NSData *)data;
/*!
 Get file list data from upper level class.
 @return NSData contains file list detail.
 */
- (NSData *)getAllFileListToBeSend;
/*!
 Delegate to update the payload size information.
 @param payload Total payload size to be sent.
 */
- (void)senderSouldUpdateCurrentPayloadSize:(NSUInteger)payload;
/*!
 Sender progress manager should update the UI using current byte.
 @param byteSent Total bytes sent through this pacakge.
 */
- (void)senderShouldCreateProcessInfomation:(long long)byteSent;
/*! 
    @brief Delegate method when something goes wrong during audio file transfer.
    @param fileSize long long value represents the size of file.
 */
- (void)senderAudioFileTransferDidFailed:(long long)fileSize;
/*!
 @brief Delegate method when something goes wrong during single file transfer.
 @param fileSize long long value represents the size of file.
 */
- (void)senderPhotoFileTransferDidFailed:(long long)fileSize;
/*! Sender received socket closed exception.*/
- (void)senderRecevieSocketClose;

@end

/*!
    @brief      This class is the P2P logic manager for sender side.
    @discussion This class contains all the delegate and logic that can finish sending process. And all the further logc should be implemented inside this class, instead of expose code into specific view controller. User delegate to communicate with upper level view controller class.
 */
@interface CTSenderP2PManager : NSObject<GCDAsyncSocketDelegate>
/*! Bool type to track if current deivce transfer process is done.*/
@property (nonatomic, assign) BOOL transferFinished;

/*! Main socket property for sender P2P.*/
@property (nonatomic,strong) GCDAsyncSocket *readAsyncSocket;
/*! Client commport socket for sender side.*/
@property (nonatomic,strong) CTCommPortClientSocket *commPortAysncSocket;
/*! Delegate for Sender P2P Manager class.*/
@property (nonatomic, weak) id <CTSenderP2PManagerDelegate> p2pManagerDelegate;
/*!Data to be written to the commport.*/
@property (nonatomic,strong) NSData *dataTobeWrittenToCommPort;

/*!
 Incomplete data received from sender.
 
 Once receiver side check the data doesn't match any of the existing type, receiver will store data to this property. After they received next package and append that to this data and check type again.
 
 It will keep appending until data match any of the existing data type. After matches, this property will be cleared.
 */
@property (nonatomic, strong) NSMutableData *incompleteData;

/*!
    @brief Setup the P2P environment.
    @discussion This method will store the socket properties using for P2P transfer, setup the delegate for the sockets. 
 
                After setup finished, method will try to send file list immediatly to receiver side to start the transfer.
    @param socket Regular socket for P2P transfer.
    @param commSocket Commport socket for P2P transfer.
    @see CTCommPortClientSocket
 */
- (void)setsocketDelegate:(GCDAsyncSocket *)socket commSocket:(CTCommPortClientSocket *)commSocket;
/*!Request manager to read next packet from socket.*/
- (void)requestToReadNextPacketfromSocket;
/*!Request to close all socket connection after transfer is completed.*/
- (void)closeAllSocketConnectionOnTransferCompletionRequest;
/*!
    @brief Try to write data into regular socket. With actual size that need to sent(no header byte included).
    @param dataToBeWritten NSData waiting to be sent.
    @param size Real size for file.
 */
- (void)writeDataToSocket:(NSData *)dataToBeWritten actualSize:(long long)size;
/*!
    @brief Try to write data into regular socket.
    @param dataToBeWritten NSData waiting to be sent.
 */
- (void)writeDataToSocket:(NSData *)dataToBeWritten;
/*!
 Send requested video
 @param asset URL for target video
 */
- (void)sendRequestVideo:(id)asset;
/*!
 Send request video chunk. This method should be called after
 @code sendRequestVideo:asset @endcode called.
 */
- (void)sendRequestedVideoPart;
/*!
    @brief Send audio file saved in specific Path.
    @discussion Due to memory issue for iOS device, not all of the audio file can be push to memory at the same time. Audio files will be sent by chunk.
    @param path NSString value for audio file saved path in local storage.
 */
- (void)sendRequestAudioFile:(NSString *)path;
/*!
    @brief Try to read the chunk of audio, and send it to receiver side.
    @see getChunkOfAudioData
 */
- (void)transferChunkofAudio;
/*!
    @brief Method to clean all the opening sockets.
 */
- (void)cleanUpAllSocketConnection;
/*!
    @brief This method will send the cancel message to the other device using P2P connection.
    @discussion Message will be fixed string value 
                @code "VZTRANSFER_CANCEL". @endcode
                Based on the current transfer method, P2P for same platform will send through main socket, and cross platform will send through commport socket.
    @warning Should send message through commport socket for all the P2P connection. Need further change.
 */
- (void)writeCancelData:(NSData *)dataToBeWritten;
/*!
    @brief Send the audio failure header.
    @discussion Any error case happened during the transfer for single audio file, this method will be called, and size will be updated, and this file will be considered as failure(show in recap page).
    @param unfinishedSize Long long value indicate the incompleted size, use for update the UI.
    @param fileSize Long long value indicate the total size of single audio file.
 */
- (void)sendAudioRequestFailure:(long long)unfinishedSize outOfFileSize:(long long)fileSize;
/*!
 @brief Send the single file failure.
 @discussion Any error case happened during the transfer for single file, this method will be called, and size will be updated, and this file will be considered as failure(show in recap page).
 @param unfinishedSize Long long value indicate the incompleted size, use for update the UI.
 @param fileSize Long long value indicate the total size of single audio file.
 @param faile BOOL value indicate that this fail file should be considered as fail in final report or not.
 */
- (void)sendRequestFailure:(long long)unfinishedSize outOfFileSize:(long long)fileSize shouldConsiderFail:(BOOL)fail;

@end
