//
//  CTSenderProgressViewController.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/17/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTTransferInProgressViewController.h"
#import "CTSenderProgressManager.h"
#import "GCDAsyncSocket.h"
#import "CTPhotosManager.h"
#import "CTCommPortClientSocket.h"
#import "CTFileList.h"

/*!
    @brief Tranfer progress page for sender side.
    @discussion This view controller is subclass of CTTransferInProgressViewController.
    @see CTTransferInProgressViewController
 */
@interface CTSenderProgressViewController : CTTransferInProgressViewController
/*! Progress manager for sender side.*/
@property(nonatomic,strong) CTSenderProgressManager *senderProgressManager;
/*! Main socket for P2P connection.*/
@property(nonatomic,strong) GCDAsyncSocket *readSocket;
/*! Commport socket for P2P connection.*/
@property(nonatomic,strong) CTCommPortClientSocket *commSocket;
/*! Metadata file list object.*/
@property (nonatomic, strong) CTFileList *fileList;
/*! Total data size need to be transferred.*/
@property(nonatomic,assign) long long totalDataSize;
/*! Manager class used to fetch the photo file and video file list. Both data types should share same manager class.*/
@property(nonatomic,strong) CTPhotosManager *mediaManager;

@end
