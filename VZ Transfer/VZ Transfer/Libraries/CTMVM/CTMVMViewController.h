//
//  MVMViewController.h
//  VZ Transfer
//
//  Created by Hadapad, Prakash on 6/16/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTMVMViewController : UIViewController

typedef NS_ENUM(NSInteger, CTMVMNavigationBarItem) {
    CTMVMNavigationBarItemSearch = 0,
    CTMVMNavigationBarItemShoppingCart
};

- (void)backButtonPressed;

@end
