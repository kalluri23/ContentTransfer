//
//  MVMAlertView.h
//  myverizon
//
//  Created by Scott Pfeil on 11/25/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//
//  Apple says that UIAlertView should not be subclassed. Do not add anything to this. This is simply for keeping track of the actions associated with the alert.

#import <UIKit/UIKit.h>

@interface CTMVMAlertView : UIAlertView

@property (strong, nonatomic) NSArray *actions;

@end
