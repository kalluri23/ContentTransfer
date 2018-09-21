//
//  UIWindow+CTMVMConvenience.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (CTMVMConvenience)

- (UIViewController *) visibleViewController;
+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc;

@end
