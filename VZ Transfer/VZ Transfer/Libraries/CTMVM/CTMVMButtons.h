//
//  MVMButtons.h
//  myverizon
//
//  Created by Scott Pfeil on 11/6/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//
//  Commonly used buttons.

#import <Foundation/Foundation.h>
#import "CTMVMCustomButton.h"

#if STANDALONE
static CGFloat const CT_PRIMARY_BUTTON_HEIGHT = 55.0;
#else
static CGFloat const CT_PRIMARY_BUTTON_HEIGHT = 55.0;

#endif
static CGFloat const CT_LINK_BUTTON_HEIGHT = 27.0;

@interface CTMVMButtons : NSObject

// Returns a primary red button. Can pass in the button to use, if not it will create it. Can also specify if we should constrain the height to the default.
+ (CTMVMCustomButton *)primaryRedButton:(UIButton *)button constrainHeight:(BOOL)constrainHeight;

// Returns a primary red button with right arrow. Can pass in the button to use, if not it will create it. Can also specify if we should constrain the height to the default.
+ (CTMVMCustomButton *)primaryRedButtonWithDetailArrow:(UIButton *)button constrainHeight:(BOOL)constrainHeight;

// Returns a primary grey button. Can pass in the button to use, if not it will create it. Can also specify if we should constrain the height to the default.
+ (CTMVMCustomButton *)primaryGreyButton:(UIButton *)button constrainHeight:(BOOL)constrainHeight;

// Returns a primary link button. Can pass in the button to use, if not it will create it. Can also specify if we should constrain the height to the default.
// Use CustomButton to use linkfo as dataPassed
+ (CTMVMCustomButton *)primaryLinkButon:(UIButton *)button constrainHeight:(BOOL)constrainHeight;

// Returns a secondary grey button. Can pass in the button to use, if not it will create it. Can also specify if we should constrain the height to the default.
+ (CTMVMCustomButton *)secondaryGreyButton:(UIButton *)button constrainHeight:(BOOL)constrainHeight;

// Returns a checkbox. Can pass in the button to use, if not it will create it. Can also specify if we should constrain the height and width to the default.
+ (UIButton *)checkBox:(UIButton *)button constrainHeightAndWidth:(BOOL)constrainHeightAndWidth;

// Returns a tooltip. Can pass in the button to use, if not it will create it. Can also specify if we should constrain the height and width to the default.
+ (UIButton *)toolTip:(UIButton *)button constrainHeightAndWidth:(BOOL)constrainHeightAndWidth;

// Returns a close button. Can pass in the button to use, if not it will create it. Can also specify if we should constrain the height and width to the default.
+ (UIButton *)closeButton:(UIButton *)button constrainHeightAndWidth:(BOOL)constrainHeightAndWidth;

+ (void)setSelectDeviceButton:(UIButton *)button constrainWidth:(BOOL)shouldConstrain;

// Sets up the expand or compress part at the end of the text for the link button.
+ (NSAttributedString *)getExpandedPrimaryLinkButonAttributedText:(NSString *)text;
+ (NSAttributedString *)getCompressedPrimaryLinkButonAttributedText:(NSString *)text;
+ (void)setExpandedPrimaryLinkButon:(UIButton *)button text:(NSString *)text;
+ (void)setCompressedPrimaryLinkButon:(UIButton *)button text:(NSString *)text;

@end
