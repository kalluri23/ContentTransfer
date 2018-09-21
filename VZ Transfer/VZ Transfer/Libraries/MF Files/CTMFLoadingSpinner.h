//
//  CTMFLoadingSpinner.h
//  mobilefirst
//
//  Created by Wesolowski, Brendan on 3/10/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTMFAnimatedObjectProtocol.h"
/*!
    @brief Mobile first stype circle spinner.
    @discussion Copied fome MF project.
 */
@interface CTMFLoadingSpinner : UIView <CTMFAnimatedObjectProtocol>

-(void)setUpCircle;

-(void)setUpCircle:(UIColor *)strokeColor;

-(void)changeColor:(UIColor *)strokeColor;

-(void)pauseSpinner;

-(void)resumeSpinner;

-(void)removeFromSuperviewAnimated;

@end
