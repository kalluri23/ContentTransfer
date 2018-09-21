//
//  CTMFLoadingViewController.m
//  myverizon
//
//  Created by Scott Pfeil on 11/20/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//

#import "CTMFLoadingViewController.h"
#import "CTMFLoadingSpinner.h"
#import "NSLayoutConstraint+CTMFConvenience.h"

CGFloat const PaddingOne = 6;
CGFloat const PaddingTwo = 12;
CGFloat const PaddingThree = 18;
CGFloat const PaddingFour = 24;
CGFloat const PaddingFive = 30;
CGFloat const PaddingSix = 36;
CGFloat const PaddingSeven = 42;
CGFloat const PaddingEight = 48;
CGFloat const PaddingNine = 54;
CGFloat const PaddingTen = 60;
CGFloat const PaddingEleven = 32;

@interface CTMFLoadingViewController ()

@property (nullable, weak, nonatomic) CTMFLoadingSpinner *activityIndicator;
@property (nullable, weak, nonatomic) UIView *transparentBackgroundView;

@end

@implementation CTMFLoadingViewController

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    self.view = view;
    
    // Sets up the loading view.
    CTMFLoadingSpinner *activityIndicatorView = [[CTMFLoadingSpinner alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    activityIndicatorView.backgroundColor = [UIColor clearColor];
    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:activityIndicatorView];
    self.activityIndicator = activityIndicatorView;
    [NSLayoutConstraint constraintPinView:activityIndicatorView heightConstraint:YES heightConstant:PaddingSix widthConstraint:YES widthConstant:PaddingSix];

    // Sets the constraints for the activityIndicatorView
    [NSLayoutConstraint constraintPinSubview:activityIndicatorView toSuperview:view pinCenterX:YES pinCenterY:YES];
    
    // Sets up the transparent background view.
    UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
    transparentBackground.translatesAutoresizingMaskIntoConstraints = NO;
    transparentBackground.backgroundColor = [UIColor clearColor];
    
    transparentBackground.backgroundColor = [UIColor colorWithRed:.965 green:.965 blue:.965 alpha:1.0];;
    transparentBackground.alpha = 0.9;
    [view insertSubview:transparentBackground belowSubview:activityIndicatorView];
    self.transparentBackgroundView = transparentBackground;
    
    // Sets the constraints of the transparent background view to be the same as the activity indicator view.
    [NSLayoutConstraint constraintPinSubview:transparentBackground toSuperview:view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - LoadingView Functions

- (void)startLoading {
    [self.activityIndicator resumeSpinner];
}

- (void)stopLoading {
    [self.activityIndicator pauseSpinner];
}

@end
