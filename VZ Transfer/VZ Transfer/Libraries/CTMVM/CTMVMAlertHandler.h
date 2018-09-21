//
//  AlertHandler.h
//  VZ Transfer
//
//  Created by Hadapad, Prakash on 5/19/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"


@interface CTMVMAlertHandler : NSObject

// Returns the shared instance of this singleton
+ (instancetype)sharedAlertHandler;


// Returns if any alert is currently showing (even if supressed).
- (BOOL)alertCurrentlyShowing;

// Returns if a greedy alert is currently showing (even if supressed).
- (BOOL)greedyAlertShowing;

/** Shows the popup with the passed in parameter. This is a convenience method that automatically handles using the proper alert type based on what's available.
 *  @param  title                   The title of the alert.
 *  @param  message                 The message of the alert.
 *  @param  cancelAction            The cancel action for the alert view. Will be displ
 *  @param  otherActions            An array of actions for the alert.
 *  @param  isGreedy                Sets up a greedy popup. In other words, any popups currently shown or queued are dismissed.
 *  @return                         Returns either a UIAlertView or UIAlertController.
 */
- (id)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelAction:(CTMVMAlertAction *)cancelAction otherActions:(NSArray *)otherActions isGreedy:(BOOL)isGreedy;

/** Shows the popup with the passed in alert object. This is a convenience method that automatically handles using the proper alert type based on what's available.
 *  @param  alertObject             The alert object to use for the alert.
 *  @return                         Returns either a UIAlertView or UIAlertController.
 */
- (id)showAlertWithAlertObject:(CTMVMAlertObject *)alertObject;

// Removes all alerts.
- (void)removeAllAlertViews;

#pragma mark - Supression Functions

// Returns true if alerts are supressed.
- (BOOL)mvmAlertsSupressed;

// Supresses the alerts (Used by mobile sso and geofencing).
- (void)supressMVMAlerts;

// Unsupresses the alerts (Used by mobile sso and geofencing).
- (void)unSupressMVMAlerts;

@end
