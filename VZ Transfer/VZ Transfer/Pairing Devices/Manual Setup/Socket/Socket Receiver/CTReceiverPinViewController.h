//
//  CTReceiverPinViewController.h
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTGenericPinViewController.h"

extern NSString *const GCD_ALWAYS_READ_QUEUE;
/*!
 Pin page for receiver. This part of manual setup process. When doing QR, logic will handle for user.
 To go to this page, should click manual setup button on QR page, and pass Bonjour list, and wifi setup page.
 */
@interface CTReceiverPinViewController : CTGenericPinViewController

@property (nonatomic, weak) IBOutlet UILabel *generatedPinLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinWidth;

@end
