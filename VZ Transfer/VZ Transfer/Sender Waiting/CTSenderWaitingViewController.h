//
//  CTSenderWaitingViewController.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTViewController.h"

/*!Waiting page when invitaion sent but haven't received response. This page only happened on sender side.*/
@interface CTSenderWaitingViewController : CTViewController

/*!Notify the sender waiting page should pop to previous view. In case of reject response received or invitation timeout (30s).*/
- (void)senderWaitingViewShouldGoBack;
/*!Notify the sender waiting page should proceed to select what page. In case of received accept response.*/
- (void)senderWaitingViewShouldGoForward;
/*!Notify the sender waiting page should pop to root. In case of version mismatch.*/
- (void)senderWaitingViewShouldPopToRoot;
/*!Notify the sender should push to cancel. In case of receiver side has sender side setup.*/
- (void)senderShouldPushCancel;
/*!Dismiss the connecting dialog.*/
- (void)dismissConnectingDialog;

@end
