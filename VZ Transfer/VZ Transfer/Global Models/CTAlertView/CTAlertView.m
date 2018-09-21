//
//  AlertView.m
//  myverizon
//
//  Created by Scott Pfeil on 11/3/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//

#import "CTAlertView.h"
//#import "CTMVMConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Helper.h"

@interface CTAlertView ()

@property (weak, nonatomic) UIView *contentView;
@property (weak, nonatomic) UIImageView *alertIcon;
@property (weak, nonatomic) UILabel *alertMessage;

// The pin for the top of the content to the view. Remove when we expect the view to hide.
@property (strong, nonatomic) NSLayoutConstraint *topPin;

@property (strong, nonatomic) NSLayoutConstraint *bottomPin;
// Boolean for if the alert is showing or not.
@property (nonatomic) BOOL alertIsShowing;

// Sets up the view on initialization
- (void)setupView;

@end

@implementation CTAlertView

- (instancetype)init {
    if (self = [super init]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    if (!self.contentView) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        // Sets the border width and color
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [contentView.layer setBorderWidth:1];
        [contentView.layer setBorderColor:[UIColor colorWithRed:.851 green:.851 blue:.859 alpha:1].CGColor];
        contentView.layer.cornerRadius = 5;
        [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:contentView];
        self.contentView = contentView;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [contentView addSubview:imageView];
        self.alertIcon = imageView;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.numberOfLines = 0;
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [contentView addSubview:label];
        self.alertMessage = label;
        
        // Sets the width and height of the icon
        [imageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView(20)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
        [imageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(20)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];

        // Sets up image constraints to be ten from the left edge and ten from the label. Sets the label to be ten from the right edge.
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[imageView]-10-[label]-10-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(imageView,label)]];
        
        // Pins the top and bottom of the label.
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label]-10-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        
        // Pins the top and bottom of the icon. (greater than or equal for bottom)
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[imageView]-(>=10)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
        
        // Pins the left and right of the content view. (greater than or equal for right)
        NSLayoutConstraint *leftPin = [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        [self addConstraint:leftPin];
        self.leftPin = leftPin;
        
        NSLayoutConstraint *rightPin = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        [self addConstraint:rightPin];
        self.rightPin = rightPin;
        
        // Adds the bottom pin.
        NSLayoutConstraint *bottomPin = [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView.superview attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:0];
        [self addConstraint:bottomPin];
        self.bottomPin = bottomPin;
        
        // Sets the message label to stretch horizontally first.
        [label setContentCompressionResistancePriority:([label contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisHorizontal] + 1) forAxis:UILayoutConstraintAxisVertical];

        // Creates the top pin but adds it later.
        self.topPin = [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:20];
        
    }
}

- (void)showAlertWithAttributedMessage:(NSAttributedString *)message ofType:(CTAlertType)type animate:(BOOL)animate {
    
    // Set the icon and colors.
    UIColor *textColor = nil;
    switch (type) {
        case CTAlertTypeError:
        {
            self.contentView.backgroundColor = [CTMVMColor mvmSecondaryRedColor];
            textColor = [UIColor colorWithRed:0.451 green:0 blue:.071 alpha:1];
            self.alertIcon.image = [[UIImage getImageFromBundleWithImageName:@"warning_20px"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.alertIcon.tintColor = [UIColor redColor];
        }
            break;
        case CTAlertTypeSuccess:
        {
            self.contentView.backgroundColor = [CTMVMColor mvmSecondaryTertiaryGreenColor];
            textColor = [UIColor colorWithRed:0 green:.404 blue:.016 alpha:1];
            self.alertIcon.image = [[UIImage getImageFromBundleWithImageName:CHECKMARK] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            self.alertIcon.tintColor = nil;
        }
            break;
        case CTAlertTypeInformation:
        {
            self.contentView.backgroundColor = [CTMVMColor mvmSecondaryTertiaryBlueColor];
            textColor = [UIColor colorWithRed:0 green:.224 blue:.494 alpha:1];
            self.alertIcon.image = [[UIImage getImageFromBundleWithImageName:@"infoIcon_blue_20px"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            self.alertIcon.tintColor = nil;
        }
            break;
        case CTAlertTypeWarning:
        {
            self.contentView.backgroundColor = [CTMVMColor mvmSecondaryTertiaryYellowColor];
            textColor = [UIColor colorWithRed:.522 green:.42 blue:0 alpha:1];
            self.alertIcon.image = [[UIImage getImageFromBundleWithImageName:@"infoIcon_yellow"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            self.alertIcon.tintColor = nil;
        }
            break;
        default:
            break;
    }
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:message];
    [attributedText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, message.length)];
    self.alertMessage.attributedText = attributedText;
    
    if (!self.alertIsShowing) {
        self.alertIsShowing = YES;
        
        // Pins the content to the bottom so it will show.
        [self addConstraint:self.topPin];
        
        if (animate) {
            [UIView animateWithDuration:.3 animations:^{
                [self layoutIfNeeded];
            }];
        }
    }
}

- (void)showAlertMessage:(NSString *)message ofType:(CTAlertType)type animate:(BOOL)animate {
    
    // Set the icon and colors.
    NSAttributedString *attributedText = [CTMVMStyler styleGetAttributedStringForStandardMessageLabel:message];
    [self showAlertWithAttributedMessage:attributedText ofType:type animate:animate];
}

- (void)showAlertMessage:(NSString *)message withBoldTitle:(NSString*)alertTitle ofType:(CTAlertType)type animate:(BOOL)animate
{
    // Construct the message with two different fonts for title and message
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@""];
    if ([alertTitle isKindOfClass:[NSString class]] && alertTitle.length > 0) {
        [string appendAttributedString:[CTMVMStyler styleGetAttributedStringForStandardBoldMessageLabel:alertTitle]];
    }
    
    if ([message isKindOfClass:[NSString class]] && alertTitle.length > 0) {
        
        // Adds a new line if necessary.
        if (string.length > 0) {
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
        
        [string appendAttributedString:[CTMVMStyler styleGetAttributedStringForStandardMessageLabel:message]];
    }
    
    [self showAlertWithAttributedMessage:string ofType:type animate:animate];
}

- (BOOL)isShowing {
    return self.alertIsShowing;
}

- (void)hideAlertMessage:(BOOL)animated {
    if (self.alertIsShowing) {
        self.alertIsShowing = NO;
        
        // Pins the content to the bottom so it will show.
        if ([[self constraints] containsObject:self.topPin]) {
            [self removeConstraint:self.topPin];
        }
        
        if (animated) {
            [UIView animateWithDuration:.3 animations:^{
                [self layoutIfNeeded];
            }];
        }
    }
}

- (void)setTopPinSpacing:(CGFloat)spacing {
    self.topPin.constant = spacing;
}

- (void)setBottomSpacing:(CGFloat)spacing {
    self.bottomPin.constant = spacing;
}

@end
