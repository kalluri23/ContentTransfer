//
//  PresentViewControllerOperation.h
//  myverizon
//
//  Created by Scott Pfeil on 9/28/15.
//  Copyright © 2015 Verizon Wireless. All rights reserved.
//
//  An operation for presenting a view controller.

#import <Foundation/Foundation.h>
#import "CTMVMOperation.h"

@interface CTMVMPresentViewControllerOperation : CTMVMOperation

- (instancetype)initWithPresentingViewController:(UIViewController *)presentingViewController presentedViewController:(UIViewController *)presentedViewController animated:(BOOL)animated;

@end
