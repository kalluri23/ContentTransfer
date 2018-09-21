//
//  MVMButtons.m
//  myverizon
//
//  Created by Scott Pfeil on 11/6/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//

#import "CTMVMButtons.h"
#import "CTMVMConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "CTMVMCustomButton.h"
#import "UIImage+Helper.h"
//#import "JSONCache.h"

@interface CTMVMButtons ()

// Creates the button if necessary and does the basic setup.
+ (CTMVMCustomButton *)setupButton:(UIButton *)button constrainHeight:(BOOL)constrainHeight;

@end

@implementation CTMVMButtons

+ (CTMVMCustomButton *)setupButton:(UIButton *)button constrainHeight:(BOOL)constrainHeight {
    CTMVMCustomButton *theButton = (CTMVMCustomButton *)button;
    if (!button) {
        theButton = [CTMVMCustomButton buttonWithType:UIButtonTypeCustom];
    }
#if STANDALONE
    theButton.layer.cornerRadius = 0;
#else 
    theButton.layer.cornerRadius = 0;
#endif
    
    // Adds the height constraint.
    if (constrainHeight) {
        [theButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[theButton(==%f)]",CT_PRIMARY_BUTTON_HEIGHT] options:0 metrics:nil views:NSDictionaryOfVariableBindings(theButton)]];
    }
    
    return theButton;
}

+ (CTMVMCustomButton *)primaryRedButton:(UIButton *)button constrainHeight:(BOOL)constrainHeight {
    CTMVMCustomButton *theButton = [self setupButton:button constrainHeight:constrainHeight];
    [theButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [theButton.titleLabel setFont:[CTMVMStyler fontForRoundedButtons]];
    theButton.backgroundColor = [CTMVMColor mvmPrimaryRedColor];
    return theButton;
}

+(CTMVMCustomButton *)primaryRedButtonWithDetailArrow:(UIButton *)button constrainHeight:(BOOL)constrainHeight {
    
    CTMVMCustomButton *theButton = [self primaryRedButton:button constrainHeight:constrainHeight];
    UIImage* arrowImage = [[UIImage getImageFromBundleWithImageName:@"arrowicon_forward"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImageView* arrowImageview = [[UIImageView alloc] initWithImage:arrowImage];
//    CGFloat leftInset = 20; //theButton.titleEdgeInsets.left;
    NSString* horizontalConstraints = @"H:[arrowImageview(20)]-20-|";
    
    //let views = ["view": view, "newView": newView]
    NSDictionary* views = @{
                            @"theButton":theButton,
                            @"arrowImageview":arrowImageview
                            };
    //[theButton addSubview:arrowImageview];
    
    [theButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraints options:NSLayoutFormatDirectionRightToLeft metrics:nil views:views]];
    [theButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[arrowImageview(20)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
    
    [theButton addConstraint:[NSLayoutConstraint constraintWithItem:arrowImageview attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:theButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

    return theButton;
}

+ (CTMVMCustomButton *)primaryGreyButton:(UIButton *)button constrainHeight:(BOOL)constrainHeight {
    CTMVMCustomButton *theButton = [self setupButton:button constrainHeight:constrainHeight];
    [theButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [theButton.titleLabel setFont:[CTMVMStyler fontForRoundedButtons]];
    theButton.backgroundColor = [CTMVMColor mvmPrimaryGreyColor];
    return theButton;
}

+ (CTMVMCustomButton *)primaryLinkButon:(UIButton *)button constrainHeight:(BOOL)constrainHeight {
    CTMVMCustomButton *theButton = (CTMVMCustomButton *)button;
    if (!button) {
        theButton = [CTMVMCustomButton buttonWithType:UIButtonTypeCustom];
    }
    
    // Adds the height constraint.
    if (constrainHeight) {
        [theButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[theButton(==%f)]",CT_LINK_BUTTON_HEIGHT] options:0 metrics:nil views:NSDictionaryOfVariableBindings(theButton)]];
    }
    
    [theButton setTitleColor:[CTMVMColor mvmPrimaryBlueColor] forState:UIControlStateNormal];
    [theButton.titleLabel setFont:[CTMVMFonts mvmBoldFontOfSize:12]];
    theButton.backgroundColor = [UIColor clearColor];
    return theButton;
}

+ (UIButton *)secondaryGreyButton:(UIButton *)button constrainHeight:(BOOL)constrainHeight {
    UIButton *theButton = [self setupButton:button constrainHeight:constrainHeight];
    [theButton setTitleColor:[CTMVMColor mvmPrimaryGreyColor] forState:UIControlStateNormal];
    [theButton.titleLabel setFont:[CTMVMStyler fontForRoundedButtons]];
    theButton.backgroundColor = [CTMVMColor mvmSecondaryGreyColor];
    return theButton;
}

+ (UIButton *)checkBox:(UIButton *)button constrainHeightAndWidth:(BOOL)constrainHeightAndWidth {
    
    UIButton *theButton = button;
    if (!button) {
        theButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    [theButton setImage:[UIImage getImageFromBundleWithImageName:CHECKMARK] forState:UIControlStateSelected];
    [theButton setImage:[UIImage getImageFromBundleWithImageName:RADIO_OFF] forState:UIControlStateNormal];
    
    // Adds the height and width constraint
    if (constrainHeightAndWidth) {
        [theButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[theButton(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(theButton)]];
        [theButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[theButton(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(theButton)]];
    }
    return theButton;
}

+ (UIButton *)toolTip:(UIButton *)button constrainHeightAndWidth:(BOOL)constrainHeightAndWidth {
    UIButton *theButton = button;
    if (!button) {
        theButton = [CTMVMCustomButton buttonWithType:UIButtonTypeCustom];
    }
    [theButton setImage:[UIImage getImageFromBundleWithImageName:@"tooltip_14px"] forState:UIControlStateNormal];
    [theButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    
    // Adds the height and width constraint
    if (constrainHeightAndWidth) {
        [theButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[theButton(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(theButton)]];
        [theButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[theButton(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(theButton)]];
    }
    return theButton;
}

+ (UIButton *)closeButton:(UIButton *)button constrainHeightAndWidth:(BOOL)constrainHeightAndWidth {
    UIButton *theButton = button;
    if (!button) {
        theButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    theButton.tintColor = [CTMVMColor mvmPrimaryGreyColor];
    [theButton setImage:[[UIImage getImageFromBundleWithImageName:@"close_30px"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    theButton.translatesAutoresizingMaskIntoConstraints = NO;
    [theButton setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 0)];
    
    // Adds the height and width constraint
    if (constrainHeightAndWidth) {
        [theButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[theButton(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(theButton)]];
        [theButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[theButton(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(theButton)]];
    }
    return theButton;
}


+ (void)setSelectDeviceButton:(UIButton *)button constrainWidth:(BOOL)shouldConstrain {
    UIButton *theButton = button;
    if (!button) {
        theButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    
//    [MVMButtons setCompressedPrimaryLinkButon:theButton text:[[JSONCache sharedCache] getStringFromStaticCache:SELECT_ANOTHER_DEVICE_KEY]];
    
    if(shouldConstrain)
    {
        [theButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[theButton(==200)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(theButton)]];
    }
}

+ (NSAttributedString *)getExpandedPrimaryLinkButonAttributedText:(NSString *)text {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    if (text.length > 0) {
        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
        imageAttachment.image = [UIImage getImageFromBundleWithImageName:DROP_UP_ARROW];
        
        [attributedString appendAttributedString:[CTMVMStyler styleGetAttributedStringForLinkButtonLabel:text]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:imageAttachment]];
    }
    return attributedString;
}

+ (NSAttributedString *)getCompressedPrimaryLinkButonAttributedText:(NSString *)text {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    if (text.length > 0) {
        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
        imageAttachment.image = [UIImage getImageFromBundleWithImageName:DROP_DOWN_ARROW];
        
        [attributedString appendAttributedString:[CTMVMStyler styleGetAttributedStringForLinkButtonLabel:text]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:imageAttachment]];
    }
    return attributedString;
}

+ (void)setExpandedPrimaryLinkButon:(UIButton *)button text:(NSString *)text {
    [button setAttributedTitle:[self getExpandedPrimaryLinkButonAttributedText:text] forState:UIControlStateNormal];
}

+ (void)setCompressedPrimaryLinkButon:(UIButton *)button text:(NSString *)text {
    [button setAttributedTitle:[self getCompressedPrimaryLinkButonAttributedText:text] forState:UIControlStateNormal];
}

@end
