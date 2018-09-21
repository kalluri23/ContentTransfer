//
//  DismissAlertViewOperation.h
//  myverizon
//
//  Created by Scott Pfeil on 9/28/15.
//  Copyright © 2015 Verizon Wireless. All rights reserved.
//
//  Operation for dismissing an alert view controller.

#import "CTMVMOperation.h"

@interface CTMVMDismissAlertViewOperation : CTMVMOperation

- (instancetype)initWithViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
