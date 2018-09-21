//
//  AlertView.h
//  myverizon
//
//  Created by Scott Pfeil on 11/3/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//
//  The alert view (error and confirmation alerts that appear on page to page).

#import <UIKit/UIKit.h>

/*!Enumeration for alert type.*/
typedef NS_ENUM(NSInteger, CTAlertType) {
    /*!Type error.*/
    CTAlertTypeError,
    /*!Type success.*/
    CTAlertTypeSuccess,
    /*!Type information.*/
    CTAlertTypeInformation,
    /*!Type warning.*/
    CTAlertTypeWarning
};

/*!MVM styled base alert view. Copied from MVM project.*/
@interface CTAlertView : UIView

// Constraints
@property (weak, nonatomic) NSLayoutConstraint *leftPin;
@property (weak, nonatomic) NSLayoutConstraint *rightPin;

// Shows the alert with the passed in message and type.
- (void)showAlertMessage:(NSString *)message ofType:(CTAlertType)type animate:(BOOL)animate;

// Shows the alert view with bold title and message and type passed in as argument
- (void)showAlertMessage:(NSString *)message withBoldTitle:(NSString*)alertTitle ofType:(CTAlertType)type animate:(BOOL)animate;

// Uses the passed in attributed text for the alertview... overrides the color to match the type.
- (void)showAlertWithAttributedMessage:(NSAttributedString *)message ofType:(CTAlertType)type animate:(BOOL)animate;

// Boolean for if it is pinned or not.
- (BOOL)isShowing;

// Hides the alert by removing the top pin.
- (void)hideAlertMessage:(BOOL)animated;

// Sets the spacing between the content and the top of the view. Default is 20
- (void)setTopPinSpacing:(CGFloat)spacing;

- (void)setBottomSpacing:(CGFloat)spacing;

@end
