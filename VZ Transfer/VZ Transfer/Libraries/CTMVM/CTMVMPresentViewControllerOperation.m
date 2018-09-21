//
//  PresentViewControllerOperation.m
//  myverizon
//
//  Created by Scott Pfeil on 9/28/15.
//  Copyright © 2015 Verizon Wireless. All rights reserved.
//

#import "CTMVMPresentViewControllerOperation.h"

@interface CTMVMPresentViewControllerOperation ()

@property (strong, nonatomic) UIViewController *presentingViewController;
@property (strong, nonatomic) UIViewController *presentedViewController;
@property (nonatomic) BOOL animate;

@end

@implementation CTMVMPresentViewControllerOperation

- (instancetype)initWithPresentingViewController:(UIViewController *)presentingViewController presentedViewController:(UIViewController *)presentedViewController animated:(BOOL)animated {
    
    if (self = [super init]) {
        self.presentedViewController = presentedViewController;
        self.presentingViewController = presentingViewController;
        self.animate = animated;
    }
    return self;
}

- (void)main {
    
    // Always check for cancellation before launching the task.
    if ([self checkAndHandleForCancellation]) {
        return;
    }
    
    if (self.presentingViewController && self.presentedViewController) {
        
        self.presentedViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.presentingViewController.view setNeedsLayout];
        [[(UIAlertController *)self.presentedViewController view] setNeedsLayout];
        [self.presentingViewController presentViewController:self.presentedViewController animated:self.animate completion:^{
            [self markAsFinished];
        }];
    } else {
        [self markAsFinished];
    }
}

@end
