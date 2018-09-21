//
//  DismissAlertViewOperation.m
//  myverizon
//
//  Created by Scott Pfeil on 9/28/15.
//  Copyright © 2015 Verizon Wireless. All rights reserved.
//

#import "CTMVMDismissAlertViewOperation.h"

@interface CTMVMDismissAlertViewOperation ()
@property (strong, nonatomic) UIViewController *viewController;
@property (nonatomic) BOOL animate;
@end

@implementation CTMVMDismissAlertViewOperation

- (instancetype)initWithViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self = [super init]) {
        self.viewController = viewController;
        self.animate = animated;
    }
    return self;
}

- (void)main {
    
    // Always check for cancellation before launching the task.
    if ([self checkAndHandleForCancellation]) {
        return;
    }
    
    if (self.viewController.presentedViewController || self.viewController.presentingViewController) {
        [self.viewController dismissViewControllerAnimated:self.animate completion:^{
            [self markAsFinished];
        }];
    } else {
        [self markAsFinished];
    }
}

@end
