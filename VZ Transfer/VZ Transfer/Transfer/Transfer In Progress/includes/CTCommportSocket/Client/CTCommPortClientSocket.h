//
//  CTCommPortClientSocket.h
//  contenttransfer
//
//  Created by Sun, Xin on 5/9/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

/*!
    @header CTCommPortClientSocket.h
    @discussion This is the commport client socket class. Contains operation for client. Some of   the methods declared in CTCommPortSocket class.
    @see CTCommPortSocket
 */
#import "CTCommPortSocket.h"

/*!
    @brief  The client side commport socket class.
 
            Client side commport socket will try to connect to specific host after it has been initialized.
 
            After connection established, it will try to first send the device list information to its server and then read the device list from server.
 */
@interface CTCommPortClientSocket : CTCommPortSocket
/*!
 * @brief init method for client commport socket.
 *
 *        Once initial process done for commport client socket, then it will try to connect to the host by calling method:
 * @param  host NString that reprent the host.
 * @param  aDelegate CTCommPortSocketGeneralDelegate for client
 * @return instance of commport client socket
 * @code [self connectToHost:host];@endcode
 */
- (instancetype)initWithHost:(NSString *)host andDelegate:(id)aDelegate;

@end
