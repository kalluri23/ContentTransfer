//
//  MVMAlertController.h
//  alerts
//
//  Created by Scott Pfeil on 10/22/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//
//  Used by our alert handler. Not for subclassing. Simply keeps track of if it's visible. Tries to parallel the UIAlertView to make it easier for the AlertHandler.

#import <UIKit/UIKit.h>

@interface CTMVMAlertController : UIAlertController

@property (nonatomic, readonly, getter=isVisible) BOOL visible;

@end
