//
//  CTReceiverProgressManager.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTReceiverP2PManager.h"
#import "CTReceiverBonjourManager.h"
#import "CTProgressInfo.h"
#import "GCDAsyncSocket.h"
#import "CTFileList.h"

/*!
 Delegate of progress manager on receiver side. This protocol contains all the callback used during P2P receiving process.
 @Note All the methods are optional.
 */
@protocol CTReceiverProgressManagerDelegate <NSObject>

@optional
/*! 
    @brief Delegate method to update UI. Information will be contained in CTProgressInfo class.
    @param progressInfo CTProgressInfo object contains all the information for updating the UI.
    @see CTProgressInfo
 */
- (void)updateUIWithProgressInfo:(CTProgressInfo *)progressInfo;
/*!
 Call this method when progress did get low space error on receiver.
 @param amountOfData Total number of data try to saved in long long value.
 */
- (void)didGetErrorLowSpaceForAmount:(NSNumber *)amountOfData;
/*!Call this method when process should proceed to next step.*/
- (void)viewShouldGotoNextView;
/*! 
    @brief This method showed that process should go to saving process.
    @discussion Everytime need to push to saving call this.
 */
- (void)viewShouldGotoSavingView;
/*!Call this method when process should allow start saving.*/
- (void)viewShouldAllowSavingProcess;
/*!Call this method when process should be cancelled.*/
- (void)viewShouldCancel;
/*!Call this method when process should be interrupted.*/
- (void)viewShouldInterrupt;
/*!
 Call this method when process should block request for reconnect.
 @param warningText NSString represents the waring text message.
 */
- (void)transferShouldBlockForReconnect:(NSString *)warningText;
/*!
 Call this method when process should accept reconnect and continue receiving.
 @param success YES if success; otherwise NO.
 */
- (void)transferShouldEnableForContinue:(BOOL)success;
/*!Call this method if process should pop to root.*/
- (void)goToRootViewController;
/*!Call this method when process failed before receiving even the very first byte.*/
- (void)tansferFailedBeforeStarted;

@end

/*!
    @brief This class is the manager class for receiver side.
    @discussion This manager contains all the receiver side logic.
    @warning All the future logic about receiving the files need to be implemented in this class instead of expose the code into specific view controller.
 */
@interface CTReceiverProgressManager : NSObject
/*!Delegate for progress manager on receiver side.*/
@property (nonatomic, weak) id<CTReceiverProgressManagerDelegate> delegate;
/*!P2P manager class for receiver side.*/
@property (nonatomic, strong) CTReceiverP2PManager *p2pManager;
/*!Bonjour manager class for receiver side.*/
@property (nonatomic, strong) CTReceiverBonjourManager *bonjourManager;
/*!Normal socket for receiving files.*/
@property (nonatomic, strong) GCDAsyncSocket *writeSocket;
/*!Progress info object that using for update the UI.*/
@property (atomic, strong) CTProgressInfo *progressInfo;
/*!Total payload for the transfer.*/
@property (nonatomic, assign) long long totalPayload;
/*!Start time when receiver side received the first byte.*/
@property (nonatomic, strong) NSDate *transferStartTime;
/*!Max speed during the transfer.*/
@property (nonatomic, assign) double maxSpeed;

/*!
 Initializer of progress manager with delegate
 @param delegate Object that assigned as CTReceiverProgressManagerDelegate.
 @return CTReceiverProgressManager object.
 @see CTReceiverProgressManagerDelegate
 */
- (instancetype)initWithDelegate:(id<CTReceiverProgressManagerDelegate>)delegate;
/*!
    @brief This method contains the logic after user cancel the process.
    @discussion This method will be called when user kill the app on receiver side. And send necessary message and do clean work.
    @param cancelMode enum type represent the way that user cancel the transfer, for analytics use.
    @warning cancelMode param acutally is the old logic, right now collected but never use. Should remove in future.
 */
- (void)cancelTransfer:(CTTransferCancelMode)cancelMode;
/*!
 Setup normal socket for P2P.
 @param socket Normal socket need to be assigned.
 */
- (void)setwriteAsyncSocket:(GCDAsyncSocket *)socket;
/*!Receiver canceled the request due to permission error when doing Bonjour transfer.*/
- (void)receiverPermissionCancelRequestForBonjour;
/*!MVM cancel the transfer by user clicking the cancel button on navi bar.*/
- (void)mvmCancelTransfer ;
/*!Create commport socket for Socket cross platform use. Receiver side will be client side.*/
- (void)createClientCommportSocket;
/*! 
    @brief Get file list object from receiver side.
    @return File list object.
    @see CTFileList
 */
- (CTFileList *)fileList;
/*! @brief Remove obeserver for progress info.*/
- (void)removeObeserver;

@end
