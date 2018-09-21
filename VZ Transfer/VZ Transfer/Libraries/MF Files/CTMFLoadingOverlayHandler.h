//
//  CTMFLoadingOverlayHandler.h
//  myverizon
//
//  Created by Scott Pfeil on 3/10/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//
//  A singleton for handling a loading screen. Ensures there is only one on the screen at any given time.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CTMFLoadingViewController;

@interface CTMFLoadingOverlayHandler : NSObject

// Returns the shared instance of this singleton
+ (nullable instancetype)sharedLoadingOverlay;

// The view controller to present on. Currently the split view controller.
@property (nullable, weak, nonatomic) UIViewController *viewControllerToPresentOn;

// Starts Loading. Every start loading call must be terminated with an end loading call.
- (void)startLoading;

// Returns if it is showing.
- (BOOL)isShowing;

// One of the loads stopped loading.
- (void)stopLoading:(BOOL)animate;

// Forces to stop loading even if other items are still loading.
- (void)forceStopLoading:(BOOL)animate;

@end
