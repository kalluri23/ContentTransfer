//
//  VZCTProgressView.h
//  contenttransfer
//
//  Created by Sun, Xin on 7/6/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!Delegate for custom alert view.*/
@protocol AlertViewEventDelegate<NSObject>
@optional
/*!Call this method when cancel button is clicked.*/
- (void)cancelButtonDidClicked;
@end

/*!Enuerations for oritation of the alert view.*/
enum CTAlertViewOritation {
    /*!Vertical oritation.*/
    CTAlertViewOritation_VERTICAL,
    /*!Horizontal oritation.*/
    CTAlertViewOritation_HORIZONTAL
};

/*!
    @brief This this custom alert view object
    @discussion This alert will contains one main text label and one MVM style spinner. Oritation can be selected for the prompt.
                
                CTAlertViewOritation_VERTICAL Spinner will be on top of the text label. Text label height will adjust to buttom based on the height of text.
 
                CTAlertViewOritation_HORIZONTAL Spinner will be on the left hand of the text labe. Text label height will adjust to buttom based on the height of the text, but the spinner will always be vertical centered.
 */
@interface CTCustomAlertView : UIView
/*! Indicate that current dialog is showing or not*/
@property (nonatomic, assign) BOOL visible;
/*!Delegate property for alert view. Target should be claimed as @b AlertViewEventDelegate.*/
@property (weak, nonatomic) id<AlertViewEventDelegate> delegate;

/*! 
    @brief Initializer of the alert view. Need to specify the oritation of the alert view.
    @param text Text message to show on the main text label.
    @param oritation enum CTAlertViewOritation type represent the oritation of the alert.
    @return CTCustomerAlertView object.
    @see enum CTAlertViewOritation
 */
- (instancetype)initCustomAlertViewWithText:(NSString *)text withOritation:(enum CTAlertViewOritation)oritation;
/*! @brief Show the alert with animation. */
- (void)show;
/*! @brief Show the alert with animation. Callback handler is provided.*/
- (void)show:(void(^)(void))handler;
/*! 
    @brief Update the label on the alert.
    @dicussion After new text message is given, the alert will adjust the height to fit the latest message.
    @param text Text message to show on the main text message.
    @param oritation enum CTAlertViewOritation type represent the oritation of the alert.
 */
- (void)updateLbelText:(NSString *)text oritation:(enum CTAlertViewOritation)oritation;
/*! @brief hide the alert with animation. Callback handler is provided.*/
- (void)hide:(void(^)(void))handler;

/*! 
    @brief Change this view to show the finish check mark animation
    @warning This method will only called when this alert is used as the continue saving prompt.
    @param saving Bool type to indicate that the process is saving or cancel.
 */
- (void)becomeFinishView:(BOOL)saving;

@end
