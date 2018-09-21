//
//  CTCommPortSocket.h
//  contenttransfer
//
//  Created by Sun, Xin on 5/9/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

/*!
    @header CTCommPortSocket.h
    @discussion This is the header file of CTCommPortSocket class
 */

#import <contentTransferFramework/contentTransferFramework.h>


/*!
    @brief      CTCommPortSocketGeneralDelegate
    @discussion This delegate contains all the methods that controlled by the request through commport socket like cancel, quit and so on.
 */
@protocol CTCommPortSocketGeneralDelegate <NSObject>

@optional
/*! @brief Method to handle logic when received cancel request sent from sender side on receiver side*/
- (void)commPortSocketdidReceivedCancelRequest;
/*! @brief Method to handle logic when received cancel request sent from receiver side on sider side*/
//- (void)commPortSocketdidReceivedCancelRequestFromReceiver;
/*! @brief Method to handle logic when commport socket disconnected.*/
- (void)commPortSocketDidDisconnected;
/*! @brief Method to handle logic when commport sokect did cancelled.*/
- (void)commPortSocketDidCancelled;
/*! @brief Method to handle logic when commport sokect did recevied device list.*/
- (void)commPortSocketDidReceivedDeviceList;

@end

/*!
    @brief  The general commport socket class.
    @discussion This class is the parent class of server and client commport class.
 
                This class contains all the general/common methods like delegate, and I/O call. 
    @warning Should not use this class directly, instead, use specific server/client commport socket.
 */
@interface CTCommPortSocket : GCDAsyncSocket <GCDAsyncSocketDelegate>

/*! CTCommPortSocketGeneralDelegate*/
@property (weak, nonatomic) id<CTCommPortSocketGeneralDelegate> generalDelegate;

/*!
    @brief Write specific data into commport soket
    @param requestData The target data that need to be sent. If this is nil, then nothing will happen, but we should be responsible for checking the empty case.
 */
- (void)writeData:(NSData *)requestData;
/*!
    @brief Try to read data from commport soket
    @discussion Once it called, it will try to read any avaliable data from socket async. Delegate socketDidRead will automatically called once data is avaiable in socket.
 */
- (void)readData;
/*!
    @brief      Method to read any data comes from commport socket for analytics use.
    @discussion The stucture of device Json list should be the same on both iOS/Android and Sender/Receiver.
 
                Other than device list information, there will be some cancel request sent through commport socket for P2P case.
 
                Json format:
    @code
                {
                    PAIRING_MODEL                   = device model number;
                    PairingType                     = P2P/Bonjour;
                    PAIRING_OS_VERSION              = OS verison;
                    PAIRING_DEVICE_TYPE             = iOS/Android;
                    USER_DEFAULTS_PAIRING_DEVICE_ID = device UUID;
                }
    @endcode
    @param data NSData that contains the information
 */
- (void)readCommPortData:(NSData *)data;
/*!
    @brief Method to write pairing device information into commport socket for analytics use.
    @discussion The stucture of device Json list should be the same on both iOS/Android and Sender/Receiver.
    Json format:
    @code
    {
        PAIRING_MODEL                   = device model number;
        PairingType                     = P2P/Bonjour;
        PAIRING_OS_VERSION              = OS verison;
        PAIRING_DEVICE_TYPE             = iOS/Android;
        USER_DEFAULTS_PAIRING_DEVICE_ID = device UUID;
    }
    @endcode
 */
- (void)writePairingInformationToCommPort;
/*!
    @brief Method to send cancel message when sender side cancelled by user. After message sent, socket will be closed.
 */
- (void)senderSideCancelMessage;
@end
