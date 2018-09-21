//
//  AlertOperation.m
//  myverizon
//
//  Created by Scott Pfeil on 9/28/15.
//  Copyright © 2015 Verizon Wireless. All rights reserved.
//

#import "CTMVMAlertOperation.h"
#import "CTMVMConstants.h"
#import "CTMVMAlertHandler.h"
#import "CTMVMAlertView.h"
#import "CTMVMAlertController.h"
#import "CTMVMPresentViewControllerOperation.h"
#import "CTMVMDismissAlertViewOperation.h"
#import "AppDelegate.h"
#import "UIWindow+CTMVMConvenience.h"
//#import "LoadingViewController.h"
//#import "VZContentHomeViewController.h"

@interface CTMVMAlertOperation ()

@property (readwrite, getter=isPaused) BOOL paused;

@property (readwrite, getter=isGreedy) BOOL greedy;

// The currently displayed alert view.
// For prior to ios 8, the alert should be UIAlertView. For ios 8 and above, the alert should be MVMAlertViewController.
@property (strong, nonatomic) id currentAlertView;

// The animation queue. Ensures we never try to dismiss until animation for present is finished.
@property (strong, nonatomic) NSOperationQueue *alertAnimationQueue;

// A boolean to keep track of if we alreadys signed up to observe.
@property (assign, nonatomic) BOOL alertBeingObserved;

// Dismisses the alert.
- (void)dismissAlertView;

// Begins observing for when the alert is dismissed.
- (void)observeForCurrentAlertViewDismissal;

// Stops observing for when the alert is dismissed.
- (void)stopObservingAlertView;

@end

@implementation CTMVMAlertOperation

// The context for kvo
static void * XXContext = &XXContext;

- (void)dealloc {
    [self stopObservingAlertView];
}

- (instancetype)initWithAlert:(id)alert isGreedy:(BOOL)isGreedy {
    
    if (self = [super init]) {
        self.currentAlertView = alert;
        self.greedy = isGreedy;
        
        self.alertAnimationQueue = [[NSOperationQueue alloc] init];
        self.alertAnimationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)main {
    
    // Always check for cancellation before launching the task.
    if ([self checkAndHandleForCancellation]) {
        return;
    }
    
    // Display alert only if alerts aren't supressed.
    if (![[CTMVMAlertHandler sharedAlertHandler] mvmAlertsSupressed] && self.currentAlertView) {
        
        // Observe for when it is removed.
        [self observeForCurrentAlertViewDismissal];
        
        if ([self.currentAlertView isKindOfClass:[UIAlertController class]]) {
            
//            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedAppli cation] delegate];
            
            UIViewController *presentingViewController;
            
#if STANDALONE
             presentingViewController = [((UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewControllers lastObject];
#else 
            
            presentingViewController =  [UIApplication sharedApplication].keyWindow.rootViewController;
#endif
            
//            if (!presentingViewController && appDelegate.contentHomeViewController) {
//                presentingViewController = appDelegate.contentHomeViewController;
//            }
            

            
            while (presentingViewController.presentedViewController && ![presentingViewController.presentedViewController isKindOfClass:[CTMVMAlertController class]]) {
                presentingViewController = presentingViewController.presentedViewController;
            }
            
            [[(UIAlertController *)self.currentAlertView view] setNeedsLayout];
            // Adds the presentation to the animation queue.
            CTMVMPresentViewControllerOperation *presentOperation = [[CTMVMPresentViewControllerOperation alloc] initWithPresentingViewController:presentingViewController presentedViewController:self.currentAlertView animated:YES];
            [self.alertAnimationQueue addOperation:presentOperation];
        } else {
            
            // For pre-ios 8.
            [self.currentAlertView show];
        }
    }
}

- (void)cancel {
    [super cancel];
    [self dismissAlertView];
}

- (void)dismissAlertView {
    
    if (self.currentAlertView) {
        
        if ([self.currentAlertView isKindOfClass:[UIAlertController class]]) {
            
            // Adds the the dismiss to the queue.
            CTMVMDismissAlertViewOperation *dismissOperation = [[CTMVMDismissAlertViewOperation alloc] initWithViewController:self.currentAlertView animated:NO];
            [self.alertAnimationQueue addOperation:dismissOperation];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Dismisses the popup. Delegate functions will get triggered before it is set to nil.
                [self.currentAlertView dismissWithClickedButtonIndex:ALERT_DISMISSED_INDEX_CONSTANT animated:NO];
                [self.currentAlertView setDelegate:nil];
            });
        }
    }
}

- (void)pause {
    [self willChangeValueForKey:@"isPaused"];
    self.paused = YES;
    [self didChangeValueForKey:@"isPaused"];
    [self dismissAlertView];
}

- (void)unpause {
    [self willChangeValueForKey:@"isPaused"];
    self.paused = NO;
    [self didChangeValueForKey:@"isPaused"];
    if (self.currentAlertView) {
        [self start];
    }
}

#pragma mark - Observer Functions

- (void)observeForCurrentAlertViewDismissal {
    if (!self.alertBeingObserved && ![[CTMVMAlertHandler sharedAlertHandler] mvmAlertsSupressed] && self.currentAlertView && [self.currentAlertView isKindOfClass:[UIAlertController class]]) {
        self.alertBeingObserved = YES;
        [self.currentAlertView addObserver:self forKeyPath:@"visible" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:XXContext];
    }
}

- (void)stopObservingAlertView {
    if (self.alertBeingObserved) {
        [self.currentAlertView removeObserver:self forKeyPath:@"visible" context:XXContext];
        self.alertBeingObserved = NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == XXContext && [keyPath isEqualToString:@"visible"]) {
        if (![object isVisible]) {
            
            // Is visible was set to NO, meaning that the alertview is no longer visible.
            if (!self.isPaused) {
                [self stopObservingAlertView];
                self.currentAlertView = nil;
                [self markAsFinished];
            }
        }
    }
}

#pragma mark - UIAlertView Functions

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    CTMVMAlertView *mvmAlertView = (CTMVMAlertView *)alertView;
    for (NSUInteger i = 0; i < mvmAlertView.actions.count; i++) {
        CTMVMAlertAction *action = [mvmAlertView.actions objectAtIndex:i ofType:[CTMVMAlertAction class]];
        if ([action.title isEqualToString:buttonTitle] && action.handler) {
            action.handler(action.alertAction);
        }
    }
    
    [self markAsFinished];
}

@end
