//
//  CTViewController.h
//  contenttransfer
//
//  Created by Development on 8/12/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTCustomButton.h"
#import "CTCustomLabel.h"
#import "CTProgressView.h"
#import "UIViewController+Convenience.h"
#import "VZCTViewController.h"

/*!
 Old base view controller. This is old structure of content transfer.
 Now all the working for this view controller moved to VZCTViewController. This view controller only contains a primary label for unknow history reason.
 @warning Should merge this view controller with VZCTViewController, since this controller is not doing anything.
 */
@interface CTViewController : VZCTViewController
/*! Primary message label for all view controllers.*/
@property (nonatomic, weak) IBOutlet CTPrimaryMessageLabel *primaryMessageLabel;
/*! Current flow for this view controller: Sender or Receiver.*/
@property (nonatomic, assign) CTTransferFlow transferFlow;

@end
