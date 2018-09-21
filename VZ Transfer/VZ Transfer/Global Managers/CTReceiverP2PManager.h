//
//  CTReceiverP2PManager.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//
/*!
    @header CTReceiverP2PManager
    @discussion This is the header of CTReceiverP2PManager class.
 */
#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "CTContentTransferSetting.h"
#import "CTVersionManager.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertHandler.h"
#import "CTCommPortSocket.h"
#import "CTReceiveManagerHelper.h"

/*!
 Delegate of Socket manager on receiver side. This protocol contains all the callback used during P2P receiving process.
 @Note All the methods are optional.
 */
@protocol CTReceiverP2pManagerDelegate <NSObject>
@optional
/*!
 Call this method when transfer will interrupted, reason will be given.
 @param Integer represents the code of error.
 */
- (void)transferWillInterrupted:(NSInteger)reason;
/*!Call this method when transfer will start.*/
- (void)transferWillStart;
/*!Call this method when transfer did finished.*/
- (void)transferDidFinished;
/*!Call this method when transfer did cancelled by user.*/
- (void)transferDidCancelled;
/*!
 Call this method when transfer got total payload.
 @param totalPayload Total size of data saved in NSNumber as long long.
 */
- (void)totalPayLoadRecevied:(NSNumber *)totalPayload;
/*!
 Call this when receiver doesn't have enought storage to save.
 @param availalbeSpace Total space available on receiver device saved in NSNumber as long long value.
 */
- (void)inSufficentStorageAvailalbe:(NSNumber *)availalbeSpace;
/*! Delegate method that calulate the transfer information.*/
- (void)dataPacketRecevied:(long)packetSize mediaInfo:(NSDictionary *)mediaInfo;
/*!Deprecated.*/
- (void)updateUI;
/*!Call this method when last bytes of last file is transferred and @b saved in local file system properly.*/
- (void)transferShouldAllowSaving;
/*!Call this method when transfer is about to cancel.*/
- (void)transferShouldCancel;
/*!Call this method when transfer should pop to root page during to cancel.*/
- (void)RequestToPopToRootViewController;

@end

/*!
    @brief This class is the manager class for P2P receiver side logic
    @discussion This class contains all the logic for P2P receiver side like delegate and request identification. And all the further logic should be implemented in this class.
 */
@interface CTReceiverP2PManager : NSObject<GCDAsyncSocketDelegate>
/*! Manager helper class for receiver side.*/
@property (nonatomic, strong) CTReceiveManagerHelper *helper;
/*! Regular socket for receiver side.*/
@property (nonatomic, strong) GCDAsyncSocket *writeAsyncSocket;
/*! Commport socket for receiver side, can be either server or client.*/
@property (nonatomic, strong) CTCommPortSocket *asyncSocketCommPort;
/*!
 Delegate to handle callbacks from manager.
 @see CTReceiverP2pManagerDelegate
 */
@property (nonatomic, weak) id <CTReceiverP2pManagerDelegate> delegate;
/*!Data needs to be written into commport.*/
@property (nonatomic, strong) NSData *dataTobeWrittenToCommPort;
/*!
 Incomplete data received from sender.
 
 Once receiver side check the data doesn't match any of the existing type, receiver will store data to this property. After they received next package and append that to this data and check type again.
 
 It will keep appending until data match any of the existing data type. After matches, this property will be cleared.
 */
@property (nonatomic, strong) NSMutableData *incompleteData;
/*!BOOL indicate that transfer finished receiving request has been sent to sender side or not.*/
@property (nonatomic, assign) BOOL transferFinishRequestSent;

/*!
    @brief This method will assign the exist regular socket to P2P manager class, and setup necessary commport socket.
    @discussion Because this method called in ViewDidLoad after verison check passed. It's too short for other side server to start listen the port, so only setup server socket in this method;
 
                For client socket, call the method
    @code [self createClientCommPortSocket] @endcode
                in viewDidAppear.
    @param socket Regular socket created when start pairing device.
    @see createClientCommPortSocket
 */
- (void)setsocketDelegate:(GCDAsyncSocket *)socket;
/*! @brief Method to clean all the opening sockets.*/
- (void)cleanupSocketConnectionOnUserCancelRequest;
/*! @brief Method to clean all the opening sockets.*/
- (void)cleanUpAllSocketConnection;
/*!
 @brief This method will try to write data into regular socket. The result of writing process will be showed in SocketDidWrite delegate.
 @param dataToBeWritten NSData object represent the data need to be sent.
 */
- (void)writeDataToSocket:(NSData *)dataToBeWritten;
/*! 
    @brief This method will try to write data into commport socket. The result of writing process will be showed in SocketDidWrite delegate.
    @param dataToBeWritten NSData object represent the data need to be sent.
 */
- (void)writeDataToSocketCommSocket:(NSData *)dataToBeWritten;
/*! @brief This method will be called after user pressed the cancel button on receiver side.*/
- (void)processDidPressCancel;
/*!This method will be called after user pressed cancel button from MVM framework.*/
- (void)processDidPressCancelFromMVM;
/*!
    @brief This method will create client commport socket seperatly.
    @discussion Call this method in viewDidAppear instead of viewDidLoad to give server socket sometime to open the socket.
 */
- (void)createClientCommPortSocket;

@end
