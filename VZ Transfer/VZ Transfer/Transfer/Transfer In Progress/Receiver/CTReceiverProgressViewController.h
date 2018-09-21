//
//  CTReceiverProgressViewController.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/17/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTTransferInProgressViewController.h"
#import "CTReceiverProgressManager.h"
#import "GCDAsyncSocket.h"
#import "CTReceiverProgressManager.h"

/*!Progress page for receiver side to show the detail information during receiving files from sender.*/
@interface CTReceiverProgressViewController : CTTransferInProgressViewController

/*! Receiver manager class, same manager class as Receiver Ready page.*/
@property (nonatomic, strong) CTReceiverProgressManager *manager;

@end
