//
//  CTReceiverReadyViewController.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/26/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTGenericTransferViewController.h"
#import "GCDAsyncSocket.h"

/*!
 Ready page for receiver side.
 This page will show after pair and sender side picking the item on select what page. At this point, connect already established.
 */
@interface CTReceiverReadyViewController : CTGenericTransferViewController
/*! Nomral socket using for receiver pairing.*/
@property (nonatomic, strong) GCDAsyncSocket *writeSocket;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewLeftMargin;

/*! This is for one-to-many process receiver side use only. Since one to many is no longer working. This one is @b deprecated.*/
@property (nonatomic, strong) NSString *serviceName;
@end
