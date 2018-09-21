//
//  CTCommPortServerSocket.h
//  contenttransfer
//
//  Created by Sun, Xin on 5/9/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

/*!
    @header CTCommPortServerSocket.h
    @discussion This is the commport server socket class. Contains operation for server. Some of   the methods declared in CTCommPortSocket class.
    @see CTCommPortSocket
 */
#import "CTCommPortSocket.h"

/*!
 * @brief  The server side commport socket class.
 *
 *         Server side commport socket will try to accept the comming connection after it has been initialized.
 *
 *         After connection established, it will try to first get the device list information from its client and then send its own device list to client.
 *
 *         This class will be used only in case that current device is a receiver side and using router to connect.
 */
@interface CTCommPortServerSocket : CTCommPortSocket

/*!
 * @brief Override super init method. 
 *
 *        Once initial process done for commport server socket, then it will try to accept any connection immediately by calling method:
 * @return instance of commport server socket
 * @code   [self listenOnPort];
 */
- (instancetype)initServierSocket;

@end
