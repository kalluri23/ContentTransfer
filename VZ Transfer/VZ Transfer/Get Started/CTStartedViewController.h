//
//  CTStartedViewController.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/1/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTViewController.h"
#import "CTCustomLabel.h"

/*! Start page of content transfer. This is the landing page for the app.*/
@interface CTStartedViewController : CTViewController

@property (nonatomic, weak) IBOutlet CTRomanFontLabel *secondaryTextLabel;
@property (weak, nonatomic) IBOutlet CTRomanFontLabel *clickableLabel;
@property (weak, nonatomic) IBOutlet CTRomanFontLabel *ppAndAboutLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondaryLabelTopMarginConstaint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clickableLabelTopMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopMarginConstraint;

@end

