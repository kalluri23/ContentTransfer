//
//  CTProgressHUD.h
//  ProgressView
//
//  Created by Mehta, Snehal Natwar on 9/15/16.
//  Copyright © 2016 Mehta, Snehal Natwar. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
    @brief MVM style spinner object.
    @discussion This class will init a spinner and attached it into specific view controller. The spinner use the same style as MVM app using.
 */
@interface CTProgressHUD : UIView

/*! 
    @brief Init a CTProgressHUD object on specified UIView.
    @param view UIView object that will attached the spinner object.
    @return CTProgressHUD object.
 */
- (instancetype)initWithView:(UIView *)view;

/*!
    @brief Show spinner dialog on target view.
    @param animated BOOL value indicate that should show dialog with animation or not.
 */
- (void)showAnimated:(BOOL)animated;
/*!
    @brief Hide spinner dialog from target view.
    @param animated BOOL value indicate that should hide dialog with animation or not.
 */
- (void)hideAnimated:(BOOL)animated;
/*!
    @brief Hide spinner dialog from target view.
    @param animated BOOL value indicate that should hide dialog with animation or not.
    @param delay Time interval value indicate the milliseconds delay before dialog getting dismissed.
 */
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;

@end
