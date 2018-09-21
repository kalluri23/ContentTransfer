//
//  CTGetStartedViewController.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/1/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTViewController.h"
#import "CTCustomLabel.h"

@interface CTGetStartedViewController : CTViewController

@property (nonatomic, weak) IBOutlet CTRomanFontLabel *secondaryTextLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopMargin;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageBottomMargin;
@property (weak, nonatomic) IBOutlet CTRomanFontLabel *clickableLabel;
@property (weak, nonatomic) IBOutlet CTRomanFontLabel *ppAndAboutLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttomMargin2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondaryLabelTopMarginConstaint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clickableLabelTopMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopMarginConstraint;

@end
