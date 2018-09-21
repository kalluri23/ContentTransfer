//
//  CTWifiSetupViewController.h
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTCustomButton.h"
#import "CTViewController.h"
#import "CTCustomLabel.h"

/*!
 Wi-Fi setup view controller for manual setup.

 To reach this page, need to select manual setup button on QR code page, and pass Bonjour list page, until reach Wi-Fi page.
 */
@interface CTWifiSetupViewController : CTViewController

@property (nonatomic, weak) IBOutlet CTCommonBlackButton *nextButton;
@property (nonatomic, weak) IBOutlet CTBlackBorderedButton *searchAgainButton;
@property (nonatomic, weak) IBOutlet UILabel *ssidNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *networkNameStaticLabel;
@property (nonatomic, weak) IBOutlet CTRomanFontLabel *secondaryLabel;

@end
