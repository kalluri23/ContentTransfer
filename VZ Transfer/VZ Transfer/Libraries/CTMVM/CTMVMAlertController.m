//
//  MVMAlertController.m
//  alerts
//
//  Created by Scott Pfeil on 10/22/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//

#import "CTMVMAlertController.h"

@interface CTMVMAlertController ()

@property (nonatomic, readwrite, getter=isVisible) BOOL visible;

@end

@implementation CTMVMAlertController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self willChangeValueForKey:@"isVisible"];
    self.visible = YES;
    [self didChangeValueForKey:@"isVisible"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self willChangeValueForKey:@"isVisible"];
    self.visible = NO;
    [self didChangeValueForKey:@"isVisible"];
}

@end
