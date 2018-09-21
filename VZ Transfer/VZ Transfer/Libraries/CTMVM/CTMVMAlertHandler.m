//
//  AlertHandler.m
//  myverizon
//
//  Created by Scott Pfeil on 3/10/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//

#import "CTMVMAlertHandler.h"
#import "CTMVMConstants.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertController.h"
#import "CTMVMAlertView.h"
#import "CTMVMAlertOperation.h"

@interface CTMVMAlertHandler ()

// Flag that keeps track of if the alerts are supressed or not.
@property (assign, nonatomic) BOOL mvmAlertsSupressed;

// An operation queue for displaying alerts.
@property (strong, nonatomic) NSOperationQueue *alertQueue;

@end

@implementation CTMVMAlertHandler

+ (instancetype)sharedAlertHandler {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.alertQueue = [[NSOperationQueue alloc] init];
        self.alertQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark - Displaying Functions

- (BOOL)alertCurrentlyShowing {
    return (self.alertQueue.operationCount > 0);
}

- (BOOL)greedyAlertShowing {
    return [self alertCurrentlyShowing] && ((CTMVMAlertOperation *)self.alertQueue.operations[0]).isGreedy;
}


- (id)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelAction:(CTMVMAlertAction *)cancelAction otherActions:(NSArray *)otherActions isGreedy:(BOOL)isGreedy {
   
    // Create the alert
    if ([UIAlertController class] != nil) {
        
        // New Style Alert. Adds the actions one by one.
        CTMVMAlertController *alertController = [CTMVMAlertController alertControllerWithTitle:(title ?: @"") message:message preferredStyle:UIAlertControllerStyleAlert];
        
        // Cancel is added first.
        if (cancelAction) {
            [alertController addAction:[cancelAction alertAction]];
        }
        
        for (NSUInteger i = 0; i < [otherActions count]; i++) {
            CTMVMAlertAction *action = [otherActions objectAtIndex:i ofType:[CTMVMAlertAction class]];
            if (action) {
                [alertController addAction:[action alertAction]];
            }
        }
        
        // Queues up the alert
        [self.alertQueue addOperation:[[CTMVMAlertOperation alloc] initWithAlert:alertController isGreedy:isGreedy]];
        return alertController;
    } else {
        
        // Old Style Alert. Adds the other buttons one by one.
        CTMVMAlertView *alertView = [[CTMVMAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:[cancelAction title] otherButtonTitles:nil];
        for (NSUInteger i = 0; i < [otherActions count]; i++) {
            CTMVMAlertAction *action = [otherActions objectAtIndex:i ofType:[CTMVMAlertAction class]];
            if (action.title) {
                [alertView addButtonWithTitle:action.title];
            }
        }
        
        // Stores all the actions for the delegate functions.
        NSMutableArray *totalActions = [NSMutableArray arrayWithArray:otherActions];
        if (cancelAction) {
            [totalActions addObject:cancelAction];
        }
        alertView.actions = totalActions;
        
        // Queues up the alert
        CTMVMAlertOperation *alertOperation = [[CTMVMAlertOperation alloc] initWithAlert:alertView isGreedy:isGreedy];
        alertView.delegate = alertOperation;
        [self.alertQueue addOperation:alertOperation];
        return alertView;
    }
}

- (id)showAlertWithAlertObject:(CTMVMAlertObject *)alertObject {
    return [self showAlertWithTitle:alertObject.title message:alertObject.message cancelAction:alertObject.cancelAction otherActions:alertObject.otherActions isGreedy:alertObject.isGreedy];
}

#pragma mark - Removal Functions

- (void)removeAllAlertViews {
    [self.alertQueue cancelAllOperations];
}

#pragma mark - Supression Functions

- (BOOL)mvmAlertsSupressed {
    return _mvmAlertsSupressed;
}

- (void)supressMVMAlerts {
    if (!self.mvmAlertsSupressed) {
        self.mvmAlertsSupressed = YES;
        if ([self alertCurrentlyShowing]) {
            [((CTMVMAlertOperation *)self.alertQueue.operations[0]) pause];
        }
    }
}

- (void)unSupressMVMAlerts {
    if (self.mvmAlertsSupressed) {
        self.mvmAlertsSupressed = NO;
        if ([self alertCurrentlyShowing]) {
            [((CTMVMAlertOperation *)self.alertQueue.operations[0]) unpause];
        }
    }
}

@end
