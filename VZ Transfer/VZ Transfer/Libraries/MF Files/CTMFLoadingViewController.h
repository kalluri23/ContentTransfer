//
//  CTMFLoadingViewController.h
//  myverizon
//
//  Created by Scott Pfeil on 11/20/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//
//  The view controller used during loading. Used by the loading handler.
#import <UIKit/UIKit.h>

@interface CTMFLoadingViewController : UIViewController

// Shows the loading indicator.
- (void)startLoading;

// Stops the loading.
- (void)stopLoading;

@end
