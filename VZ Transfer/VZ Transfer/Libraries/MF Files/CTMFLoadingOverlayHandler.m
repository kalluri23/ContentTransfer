//
//  CTMFLoadingOverlayHandler.m
//  myverizon
//
//  Created by Scott Pfeil on 3/10/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//

#import "CTMFLoadingOverlayHandler.h"
#import "NSLayoutConstraint+CTMFConvenience.h"
#import "CTMFLoadingViewController.h"

@interface CTMFLoadingOverlayHandler ()

// The loading ui elements
@property (nullable, weak, nonatomic, readwrite) CTMFLoadingViewController *loadingViewController;

// A reference to the animation timer. Used to delay animation.
@property (nullable, strong, nonatomic) NSTimer *animationTimer;

// Animation Flags
@property (nonatomic) BOOL animatingIn;
@property (nonatomic) BOOL animatingOut;

// The number of start loads called.
@property (nonatomic) NSInteger loadCount;

// Creates the loading view controller
- (void)generateLoadingViewController;

// Animates in the overlay after the delay.
- (void)animateAfterDelay:(nonnull NSTimer *)timer;

// Animates in the overlay.
- (void)animateLoadingViewController;

@end

@implementation CTMFLoadingOverlayHandler

+ (instancetype)sharedLoadingOverlay {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [[self alloc] init];
                  });
    
    return sharedInstance;
}

#pragma mark - Overlay Functions

- (void)generateLoadingViewController {
    
    CTMFLoadingViewController *loadingViewController = [[CTMFLoadingViewController alloc] init];
    UIView *view = loadingViewController.view;
    view.hidden = YES;
    self.loadingViewController = loadingViewController;

    // Adds the overlay to the screen.
    self.viewControllerToPresentOn = self.viewControllerToPresentOn;
    UIView *viewToPresentOn = self.viewControllerToPresentOn.view;
    
    [self.viewControllerToPresentOn addChildViewController:loadingViewController];
    [viewToPresentOn addSubview:view];
    [loadingViewController didMoveToParentViewController:self.viewControllerToPresentOn];
    
    // Sets the constraints for autolayout
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint constraintPinSubview:view toSuperview:viewToPresentOn];
}

- (void)startLoading {
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        self.loadCount++;
        
        // Disables the UI when loading
        self.viewControllerToPresentOn.view.userInteractionEnabled = NO;
        
        // If loading view hasn't been made yet, create it.
        if (!self.loadingViewController) {
            [self generateLoadingViewController];
        }

        // If we are already waiting to animate or animating in, do nothing.
        if (!self.animationTimer && !self.animatingIn) {
            
            // Restarts the loading animation.
            [self.loadingViewController startLoading];
            
            if (self.animatingOut) {
                
                // If we are animating out, just start animating back in.
                [self animateLoadingViewController];
            } else if (self.loadingViewController.view.isHidden) {
                
                self.loadingViewController.view.hidden = NO;
                self.loadingViewController.view.alpha = 0;

                // Animate in after a small delay in case the response comes back very quickly.
                self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(animateAfterDelay:) userInfo:nil repeats:NO];
            }
        }
    });
}

- (void)animateLoadingViewController {
    
    self.animatingIn = YES;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.loadingViewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.animatingIn = NO;
    }];
}

- (void)animateAfterDelay:(nonnull NSTimer *)timer {
    
    // Only animates in if the timer hasn't been nilled out yet.
    if (self.animationTimer == timer) {
        [self animateLoadingViewController];
    }
    self.animationTimer = nil;
}

- (BOOL)isShowing {
    return !self.loadingViewController.view.hidden;
}

- (void)stopLoading:(BOOL)animate {
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (--self.loadCount <= 0) {
            [self forceStopLoading:animate];
        }
    });
}

- (void)forceStopLoading:(BOOL)animate {
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        self.loadCount = 0;
        
        // Kills the timer if it is going.
        if (self.animationTimer) {
            [self.animationTimer invalidate];
            self.animationTimer = nil;
        }
        
        if (self.loadingViewController.view && [self isShowing] && !self.animatingOut) {
            
            if (animate) {
                self.animatingOut = YES;
                
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.loadingViewController.view.alpha = 0;
                } completion:^(BOOL finished) {
                    self.animatingOut = NO;
                    
                    // May have been cancelled to animate back in.
                    if (!self.animatingIn) {
                        self.loadingViewController.view.alpha = 0;
                        self.loadingViewController.view.hidden = YES;
                        [self.loadingViewController stopLoading];
                        self.viewControllerToPresentOn.view.userInteractionEnabled = YES;
                    }
                }];
            } else {
                
                // No animation, reset state.
                self.loadingViewController.view.alpha = 0;
                self.loadingViewController.view.hidden = YES;
                [self.loadingViewController stopLoading];
                self.viewControllerToPresentOn.view.userInteractionEnabled = YES;
            }
        }
    });
}


@end
