//
//  CTReceiverBonjourManager.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//
/*!
    @header CTReceiverBonjourManager
    @discussion This is the header of CTReceiverBonjourManager class.
 */
#import <Foundation/Foundation.h>
#import "CTReceiveManagerHelper.h"

/*!
 Delegate of Bonjour manager on receiver side. This protocol contains all the callback used during bonjour receiving process.
 @Note All the methods are optional.
 */
@protocol CTReceiverBonjourManagerDelegate <NSObject>
@optional
/*!
 Call this method when transfer will interrupted. Reason will be given.
 @warning This method is currently not using.
 @param reason Error code represents the reason of interrupted.
 */
- (void)transferWillInterrupted:(NSInteger)reason;
/*!Call this method when transfer is about to start.*/
- (void)transferWillStart;
/*!Call this method when transfer is about to cancel.*/
- (void)transferShouldCancel;
/*!Call this method when transfer is finished.*/
- (void)transferDidFinished;
/*!Call this method when transfer is cancelled.*/
- (void)transferDidCancelled;
/*!Call this method when last bytes of last file is transferred and @b saved in local file system properly.*/
- (void)transferShouldAllowSaving;
/*!
 Call this method receiver side doesn't have enough space to save.
 @warning This is deprecated process. Now space is checking during the pairing process. But this code remains same for stable reason, but will never be called again.
 */
- (void)inSufficentStorageAvailalbe:(NSNumber *)availalbeSpace;
/*!
 Call this method when transfer get total data amount.
 @param totalPayload NSNumber contains total file size in long long value.
 */
- (void)totalPayLoadRecevied:(NSNumber *)totalPayload;
/*!Delegate method that calulate the transfer information.*/
- (void)dataPacketRecevied:(long)packetSize mediaInfo:(NSDictionary *)mediaInfo;
/*!
 Call this method when sender should block the request for reconnect.
 @param warningText NSString value represents the warning message.
 */
- (void)senderTransferShouldBlockForReconnect:(NSString *)warningText;
/*!
 Call this method when sender should accept reconnect request and continue the transfer.
 @param success YES if can be established; otherwise NO.
 */
- (void)senderTransferShouldEnableForContiue:(BOOL)success;
/*!Call this request to pop to root controller after user interrupted transfer.*/
- (void)RequestToPopToRootViewController;
/*!Call this method when transfer failed for some reason before even received the very first byte.*/
- (void)tansferFailedBeforeStarted;
@end

/*!
    @brief This class is the manager class for receiver logic for Bonjour connection type.
    @discussion This class contains all the logic that related to Bonjour receiving, such as delegate, and all the further logic should be implemented in this class instead of in view controller.
 */
@interface CTReceiverBonjourManager : NSObject
/*! Manager helper class for receiver side.*/
@property (nonatomic, strong) CTReceiveManagerHelper *helper;
/*!BOOL value indicate that process is cancelled by user or not.*/
@property (nonatomic, assign) BOOL processCancelled;
/*!
 Delegate assigned to handle the callback of Bonjour manager from receiver.
 @see senderTransferShouldEnableForContiue
 */
@property (nonatomic, weak) id<CTReceiverBonjourManagerDelegate> delegate;

/*!
 Initialize manager with delegate.
 @param delegate CTReceiverBonjourManagerDelegate method to handle the callback.
 @return CTReceiverBonjourManager object.
 */
- (instancetype)initWithDelegate:(id<CTReceiverBonjourManagerDelegate>)delegate;
/*!
    @brief This method contains all the process after user cancel the transfer.
    @discussion This method will be called when user cancel on the recevier side, no matter by clicke button or kill the app.
 */
- (void)processDidPressCancel;
/*!
 Stop transfer when permission error happend. @b Deprecated.
 */
- (void)stopTransferDueToPermission;

@end
