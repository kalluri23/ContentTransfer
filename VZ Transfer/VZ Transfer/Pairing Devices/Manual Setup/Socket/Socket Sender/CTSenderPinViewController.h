//
//  CTSenderPinViewController.h
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTGenericPinViewController.h"

/*!
 Pin page for sender. This part of manual setup process. When doing QR, logic will handle for user.
 To go to this page, should click manual setup button on QR page, and pass Bonjour list, and wifi setup page.
 */
@interface CTSenderPinViewController : CTGenericPinViewController

@property (nonatomic, weak) IBOutlet CTCommonBlackButton *nextButton;
@property (nonatomic, weak) IBOutlet CTBlackBorderedButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *enterPinTextField1;
@property (weak, nonatomic) IBOutlet UITextField *enterPinTextField2;
@property (weak, nonatomic) IBOutlet UITextField *enterPinTextField3;
@property (weak, nonatomic) IBOutlet UITextField *enterPinTextField4;

//Adapt constraints to iPhone 4 screen size using below properties
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *primaryLabelTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorViewTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondaryLabelTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifiHeaderVerticalAlignmentConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifiHeaderTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *codeViewTopSpaceConstraint;

@end
