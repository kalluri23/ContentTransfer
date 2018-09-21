//
//  CTProgressHUD.m
//  ProgressView
//
//  Created by Mehta, Snehal Natwar on 9/15/16.
//  Copyright © 2016 Mehta, Snehal Natwar. All rights reserved.
//

#import "CTProgressHUD.h"
#import "CTMFLoadingSpinner.h"
#import "NSLayoutConstraint+CTMFConvenience.h"


CGFloat const CTPaddingOne = 6;
CGFloat const CTPaddingTwo = 12;
CGFloat const CTPaddingThree = 18;
CGFloat const CTPaddingFour = 24;
CGFloat const CTPaddingFive = 30;
/*! Height & Width of the spinner.*/
CGFloat const CTPaddingSix = 36;
CGFloat const CTPaddingSeven = 42;
CGFloat const CTPaddingEight = 48;
CGFloat const CTPaddingNine = 54;
CGFloat const CTPaddingTen = 60;
CGFloat const CTPaddingEleven = 32;

@interface CTProgressHUD ()
/*! MF style spinner parameter.*/
@property (nullable, strong, nonatomic) CTMFLoadingSpinner *activityIndicator;
/*! Background view for HUD object.*/
@property (nullable, weak, nonatomic) UIView *transparentBackgroundView;

@end

@implementation CTProgressHUD

- (instancetype)initWithView:(UIView *)viewControllerView {
    
    self = [[CTProgressHUD alloc] initWithFrame:viewControllerView.bounds];
    
    // Sets up the loading view.
    self.activityIndicator = [[CTMFLoadingSpinner alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    self.activityIndicator.backgroundColor = [UIColor clearColor];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.activityIndicator];
    
    // Sets the constraints for the activityIndicatorView
    [NSLayoutConstraint constraintPinView:self.activityIndicator heightConstraint:YES heightConstant:CTPaddingSix widthConstraint:YES widthConstant:CTPaddingSix];
    [NSLayoutConstraint constraintPinSubview:self.activityIndicator toSuperview:self pinCenterX:YES pinCenterY:YES];
    
    // Sets up the transparent background view.
    UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
    transparentBackground.translatesAutoresizingMaskIntoConstraints = NO;
    transparentBackground.backgroundColor = [UIColor clearColor];
    
    transparentBackground.backgroundColor = [UIColor colorWithRed:.965 green:.965 blue:.965 alpha:1.0];;
    transparentBackground.alpha = .45f;
    [self insertSubview:transparentBackground belowSubview:self.activityIndicator];
    self.transparentBackgroundView = transparentBackground;
    
    // Sets the constraints of the transparent background view to be the same as the activity indicator view.
    [NSLayoutConstraint constraintPinSubview:transparentBackground toSuperview:self];
    
    return self;
}

- (void)showAnimated:(BOOL)animated {
    [self.activityIndicator resumeSpinner];
}

- (void)hideAnimated:(BOOL)animated {
    [self.activityIndicator pauseSpinner];
    [self removeFromSuperview];
}

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideAnimated:animated];
    });
}

@end
