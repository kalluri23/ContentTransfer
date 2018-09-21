//
//  CTSurveyOverlay.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/27/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTCustomLabel.h"

/*!
 Overlay on finish view to show survey image and clickable button.
 @note Currently vzcloud ad overlay is showing on finish view. Reserve this page for any possible future use.
 */
@interface CTSurveyOverlay : UIView

@property (weak, nonatomic) IBOutlet UIView *surveyContainer;
@property (weak, nonatomic) IBOutlet CTPrimaryMessageLabel *surveyHeader;
@property (weak, nonatomic) IBOutlet CTBoldFontLabel *surveySubText;
@property (weak, nonatomic) IBOutlet CTRomanFontLabel *surveyBody;

/*!
 Overlay view initializer.
 @return CTSurveyOverlay object contains survey background image and link.
 */
+ (instancetype)customView;

@end
