//
//  MVMViewController.h
//  VZ Transfer
//
//  Created by Hadapad, Prakash on 6/16/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVMViewController : UIViewController

typedef NS_ENUM(NSInteger, MVMNavigationBarItem) {
    MVMNavigationBarItemSearch = 0,
    MVMNavigationBarItemShoppingCart
};

- (void)backButtonPressed;

@end
